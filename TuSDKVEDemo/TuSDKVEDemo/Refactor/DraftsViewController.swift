//
//  DraftsViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class DraftsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    private let tableView = UITableView()
    let lock = NSLock()
    var items:[JMDraft] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Router.Scene.drafts.rawValue
        self.view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 90
        tableView.register(DraftsTableViewCell.self, forCellReuseIdentifier: "DraftsTableViewCell")
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
        items = DraftsManager.shared.items
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DraftsTableViewCell") as! DraftsTableViewCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        guard let scene = Router.Scene.init(rawValue: item.scene) else { return }
        Router.shared.show(segue: scene, sender: self, draft: item.url().path)
    }
    @objc func clearAction() {
        clear()
        if items.count == 0 {
            return
        }
        items = []
        tableView.reloadData()
    }
    private func clear() {
        DraftsManager.shared.clear()
        ResourceManager.shared.clear()
        TuFileManager.remove(state: .drafts)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let draft = items[indexPath.row]
        TuFileManager.remove(state: .drafts, name: draft.name)
        DraftsManager.shared.remove(at: indexPath.row)
        ResourceManager.shared.remove(at: draft)
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if items.count == 0 {
            clear()
        }
    }
}
