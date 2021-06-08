//
//  EditorViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

@_exported import TuSDKPulse
@_exported import TuSDKPulseEditor


class EditorViewController: UIViewController {
    
    enum Math {
        static let displayHeight = UIScreen.width()
        static let displayY = UIScreen.width() + CGFloat.naviHeight + 50
        static let displaySpace: CGFloat = 30
        static let controlHeight: CGFloat = 50
    }
    let scene: Navigator.Scene
    var viewModel: SourceViewModel?
    var adapter: EditorAdapter
    var isDraft: Bool = false
    lazy var player = setupPlayer()
    lazy var displayView = setupDisplayView()
    lazy var controlView = setupControlView()
    var isPlaying = false
    internal var duration: Int {
        return player.getDuration()
    }
    var originalDuration: Int = 0
    var audioDuration: Int = 0
    var currentTs: Int = 0
    var playerState: TUPPlayerState = .EOS
    lazy var interactionRect: CGRect = {
        return displayView.getInteractionRect(adapter.naturalSize)
    }()
    
    // 相册进入
    init(scene: Navigator.Scene, viewModel: SourceViewModel) {
        self.scene = scene
        self.viewModel = viewModel
        adapter = EditorAdapter()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // 草稿箱进入
    init(scene: Navigator.Scene, draftPath: String) {
        self.scene = scene
        adapter = EditorAdapter(path:draftPath)
        self.isDraft = true
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        originalDuration = adapter.getDuration()
        audioDuration = adapter.getAuidoDuration()
        
        displayView.attach(player)
        player.previewFrame(0)
        controlView.updateProgress(current: 0, duration: originalDuration)
        SVProgressHUD.dismiss()
        
        // 添加后台、前台切换的通知
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackFromFront), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFrontFromBack), name: UIApplication.didBecomeActiveNotification, object: nil)
        


    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayView.teardown()
        player.close()
        adapter.destroy()
        SVProgressHUD.dismiss()
    }
    func fetchLock() {
        pause()
        player.lock()
        if self.isPlaying == true {
            self.isPlaying = false
            self.controlView.isPlaying = false
        }
    }
    func fetchUnlock(autoPlay: Bool = true) {
        player.unlock()
        if autoPlay {
            player.seek(to: 0)
            play()
        }
    }
    func fetchUnlockToSeekTime(time: Int) {
        player.unlock()
        player.seek(to: time)
        player.previewFrame(time)
        play()
    }
    func saveToVideo() {
        
        adapter.saveVideo(completed: {[weak self] in
            guard let `self` = self else { return }
            
            self.player.seek(to: self.currentTs)
            self.player.previewFrame(self.currentTs)
        })
    }
    
    func reloadVideoDuration()
    {
        self.audioDuration = adapter.getAuidoDuration()
    }
    
    @objc func saveAction() {
        
        fetchLock()
        if self.isPlaying == true {
            self.isPlaying = false
            self.controlView.isPlaying = false
        }
        
        let alertController = UIAlertController.init(title: "保存选项", message: "请选择保存为视频或草稿", preferredStyle: .alert)
        let draftAction = UIAlertAction.init(title: "保存为草稿", style: .default) { (UIAlertAction) in
            SVProgressHUD.showSuccess(withStatus: "保存成功")
            self.saveToDraft()
        }
        let videoAction = UIAlertAction.init(title: "保存为视频", style: .default) { (UIAlertAction) in
            self.saveToVideo()
        }
        alertController.addAction(draftAction)
        alertController.addAction(videoAction)
        self.present(alertController, animated: true) {
            
            self.fetchUnlock(autoPlay: false)
            self.player.seek(to: self.currentTs)
            alertController.alertTapDismiss()
        }
    }
    
    private func saveToDraft()
    {
        if self.isPlaying == true {
            self.isPlaying = false
            self.controlView.isPlaying = false
            self.player.pause()
        }
        
//        let  timeInterval: TimeInterval  = NSDate().timeIntervalSince1970
//        let  timeStamp =  Int (timeInterval)
//        let outPutFileName = "editor_draft\(timeStamp)"
//        let draftName = title
//
//        let dateformatter = DateFormatter()
//        dateformatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
//        dateformatter.string(from: Date())
//
//        print("输出地址:\(outPutFileName)")
//        print("标题:\(String(describing: draftName))")
//        print("时间:\(dateformatter.string(from: Date()))")
//
//        let items: [Navigator.Scene] = Navigator.Scene.all
//        let sceneIndex = items.firstIndex(of: scene)
//
//        let path = TuFileManager.createURL(state: .drafts, name: outPutFileName).path
//        print("路径 : \(path)")
//
//        let item = NSMutableDictionary()
//        item.setObject(outPutFileName, forKey: "fileName" as NSCopying)
//        item.setObject(dateformatter.string(from: Date()), forKey: "fileTime" as NSCopying)
//        item.setObject(draftName!, forKey: "itemTitle" as NSCopying)
//        item.setObject(sceneIndex!, forKey: "sceneIndex" as NSCopying)
//
//        if UserDefaults.standard.object(forKey: "drafts") == nil {
//            let draftList = NSMutableArray.init()
//            draftList.add(item)
//            UserDefaults.standard.setValue(draftList.copy(), forKey: "drafts")
//            UserDefaults.standard.synchronize()
//        } else {
//            let list = UserDefaults.standard.object(forKey: "drafts") as! NSArray
//            let draftList = NSMutableArray.init(array: list)
//            draftList.add(item)
//            UserDefaults.standard.setValue(draftList, forKey: "drafts")
//            UserDefaults.standard.synchronize()
//        }
        let draftModel = EditorDraftModel(scene: scene)
        DraftManager.shared.append(model: draftModel)
        adapter.saveToDraft(path: draftModel.absoluteFile)
    }
    
    @objc private func enterBackFromFront () {
        
        if self.isPlaying == true {
            self.isPlaying = false
            self.controlView.isPlaying = false
            self.player.pause()
        }
        
        adapter.cancelProducter()
    }
    
    @objc private func enterFrontFromBack () {
        
        if self.isPlaying == false {
            
            self.player.seek(to: currentTs)
            self.player.previewFrame(currentTs)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EditorViewController {
    //MARK: - View
    private func setupView() {
        title = scene.rawValue
        view.backgroundColor = .black
        view.addSubview(displayView)
        view.addSubview(controlView)
        let contentView = UIView()
        contentView.backgroundColor = .black
        view.addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: controlView.frame.maxY, width: UIScreen.width, height: view.frame.height - controlView.frame.maxY)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveAction))
    }
    
    func initView() {
        setupView()
        
        displayView.attach(player)
        player.previewFrame(0)
        controlView.updateProgress(current: 0, duration: originalDuration)
        SVProgressHUD.dismiss()
        
        // 添加后台、前台切换的通知
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackFromFront), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFrontFromBack), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupDisplayView() -> TUPDisplayView {
        let displayView = TUPDisplayView()
        displayView.frame = CGRect(x: 0, y: CGFloat.naviHeight, width: UIScreen.width(), height: Math.displayHeight)
        displayView.setup(nil)
        //VEManager.setupDisplayView(displayView)
        return displayView
    }
    private func setupControlView() -> ControlPlayerView {
        let controlView = ControlPlayerView(frame: CGRect(x: 0, y: CGFloat.naviHeight + Math.displayHeight, width: UIScreen.width(), height: Math.controlHeight))
        controlView.backgroundColor = .black
        controlView.playCompleted = {[weak self] in
            guard let `self` = self else { return }
            self.playToggle()
        }
        controlView.pauseCompleted = {[weak self] in
            self?.pause()
        }
        controlView.seekCompleted = {[weak self] time in
            guard let `self` = self else { return }

            if time != 1
            {
                print("中间时间进度条:\(time)")
                self.player.seek(to: Int(time * Float(self.duration)))
                self.player.previewFrame(Int(time * Float(self.duration)))
//                self.play()
                controlView.updateProgress(current: Int(time * Float(self.duration)), duration: self.duration)
            }
            else
            {
                print("已完成:\(time)")
                self.player.seek(to: Int(time * Float(self.duration) - 100))
                self.player.previewFrame(Int(time * Float(self.duration) - 100))
                controlView.updateProgress(current: self.duration, duration: self.duration)
            }
        }
        return controlView
    }
}

