//
//  MatteController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class MatteController: EditorBaseController {

    class MatteItem {
        let viewModel: EditorViewModel
        let effect: TUPVEditorEffect
        var builder = TUPVEMatteEffect_PropertyBuilder()
        var model = TTMatteModel()
        var mode: String = ""
        private let index: Int = 2000
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .resource {
                self.effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVEMatteEffect_TYPE_NAME)
            } else {
                if let e = viewModel.mainVideoLayer.effects().getEffect(index) {
                    effect = e
                    mode = effect.getConfig().getString(TUPVEMatteEffect_CONFIG_TYPE, or: "")
                    if let pro = effect.getProperty(TUPVEMatteEffect_PROP_INTERACTION_INFO) {
                        let info = TUPVEMatteEffect_InteractionInfo(pro)
                        print("Matte info: \(info.values)")
                        if let m = TTMatteModel.deserialize(from: info.values) {
                            model = m
                        }
                    }
                } else {
                    self.effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVEMatteEffect_TYPE_NAME)
                }
            }
        }
        func add(code: String) {
            guard mode != code else { return }
            mode = code
            let matteConfig = effect.getConfig()
            matteConfig.setString(code, forKey: TUPVEMatteEffect_CONFIG_TYPE)
            effect.setConfig(matteConfig)
            if let _ = viewModel.mainVideoLayer.effects().getEffect(index) {
                viewModel.mainVideoLayer.effects().deleteEffect(index)
            }
            viewModel.mainVideoLayer.effects().add(effect, at: index)
            viewModel.build()
//            if let pro = effect.getProperty(TUPVEMatteEffect_PROP_INTERACTION_INFO) {
//                let info = TUPVEMatteEffect_InteractionInfo(pro)
//                print("Matte info: \(info.values)")
//            }
        }
        func remove() {
            model = TTMatteModel()
            update()
            viewModel.mainVideoLayer.effects().deleteEffect(index)
            viewModel.build()
            mode = ""
        }
        func update() {
            guard mode != "" else { return }
            let dict = model.dictionary()
            if mode == TUPVEMatteEffect_CONFIG_TYPE_LOVE || mode == TUPVEMatteEffect_CONFIG_TYPE_STAR {
                dict["size-y"] = model.scaleX
            }
            builder.holder.values = dict
            effect.setProperty(builder.makeProperty(), forKey: TUPVEMatteEffect_PROP_PARAM)
        }
    }
    
    var matteView: TTMatteView!
    var collectionView: UICollectionView!
    let diffView = SliderBarView(title: "阴影", state: .native)
    let radiusView = SliderBarView(title: "圆角", state: .native)
    let invertButton = UIButton()
    var videoItem: MatteItem!
    var items:[TTMatteSourceItem] = TTMatteSourceItem.all()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        self.videoItem = MatteItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var selectedIndex = 0
        for (index,item) in items.enumerated() {
            item.isSelected = false
            if item.code == videoItem.mode {
                item.isSelected = true
                selectedIndex = index
            }
        }
        setupView()
        
        matteView.updateinteraction(rect: interactionRect())
        if videoItem.model.scaleX == kDefaultMatteScale {
            videoItem.model.scaleY = videoItem.model.scaleX * matteView.interactionRatio
        }
        if viewModel.state == .draft {
            updateMatteView()
            collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func setupView() {
        matteView = TTMatteView(frame: CGRect(x: 0, y: 0, width: displayView.frame.width, height: displayView.frame.height))
        matteView.delegate = self
        displayView.addSubview(matteView)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 15, width: UIScreen.width, height: 75), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TTCollectionViewvalue1Cell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        contentView.addSubview(collectionView)
        self.collectionView = collectionView
        
        diffView.isHidden = videoItem.mode == ""
        diffView.slider.maximumValue = 1
        diffView.slider.value = videoItem.model.diff
        
        diffView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.videoItem.model.diff = value
            self.update()
        }
        contentView.addSubview(diffView)
        diffView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(50)
            make.top.equalTo(collectionView.snp.bottom).offset(15)
        }
        
