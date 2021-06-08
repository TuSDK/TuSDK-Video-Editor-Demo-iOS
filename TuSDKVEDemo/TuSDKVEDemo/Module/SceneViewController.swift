//
//  SceneViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
let refactor = false
class SceneViewController: UITableViewController {
    let items: [Navigator.Scene] = Navigator.Scene.all
    let refactorItems: [Router.Scene] = Router.Scene.all
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "涂图"
        
        tableView.rowHeight = 56
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 40))
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.text = "TuSDK Video Editor SDK 1.0.1-\(bundleVersion)\n@2021 TUTUCLOUD.COM"
        tableFooterView.addSubview(label)
        tableView.tableFooterView = tableFooterView
        /// 清空存储素材临时文件
        TuFileManager.remove(state: .temp)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if refactor {
            return refactorItems.count
        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = items[indexPath.row].rawValue
        if refactor {
            cell.textLabel?.text = refactorItems[indexPath.row].rawValue
        }
        if indexPath.row == items.count - 1 {
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if refactor {
            let item = refactorItems[indexPath.row]
            Router.shared.show(segue: item, sender: self)
            return
        }
        let item = items[indexPath.row]
        if item == .pip  {
            Navigator.shared.show(segue: item, sender: self)
        } else {
            Navigator.shared.show(segue: item, draft:nil, sender: self)
        }
    }

}