extension EditorViewController: TUPPlayerDelegate {
    // MARK: - Player
    private func setupPlayer() -> TUPVEditorPlayer {
        let player = adapter.player
        player.open()
        player.delegate = self
        return player
    }
    func onPlayerEvent(_ state: TUPPlayerState, withTimestamp ts: Int) {
        playerState = state
        switch state {
        case .EOS:
            DispatchQueue.main.async {
                self.player.seek(to: 0)
                self.currentTs = 0
                self.isPlaying = false
                self.controlView.isPlaying = false
                self.controlView.updateProgress(current: 0, duration: self.duration)
                self.player.previewFrame(0)
            }
            break
        case .PLAYING:
            controlView.updateProgress(current: ts, duration: duration)
            currentTs = ts
            break
        case .DO_SEEK:
            currentTs = ts
            break

            
        default:
            break
        }
        
        // 文字特效通知
        if scene == .text {
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorTimeChangeNotification"), object: ts)

            if state == .DO_PLAY {
                NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorDoPlayNotification"), object: ts)
            }
        }
        
        // 画中画通知
        if scene == .pip {
            NotificationCenter.default.post(name: NSNotification.Name.init("ImageEditorTimeChangeNotification"), object: ts)

            if state == .DO_PLAY {
                NotificationCenter.default.post(name: NSNotification.Name.init("ImageEditorDoPlayNotification"), object: ts)
            }
        }
        
        //print("state: \(state.rawValue) \n duration/\(player.getDuration()) \n ts: \(ts)")
        //print("当前播放时长:\(ts)")
    }
    private func playToggle() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    internal func pause() {
        DispatchQueue.main.async {
            let ret = self.player.pause()
            if ret {
                self.isPlaying = false
                self.controlView.isPlaying = false
            }
        }
    }
    internal func play() {
        DispatchQueue.main.async {
            let ret = self.player.play()
            if ret {
                self.isPlaying = true
                self.controlView.isPlaying = true
            }
        }
    }
    internal func seek(to time: Int) {
        player.seek(to: time)
    }
    
    /**
     *  请求暂停播放，如果需要的话
     *
     */
    func applyPause(){
        if isPlaying {
            pause()
        } 
    }
}



