//
//  SceneController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class SceneController: EditorBaseController {
    class SceneItem {
        var builder = TUPVETusdkSceneEffect_PropertyBuilder()
        var begin: Float = 0
        var end: Float = 1
        var defaultCode: String?
        let config = TUPConfig()
        lazy var effect: TUPVEditorEffect = {
            return TUPVEditorEffect(viewModel.ctx, withType: TUPVETusdkSceneEffect_TYPE_NAME)
        }()
        
        private let index = 3000
        
        let viewModel: EditorViewModel
        init(viewModel: EditorViewModel) {
            self.viewModel = viewModel
            if viewModel.state == .draft {
                
                if let videoEffect = viewModel.clipItems[0].videoClip.effects().getEffect(index) {
                    effect = videoEffect
                    defaultCode = videoEffect.getConfig().getString(TUPVETusdkSceneEffect_CONFIG_NAME)
                    if let prop = effect.getProperty(TUPVETusdkSceneEffect_PROP_PARAM) {
                        let holder = TUPVETusdkSceneEffect_PropertyHolder(property: prop)
                        builder = TUPVETusdkSceneEffect_PropertyBuilder(holder: holder)
                        begin = Float(holder.begin) / viewModel.originalDuration
                        end = Float(holder.end) / viewModel.originalDuration
                    }
                }
                
            }
        }
        func editor(code: String) {
            config.setString(code, forKey: TUPVETusdkSceneEffect_CONFIG_NAME)
            effect.setConfig(config)
            if viewModel.clipItems[0].videoClip.effects().getEffect(index) == nil {
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
            }
            viewModel.build()
        }
        func change() {
            builder.holder.begin = Int64(viewModel.originalDuration * begin)
            builder.holder.end = Int64(viewModel.originalDuration * end)
            effect.setProperty(builder.makeProperty(), forKey: TUPVETusdkSceneEffect_PROP_PARAM)
        }
    }
    var videoItem: SceneItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = SceneItem(viewModel: viewModel)
    }
    var items: [EditorSourceItem] = []
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groups: [String] = VEManager.share().sceneGroup()
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
    lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(SceneCollectionViewCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        return collectionView
    }()
}
extension SceneController:UICollectionViewDelegate, UICollectionViewDataSource {
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
            self.videoItem.change()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! SceneCollectionViewCell
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
    
}
