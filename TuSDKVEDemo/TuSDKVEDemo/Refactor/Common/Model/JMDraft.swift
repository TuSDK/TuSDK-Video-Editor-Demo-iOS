//
//  JMDraft.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import HandyJSON

class JMDraft: HandyJSON {
    required init() {}
    /// 场景
    var scene: String = ""
    /// 唯一标识
    var name: String = ""
    /// 格式化时间
    var time: String = ""
    /// 使用所有素材文件
    var sources: Set<String> = []
    init(scene: Router.Scene) {
        let date = Date()
        let timeStamp = Int(date.timeIntervalSince1970)
        let fileName = "editor_draft\(timeStamp)"
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        self.scene = scene.rawValue
        self.name = fileName
        self.time = dateformatter.string(from: date)
    }
    /// 添加依赖素材
    func appendSource(clipItem: [JMClipItem]) {
        for item in clipItem {
            sources.insert(item.source.filename)
        }
    }
    /// 草稿箱JSON路径
    func url() -> URL {
        TuFileManager.createURL(state: .drafts, name: name)
    }
    var debugDescription: String {
        return "Draft scene:\(scene), name: \(name), time:\(time), sources:\(sources)"
    }
}
