//
//  DraftModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/15.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import HandyJSON
class DraftModel: HandyJSON {
    required init() {}
    var items: [DraftListModel] = []
    var map: [String: [String]] = [:]
}


class DraftListModel: HandyJSON {
    var fileName: String = ""
    var scene: String = ""
    var fileTime: String = ""
    
    init(segue: Navigator.Scene) {
        let date = Date()
        let timeStamp = Int(date.timeIntervalSince1970)
        let outPutFileName = "editor_draft\(timeStamp)"
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        scene = segue.rawValue
        fileName = outPutFileName
        fileTime = dateformatter.string(from: date)
    }
    func url() -> URL {
        TuFileManager.createURL(state: .drafts, name: fileName)
    }
    required init() {}
}
