//
//  StitchTableView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/26.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class StitchTableView: UITableView {

    let editButton = UIButton()
    private let addButton = UIButton()
    var editCompletion:((UIButton)->Void)?
    var addCompletion:((UIButton)->Void)?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        rowHeight = 75
        register(StitchTableCell.self, forCellReuseIdentifier: "reuseIdentifier")
        separatorInset = .zero
        showsVerticalScrollIndicator = false
        backgroundColor = .black
        tableFooterView = UIView()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 40))
        tableHeaderView = headerView
        editButton.setTitle("编辑", for: .normal)
        editButton.setTitle("完成", for: .selected)
        editButton.layer.cornerRadius = 7
        editButton.clipsToBounds = true
        editButton.titleLabel?.font = .systemFont(ofSize: 13)
        editButton.addTarget(self, action: #selector(editAction(_:)), for: .touchUpInside)
        editButton.backgroundColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
        headerView.addSubview(editButton)
        editButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
            make.width.equalTo(75)
            make.height.equalTo(35)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createApeend() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 40))
        tableFooterView = footerView
        
        addButton.titleLabel?.font = .systemFont(ofSize: 13)
        addButton.setTitle("添加", for: .normal)
        addButton.layer.cornerRadius = 7
        addButton.clipsToBounds = true
        addButton.backgroundColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
        addButton.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        footerView.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(75)
            make.height.equalTo(35)
        }
    }
    @objc func editAction(_ sender: UIButton) {
        editCompletion?(sender)
    }
    @objc func addAction(_ sender: UIButton) {
        addCompletion?(sender)
    }

}

class StitchTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        imageView?.contentMode = .scaleAspectFit
        imageView?.clipsToBounds = true
        textLabel?.textColor = .white
        let lineView = UIView()
        lineView.backgroundColor = .white
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.frame = CGRect(x: 15, y: 0, width: 35, height: 75)
        self.imageView?.frame = CGRect(x: 65, y: 10, width: 55, height: 55)
    }
}
