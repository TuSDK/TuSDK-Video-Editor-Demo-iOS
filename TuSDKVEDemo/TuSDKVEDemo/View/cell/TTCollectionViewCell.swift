//
//  TTCollectionViewCell.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/27.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import Gifu

class TTCollectionViewCell: UICollectionViewCell {
    enum Style {
        case text
        case textBorder
    }
    var item: EditorSourceItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.name
            titleLabel.textColor = item.isSelected ? .red : .white
        }
    }
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    func update(item:EditorSourceItem?, style: TTCollectionViewCell.Style = .text) {
        guard let item = item else { return }
        titleLabel.text = item.name
        switch style {
        case .text:
            titleLabel.textColor = item.isSelected ? .red : .white
        case .textBorder:
            titleLabel.layer.cornerRadius = 5
            titleLabel.clipsToBounds = true
            titleLabel.textColor = item.isSelected ? .white : UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
            titleLabel.backgroundColor = item.isSelected ? UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1) : .white
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class TTCollectionViewvalue1Cell: UICollectionViewCell {
    var item: EditorSourceItem? {
        didSet {
            if let item = item {
                titleLabel.text = item.name
                iconView.image = UIImage(named: item.code)
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
            make.width.height.equalTo(50)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TTCollectionViewGIFCell: UICollectionViewCell {
    
    var animationTextItem: EditorSourceItem? {
        didSet {
            guard let item = animationTextItem else { return }
            iconView.alpha = item.isSelected ? 0.4 : 1
            titleLabel.text = item.name
            titleLabel.textColor = item.isSelected ? .red : .white
            let gifCode = item.code.replacingOccurrences(of: "animation_text", with: "anitext_thumb")
            if let url = Bundle.main.url(forResource: gifCode, withExtension: "gif") {
                iconView.animate(withGIFURL:url)
            } else {
                iconView.image = UIImage(named: "lsq_anitext_thumb_0.png")
            }
        }
    }
    private let iconView = GIFImageView()
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
      super.prepareForReuse()
      iconView.prepareForReuse()
    }
}
