//
//  DraftsTableViewCell.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class DraftsTableViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let draftItemLabel = UILabel()
    let draftTimeLabel = UILabel()
    var item: JMDraft? {
        didSet {
            titleLabel.text = item?.scene
            draftItemLabel.text = item?.name
            draftTimeLabel.text = item?.time
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .white
        
        titleLabel.font = .systemFont(ofSize: 13);
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        
        draftItemLabel.font = .systemFont(ofSize: 13);
        draftItemLabel.textColor = .black
        contentView.addSubview(draftItemLabel)
        
        draftTimeLabel.font = .systemFont(ofSize: 13);
        draftTimeLabel.textColor = .black
        contentView.addSubview(draftTimeLabel)
 
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.height.equalTo(30)
        }
        draftItemLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom)
        }
        draftTimeLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel)
            make.top.equalTo(draftItemLabel.snp_bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
