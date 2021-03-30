//
//  ResourceManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/23.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

let kResourceSideTable_UD_Key = "TuSDKDemo_ResourceSideTable"
/// 素材管理
class ResourceManager: NSObject {
    static let shared = ResourceManager()
    typealias Completion = (EditorManager)->Void
    private let imagePicker = ImagePickerManager()
    /// 素材引用计数表
    private var sideTable:[String: Int] = [:]
    private let lock = NSLock()
    override init() {
        super.init()
        if let dict = UserDefaults.standard.dictionary(forKey: kResourceSideTable_UD_Key) as? [String: Int] {
            sideTable = dict
        }
    }
    /// 相册选择素材
    public func showImagePicker(segue: Router.Scene, sender: UIViewController?, completion: Completion?) {
        imagePicker.show(segue: segue, sender: sender) { (items) in
            let adapter = EditorManager(source: items, segue: segue)
            completion?(adapter)
        }
    }
    /// 相册素材保存至沙盒
    public func repleace(adapter: EditorManager, completion:(()->Void)?) {
        imagePicker.writeData(clipItems: adapter.clipItems, completion: {isReplaced in
            if isReplaced {
                adapter.repleaceSourcePath()
            }
            completion?()
        })
    }
}
// MARK: - 引用计数
extension ResourceManager {
    /// 移除草稿 更新引用计数
    public func remove(at draft: JMDraft) {
        printTu("草稿素材：",draft.sources)
        lock.lock()
        for filename in draft.sources {
            releasePointer(tagged: filename)
        }
        fetch()
        lock.unlock()
    }
    
    /// 更新引用计数
    func taggedPointer(adapter: EditorManager) {
        lock.lock()
        for item in adapter.clipItems {
            guard item.source.isReplaced else { continue }
            retainPointer(tagged: item.source.filename)
        }
        fetch()
        lock.unlock()
    }
    
    /// 引用计数 +1
    private func retainPointer(tagged: String) {
        if var count = sideTable[tagged] {
            count += 1
            sideTable[tagged] = count
        } else {
            sideTable[tagged] = 1
        }
    }
    /// 引用计数 -1
    private func releasePointer(tagged: String) {
        guard var count = sideTable[tagged] else { return }
        count = count == 1 ? 0 : (count - 1)
        sideTable[tagged] = count
        if count == 0 {
            TuFileManager.remove(state: .drafts, name: tagged)
        }
    }
    /// 清空引用计数表
    public func clear() {
        sideTable = [:]
        fetch()
    }
    /// 更新UD
    private func fetch() {
        printTu("update sideTable", sideTable)
        UserDefaults.standard.setValue(sideTable, forKey: kResourceSideTable_UD_Key)
        UserDefaults.standard.synchronize()
    }
}
