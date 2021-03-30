//
//  StitchingController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/16.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class StitchingController: EditorBaseController {
    
    lazy var tableView: ClipsTableView = {
        let tableView = ClipsTableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    var isAllowAddClip = true
    var clipLastIndex: Int = 0
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        if viewModel.state == .draft {
            viewModel.clipItems.sort { $0.index < $1.index }
        }
    }
    lazy var imagePicker: ImagePicker = {
        let ip = ImagePicker()
        ip.maxCount = 9
        if viewModel.scene == .pictures {
            ip.state = .image
        } else if viewModel.scene == .video {
            ip.state = .video
        } else {
            ip.state = .both
        }
        return ip
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        clipLastIndex = viewModel.clipItems.count - 1
    }
}
extension StitchingController {
    func removeClip(index: Int) {
        fetchLock()
        defer {
            fetchUnlock()
            seek(0)
        }
        let clipItem = viewModel.clipItems[index]
        viewModel.mainVideoLayer.deleteClip(clipItem.index)
        viewModel.mainAudioLayer.deleteClip(clipItem.index)
        viewModel.clipItems.remove(at: index)
        viewModel.build()
        reloadData()
        if viewModel.scene != .cut {
            DraftManager.shared.clearSandboxVideo(clipItem: clipItem)
        }
    }
    func append(sources: [ResourceModel]) {
        clipLastIndex += 1
        fetchLock()
        defer {
            fetchUnlock()
            seek(currentTs)
        }
        
        for (i, item) in sources.enumerated() {
            let index = clipLastIndex + i
            let clipItem = VideoClipItem(ctx: viewModel.ctx, source: item, index: index)
            let appendEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVECanvasResizeEffect_TYPE_NAME)
            clipItem.videoClip.effects().add(appendEffect, at: clipItem.index)
            viewModel.mainAudioLayer.add(clipItem.audioClip, at: clipItem.index)
            viewModel.mainVideoLayer.add(clipItem.videoClip, at: clipItem.index)
            viewModel.clipItems.append(clipItem)
        }
        viewModel.build()
        reloadData()
    }
    @objc func swap(from idx0: Int, to idx1: Int) {
        fetchLock()
        defer {
            fetchUnlock()
            seek(0)
        }
        var step : Int = 1

        if idx1 > idx0  {
            step = 1
        }else if idx1 < idx0 {
            step = -1
        }
        printTu(idx0, idx1, step)
        for index in stride(from: idx0, to: idx1, by: step) {
            let next = index + step
            let id0 = viewModel.clipItems[index].index
            let id1 = viewModel.clipItems[next].index
            printTu(index,next, id0, id1)
            viewModel.mainVideoLayer.swapClips(id0,and:id1)
            viewModel.mainAudioLayer.swapClips(id0,and:id1)
            
        }
        viewModel.build()
        for index in stride(from: idx0, to: idx1, by: step) {
            let next = index + step

            viewModel.clipItems.swapAt(index, next)

            let tmp = viewModel.clipItems[index].index
            viewModel.clipItems[index].index = viewModel.clipItems[next].index
            viewModel.clipItems[next].index = tmp
            
        }
        reloadData()
    }
}
extension StitchingController: UITableViewDataSource, UITableViewDelegate {
    func setupView() {
        if isAllowAddClip {
            tableView.setupAdd()
        }
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.editCompletion = {[weak self] sender in
            guard let `self` = self, self.viewModel.clipItems.count > 1 else { return }
            sender.isSelected = !sender.isSelected
            self.tableView.isEditing = sender.isSelected
        }
        tableView.addCompletion = {[weak self] sender in
            guard let `self` = self else { return }
            self.addAcion()
        }
    }    
    func addAcion() {
        pause()
        tableView.isEditing = false
        tableView.editButton.isSelected = false
        imagePicker.show(sender: self) {[weak self] (sources) in
            guard let `self` = self else { return }
            self.append(sources: sources)
        }
    }
    func reloadData() {
        if viewModel.clipItems.count <= 1 {
            tableView.editButton.isSelected = false
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.clipItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! AppendEditorCell
        cell.selectionStyle = .none
        let item = viewModel.clipItems[indexPath.row]
        cell.textLabel?.text = "\(item.index)"
        cell.imageView?.image = item.source.coverImage
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.clipItems.count > 1
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        removeClip(index: indexPath.row)
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        DispatchQueue.main.async {
            self.swap(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
}
