//
//  EditorVideoController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
/// 最小时间间隔 默认1000ms
let minDurationInterval: Float = 1000
class EditorVideoController: UIViewController {

    let adapter: EditorManager
    init(adapter: EditorManager) {
        self.adapter = adapter
        super.init(nibName: nil, bundle: nil)
        player = adapter.player
        duration = adapter.duration()
    }
    /// 播放器视图
    let displayView = TUPDisplayView(frame: CGRect(x: 0,
                                                   y: CGFloat.naviHeight,
                                                   width: UIScreen.width,
                                                   height: UIScreen.width))
    /// 播放器控制视图
    let controlView = PlayerControlView(frame:
                                            CGRect(x: 0,
                                                   y: UIScreen.width - 50,
                                                   width: UIScreen.main.bounds.width,
                                                   height: 50))
    /// 用户自定义视图
    let contentView = UIView(frame: CGRect(x: 0,
                                           y: CGFloat.naviHeight + UIScreen.width,
                                           width: UIScreen.width,
                                           height: UIScreen.height - UIScreen.width - CGFloat.naviHeight))
    /// 播放器
    var player: TUPVEditorPlayer!
    /// 当前进度
    var currentTs: Int = 0
    /// 视频合成器
    var producer: TUPVEditorProducer?
    /// 视频合成临时地址
    var producerURL: URL?
    // 子类使用
    var effectIndex: Int = 300
    var config = TUPConfig()
    var duration: Int = 0
    /// 是否播放中
    var isPlaying = false {
        didSet {
            controlView.isPlaying = isPlaying
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlayer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayView.teardown()
        adapter.destroy()
    }
    deinit {
        printTu("deinit")
    }
    @available(*, unavailable, message: "Loading this viewController from a nib is unsuppored")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension EditorVideoController {
    /// 播放
    func play() {
        guard !isPlaying else { return }
        let result = player.play()
        if result {
            isPlaying = true
        }
    }
    func startPlay() {
        player.seek(to: 0)
        play()
    }
    /// 暂停
    func pause() {
        guard isPlaying else { return }
        player.pause()
        isPlaying = false
    }
    func playerLock() {
        pause()
        player.lock()
    }
    func playerUnlock() {
        player.unlock()
    }
    /// seek
    func seek(pts: Int) {
        player.seek(to: pts)
    }
    /// 预览
    func preview(pts: Int) {
        guard !isPlaying else {return}
        player.previewFrame(pts)
        controlView.progress(current: pts, duration: playerDuration())
    }
    /// 播放器时长
    private func playerDuration() -> Int {
        player.getDuration()
    }
    /// 播放结束 重置
    private func resetPlay() {
        isPlaying = false
        currentTs = 0
        preview(pts: currentTs)
    }
}
// MARK: - 控制器&播放器代理
extension EditorVideoController: PlayerControlDelegate, TUPPlayerDelegate {
    func controlView(_ controlView: PlayerControlView, isPlay: Bool) {
        isPlay ? play() : pause()
    }
    func controlView(_ controlView: PlayerControlView, valueChanged progress: Float) {
        let pts = Int(progress * Float(player.getDuration()))
        preview(pts: pts)
    }
    func onPlayerEvent(_ state: TUPPlayerState, withTimestamp ts: Int) {
        switch state {
        case .EOS:
            resetPlay()
            break
        case .PLAYING:
            controlView.progress(current: ts, duration: playerDuration())
            currentTs = ts
            break
        default:
            break
        }
    }
    @objc func enterBackFromFront() {
        pause()
    }
}
// MARK: - 保存
extension EditorVideoController: TUPProducerDelegate {
    @objc func saveAction() {
        pause()
        let alertController = UIAlertController.init(title: "保存选项", message: "请选择保存为视频或草稿", preferredStyle: .alert)
        let draftAction = UIAlertAction.init(title: "保存为草稿", style: .default) { (UIAlertAction) in
            self.saveDraft()
        }
        let videoAction = UIAlertAction.init(title: "保存为视频", style: .default) { (UIAlertAction) in
            self.saveAlbum()
        }
        alertController.addAction(draftAction)
        alertController.addAction(videoAction)
        self.present(alertController, animated: true) {
            alertController.alertTapDismiss()
        }
    }
    /// 保存相册
    private func saveAlbum() {
        self.producer = adapter.createProducer()
        let sandboxURL = TuFileManager.createURL(state: .temp, name: String.currentTimestamp + ".mov")
        producerURL = sandboxURL
        producer?.savePath = sandboxURL.absoluteString
        producer?.delegate = self
        producer?.open()
        producer?.start()
    }
    /// 视频合成回调
    func onProducerEvent(_ state: TUPProducerState, withTimestamp ts: Int) {
        if state == .DO_START || state == .WRITING {
            ProgressHUD.showProgress(Float(ts)/Float(adapter.duration()))
        } else if state == .END {
            producer?.close()
            ImagePickerManager.saveVideo(producerURL!) {[weak self] (success, message) in
                guard let `self` = self else { return }
                ProgressHUD.showProgress(success: success, message: message)
                self.destroyProducer()
                // 生成视频后steam seek到最后 需要重新seek到当前
                self.seek(pts: self.currentTs)
            }
        }
    }
    /// 销毁视频合成器
    private func destroyProducer() {
        producer?.close()
        producer = nil
        producerURL = nil
        adapter.destroyProducer()
    }
    /// 保存草稿
    private func saveDraft() {
        // 地址替换
        ResourceManager.shared.repleace(adapter: adapter, completion:{[weak self] in
            guard let `self` = self else { return }
            
            self.editorSaveDraft()
        })
    }
    private func editorSaveDraft() {
        // editor JSON
        let editorModel = adapter.getModel()
        // 草稿箱列表
        let draft = JMDraft(scene: adapter.scene)
        draft.appendSource(clipItem: adapter.clipItems)
        let result = editorModel.save(draft.url().path)
        guard result else {
            ProgressHUD.showError(message: "保存草稿失败")
            return
        }
        // 增加引用计数
        ResourceManager.shared.taggedPointer(adapter: adapter)
        // 添加草稿箱列表
        DraftsManager.shared.append(draft)
        ProgressHUD.showSuccess(message: "保存草稿成功")
    }
}
extension EditorVideoController {
    private func setupView() {
        title = adapter.scene.rawValue
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: adapter.scene == .cover ? "" : "保存", style: .done, target: self, action: #selector(saveAction))
        view.backgroundColor = .black
        displayView.setup(nil)
        view.addSubview(displayView)
        view.addSubview(contentView)
        displayView.addSubview(controlView)
        controlView.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackFromFront),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

    }
    private func setupPlayer() {
        player.open()
        player.delegate = self
        displayView.attach(player)
        preview(pts: currentTs)
    }
}
