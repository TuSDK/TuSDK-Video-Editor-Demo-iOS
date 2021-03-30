//
//  DraftManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/15.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
let kDraft_UD_Key = "TuSDKDemo_Draft"
let kDraft_VideoMap_UD_Key = "TuSDKDemo_Draft_VideoMap"

class DraftManager {
    static let shared = DraftManager()
    var items: [EditorDraftModel] = []
    var map: [String: [String]] = [:]
    let lock = NSLock()
    init() {
        items = loadList().compactMap { EditorDraftModel.deserialize(from: $0) }
        if let item = UserDefaults.standard.value(forKey: kDraft_VideoMap_UD_Key) as? [String: [String]] {
            map = item
        }
    }
}
extension DraftManager {
    public func save(viewModel: EditorViewModel) -> Bool {
        let draftModel = EditorDraftModel(scene: viewModel.scene)
        let model = viewModel.editor.getModel()
        let saveRet = model.save(draftModel.absoluteFile)
        if saveRet {
            var sources:[String] = []
            for clipItem in viewModel.clipItems {
                let filename = clipItem.source.filename
                var arrs = map[filename] ?? []
                arrs.append(draftModel.fileName)
                map[filename] = arrs
                sources.append(filename)
            }
            draftModel.sources = sources
            append(model: draftModel)
            updateMap()
        }
        return saveRet
    }
    public func clearSandboxVideo(viewModel: EditorViewModel) {
        for clipItem in viewModel.clipItems {
            let filename = clipItem.source.filename
            let arrs = map[filename] ?? []
            if arrs.count == 0, !filename.contains("reverse_") {
                TuFileManager.remove(state: .resource, name: filename)
            }
        }
    }
    public func clearSandboxVideo(clipItem: VideoClipItem) {
        let filename = clipItem.source.filename
        let arrs = map[filename] ?? []
        if arrs.count == 0 {
            TuFileManager.remove(state: .resource, name: filename)
        }
    }
    public func remove(at index: Int) {
        lock.lock()
        let model = items[index]
        TuFileManager.remove(state: .drafts, name: model.fileName)
        for source in items[index].sources {
            if var arrs = map[source] {
                if let index = arrs.firstIndex(of: model.fileName) {
                    arrs.remove(at: index)
                }
                map[source] = arrs
                if arrs.count == 0 {
                    TuFileManager.remove(state: .resource, name: source)
                }
            }
        }
        items.remove(at: index)
        updateItems()
        updateMap()
        lock.unlock()
    }
    public func clear() {
        items = []
        map = [:]
        updateItems()
        updateMap()
        TuFileManager.remove(state: .resource)
        TuFileManager.remove(state: .drafts)
    }
    func append(model: EditorDraftModel) {
        lock.lock()
        items.insert(model, at: 0)
        updateItems()
        lock.unlock()
    }
    private func loadList() -> [String] {
        if let arrs = UserDefaults.standard.array(forKey: kDraft_UD_Key) as? [String] {
             return arrs
        }
        return []
    }
    private func updateItems() {
        let arrs = items.compactMap { $0.toJSONString() }
        UserDefaults.standard.setValue(arrs, forKey: kDraft_UD_Key)
        UserDefaults.standard.synchronize()
    }
    private func updateMap() {
        printLog(map)
        UserDefaults.standard.setValue(map, forKey: kDraft_VideoMap_UD_Key)
        UserDefaults.standard.synchronize()
    }
}

extension DraftManager {
    public func path(filename: String) -> String {
        TuFileManager.path(state: .drafts, name: filename)
    }
}
