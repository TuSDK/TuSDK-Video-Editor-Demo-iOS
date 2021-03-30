//
//  EditorDraftModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import HandyJSON

class EditorDraftModel: HandyJSON {
    required init() {}
    /// 文件名
    var fileName: String = ""
    /// 绝对路径
    var absoluteFile: String = ""
    /// 资源文件
    var sources:[String] = []
    var scene: String = ""
    var fileTime: String = ""
    
    init(scene: Navigator.Scene) {
        let date = Date()
        let timeStamp = Int(date.timeIntervalSince1970)
        let outPutFileName = "editor_draft\(timeStamp)"
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        let savePath = TuFileManager.createURL(state: .drafts, name: outPutFileName).path
        print("草稿箱路径 : \(savePath)")
        self.scene = scene.rawValue
        self.fileName = outPutFileName
        self.fileTime = dateformatter.string(from: date)
        self.absoluteFile = savePath
    }
}