//        radiusView.isHidden = videoItem.mode != TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE
//        radiusView.slider.value = videoItem.model.radius
//        radiusView.slider.minimumValue = 0.05
//        radiusView.sliderValueChangedCompleted = {[weak self] value in
//            guard let `self` = self else { return }
//            self.videoItem.model.radius = value
//            self.update()
//        }
//        contentView.addSubview(radiusView)
//        radiusView.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.width.equalTo(UIScreen.width)
//            make.height.equalTo(50)
//            make.top.equalTo(diffView.snp.bottom).offset(15)
//        }
        
        invertButton.isHidden = videoItem.mode == ""
        invertButton.setTitle("反转", for: .normal)
        invertButton.backgroundColor = .white
        invertButton.titleLabel?.font = .systemFont(ofSize: 15)
        invertButton.setTitleColor(.black, for: .normal)
        invertButton.layer.cornerRadius = 5
        invertButton.addTarget(self, action: #selector(invertAction), for: .touchUpInside)
        contentView.addSubview(invertButton)
        invertButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(35)
            make.bottom.equalTo(-CGFloat.safeBottom-5)
        }
    }
    func addAction(code: String) {
        if (code == TUPVEMatteEffect_CONFIG_TYPE_CIRCLE || code == TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE), videoItem.mode != TUPVEMatteEffect_CONFIG_TYPE_CIRCLE, videoItem.mode != TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE { // 重置
            videoItem.model.scaleX = kDefaultMatteScale
            videoItem.model.scaleY = kDefaultMatteScale * matteView.interactionRatio
            matteView.currentScale = .init(x: 1, y: 1)
        }
        fetchLock()
        videoItem.add(code: code)
        fetchUnlock()
        update()
        updateMatteView()
    }
    func update() {
        videoItem.update()
        previewFrame()
    }
    
    func updateMatteView() {
        guard videoItem.mode != "" else { return }
        matteView.addItem(code: videoItem.mode,
                          model: videoItem.model)
    }
    @objc func invertAction() {
        guard videoItem.mode != "" else { return }
        videoItem.model.invert = !videoItem.model.invert
        videoItem.update()
        previewFrame()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        matteView.isHidden = true
    }
    deinit {
        matteView.removeFromSuperview()
    }
}

extension MatteController: TTMatteViewDelegate {
    func matteView(_ matteView: TTMatteView, posX: Float, posY: Float) {
        videoItem.model.native2Pulse(posX: posX, posY: posY)
        update()
    }
    func matteView(_ matteView: TTMatteView, rotate: Float) {
        videoItem.model.rotate = rotate
        update()
    }
    
    func matteView(_ matteView: TTMatteView, scaleX: Float, scaleY: Float) {
        videoItem.model.scaleX = scaleX
        videoItem.model.scaleY = scaleY
        videoItem.model.scale = scaleY
        update()
    }
}
extension MatteController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! TTCollectionViewvalue1Cell
        cell.imageItem = items[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        if item.isSelected {
            return
        }
        for (index,item) in items.enumerated() {
            item.isSelected = (index == indexPath.item)
        }
        collectionView.reloadData()
        invertButton.isHidden = item.code == ""
        if item.code == "" {
            diffView.isHidden = true
            matteView.reload()
            videoItem.remove()
            previewFrame()
        } else {
            diffView.isHidden = false
            diffView.slider.value = videoItem.model.diff
            addAction(code: item.code)
        }
        radiusView.isHidden = item.code != TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE
    }
}

extension MatteController {
    func interactionRect() -> CGRect {
        guard let property = viewModel.mainVideoLayer.getProperty(TUPVEditorLayer_PROP_INTERACTION_INFO) else { return interactionRect }
        let info = TUPVEditorLayer_InteractionInfo(property)
        let width = CGFloat(info.width) * naturalRatio
        let height = CGFloat(info.height) * naturalRatio
        let x = interactionRect.width * CGFloat(info.posX) + interactionRect.origin.x - width / 2
        let y = interactionRect.height * CGFloat(info.posY) + interactionRect.origin.y - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
