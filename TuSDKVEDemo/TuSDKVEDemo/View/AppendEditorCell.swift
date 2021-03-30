//
//  AppendEditorCell.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class AppendEditorCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.frame = CGRect(x: 15, y: 0, width: 20, height: 50)
        self.imageView?.frame = CGRect(x: 35, y: 2, width: 50, height: 46)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
