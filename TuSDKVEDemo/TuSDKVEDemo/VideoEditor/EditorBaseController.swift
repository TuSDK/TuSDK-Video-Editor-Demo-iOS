//
//  EditorBaseController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/10.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
class EditorBaseController: UIViewController {

    let viewModel: EditorViewModel
    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    /// 播放器视图
    let displayView = TUPDisplayView(frame: CGRect(x: 0,
                                                   y: CGFloat.naviHeight,
                                                   width: UIScreen.width,
                                                   height: UIScreen.width))
    /// 播放器控制视图
    let controlView = ControlPlayerView(frame:
                                            CGRect(x: 0,
                                                   y: CGFloat.naviHeight + UIScreen.width,
                                                   width: UIScreen.main.bounds.width,
                                                   height: 50))
    /// 用户自定义视图
    let contentView = UIView(frame: CGRect(x: 0,
                                           y: CGFloat.naviHeight + UIScreen.width + 50,
                                           width: UIScreen.width,
                                           height: UIScreen.height - UIScreen.width - CGFloat.naviHeight - 50))
    /// 播放器
    lazy var player: TUPVEditorPlayer = {
        let item = viewModel.editor.newPlayer() as! TUPVEditorPlayer
        return item
    }()
    var currentTs: Int = 0
    var playerDuration: Float {
        return Float(player.getDuration())
    }
    var isPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.controlView.isPlaying = self.isPlaying
            }
        }
    }
    var isPlayEnd = false
    /// 视频交互尺寸
    lazy var interactionRect: CGRect = {
        return displayView.getInteractionRect(viewModel.videoNaturalSize)
    }()
    internal let effectIndex: Int = 3000
   
    private var isSaveToDraft = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlayer()
        // 添加后台、前台切换的通知
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackFromFront), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveAlbumSuccessAction), name: .init("saveAlbumSuccess"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayView.teardown()
        player.close()
        viewModel.destroy()
    }
    func clearSandbox() {
        guard !isSaveToDraft else { return }
        DraftManager.shared.clearSandboxVideo(viewModel: viewModel)
    }
    deinit {
        clearSandbox()
        printLog("")
    }
    @available(*, unavailable, message: "Loading this viewController from a nib is unsuppored")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View
extension EditorBaseController {
    private func setupView() {
        view.backgroundColor = .black
        title = viewModel.scene.rawValue
        SVProgressHUD.dismiss()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if viewModel.scene != .cover {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveAction))
        }
        displayView.setup(nil)
        view.addSubview(displayView)
        view.addSubview(controlView)
        view.addSubview(contentView)
        controlView.playCompleted = { [weak self] in
            guard let `self` = self else { return }
            self.playToggle()
        }
        controlView.pauseCompleted = { [weak self] in
            guard let `self` = self, self.isPlaying else { return }
            self.pause()
        }
        controlView.valueChangedCompleted = {[weak self] progress in
            guard let `self` = self else { return }
            let ts = Int(progress * self.playerDuration)
            self.controlView.durationLabel.text = "\(ts.formatTime())/\(Int(self.playerDuration).formatTime())"
            self.player.previewFrame(Int(progress * self.playerDuration))
        }
        controlView.seekCompleted = {[weak self] progress in
            guard let `self` = self else { return }
            if progress >= 1 {
                self.seek(Int(self.playerDuration - minTimeInterval))
            } else {
                self.seek(Int(progress * self.playerDuration))
            }
        }
    }
}
// MARK: - Player
extension EditorBaseController: TUPPlayerDelegate {
    func setupPlayer() {
        player.open()
        player.delegate = self
        // must build success
        assert(viewModel.isBuilt)
        displayView.attach(player)
        player.previewFrame(0)
        controlView.progress(current: 0, duration: playerDuration)
    }
    func onPlayerEvent(_ state: TUPPlayerState, withTimestamp ts: Int) {
        
        isPlayEnd = false
        switch state {
        case .EOS:
            isPlaying = false
            seek(0)
            currentTs = 0
            isPlayEnd = true
            break
        case .PLAYING:
            controlView.progress(current: ts, duration: playerDuration)
            currentTs = ts
            break
        case .DO_SEEK:
            currentTs = ts
            break
        default:
            break
        }
        // 文字特效通知
        if viewModel.scene == .text || viewModel.scene == .image {
            NotificationCenter.default.post(name: NSNotification.Name.init("EditorTimeChangeNotification"), object: ts)
            if state == .DO_PLAY {
                NotificationCenter.default.post(name: NSNotification.Name.init("EditorDoPlayNotification"), object: ts)
            }
        }
    }
    internal func seek(_ pts: Int) {
        var pts = pts
        if Int(playerDuration) - pts < 200 {
            pts = Int(playerDuration) - 200
        }
        player.previewFrame(pts)
        player.seek(to: pts)
        controlView.progress(current: pts, duration: playerDuration)
    }
    
    internal func pause() {
        DispatchQueue.main.async {
            self.player.pause()
            self.isPlaying = false
        }
    }
    internal func play() {
        DispatchQueue.main.async {
            self.isPlaying = self.player.play()
        }
    }
    internal func fetchLock() {
        pause()
        player.lock()
    }
    internal func fetchUnlock(autoPlay: Bool = false) {
        player.unlock()
        guard autoPlay else { return }
        player.seek(to: 0)
        play()
    }
    internal func fetchUnlockToSeekTime(_ pts: Int, autoPlay: Bool = false) {
        player.unlock()
        seek(pts)
        guard autoPlay else { return }
        play()
    }
    func fetchUnlockOriginal() {
        if self.isPlaying {
            fetchUnlockToSeekTime(currentTs, autoPlay: true)
        } else {
            fetchUnlock()
            player.previewFrame(currentTs)
        }
    }
    private func playToggle() {
        isPlaying ? pause() : play()
    }
    @objc private func enterBackFromFront() {
        pause()
        viewModel.resetProducer()
    }
    
}
extension EditorBaseController {
    @objc func saveAction() {
        pause()
        let alertController = UIAlertController.init(title: "保存选项", message: "请选择保存为视频或草稿", preferredStyle: .alert)
        let draftAction = UIAlertAction.init(title: "保存为草稿", style: .default) { (UIAlertAction) in
            self.isSaveToDraft = DraftManager.shared.save(viewModel: self.viewModel)
            SVProgressHUD.showSuccess(self.isSaveToDraft, texts: ["保存草稿成功","保存草稿失败"])
        }
        let videoAction = UIAlertAction.init(title: "保存为视频", style: .default) { (UIAlertAction) in
            self.viewModel.saveToAlbum()
            //self.seek(self.currentTs)
        }
        alertController.addAction(draftAction)
        alertController.addAction(videoAction)
        self.present(alertController, animated: true) {
            alertController.alertTapDismiss()
        }
    }
    @objc func saveAlbumSuccessAction() {
        seek(currentTs)
    }
}
 
