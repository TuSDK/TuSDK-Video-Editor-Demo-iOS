//
//  AudioMixController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class AudioMixController: EditorBaseController {
    class AudioMixItem {
        let musicList = ["eye_of_forgiveness", "lovely_piano_song"]
        var volumeMap: [Int: Float] = [:]
        let audioConfig = TUPConfig()
        let layerIndex = 1010
        init(viewModel: EditorViewModel) {
            volumeMap[viewModel.mainLayerIndex] = 1
            for index in 0..<musicList.count {
                volumeMap[index + layerIndex] = 0
            }
            if viewModel.state == .resource {
                for (index, item) in musicList.enumerated() {
                    let path = Bundle.main.url(forResource: item, withExtension: "mp3")?.absoluteString ?? ""
                    audioConfig.setString(path, forKey: TUPVEFileClip_CONFIG_PATH)
                    let audioMixClip = TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
                    audioMixClip.setConfig(audioConfig)
                    let musicAudioLayer = TUPVEditorClipLayer(forAudio: viewModel.ctx)
                    musicAudioLayer.add(audioMixClip, at: 30)
                    viewModel.editor.audioComposition().add(musicAudioLayer, at: layerIndex + index)
                    let musicMixBuilder = TUPVEditorLayer_MixPropertyBuilder()
                    musicMixBuilder.holder.weight = 0
                    musicAudioLayer.setProperty(musicMixBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
                }
                let config = TUPConfig()
                config.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
                config.setNumber(NSNumber(value: viewModel.originalDuration), forKey: TUPVETrimEffect_CONFIG_END)
                let effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETrimEffect_AUDIO_TYPE_NAME)
                effect.setConfig(config)
                viewModel.editor.audioComposition().effects().add(effect, at: 20)
                viewModel.build()
            } else {
                for layer in viewModel.editor.audioComposition().getAllLayers() {
                    if let _ = volumeMap[layer.key.intValue].value, let pro = layer.value.getProperty(TUPVEditorLayer_PROP_MIX) {
                        let holder = TUPVEditorLayer_MixPropertyHolder(property: pro)
                        volumeMap[layer.key.intValue] = holder.weight
                    }
                }
            }
        }
    }
    var videoItem: AudioMixItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = AudioMixItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    private func fetchVolumeEditor() {
        for item in videoItem.volumeMap {
            if item.key == viewModel.mainLayerIndex {
                let mixBuilder = TUPVEditorLayer_MixPropertyBuilder()
                mixBuilder.holder.weight = item.value
                viewModel.mainAudioLayer.setProperty(mixBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
            } else {
                let layer = viewModel.editor.audioComposition().getLayer(item.key)
                let musicMixBuilder = TUPVEditorLayer_MixPropertyBuilder()
                musicMixBuilder.holder.weight = item.value
                layer?.setProperty(musicMixBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_MIX)
            }
        }
    }
}
extension AudioMixController {
    func setupView() {
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.width(), height: contentView.frame.height)
        scrollView.isUserInteractionEnabled = true
        contentView.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: UIScreen.width(), height: 400)
        let volumeView = SliderBarView(title: "主音轨", state: .native)
        volumeView.startValue = videoItem.volumeMap[viewModel.mainLayerIndex].value ?? 1
        scrollView.addSubview(volumeView)
        volumeView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        /**主音轨音量调节回调*/
        volumeView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.volumeMap[self.viewModel.mainLayerIndex] = value
            self.fetchVolumeEditor()
        }
        for index in 0..<videoItem.musicList.count {
            let layerIndex = index + videoItem.layerIndex
            let audioVolumeView = SliderBarView(title: "副音轨\(index + 1)\n(0~1)", state: .native)
            audioVolumeView.startValue = videoItem.volumeMap[layerIndex] ?? 0
            scrollView.addSubview(audioVolumeView)
            audioVolumeView.snp.makeConstraints { (make) in
                make.top.equalTo((index + 1)*55)
                make.left.width.height.equalTo(volumeView)
            }
            audioVolumeView.sliderValueChangedCompleted = {[weak self] value in
                guard let `self` = self else { return }
                self.videoItem.volumeMap[layerIndex] = value
                self.fetchVolumeEditor()
            }
        }
    }
}
