//
//  SpeedController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class SpeedController: EditorBaseController {

    class SpeedItem {
        var items: [Float] = [0.33,0.5,1,2,3]
        var defaultIndex = 2
        var audioEffect: TUPVEditorEffect
        var videoEffect: TUPVEditorEffect
        let config = TUPConfig()
        private let index = 3000
        init(viewModel: EditorViewModel) {
            if viewModel.state == .resource {
                audioEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVEStretchEffect_AUDIO_TYPE_NAME)
                videoEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVEStretchEffect_VIDEO_TYPE_NAME)
                viewModel.clipItems[0].audioClip.effects().add(audioEffect, at: index)
                viewModel.clipItems[0].videoClip.effects().add(videoEffect, at: index)
                config.setNumber(NSNumber(value: items[defaultIndex]), forKey: TUPVEStretchEffect_CONFIG_STRETCH)
                audioEffect.setConfig(config)
                videoEffect.setConfig(config)
            } else {
                audioEffect = viewModel.clipItems[0].audioClip.effects().getEffect(index)!
                videoEffect = viewModel.clipItems[0].videoClip.effects().getEffect(index)!
                let speed = videoEffect.getConfig().getNumber(TUPVEStretchEffect_CONFIG_STRETCH).floatValue
                for (index, item) in items.reversed().enumerated() {
                    if item == speed {
                        defaultIndex = index
                    }
                }
            }
        }
        /// 线性变速
        public func speed() {
            let multiple = items.reversed()[defaultIndex]
            config.setNumber(NSNumber(value: multiple), forKey: TUPVEStretchEffect_CONFIG_STRETCH)
            audioEffect.setConfig(config)
            videoEffect.setConfig(config)
        }
    }
    var videoItem: SpeedItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = SpeedItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func editor() {
        fetchLock()
        defer {
            fetchUnlock(autoPlay: true)
        }
        videoItem.speed()
        viewModel.build()
    }
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()
}

extension SpeedController {
    func setupView() {
        titleLabel.text = "当前播放速率: \(videoItem.items[videoItem.defaultIndex])"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        let countBarView = SliderBarView(title: "播放速度", state: .native)
        countBarView.isRounded = true
        countBarView.slider.maximumValue = Float(videoItem.items.count - 1)
        countBarView.slider.minimumValue = 0
        countBarView.slider.value = Float(videoItem.defaultIndex)
        //countBarView.slider.isContinuous = false
        view.addSubview(countBarView)
        countBarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        countBarView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.titleLabel.text = "当前播放速率: \(self.videoItem.items[Int(value)])"
            self.videoItem.defaultIndex = Int(value)
        }
        
        countBarView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.editor()
        }
    }
}
