//
//  ParticleViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class ParticleController: EditorBaseController {
    class ParticleItem {
        var beginTs: Int = 0
        var effects:[TUPVEditorEffect] = []
        var defaultEffectsCount = 0
        var posInfos: [TUPVETusdkParticleEffect_PosInfo] = []
        var scale: Float = 0.5
        var color = UIColor.clear
        lazy var builder: TUPVETusdkParticleEffect_PropertyBuilder = {
            return TUPVETusdkParticleEffect_PropertyBuilder()
        }()
        lazy var posBuilder: TUPVETusdkParticleEffect_PosPropertyBuilder = {
            return TUPVETusdkParticleEffect_PosPropertyBuilder()
        }()
        
        var defaultCode: String?
        let config = TUPConfig()
        let viewModel: EditorViewModel
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .draft {
                defaultEffectsCount = viewModel.clipItems[0].videoClip.effects().getAllEffects().count
            }
        }
        func editor(code: String) {
            config.setString(code, forKey: TUPVETusdkParticleEffect_CONFIG_NAME)
            let effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETusdkParticleEffect_TYPE_NAME)
            effect.setConfig(config)
            effects.append(effect)
            
            let index = effects.count + defaultEffectsCount + 200
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
            }
            viewModel.build()
        }
        func move(posX: CGFloat, posY: CGFloat) {
            posBuilder.posX = Double(posX)
            posBuilder.posY = Double(posY)
            posBuilder.scale = Double(scale)
            posBuilder.tint = color
            //printLog("x:\(posX)==y:\(posY)")
            let effect = effects.last
            effect?.setProperty(posBuilder.makeProperty(), forKey: TUPVETusdkParticleEffect_PROP_PARTICLE_POS)
        }
        // 移动结束
        func moveEnd(beginTs: Int, endTs: Int) {
            builder.holder.begin = Int64(beginTs)
            builder.holder.end = Int64(endTs)
            builder.holder.trajectory = posInfos
            builder.holder.scale = Double(scale)
            builder.holder.tint = color
            let effect = effects.last
            effect?.setProperty(builder.makeProperty(), forKey: TUPVETusdkParticleEffect_PROP_PARAM)
            posBuilder.posX = -1
            posBuilder.posY = -1
            effect?.setProperty(posBuilder.makeProperty(), forKey: TUPVETusdkParticleEffect_PROP_PARTICLE_POS)
        }
    }
    var videoItem: ParticleItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = ParticleItem(viewModel: viewModel)
    }
    var items: [EditorSourceItem] = []
    var selectedIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        let groups = VEManager.share().particleGroup()
        for (index, group) in groups.enumerated() {
            let item = EditorSourceItem(code: group, name: "")
            if let code = videoItem.defaultCode, code == group {
                item.isSelected = true
                selectedIndex = index
            }
            items.append(item)
        }
        setupView()
    }
    private func fetchEditor() {
        fetchLock()
        defer {
            fetchUnlockToSeekTime(currentTs, autoPlay: true)
        }
        videoItem.editor(code: items[selectedIndex!].code)
    }
    var tempTs: Int = -50

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = selectedIndex else { return }
        for touch:AnyObject in touches {
            let t:UITouch = touch as! UITouch
            _ = t.location(in: self.view)
            videoItem.beginTs = currentTs
            tempTs = currentTs
            fetchEditor()
            videoItem.posInfos = []
            videoItem.moveEnd(beginTs: 0, endTs: 0)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch:AnyObject in touches {
            let t:UITouch = touch as! UITouch
            let point = t.location(in: view)
            let displayePoint = displayView.layer.convert(point, from: view.layer)
            if displayView.layer.contains(displayePoint) {
                if currentTs - tempTs >= 50 {
                    let naturalPoint = CGPoint(x: point.x - interactionRect.origin.x, y: point.y - interactionRect.origin.y-CGFloat.naviHeight)
                    let posX = naturalPoint.x/interactionRect.width
                    let posY = naturalPoint.y/interactionRect.height
                    let posInfo = TUPVETusdkParticleEffect_PosInfo(Int64(currentTs - videoItem.beginTs), withPosX: Double(posX), andY: Double(posY))
                    videoItem.posInfos.append(posInfo)
                    videoItem.move(posX: posX, posY: posY)
                    tempTs = currentTs
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        videoItem.moveEnd(beginTs: videoItem.beginTs, endTs: currentTs)
        pause()
    }
    lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        return collectionView
    }()
}

extension ParticleController: UICollectionViewDelegate, UICollectionViewDataSource {
    func setupView() {
        let colorBarView = SliderBarView(title: "颜色", state: .color)
        colorBarView.colorSlider.color = videoItem.color
        contentView.addSubview(colorBarView)
        colorBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        colorBarView.colorSliderDownCompleted = {[weak self] (color) in
            guard let `self` = self else { return }
            self.videoItem.color = color
        }
        let barView = SliderBarView(title: "大小", state: .native)
        barView.startValue = 0
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(colorBarView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        barView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.scale = value
        }
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(barView.snp.bottom).offset(10)
        }
                
        self.view.isMultipleTouchEnabled = true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! FilterCollectionViewCell
        cell.particleItem = items[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndex = selectedIndex {
            items[selectedIndex].isSelected = false
        }
        items[indexPath.row].isSelected = true
        selectedIndex = indexPath.row
        collectionView.reloadData()
        
    }
}
