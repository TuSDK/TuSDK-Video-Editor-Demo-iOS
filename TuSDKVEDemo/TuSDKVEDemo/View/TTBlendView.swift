//
//  TTBlendView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/27.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TTBlendView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    private let items:[TTBlendSourceItem] = TTBlendSourceItem.all()
    private let blendButton = UIButton()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let slider = SliderBarView(title: "混合强度", state: .native)
    private var currentCode: String?
    public var blendCompletion:((String, Float)->Void)?
    public var strengthCompletion:((Float)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        blendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        blendButton.setTitle("混合模式", for: .normal)
        addSubview(blendButton)
        blendButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(10)
            make.width.equalTo(70)
            make.height.equalTo(45)
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 45)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(TTCollectionViewCell.self, forCellWithReuseIdentifier: "TTBlendView")
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.right.top.equalToSuperview()
            make.left.equalTo(blendButton.snp.right)
        }
        
        slider.startValue = 1
        addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(15)
            make.height.equalTo(50)
        }
        slider.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.strengthCompletion?(value)
        }
    }
    func setup(mode: String?, strength: Float?) {
        currentCode = mode
        for item in items {
            item.isSelected = (mode == item.code)
        }
        collectionView.reloadData()
        if let strength = strength {
            slider.slider.value = strength
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TTBlendView", for: indexPath) as! TTCollectionViewCell
        cell.item = items[indexPath.item]
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
        currentCode = item.code
        blendCompletion?(currentCode!, slider.slider.value)
    }
    func reset() {
        currentCode = nil
        slider.startValue = 1
        for item in items {
            item.isSelected = false
        }
        collectionView.reloadData()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
