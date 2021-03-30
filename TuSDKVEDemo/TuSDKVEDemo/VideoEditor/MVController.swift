//
//  MVController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
class MVController: EditorBaseController {
    class MVItem {
        var builder = TUPVETusdkMVEffect_PropertyBuilder()
        var begin: Float = 0
        var end: Float = 1
        var defaultCode: Int?
        let config = TUPConfig()
        lazy var effect: TUPVEditorEffect = {
            return TUPVEditorEffect(viewModel.ctx, withType: TUPVETusdkMVEffect_TYPE_NAME)
        }()
        lazy var mixAudioClip: TUPVEditorClip = {
            return TUPVEditorClip(viewModel.ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
        }()
        lazy var mixAudioLayer: TUPVEditorClipLayer = {
            let layer = TUPVEditorClipLayer(forAudio: viewModel.ctx)
            let audioLayerConfig = TUPConfig()
            audioLayerConfig.setNumber(NSNumber(value: 0), forKey: TUPVEditorLayer_CONFIG_START_POS)
            layer.setConfig(audioLayerConfig)
            return layer
        }()
        lazy var repeatAudioEffectV2: TUPVEditorEffect = {
            return TUPVEditorEffect(viewModel.ctx, withType: TUPVERepeatEffectV2_AUDIO_TYPE_NAME)
        }()
        
        private let index = 3000
        private let mixAudioIndex = 1100
        
        let viewModel: EditorViewModel
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .draft {
                if let audioLayer = viewModel.editor.audioComposition().getLayer(mixAudioIndex) as? TUPVEditorClipLayer {
                    mixAudioLayer = audioLayer
                    if let audioClip = audioLayer.getClip(mixAudioIndex) {
                        mixAudioClip = audioClip
                        if let effect = audioClip.effects().getEffect(mixAudioIndex) {
                            repeatAudioEffectV2 = effect
                        }
                    }
                }
                if let videoEffect = viewModel.clipItems[0].videoClip.effects().getEffect(index) {
                    effect = videoEffect
                    defaultCode = videoEffect.getConfig().getNumber(TUPVETusdkMVEffect_CONFIG_CODE).intValue
                    if let prop = effect.getProperty(TUPVETusdkMVEffect_PROP_PARAM) {
                        let holder = TUPVETusdkMVEffect_PropertyHolder(property: prop)
                        builder = TUPVETusdkMVEffect_PropertyBuilder(holder: holder)
                        begin = Float(holder.begin) / viewModel.originalDuration
                        end = Float(holder.end) / viewModel.originalDuration
                    }
                }
                
            }
        }
        func editor(code: Int) {
            config.setNumber(NSNumber(value: code), forKey: TUPVETusdkMVEffect_CONFIG_CODE)
            effect.setConfig(config)
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
            }
            
            let path = VEManager.share().audioURL(withStickerIdt: Int64(code)).absoluteString
            print("MV音频 ==\(path)")
            let totalDuration = viewModel.originalDuration
            let audioConfig = TUPConfig()
            audioConfig.setString(path, forKey: TUPVEFileClip_CONFIG_PATH)
            mixAudioClip.setConfig(audioConfig)
            if mixAudioLayer.getClip(mixAudioIndex) == nil {
                mixAudioLayer.add(mixAudioClip, at: mixAudioIndex)
            }
            let mixAudioConfig = TUPConfig()
            mixAudioConfig.setNumber(NSNumber(value: Int(totalDuration * begin)), forKey: TUPVEditorLayer_CONFIG_START_POS)
            mixAudioLayer.setConfig(mixAudioConfig)
            if viewModel.editor.audioComposition().getLayer(mixAudioIndex) == nil {
                viewModel.editor.audioComposition().add(mixAudioLayer, at: mixAudioIndex)
            }
                                  
            let mvAudioConfig = TUPConfig()
            mvAudioConfig.setNumber(NSNumber(value: Int(totalDuration * (end - begin))), forKey: TUPVERepeatEffectV2_CONFIG_DURATION)
            repeatAudioEffectV2.setConfig(mvAudioConfig)
            
            if mixAudioClip.effects().getEffect(mixAudioIndex) == nil {
                mixAudioClip.effects().add(repeatAudioEffectV2, at: mixAudioIndex)
            }
            mixAudioClip.activate()
            viewModel.build()
            builder.holder.begin = Int64(totalDuration * begin)
            builder.holder.end = Int64(totalDuration * end)
            effect.setProperty(builder.makeProperty(), forKey: TUPVETusdkMVEffect_PROP_PARAM)
        }
    }
    var videoItem: MVItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = MVItem(viewModel: viewModel)
    }
    var items: [MVSourceItem] = []
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groups: [TuStickerGroup] = VEManager.share().tuMVStickerGroup()
        for (index, group) in groups.enumerated() {
            let item = MVSourceItem(code: "", name: "")
            item.group = group
            if let code = videoItem.defaultCode, code == group.idt {
                item.isSelected = true
                selectedIndex = index
            }
            items.append(item)
        }
        setupView()
    }
    lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        return collectionView
    }()
}
extension MVController:UICollectionViewDelegate, UICollectionViewDataSource {
    func setupView() {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 13)
        let startText = Int(viewModel.originalDuration * videoItem.begin).formatTime()
        let endText = Int(viewModel.originalDuration * videoItem.end).formatTime()
        titleLabel.text = "MV特效开始时间\(startText) 结束时间\(endText)"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(15)
            make.height.equalTo(20)
        }
        let barView = SliderBarView(title: "起止位置", state: .multi)
        barView.multiSlider.value = [CGFloat(videoItem.begin), CGFloat(videoItem.end)]
        view.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        barView.multiValueChangedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            let startText = Int(self.viewModel.originalDuration * begin).formatTime()
            let endText = Int(self.viewModel.originalDuration * end).formatTime()
            titleLabel.text = "MV特效开始时间\(startText) 结束时间\(endText)"
            self.videoItem.begin = begin
            self.videoItem.end = end
        }
        barView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self, let _ = self.selectedIndex else { return }
            self.fetchEditor()
        }
       
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(barView.snp.bottom).offset(10)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! FilterCollectionViewCell
        cell.item = items[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndex = selectedIndex {
            items[selectedIndex].isSelected = false
        }
        items[indexPath.row].isSelected = true
        selectedIndex = indexPath.row
        collectionView.reloadData()
        fetchEditor()
    }
    private func fetchEditor() {
        fetchLock()
        defer {
            fetchUnlockOriginal()
        }
        videoItem.editor(code: Int(items[selectedIndex!].group.idt))
    }
    
}
