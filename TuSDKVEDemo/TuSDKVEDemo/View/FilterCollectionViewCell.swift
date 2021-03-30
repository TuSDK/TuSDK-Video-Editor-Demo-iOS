//
//  FilteCollectionViewCell.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import Gifu
class FilterCollectionViewCell: UICollectionViewCell {
    var item: EditorSourceItem? {
        didSet {
            guard let item = item else { return }
            if let item = item as? MVSourceItem {
                titleLabel.text = Bundle.main.localizedString(forKey: item.group.name, value: "", table: "TuSDKConstants")
                VEManager.share().loadThumb(with: item.group, imageView: iconView)
                iconView.alpha = item.isSelected ? 0.4 : 1
                return
            }
            titleLabel.text = Bundle.main.localizedString(forKey: item.name, value: "", table: "TuSDKConstants")
            if let file = Bundle.main.path(forResource: "lsq_filter_thumb_\(item.code)", ofType: ".jpg") {
                iconView.image = UIImage(contentsOfFile: file)
            } else {
                iconView.image = nil
            }
            iconView.alpha = item.isSelected ? 0.4 : 1
        }
    }
    var particleItem: EditorSourceItem? {
        didSet {
            guard let item = particleItem else { return }
            titleLabel.text = Bundle.main.localizedString(forKey: "lsq_filter_\(item.code)", value: "", table: "TuSDKConstants")
            if let file = Bundle.main.path(forResource: "lsq_effect_thumb_\(item.code)", ofType: ".jpg") {
                iconView.image = UIImage(contentsOfFile: file)
            } else {
                iconView.image = nil
            }
            iconView.alpha = item.isSelected ? 0.4 : 1
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
class SceneCollectionViewCell: UICollectionViewCell {
    
    
    var item: EditorSourceItem? {
        didSet {
            guard let item = item else { return }
            iconView.alpha = item.isSelected ? 0.4 : 1
            if let url =  Bundle.main.url(forResource: "lsq_effect_thumb_\(item.code)", withExtension: "gif") {
                iconView.animate(withGIFURL:url)
                titleLabel.text = Bundle.main.localizedString(forKey: "lsq_filter_\(item.code)", value: "", table: "TuSDKConstants")
            } 
        }
    }
    private let iconView = GIFImageView()
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
class PresentCollectionViewCell: UICollectionViewCell {
    
    var item: TransitionSourceItem? {
        didSet {
            if let item = item {
                titleLabel.text = item.name
                titleLabel.textColor = item.isSelected ? .white : UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
                titleLabel.backgroundColor = item.isSelected ? UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1) : .white
            }
        }
    }
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        titleLabel.layer.borderColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1).cgColor
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.cornerRadius = 4
        titleLabel.clipsToBounds = true
        titleLabel.backgroundColor = .white
        titleLabel.textColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





class FilterListCell: UICollectionViewCell {
    var item: TuFilterOption? {
        didSet {
            if let item = item {
                titleLabel.text = Bundle.main.localizedString(forKey: item.name, value: "", table: "TuSDKConstants")
                if let code = item.code, let file = Bundle.main.path(forResource: "lsq_filter_thumb_\(code)", ofType: ".jpg") {
                    iconView.image = UIImage(contentsOfFile: file)
                } else {
                    iconView.image = nil
                }
            }
        }
    }
    var itemSelected: Bool = false {
        didSet {
            iconView.alpha = itemSelected ? 0.4 : 1
        }
    }
    var stickerItem: TuStickerGroup? {
        didSet {
            if let stickerItem = stickerItem {
                
                titleLabel.text = Bundle.main.localizedString(forKey: stickerItem.name, value: "", table: "TuSDKConstants")
                VEManager.share().loadThumb(with: stickerItem, imageView: iconView)
            }
        }
    }
    lazy var package: TuStickerLocalPackage = {
        return TuStickerLocalPackage()
    }()
    var particleItem: String? {
        didSet {
            if let particleItem = particleItem {
                titleLabel.text = Bundle.main.localizedString(forKey: "lsq_filter_\(particleItem)", value: "", table: "TuSDKConstants")
                if let file = Bundle.main.path(forResource: "lsq_effect_thumb_\(particleItem)", ofType: ".jpg") {
                    iconView.image = UIImage(contentsOfFile: file)
                } else {
                    iconView.image = nil
                }
            }
        }
    }
    var textItem: (String, String)? {
        didSet {
            if let textItem = textItem {
                titleLabel.text = textItem.0
                iconView.image = UIImage(named: textItem.1)
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
class PresentListCell: UICollectionViewCell {
    
    var multiItem: (String, String, Bool)? {
        didSet {
            if let item = multiItem {
                titleLabel.text = item.1
                titleLabel.textColor = item.2 ? .white : UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
                titleLabel.backgroundColor = item.2 ? UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1) : .white
            }
        }
    }
    var item: (String, Bool)? {
        didSet {
            if let item = item {
                titleLabel.text = item.0
                titleLabel.textColor = item.1 ? .white : UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
                titleLabel.backgroundColor = item.1 ? UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1) : .white
            }
        }
    }
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        titleLabel.layer.borderColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1).cgColor
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.cornerRadius = 4
        titleLabel.clipsToBounds = true
        titleLabel.backgroundColor = .white
        titleLabel.textColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
