//
//  DraftsManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

let kDrafts_UD_Key = "TuSDKDemo_Drafts"
/// 草稿箱管理
class DraftsManager: NSObject {
    static let shared = DraftsManager()
    private(set) var items: [JMDraft] = []
    private let lock = NSLock()
    override init() {
        super.init()
        if let arrs = UserDefaults.standard.array(forKey: kDrafts_UD_Key) as? [String] {
            items = arrs.compactMap {JMDraft.deserialize(from: $0)}
        }
    }
    /// 新增
    public func append(_ draft: JMDraft) {
        lock.lock()
        items.insert(draft, at: 0)
        fetch()
        lock.unlock()
    }
    /// 移除
    public func remove(at index: Int) {
        lock.lock()
        items.remove(at: index)
        fetch()
        lock.unlock()
    }
    /// 清空草稿箱列表
    public func clear() {
        items = []
        fetch()
    }
    /// 更新UD
    private func fetch() {
        printTu("update Drafts", items.map {$0.debugDescription})
        let arrs = items.compactMap { $0.toJSONString() }
        UserDefaults.standard.setValue(arrs, forKey: kDrafts_UD_Key)
        UserDefaults.standard.synchronize()
    }
}
