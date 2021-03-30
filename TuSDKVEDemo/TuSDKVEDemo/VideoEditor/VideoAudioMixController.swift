//
//  VideoAudioMixController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class VideoAudioMixController: EditorBaseController {

    class MixItem {
        public var mixBegin: Float = 0
        public var mixEnd: Float = 1
        public var mixStart: Float = 0
        public var volume: Float = 1
        public var mixVolume: Float = 1
        public let audioLayer: TUPVEditorClipLayer
        public let audioLayerIndex = 1001
        public let duration: Float
        public let clipDuration: Float
        let layerConfig = TUPConfig()
        let audioClip: TUPVEditorClip
        let audioClipIndex = 1
        let clipConfig = TUPConfig()
        var trimEffectConfig = TUPConfig()
        let trimEffect: TUPVEditorEffect
        let trimEffectIndex = 3000
        var mainLayerBuilder: TUPVEditorLayer_MixPropertyBuilder
        var mixLayerBuilder: TUPVEditorLayer_MixPropertyBuilder
        init(viewModel: EditorViewModel) {
            self.duration = Float(viewModel.editor.videoComposition().getStreamInfo()?.duration ?? Int64(viewModel.getDuration()))
            mainLayerBuilder = TUPVEditorLayer_MixPropertyBuilder()
            mixLayerBuilder = TUPVEditorLayer_MixPropertyBuilder()
            if viewModel.state == .draft {
                audioLayer = viewModel.editor.audioComposition().getLayer(audioLayerIndex) as! TUPVEditorClipLayer
                audioClip = audioLayer.getClip(audioClipIndex)!
                trimEffect = audioClip.effects().getEffect(trimEffectIndex)!
                let mixClipPath = audioClip.getConfig().getString(TUPVEFileClip_CONFIG_PATH)
                clipDuration = Float(TUPMediaInspector.shared().inspect(mixClipPath).streams[0].duration)
                trimEffectConfig = trimEffect.getConfig()
                if let pro = viewModel.mainAudioLayer.getProperty(TUPVEditorLayer_PROP_MIX){
                    let holder = TUPVEditorLayer_MixPropertyHolder(property: pro)
                    volume = holder.weight
                }
                if let pro = audioLayer.getProperty(TUPVEditorLayer_PROP_MIX){
                    let holder = TUPVEditorLayer_MixPropertyHolder(property: pro)
                    mixVolume = holder.weight
                }

                mixStart = Float(audioLayer.getConfig().getDoubleNumber(TUPVEditorLayer_CONFIG_START_POS, or: 0)) / Float(duration)
                
                mixBegin = Float(trimEffectConfig.getIntNumber(TUPVETrimEffect_CONFIG_BEGIN)) / Float(clipDuration)
                mixEnd = Float(trimEffectConfig.getIntNumber(TUPVETrimEffect_CONFIG_END)) / Float(clipDuration)
            } else {
                audioLayer = TUPVEditorClipLayer(forAudio: viewModel.ctx)
                layerConfig.setNumber(NSNumber(value: 1), forKey: TUPVEditorLayer_PROP_MIX)
                audioLayer.setConfig(layerConfig)
                
                audioClip = TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
                let path = Bundle.main.url(forResource: "city_sunshine", withExtension: "mp3")?.absoluteString ?? ""
                clipConfig.setString(path, forKey: TUPVEFileClip_CONFIG_PATH)
                audioClip.setConfig(clipConfig)
                let ret = audioClip.activate()
                printResult("activate mix audio clip", result: ret)
                clipDuration = Float(audioClip.getStreamInfo()?.duration ?? 180000)
                trimEffectConfig.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
                trimEffectConfig.setNumber(NSNumber(value: clipDuration), forKey: TUPVETrimEffect_CONFIG_END)
                trimEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETrimEffect_AUDIO_TYPE_NAME)
                trimEffect.setConfig(trimEffectConfig)
                audioClip.effects().add(trimEffect, at: trimEffectIndex)
                audioLayer.add(audioClip, at: audioClipIndex)
                viewModel.editor.audioComposition().add(audioLayer, at: audioLayerIndex)
            }
        }
        // 音视频合成
        func mediaEditor() {
            layerConfig.setNumber(NSNumber(value: Int(duration * mixStart)), forKey: TUPVEditorLayer_CONFIG_START_POS)
            audioLayer.setConfig(layerConfig)
            trimEffectConfig.setNumber(NSNumber(value: Int(clipDuration * mixBegin)), forKey: TUPVETrimEffect_CONFIG_BEGIN)
            trimEffectConfig.setNumber(NSNumber(value: Int(clipDuration * mixEnd)), forKey: TUPVETrimEffect_CONFIG_END)
            trimEffect.setConfig(trimEffectConfig)
        }
    }
    
    var videoItem: MixItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = MixItem(viewModel: viewModel)
        
        let effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETrimEffect_AUDIO_TYPE_NAME)
        let effectConfig = TUPConfig()
        effectConfig.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
        effectConfig.setNumber(NSNumber(value: videoItem.duration), forKey: TUPVETrimEffect_CONFIG_END)
        effect.setConfig(effectConfig)
        viewModel.editor.audioComposition().effects().add(effect, at: 10)
        viewModel.build()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func editor() {
        fetchLock()
        defer {
            fetchUnlockToSeekTime(Int(videoItem.mixStart * videoItem.duration))
        }
        videoItem.mediaEditor()
        viewModel.build()
    }
    /// 修改主副音轨音量
    public func editorVolume() {
        videoItem.mainLayerBuilder.holder.weight = videoItem.volume
        viewModel.mainAudioLayer.setProperty(videoItem.mainLayerBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
        videoItem.mixLayerBuilder.holder.weight = videoItem.mixVolume
        videoItem.audioLayer.setProperty(videoItem.mixLayerBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
    }
    lazy var mixMultiSlider: SliderBarView = {
        return SliderBarView(title: "副音轨素材裁剪区间", state: .multi)
    }()
    lazy var mixSlider: SliderBarView = {
        return SliderBarView(title: "副音轨开始位置", state: .native)
    }()
    lazy var volumeSlider: SliderBarView = {
        let view = SliderBarView(title: "主音轨音量(0~1)", state: .native)
        view.startValue = 1
        return view
    }()
    lazy var mixVolumeSlider: SliderBarView = {
        let view = SliderBarView(title: "副音轨音量(0~1)", state: .native)
        view.startValue = 1
        return view
    }()
    lazy var msgLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
}
extension VideoAudioMixController {
    func setupView() {
        let scrollView = UIScrollView()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        contentView.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: UIScreen.width(), height: 400)
        
        scrollView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(UIScreen.width())
        }
        
        scrollView.addSubview(mixMultiSlider)
        mixMultiSlider.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(msgLabel.snp_bottom).offset(20)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        scrollView.addSubview(mixSlider)
        mixSlider.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(UIScreen.width())
            make.top.equalTo((50 + 50) * 1)
            make.height.equalTo(50)
        }
        scrollView.addSubview(volumeSlider)
        volumeSlider.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(UIScreen.width())
            make.top.equalTo((50 + 30) * 2)
            make.height.equalTo(50)
        }
        
        scrollView.addSubview(mixVolumeSlider)
        mixVolumeSlider.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(UIScreen.width())
            make.top.equalTo((50 + 30) * 3)
            make.height.equalTo(50)
        }
        updateMessage()
        
        mixMultiSlider.multiSlider.value = [CGFloat(videoItem.mixBegin),CGFloat(videoItem.mixEnd)]
        mixMultiSlider.multiBetweenThumbs(distance: minTimeInterval/videoItem.clipDuration)
        /**副音轨素材裁剪时长调节回调*/
        mixMultiSlider.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.videoItem.mixBegin = begin
            self.videoItem.mixEnd = end
            self.updateMessage()
            self.editor()
        }
        /**副音轨开始位置调节回调*/
        mixSlider.slider.value = videoItem.mixStart
        mixSlider.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.mixStart = value
            self.updateMessage()
            self.editor()
        }
        /**主音轨音量调节回调*/
        volumeSlider.slider.value = videoItem.volume
        volumeSlider.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.volume = value
            self.editorVolume()
        }
        /**副音轨音量调节回调*/
        mixVolumeSlider.slider.value = videoItem.mixVolume
        mixVolumeSlider.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.mixVolume = value
            self.editorVolume()
        }
    }
    private func updateMessage() {
        let startText = Int(videoItem.clipDuration * videoItem.mixBegin).formatTime()
        let endText = Int(videoItem.clipDuration * videoItem.mixEnd).formatTime()
        let positionText = Int(viewModel.originalDuration * videoItem.mixStart).formatTime()
        
        self.msgLabel.text = "副音轨素材信息 开始时间:\(startText) 结束时间 \(endText)\n副音轨位于主音轨位置\(positionText)"
    }
    
}
