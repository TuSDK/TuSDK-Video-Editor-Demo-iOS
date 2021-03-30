//
//  ReverseController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
class ReverseController: EditorBaseController,TUPProducerDelegate {
    class ReverseItem {
        var videoPath: String!
        //var reversePath: String!
        /// 可直接倒放 不需要转码
        var directReverse = false
        var clip: TUPVEditorClip
        lazy var reverseClip: TUPVEditorClip = {
            let clip = TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_VIDEO_REVERSE_TYPE_NAME)
            let resizeEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVECanvasResizeEffect_TYPE_NAME)
            clip.effects().add(resizeEffect, at: 1)
            return clip
        }()
        let viewModel:EditorViewModel
        let config = TUPConfig()
        let clipIndex: Int
        var isReverse = false
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            videoPath = viewModel.clipItems[0].source.path().absoluteString
            clipIndex = viewModel.clipItems[0].index
            
            let vClip = viewModel.clipItems[0].videoClip
            if viewModel.state == .draft, vClip.getType() == TUPVEFileClip_VIDEO_REVERSE_TYPE_NAME {
                clip = TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_VIDEO_TYPE_NAME)
                config.setString(videoPath, forKey: TUPVEFileClip_CONFIG_PATH)
                clip.setConfig(config)
                self.reverseClip = vClip
                isReverse = true
                directReverse = true
            } else {
                clip = viewModel.clipItems[0].videoClip
                for item in TUPMediaInspector.shared().inspect(videoPath).streams {
                    if let videoItem = item as? TUPMediaInspector_Result_VideoItem {
                        if videoItem.directReverse {
                            directReverse = true
                            break
                        }
                    }
                }
            }
        }
        func editor() {
            if isReverse {
                config.setString(videoPath, forKey: TUPVEFileClip_CONFIG_PATH)
                reverseClip.setConfig(config)
                reverseClip.activate()
                viewModel.mainVideoLayer.deleteClip(clipIndex)
                viewModel.mainVideoLayer.add(reverseClip, at: clipIndex)
            } else {
                viewModel.mainVideoLayer.deleteClip(clipIndex)
                viewModel.mainVideoLayer.add(clip, at: clipIndex)
            }
            viewModel.build()
        }
    }
    var videoItem: ReverseItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = ReverseItem(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    private let reverseButton = UIButton()
    func editor() {
        if videoItem.isReverse, !videoItem.directReverse {
            pause()
            startTranscoder()
        } else {
            fetchLock()
            defer {
                fetchUnlock(autoPlay: true)
            }
            videoItem.editor()
        }
    }
    lazy var transcoder: TUPTranscoder = {
        let item = TUPTranscoder()
        item.delegate = self
        let config = TUPProducer_OutputConfig()
        config.keyint = 0
        item.setOutputConfig(config)
        return item
    }()
    private func startTranscoder() {
        SVProgressHUD.show(withStatus: "转码中...")
        
        transcoder.savePath = TuFileManager.createURL(state: .resource, name: "reverse_" + viewModel.clipItems[0].source.filename).absoluteString
        DispatchQueue.global().async {
            self.transcoder.open(self.videoItem.videoPath)
            self.transcoder.start()
        }
    }
    func onProducerEvent(_ state: TUPProducerState, withTimestamp ts: Int) {
        if case state = TUPProducerState.END {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.videoItem.directReverse = true
                self.videoItem.videoPath = self.transcoder.savePath
                self.transcoder.close()
                self.editor()
            }
        }
        if state == .DO_START || state == .WRITING {
            DispatchQueue.main.async {
                SVProgressHUD.showProgress(Float(ts)/self.viewModel.originalDuration, status: "转码中...")
            }
        }
    }
    
}
extension ReverseController {
    func setupView() {
        reverseButton.titleLabel?.font = .systemFont(ofSize: 13)
        reverseButton.setTitle("开启倒放", for: .normal)
        reverseButton.setTitle("关闭倒放", for: .selected)
        reverseButton.isSelected = videoItem.isReverse
        reverseButton.layer.cornerRadius = 7
        reverseButton.clipsToBounds = true
        reverseButton.backgroundColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
        reverseButton.addTarget(self, action: #selector(reverseAction(_:)), for: .touchUpInside)
        contentView.addSubview(reverseButton)
        reverseButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(35)
            make.top.equalTo(30)
        }
    }
    @objc func reverseAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        videoItem.isReverse = sender.isSelected
        editor()
    }
}
