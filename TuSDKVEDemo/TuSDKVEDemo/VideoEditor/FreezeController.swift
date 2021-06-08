//
//  FreezeController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/12.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class FreezeController: EditorBaseController {

    class FreezeItem {
        var begin: Float = 0
        var freezeDuration: Float = 1
        let viewModel:EditorViewModel
        var config = TUPConfig()
        let index = 10000
        lazy var audioEffect: TUPVEditorEffect = {
            return TUPVEFreezeEffect(audio: viewModel.ctx)
        }()
        lazy var videoEffect: TUPVEditorEffect = {
            return TUPVEFreezeEffect(video: viewModel.ctx)
        }()
        // 素材时长
        var duration: Float = 0
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .resource {
                duration = viewModel.originalDuration
            } else {
                audioEffect = viewModel.clipItems[0].audioClip.effects().getEffect(index)!
                videoEffect = viewModel.clipItems[0].videoClip.effects().getEffect(index)!
                config = videoEffect.getConfig()
                duration = Float(viewModel.clipItems[0].originalDuration())
                freezeDuration = Float(config.getIntNumber(TUPVEFreezeEffect_CONFIG_FREEZE_DURATION, or: 1000))/1000
                begin = Float(config.getIntNumber(TUPVEFreezeEffect_CONFIG_FREEZE_POS, or: 0)) / Float(duration)
            }
        }
        func editor() {
            config.setNumber(NSNumber(value: Int(duration * begin)), forKey: TUPVEFreezeEffect_CONFIG_FREEZE_POS)
            config.setNumber(NSNumber(value: freezeDuration * 1000), forKey: TUPVEFreezeEffect_CONFIG_FREEZE_DURATION)
            audioEffect.setConfig(config)
            videoEffect.setConfig(config)
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].videoClip.effects().add(videoEffect, at: index)
            }
            if viewModel.clipItems[0].audioClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].audioClip.effects().add(audioEffect, at: index)
            }
            viewModel.build()
        }
    }
    var videoItem: FreezeItem!
    private let msgLabel = UILabel()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = FreezeItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        printLog(videoItem.duration)
        setupView()
    }
    private func editor() {
        
        fetchLock()
        defer {
            fetchUnlockToSeekTime(Int(videoItem.duration * videoItem.begin), autoPlay: true)
        }
        videoItem.editor()
    }
    
}
extension FreezeController {
    func setupView() {
        updateText()
        msgLabel.textColor = .white
        msgLabel.font = .systemFont(ofSize: 13)
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0
        contentView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(15)
            make.width.equalTo(UIScreen.width())
        }
        
        let barView = SliderBarView(title: "定格位置", state: .native)
        barView.startValue = videoItem.begin
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(msgLabel.snp.bottom).offset(30)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        let countBarView = SliderBarView(title: "定格持续时间（1 ~ 10）", state: .native)
        countBarView.isRounded = true
        countBarView.slider.maximumValue = 10
        countBarView.slider.minimumValue = 1
        countBarView.slider.isContinuous = false
        countBarView.slider.value = videoItem.freezeDuration
        contentView.addSubview(countBarView)
        countBarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(50)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        
        barView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.begin = value
            self.updateText()
            self.editor()
        }
        countBarView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.freezeDuration = value
            self.updateText()
            self.editor()
        }
    }
    func updateText() {
        let startText = Int(videoItem.duration * videoItem.begin).formatTime()
        msgLabel.text = "定格位置: \(startText) 定格持续时间: \(Int(videoItem.freezeDuration))s"
    }
}
