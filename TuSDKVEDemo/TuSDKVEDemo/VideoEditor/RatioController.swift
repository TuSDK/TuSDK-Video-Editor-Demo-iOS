//
//  RatioController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class RatioController: EditorBaseController {

    var items: [RatioSourceItem] = RatioSourceItem.all()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        if viewModel.state == .draft {
            if let info = viewModel.editor.videoComposition().getStreamInfo() as? TUPVideoStreamInfo {
                let w = info.width
                let h = info.height
                let radio = Float(w)/Float(h)
                for item in items {
                    let temp = Float(item.width) / Float(item.height)
                    if radio - temp <= 0.01, (radio - temp) >= 0 {
                        item.isSelected = true
                    }
                }
            }
        } else {
            items[3].isSelected = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    func ratio(percent: Float) {
        fetchLock()
        defer {
           self.fetchUnlockToSeekTime(self.currentTs)
        }
        let config = viewModel.editor.getConfig()
        let maxWidth = viewModel.videoNaturalSize.width
        let width = percent > 0 ? Int(maxWidth) : Int(Float(maxWidth) / percent)
        config.width = width
        config.height = Int(Float(width) / percent)
        viewModel.editor.update(with: config)
        viewModel.build()
    }
}
extension RatioController: UICollectionViewDataSource, UICollectionViewDelegate {
    func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(RatioCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(40)
            make.height.equalTo(100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! RatioCell
        cell.item = items[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for item in items {
            item.isSelected = false
        }
        items[indexPath.row].isSelected = true
        collectionView.reloadData()
        ratio(percent: Float(items[indexPath.row].width) / Float(items[indexPath.row].height))
    }
}


class RatioCell: UICollectionViewCell {
    var item: RatioSourceItem? {
        didSet {
            if let item = item {
                let temp = item.isSelected ? "sel" : "nor"
                iconView.image = UIImage(named: "crop_\(item.width)-\(item.height)_\(temp)")
                titleLabel.text = "\(item.width):\(item.height)"
            }
        }
    }
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
