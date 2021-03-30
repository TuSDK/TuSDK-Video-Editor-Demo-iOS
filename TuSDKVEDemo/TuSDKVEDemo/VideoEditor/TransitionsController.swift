//
//  TransitionsController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TransitionsController: EditorBaseController {

    var items:[TransitionSourceItem] = TransitionSourceItem.all()
    var timeValue : NSInteger = 1
    var selectedIndex: Int?
    var firstVideoDuration: Int = 0
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        firstVideoDuration = Int(viewModel.clipItems[0].videoClip.getStreamInfo()!.duration)
        if viewModel.state == .draft {
            let tran = viewModel.mainVideoLayer.getTransition(viewModel.clipItems[1].index)
            for (index,item) in items.enumerated() {
                if index != 0, item.code == tran.name {
                    item.isSelected = true
                    selectedIndex = index
                }
            }
            if tran.duration > 0 {
                timeValue = Int((tran.duration + 100) / 1000)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    func editor() {
        fetchLock()
        let isClose = selectedIndex == 0
        defer {
            var time = firstVideoDuration - 3000
            if time <= 0 {
                time = 0
            }
            fetchUnlockToSeekTime(time, autoPlay: true)
        }
        let code = items[selectedIndex!].code
        let transition = TUPVEditorClipLayer_Transition()
        transition.duration = timeValue * 1000 - 100
        for index in 1..<viewModel.clipItems.count {
            let clipItem = viewModel.clipItems[index]
            if isClose {
                viewModel.mainAudioLayer.unsetTransition(clipItem.index)
                viewModel.mainVideoLayer.unsetTransition(clipItem.index)
            } else {
                transition.name = code
                viewModel.mainAudioLayer.setTransition(transition, at: clipItem.index)
                viewModel.mainVideoLayer.setTransition(transition, at: clipItem.index)
            }
        }
        viewModel.build()
    }
}
extension TransitionsController: UICollectionViewDataSource, UICollectionViewDelegate {
    func setupView() {
        let msgLabel = UILabel()
        msgLabel.textColor = .white
        msgLabel.font = .systemFont(ofSize: 13)
        msgLabel.textAlignment = .center
        msgLabel.text = "当前转场持续时长: \(timeValue)秒"
        contentView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { (make) in
            make.left.left.right.equalToSuperview()
            make.top.equalTo(15)
        }
        
        let barView = SliderBarView(title: "转场时长1~3秒", state: .native)
        barView.slider.maximumValue = 3
        barView.slider.minimumValue = 1
        barView.slider.value = Float(timeValue)
        barView.isRounded = true
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        barView.sliderValueChangedCompleted = {value in
            msgLabel.text = "当前转场持续时长: \(Int(value))秒"
        }
        
        barView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self, let _ = self.selectedIndex else { return }
            self.timeValue = Int(value)
            self.editor()
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 40)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PresentCollectionViewCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(barView.snp.bottom).offset(20)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! PresentCollectionViewCell
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
        
        editor()
    }
}
