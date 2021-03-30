//
//  MovieCutEditorController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class MovieCutEditorController: EditorVideoController {

    var audioTrimEffect: TUPVEditorEffect!
    var videoTrimEffect: TUPVEditorEffect!
    var model = Math()
    class Math {
        var begin: Float = 0
        var end: Float = 1
        var duration: Int = 0
        var beginDuration: Int {
            return Int(begin * Float(duration))
        }
        var endDuration: Int {
            return Int(end * Float(duration))
        }
        var trimDuration: Int {
            return Int((end - begin) * Float(duration))
        }
    }
    // 初始化配置
    override init(adapter: EditorManager) {
        super.init(adapter: adapter)
        audioTrimEffect = adapter.beginClipItem.audioEffect(effectIndex) ?? TUPVETrimEffect.makeAudio(adapter.ctx)
        videoTrimEffect = adapter.beginClipItem.videoEffect(effectIndex) ?? TUPVETrimEffect.makeVideo(adapter.ctx)
        // math
        model.duration = duration
        if adapter.state == .draft {
            model.duration = adapter.beginClipItem.sourceDuration()
            let beginDuration = videoTrimEffect.getConfig().getIntNumber(TUPVETrimEffect_CONFIG_BEGIN, or: 0)
            let endDuration = videoTrimEffect.getConfig().getIntNumber(TUPVETrimEffect_CONFIG_END, or: model.duration)
            model.begin = Float(beginDuration)/Float(model.duration)
            model.end = Float(endDuration)/Float(model.duration)
        }
        
    }
    private let titleLabel = UILabel()
    private let barView = SliderBarView(title: "起止位置", state: .multi)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateView()
    }
    func updateView() {
        barView.multiSlider.value = [CGFloat(model.begin), CGFloat(model.end)]
        barView.multiBetweenThumbs(distance: minDurationInterval/Float(model.duration))
        updateTitle()
    }
    func updateTitle() {
        titleLabel.text = "当前片段开始时间\(model.beginDuration.formatTime()) 结束时间\(model.endDuration.formatTime()) \n当前输出时长:\(model.trimDuration.formatTime())"
    }
    func editor() {
        playerLock()
        defer {
            playerUnlock()
            startPlay()
        }
        printTu("cut duration:\(model.duration) begin:\(model.begin) end:\(model.end)")
        config.setIntNumber(model.beginDuration, forKey: TUPVETrimEffect_CONFIG_BEGIN)
        config.setIntNumber(model.endDuration, forKey: TUPVETrimEffect_CONFIG_END)
        audioTrimEffect.setConfig(config)
        videoTrimEffect.setConfig(config)
        adapter.beginClipItem.addAudioEffect(audioTrimEffect, at: effectIndex)
        adapter.beginClipItem.addVideoEffect(videoTrimEffect, at: effectIndex)
        adapter.build()
    }
}
extension MovieCutEditorController {
    func setupView() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(30)
        }
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        barView.multiValueChangedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.model.begin = begin
            self.model.end = end
            self.updateTitle()
        }
        barView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.editor()
        }
    }
}
