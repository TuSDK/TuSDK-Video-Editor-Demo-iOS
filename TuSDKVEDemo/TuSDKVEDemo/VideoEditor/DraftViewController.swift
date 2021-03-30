//
//  DraftViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class DraftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    private let tableView = UITableView()
    let lock = NSLock()
    var items:[EditorDraftModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Navigator.Scene.draft.rawValue
        self.view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 90
        tableView.register(DraftCell.self, forCellReuseIdentifier: "DraftCell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(CGFloat.naviHeight)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .done, target: self, action: #selector(clearAction))
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        items = DraftManager.shared.items
        tableView.reloadData()
        if items.count == 0 {
            clear()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DraftCell") as! DraftCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        guard let scene = Navigator.Scene.init(rawValue: item.scene) else { return }
        let draftPath = DraftManager.shared.path(filename: item.fileName)
         if scene == .image {
            self.navigationController?.pushViewController(ImageStickerEditorViewController(scene: scene, draftPath: draftPath), animated: true)
        } else {
            Navigator.shared.show(segue: scene, draft: draftPath, sender: self)
        }        
    }
    @objc func clearAction() {
        if items.count == 0 {
            return
        }
        items = []
        tableView.reloadData()
        clear()
    }
    private func clear() {
        DraftManager.shared.clear()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if items.count == 0 {
            clear()
        } else {
            DraftManager.shared.remove(at: indexPath.row)
        }
    }
}


class DraftCell : UITableViewCell {
    let titleLabel = UILabel()
    let draftItemLabel = UILabel()
    let draftTimeLabel = UILabel()
    var item: EditorDraftModel? {
        didSet {
            titleLabel.text = item?.scene
            draftItemLabel.text = item?.fileName
            draftTimeLabel.text = item?.fileTime
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
