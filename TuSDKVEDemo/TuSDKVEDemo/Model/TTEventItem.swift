//
//  TTEventItem.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/28.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
enum TTReverseEvents: String {
    // 气泡文字
    case tjqpwz = "添加气泡文字"
    case schhms = "素材混合模式"
    case scsc = "素材时长"
    
    // 马赛克
    case bc = "笔触"
    case jxk = "矩形框"
    case cx = "撤销"
    
    case back = "返回"
}
let mosaicEventItems:[[TTReverseEvents]] = [[.jxk, .bc], [.jxk, .bc, .cx], [.back], [.back, .cx]]

class TTEventItem: NSObject {
    
}
