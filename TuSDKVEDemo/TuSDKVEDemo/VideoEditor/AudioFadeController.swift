//
//  AudioFadeController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/9.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class AudioFadeController: EditorBaseController {
/*
    class FadeItem {
        public var begin: Float = 0.1
        public var end: Float = 0.9
        public var duration: Float
        public let musicName = "city_sunshine"
        public var mainVolume: Float = 1
        public var musicVolume: Float = 1
        private let viewModel: EditorViewModel
        private let effectIndex = 4000
        private let layerIndex = 1010
        private var audioClip:TUPVEditorClip!
        var effect: TUPVEditorEffect!
        let mixBuilder = TUPVEditorLayer_MixPropertyBuilder()
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            self.duration = viewModel.originalDuration
            
            if viewModel.state == .resource {
                self.effect = TUPVEditorEffect.init(viewModel.ctx, withType: TUPVEFadeEffect_AUDIO_TYPE_NAME)
                audioClip = TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
                let audioConfig = audioClip.getConfig()
                let path = Bundle.main.url(forResource: musicName, withExtension: "mp3")?.absoluteString ?? ""
                audioConfig.setString(path, forKey: TUPVEFileClip_CONFIG_PATH)
                audioClip.setConfig(audioConfig)
                let musicAudioLayer = TUPVEditorClipLayer(forAudio: viewModel.ctx)
                musicAudioLayer.add(audioClip, at: 30)
                viewModel.editor.audioComposition().add(musicAudioLayer, at: layerIndex)
                let config = TUPConfig()
                config.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
                config.setNumber(NSNumber(value: viewModel.originalDuration), forKey: TUPVETrimEffect_CONFIG_END)
                let effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETrimEffect_AUDIO_TYPE_NAME)
                effect.setConfig(config)
                audioClip.effects().add(effect, at: 3000)
            } else {
                if let musicAudioLayer = viewModel.editor.audioComposition().getLayer(layerIndex) as? TUPVEditorClipLayer, let clip = musicAudioLayer.getClip(30) {
                    audioClip = clip
                    effect = audioClip.effects().getEffect(effectIndex)
                    let fadeIn = effect.getConfig().getIntNumber(TUPVEFadeEffect_CONFIG_FADEIN_DURATION, or: 0)
                    begin = Float(fadeIn)/duration
                    let fadeOut = Float(effect.getConfig().getIntNumber(TUPVEFadeEffect_CONFIG_FADEOUT_DURATION, or: 0))
                    end = (duration - fadeOut)/duration
                    
                    if let pro = musicAudioLayer.getProperty(TUPVEditorLayer_PROP_MIX) {
                        let holder = TUPVEditorLayer_MixPropertyHolder(property: pro)
                        musicVolume = holder.weight
                    }
                }
                
                if let pro = viewModel.mainAudioLayer.getProperty(TUPVEditorLayer_PROP_MIX) {
                    let holder = TUPVEditorLayer_MixPropertyHolder(property: pro)
                    mainVolume = holder.weight
                }
            }
        }
        func beginTime() -> Int {
            Int(begin * duration)
        }
        func endTime() -> Int {
            Int(end * duration)
        }
        func editor() {
            let config = effect.getConfig()
            config.setNumber(NSNumber(value: beginTime()), forKey: TUPVEFadeEffect_CONFIG_FADEIN_DURATION)
            config.setNumber(NSNumber(value: Int((1-end)*duration)), forKey: TUPVEFadeEffect_CONFIG_FADEOUT_DURATION)
            effect.setConfig(config)
            if audioClip.effects().getEffect(effectIndex) == nil {
                audioClip.effects().add(effect, at: effectIndex)
            }
            viewModel.build()
        }
        func editorVolume(isMain: Bool) {
            if isMain {
                mixBuilder.holder.weight = mainVolume
                viewModel.mainAudioLayer.setProperty(mixBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
            } else {
                let layer = viewModel.editor.audioComposition().getLayer(layerIndex)
                mixBuilder.holder.weight = musicVolume
                layer?.setProperty(mixBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
            }
            
        }
    }
    private let descLabel = UILabel()
    var videoItem: FadeItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = FadeItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if viewModel.state == .resource {
            editor(autoPlay: false)
            previewFrame()
        }
        
    }
    func editor(autoPlay: Bool = true) {
        fetchLock()
        defer {
            viewModel.build()
            fetchUnlock(autoPlay: autoPlay)
        }
        videoItem.editor()
    }
 */
}
/*
extension AudioFadeController {
    func setupView() {
        let titleLabel = UILabel()
        titleLabel.text = "背景音乐\n音乐名称：\(videoItem.musicName).mp3\n"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(15)
            make.right.equalToSuperview()
            make.height.equalTo(35)
        }
        let barView = SliderBarView(title: "淡入淡出", state: .multi)
        barView.multiSlider.value = [CGFloat(videoItem.begin), CGFloat(videoItem.end)]
        barView.multiBetweenThumbs(distance: minTimeInterval*10/viewModel.originalDuration)
        contentView.addSubview(barView)
        barView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
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
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.textColor = .white
        descLabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(barView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        updateTitle()
        
        let volumeView = SliderBarView(title: "主音量", state: .native)
        volumeView.startValue = videoItem.mainVolume
        contentView.addSubview(volumeView)
        volumeView.snp.makeConstraints { (make) in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        /**主音轨音量调节回调*/
        volumeView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.mainVolume = value
            self.videoItem.editorVolume(isMain: true)
        }
        
        let audioVolumeView = SliderBarView(title: "音乐音量", state: .native)
        audioVolumeView.startValue = videoItem.musicVolume
        contentView.addSubview(audioVolumeView)
        audioVolumeView.snp.makeConstraints { (make) in
            
            make.top.equalTo(volumeView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        audioVolumeView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.musicVolume = value
            self.videoItem.editorVolume(isMain: false)
        }
    }
    func updateTitle() {
        descLabel.text = "淡入开始: 00:00 结束: \(videoItem.beginTime().formatTime()) \n淡出开始: \(videoItem.endTime().formatTime()) 结束: \(Int(videoItem.duration).formatTime())"
    }
}
 */

