//
//  TTSourceManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/28.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import FCFileManager
class TTSourceManager: NSObject {
    
    var bubbleImages:[String] = ["message", "带劲", "快乐水"]
    let bundle: String
    override init() {
        self.bundle = Bundle.main.path(forResource: "TuSDKPulse", ofType: "bundle")!
    }
    func bubble(_ index: Int) -> String? {
        let bubbleIndex = index + 5
        let bubbleName = "bt/lsq_bubble_\(bubbleIndex).bt"
        let bubblePath = bundle + "/" + bubbleName
        let sandboxPath = FCFileManager.pathForDocumentsDirectory(withPath: bubbleName)
        if FCFileManager.existsItem(atPath: sandboxPath) {
            return sandboxPath
        }
        let ret = FCFileManager.copyItem(atPath: bubblePath, toPath: sandboxPath)
        return ret ? sandboxPath : nil
    }
    func bubbleFont() -> String {
        return bundle + "/bubbleFont"
    }
    func textAnimation(code: String) -> String? {
        let bubbleName = "animtext/\(code).at"
        let bubblePath = bundle + "/" + bubbleName
        let sandboxPath = FCFileManager.pathForDocumentsDirectory(withPath: bubbleName)
        if FCFileManager.existsItem(atPath: sandboxPath) {
            return sandboxPath
        }
        let ret = FCFileManager.copyItem(atPath: bubblePath, toPath: sandboxPath)
        return ret ? sandboxPath : nil
    }
}
