//
//  TTReverseTableViewCell.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/27.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

/// 从下往上
class TTReverseTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .black
        textLabel?.textColor = UIColor.white
        textLabel?.textAlignment = .center
        contentView.transform = CGAffineTransform(rotationAngle: .pi)
        let bgView = UIView()
        bgView.layer.cornerRadius = 3
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = .lightGray
        contentView.addSubview(bgView)
        contentView.sendSubviewToBack(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
