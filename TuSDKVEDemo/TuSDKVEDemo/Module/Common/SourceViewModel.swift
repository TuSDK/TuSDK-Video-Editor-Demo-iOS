//
//  SourceViewModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/26.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import HandyJSON
import Photos
class SourceViewModel: NSObject, NSCoding {
    struct Item: Identifiable {
        var id: Int = 0
        var model = SourceModel()
    }
    public var items: [Item] = []
    public var state: ImagePicker.State = .video
    public var totalCount = 0
    init(sources: [SourceModel], state: ImagePicker.State = .video) {
        for (index,value) in sources.enumerated() {
            items.append(Item(id: index + 1, model: value))
            totalCount += 1
        }
        self.state = state
    }
    public func remove(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
    }
    public func swapAt(_ i: Int, _ j: Int) {
        guard i < items.count, j < items.count else { return }
        let sourceItem = items[i]
        items.remove(at: i)
        items.insert(sourceItem, at: j)
//        (items[i], items[j]) = (items[j], items[i])
    }
    public func append(contentsOf newElements: [Item]) {
        let startIndex = totalCount
        for (index,var item) in newElements.enumerated() {
            item.id = (index + 1) + startIndex
            items.append(item)
            totalCount += 1
        }
    }
    func encode(with coder: NSCoder) {
        coder.encode(items, forKey: "items")
        coder.encode(state, forKey: "state")
        coder.encode(totalCount, forKey: "totalCount")
    }
    
    required init?(coder: NSCoder) {
        items = coder.decodeObject(forKey: "items") as! [SourceViewModel.Item]
        state = coder.decodeObject(forKey: "state") as! ImagePicker.State
        totalCount = coder.decodeObject(forKey: "totalCount") as! Int
    }
}



