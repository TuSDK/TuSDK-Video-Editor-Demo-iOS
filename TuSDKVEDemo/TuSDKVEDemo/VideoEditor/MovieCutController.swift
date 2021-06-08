//
//  TrimViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class MovieCutController: EditorBaseController {

    class MovieCutItem {
        public var begin: Float
        public var end: Float
        private var audioEffect: TUPVEditorEffect
        private var videoEffect: TUPVEditorEffect
        private var duration: Float
        private var clipItem: VideoClipItem
        private let index: Int = 3000
        private let config = TUPConfig()
        init(viewModel: EditorViewModel) {
            self.clipItem = viewModel.clipItems[0]
            self.duration = viewModel.state == .resource ? viewModel.originalDuration : Float(clipItem.originalDuration())
            audioEffect = clipItem.audioClip.effects().getEffect(index) ?? TUPVETrimEffect.makeAudio(viewModel.ctx)
            videoEffect = clipItem.videoClip.effects().getEffect(index) ?? TUPVETrimEffect.makeVideo(viewModel.ctx)
            let trimBegin = videoEffect.getConfig().getIntNumber(TUPVETrimEffect_CONFIG_BEGIN, or: 0)
            let trimEnd = videoEffect.getConfig().getIntNumber(TUPVETrimEffect_CONFIG_END, or:Int(duration))
            begin = Float(trimBegin) / duration
            end = Float(trimEnd) / duration
        }
        func beginTime() -> Int {
            Int(begin * duration)
        }
        func endTime() -> Int {
            Int(end * duration)
        }
        func trimTime() -> Int {
            Int((end - begin) * duration)
        }
        func editor() {
            config.setNumber(NSNumber(value: beginTime()), forKey: TUPVETrimEffect_CONFIG_BEGIN)
            config.setNumber(NSNumber(value: endTime()), forKey: TUPVETrimEffect_CONFIG_END)
            audioEffect.setConfig(config)
            videoEffect.setConfig(config)
            if clipItem.audioClip.effects().getEffect(index) == nil {
                clipItem.audioClip.effects().add(audioEffect, at: index)
            }
            if clipItem.videoClip.effects().getEffect(index) == nil {
                clipItem.videoClip.effects().add(videoEffect, at: index)
            }
        }
    }
    var videoItem: MovieCutItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = MovieCutItem(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(30)
        }
        let barView = SliderBarView(title: "起止位置", state: .multi)
        barView.multiBetweenThumbs(distance: minTimeInterval * 10 / viewModel.originalDuration)
        barView.multiSlider.value = [CGFloat(videoItem.begin), CGFloat(videoItem.end)]
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        barView.multiValueChangedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.videoItem.begin = begin
            self.videoItem.end = end
            self.updateTitle()
        }
        barView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.editor()
        }
        updateTitle()
    }
    func updateTitle() {
        titleLabel.text = "当前片段开始时间\(videoItem.beginTime().formatTime()) 结束时间\(videoItem.endTime().formatTime()) \n当前输出时长:\(videoItem.trimTime().formatTime())"
    }
    func editor() {
        fetchLock()
        defer {
            viewModel.build()
            fetchUnlock(autoPlay: true)
        }
        videoItem.editor()
    }
   
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()
}
