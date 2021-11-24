//
//  TTTextAnimationView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TTTextAnimationView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    class Model {
        enum AnimationState: Int {
            case `in`
            case `out`
            case overall
        }
        var items: [EditorSourceItem] = []
        var state: AnimationState = .in
        var start: Float = 0
        var end: Float = 1
        var selectedIndex = 0
        init(state: AnimationState) {
            switch state {
            case .in:
                items = TTTextSourceItem.animationInAll()
            case .out:
                items = TTTextSourceItem.animationOutAll()
            case .overall:
                items = TTTextSourceItem.animationOverall()
            }
            self.state = state
        }
        func update(index: Int) {
            guard items.count > index else { return }
            for i in 0..<items.count {
                items[i].isSelected = (index == i)
            }
            selectedIndex = index
        }
        func update(animator: TUPVEAnimationTextClip_Animator) {
            if animator.path != "" {
                for (index,item) in items.enumerated() {
                    if animator.path.contains(item.code) {
                        selectedIndex = index
                        item.isSelected = true
                    } else {
                        item.isSelected = false
                    }
                }
            }
            
            if state == .in {
                end = Float(animator.end)
            } else if state == .out {
                start = Float(animator.start)
            } else {
                start = Float(animator.start)
                end = Float(animator.end)
            }
        }
    }
    
    private var models: [Model] = [Model(state: .in), Model(state: .out), Model(state: .overall)]
    private var stateIndex: Int = 0
    private var collectionView: UICollectionView!
    private var contentView = UIView()
    private var barView = SliderBarView(title: "进入/退出时长", state: .multi)
    private var titleLabel = UILabel()
    var start: Int = 0
    var duration: Int = 0
    lazy var sourceManager = TTSourceManager()

    var animators:[TUPVEAnimationTextClip_Animator] = [] {
        didSet {
            setupData()
        }
    }
    var completed:(()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let btnsView = TTButtonsView(items: TTTextSourceItem.animationStateAll(), frame: CGRect(x: 0, y: 0, width: frame.width, height: 45), hasImage: false)
        btnsView.indexCompleted = {[weak self] index in
            guard let `self` = self else { return }
            self.stateIndex = index
            self.update()
        }
        addSubview(btnsView)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: btnsView.frame.height + 10, width: frame.width, height: 75), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(TTCollectionViewGIFCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        addSubview(collectionView)
        
        contentView.isHidden = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.height.equalTo(70)
        }
        
        barView.multiSlider.tintColor = .lightGray
        barView.multiSlider.outerTrackColor = actualTintColor
        barView.multiValueChangedCompleted = {[weak self] (start,end) in
            guard let `self` = self else { return }
            let model = self.models[self.stateIndex]
            if model.state == .in {
                model.end = Float(start)
            } else if model.state == .out {
                model.start = Float(end)
            } else {
                model.start = Float(start)
                model.end = Float(end)
            }
            self.updateTitle()
            self.fetch(model: model)
        }
        contentView.addSubview(barView)
        barView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(durationUpdate(_:)), name: .init(rawValue: "TextUpdateDuration"), object: nil)
    }
    @objc func durationUpdate(_ notification: Notification) {
        guard let item = notification.object as? (Int, Int) else { return }
        start = item.0
        duration = item.1
        updateTitle()
    }
    func setupData() {
        for (index,animator) in animators.enumerated() {
            models[index].update(animator: animator)
        }
        update()
    }
    func updateTitle() {
        let begin = start + Int(CGFloat(duration) * barView.multiSlider.value[0])
        let end = start + Int(CGFloat(duration) * barView.multiSlider.value[1])
        if stateIndex == 2 {
            titleLabel.text = "整体动画开始:\(begin.formatTime()) 结束:\(end.formatTime())"
        } else {
            titleLabel.text = "进入动画开始:\(start.formatTime()) 结束:\(begin.formatTime())\n退出动画开始:\(end.formatTime()) 结束:\((start + duration).formatTime())"
        }
    }
    // 更新 进入/退出/整体动画
    func update() {
        let model = models[stateIndex]
        if model.state == .overall {
            barView.text = "动画时长"
            barView.multiSlider.tintColor = actualTintColor
            barView.multiSlider.outerTrackColor = .lightGray
            barView.multiSlider.value = [CGFloat(model.start),CGFloat(model.end)]
        } else {
            barView.text = "进入/退出时长"
            barView.multiSlider.tintColor = .lightGray
            barView.multiSlider.outerTrackColor = actualTintColor
            barView.multiSlider.value = [CGFloat(models[0].end),CGFloat(models[1].start)]
        }
        contentView.isHidden = (model.selectedIndex == 0)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: model.selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        updateTitle()
    }
    // 更新选中动画
    func update(index: Int) {
        let model = models[stateIndex]
        guard !model.items[index].isSelected else { return }
        contentView.isHidden = (index == 0)
        model.update(index: index)
        collectionView.reloadData()
        guard index != 0 else {
            fetch(model: model)
            return }
        if model.state == .overall {
            models[0].update(index: 0)
            models[1].update(index: 0)
            animators[0].path = ""
            animators[1].path = ""
        } else {
            models[2].update(index: 0)
            animators[2].path = ""
        }
        fetch(model: model)
    }
    func fetch(model: TTTextAnimationView.Model) {
        var path: String? = nil
        if model.selectedIndex == 0 {
            path = ""
        } else {
            if let sandbox = self.sourceManager.textAnimation(code: model.items[model.selectedIndex].code) {
                path = TUPPathMarshal.marshalPath(sandbox)
            }
        }
        if let path = path {
            let animator = animators[stateIndex]
            animator.start = Double(model.start)
            animator.end = Double(model.end)
            animator.path = path
            completed?()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models[stateIndex].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! TTCollectionViewGIFCell
        cell.animationTextItem = models[stateIndex].items[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        update(index: indexPath.item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
