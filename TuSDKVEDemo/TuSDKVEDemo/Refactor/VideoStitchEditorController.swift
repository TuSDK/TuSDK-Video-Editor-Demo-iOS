//
//  VideoStitchEditorController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/26.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class VideoStitchEditorController: EditorVideoController {

    private let tableView = StitchTableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

}
extension VideoStitchEditorController: UITableViewDelegate, UITableViewDataSource {
    func setupView() {
        tableView.createApeend()
        tableView.delegate = self
        tableView.dataSource = self
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        adapter.clipItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! StitchTableCell
        let item = adapter.clipItems[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row)"
        cell.imageView?.image = item.source.coverImage
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return adapter.clipItems.count > 1
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
       // removeClip(index: indexPath.row)
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        
    }
}
