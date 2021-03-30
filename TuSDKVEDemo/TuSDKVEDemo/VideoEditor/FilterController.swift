//
//  FilterController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class FilterController: EditorBaseController {
    class FilterItem {
        var effect: TUPVEditorEffect
        var builder = TUPVETusdkFilterEffect_PropertyBuilder()
        var strength : Float = 0.75
        var defaultCode: String?
        let config = TUPConfig()
        private let index = 3000
        let viewModel: EditorViewModel
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .resource {
                effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETusdkFilterEffect_TYPE_NAME)
                
            } else {
                if  let effect = viewModel.clipItems[0].videoClip.effects().getEffect(index) {
                    self.effect = effect
                    defaultCode = effect.getConfig().getString(TUPVETusdkFilterEffect_CONFIG_NAME)
                    if let prop = effect.getProperty(TUPVETusdkFilterEffect_PROP_PARAM) {
                        let holder = TUPVETusdkFilterEffect_PropertyHolder(property: prop)
                        builder = TUPVETusdkFilterEffect_PropertyBuilder(holder: holder)
                        strength = Float(holder.strength)
                    }
                } else {
                    effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETusdkFilterEffect_TYPE_NAME)
                }
            }
        }
        func editor(code: String) {
            config.setString(code, forKey: TUPVETusdkFilterEffect_CONFIG_NAME)
            effect.setConfig(config)
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
            }
            viewModel.build()
        }
        func delete() {
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) != nil {
                viewModel.clipItems[0].videoClip.effects().deleteEffect(index)
                viewModel.build()
            }
        }
        func updateStrength() {
            effect.setProperty(builder.makeProperty(), forKey: TUPVETusdkFilterEffect_PROP_PARAM)
        }
    }
    var videoItem: FilterItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = FilterItem(viewModel: viewModel)
    }
    var items: [EditorSourceItem] = []
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groups: [TuFilterOption] = VEManager.share().filterGroups()
        for (index, group) in groups.enumerated() {
            let item = EditorSourceItem(code: group.code, name: group.name)
            if let code = videoItem.defaultCode, code == group.code {
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
extension FilterController:UICollectionViewDelegate, UICollectionViewDataSource {
    func setupView() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(15)
            make.left.equalTo(80)
            make.height.equalTo(80)
        }
        let closeView = UIView()
        closeView.isUserInteractionEnabled = true
        contentView.addSubview(closeView)
        closeView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.height.width.equalTo(75)
            make.left.equalTo(10);
        }
        
        let iconView = UIImageView()
        iconView.image = UIImage.init(named: "qn_icon_close")
        iconView.isUserInteractionEnabled = true
        iconView.contentMode = .scaleAspectFit
        closeView.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "滤镜关闭"
        closeView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
        }
        
        let closeTap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        closeView.addGestureRecognizer(closeTap)
        
        let msgLabel = UILabel()
        msgLabel.text = "当前滤镜强度: \(videoItem.strength)"
        msgLabel.textColor = .white
        msgLabel.font = .systemFont(ofSize: 13)
        msgLabel.textAlignment = .center
        contentView.addSubview(msgLabel);
        msgLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(collectionView.snp.bottom).offset(20)
        }
        
        let countBarView = SliderBarView(title: "滤镜强度", state: .native)
        countBarView.startValue = videoItem.strength
        contentView.addSubview(countBarView)
        countBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(msgLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        countBarView.sliderValueChangedCompleted = {[weak self] value in
            msgLabel.text = "当前滤镜强度: \(value.titleFormat())"
            guard let `self` = self, let _ = self.selectedIndex else { return }
            DispatchQueue.main.async {
                self.videoItem.builder.holder.strength = Double(value)
                self.videoItem.updateStrength()
                if !self.isPlaying {
                    self.player.previewFrame(self.currentTs)
                }
            }
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
        videoItem.editor(code: items[selectedIndex!].code)
    }
    
    @objc private func closeAction() {
        guard let selectedIndex = selectedIndex else { return }
        fetchLock()
        defer {
            fetchUnlockOriginal()
        }
        videoItem.delete()
        self.selectedIndex = nil
        items[selectedIndex].isSelected = false
        collectionView.reloadData()
    }
}
