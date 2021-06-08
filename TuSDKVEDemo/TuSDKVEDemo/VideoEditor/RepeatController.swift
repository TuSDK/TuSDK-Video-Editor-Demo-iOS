//
//  RepeatController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class RepeatController: EditorBaseController {

    class RepeatItem {
        var begin: Float = 0
        var end: Float = 0
        var multiple: Float = 1
        let viewModel:EditorViewModel
        var config = TUPConfig()
        let index = 3000
        lazy var audioEffect: TUPVEditorEffect = {
            return TUPVEditorEffect(viewModel.ctx, withType: TUPVERepeatEffect_AUDIO_TYPE_NAME)
        }()
        lazy var videoEffect: TUPVEditorEffect = {
            return TUPVEditorEffect(viewModel.ctx, withType: TUPVERepeatEffect_VIDEO_TYPE_NAME)
        }()
        // 素材时长
        var duration: Float = 0
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .resource {
                duration = Float(viewModel.clipItems[0].duration())
                config.setNumber(NSNumber(value: 0), forKey: TUPVERepeatEffect_CONFIG_BEGIN)
                config.setNumber(NSNumber(value: duration), forKey: TUPVERepeatEffect_CONFIG_END)
                config.setNumber(NSNumber(value: multiple), forKey: TUPVERepeatEffect_CONFIG_REPEAT_COUNT)
                
                audioEffect.setConfig(config)
                videoEffect.setConfig(config)
                viewModel.clipItems[0].audioClip.effects().add(audioEffect, at: index)
                viewModel.clipItems[0].videoClip.effects().add(videoEffect, at: index)
                viewModel.build()
            } else {
                audioEffect = viewModel.clipItems[0].audioClip.effects().getEffect(index)!
                videoEffect = viewModel.clipItems[0].videoClip.effects().getEffect(index)!
                
                config = videoEffect.getConfig()
                duration = Float(viewModel.clipItems[0].originalDuration())
                multiple = Float(config.getIntNumber(TUPVERepeatEffect_CONFIG_REPEAT_COUNT, or: 1))
                begin = Float(config.getIntNumber(TUPVERepeatEffect_CONFIG_BEGIN, or: 0)) / Float(duration)
                end = Float((config.getIntNumber(TUPVERepeatEffect_CONFIG_END, or: Int(duration)))) / Float(duration)
            }
        }
        func editor() {
            config.setNumber(NSNumber(value: Int(duration * begin)), forKey: TUPVERepeatEffect_CONFIG_BEGIN)
            config.setNumber(NSNumber(value: Int(duration * end)), forKey: TUPVERepeatEffect_CONFIG_END)
            config.setNumber(NSNumber(value: multiple), forKey: TUPVERepeatEffect_CONFIG_REPEAT_COUNT)
            audioEffect.setConfig(config)
            videoEffect.setConfig(config)
            viewModel.build()
        }
    }
    var videoItem: RepeatItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = RepeatItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        printLog(videoItem.duration)
        setupView()
    }
    private func editor() {
        if self.videoItem.begin >= self.videoItem.end {
            return
        }
        fetchLock()
        defer {
            fetchUnlockToSeekTime(Int(videoItem.duration * videoItem.begin), autoPlay: true)
        }
        videoItem.editor()
    }
    private let msgLabel = UILabel()
}
extension RepeatController {
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
        
        let barView = SliderBarView(title: "重复区间", state: .multi)
        contentView.addSubview(barView)
        barView.multiBetweenThumbs(distance: minTimeInterval/videoItem.duration)
        barView.multiSlider.value = [CGFloat(videoItem.begin),CGFloat(videoItem.end)]
        barView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(msgLabel.snp.bottom).offset(30)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        let countBarView = SliderBarView(title: "区间重复次数（0 ~ 3）", state: .native)
        countBarView.isRounded = true
        countBarView.slider.maximumValue = 4
        countBarView.slider.minimumValue = 1
        countBarView.slider.isContinuous = false
        countBarView.slider.value = videoItem.multiple
        contentView.addSubview(countBarView)
        countBarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(50)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        
        barView.multiDragEndedCompleted = {[weak self] begin,end in
            guard let `self` = self else { return }
            self.videoItem.begin = begin
            self.videoItem.end = end
            self.updateText()
            self.editor()
        }
        countBarView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.multiple = value
            self.updateText()
            self.editor()
        }
    }
    func updateText() {
        let startText = Int(videoItem.duration * videoItem.begin).formatTime()
        let endText = Int(videoItem.duration * videoItem.end).formatTime()
        msgLabel.text = "当前重复区间 开始时间: \(startText) 结束时间: \(endText)\n重复次数:\(Int(videoItem.multiple - 1))"
    }
}
