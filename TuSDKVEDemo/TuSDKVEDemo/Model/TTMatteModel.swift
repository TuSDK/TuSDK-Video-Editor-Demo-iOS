//
//  TTMatteModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import HandyJSON

let kDefaultMatteScale: Float = 0.35
class TTMatteModel: HandyJSON {
    var posX: Float = 0
    var posY: Float = 0
    var rotate: Float = 0 //-270*Double.pi/180
    var invert: Bool = false
    var diff: Float = 0
    var scale: Float = kDefaultMatteScale
    var scaleX: Float = kDefaultMatteScale
    var scaleY: Float = kDefaultMatteScale
    var radius: Float = 0
    required init() {}
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.posX <-- "center-x"
        mapper <<<
            self.posY <-- "center-y"
        mapper <<<
            self.scaleX <-- "size-x"
        mapper <<<
            self.scaleY <-- "size-y"
    }
    func dictionary() -> NSMutableDictionary {
        guard let dict = toJSON() else {return NSMutableDictionary()}
        print("Matte values: \(dict)")
        return NSMutableDictionary(dictionary: dict)
    }
    func native2Pulse(posX: Float, posY: Float) {
        self.posX = posX * 2 - 1
        self.posY = (1-posY) * 2 - 1
//        print("Matte native2PulseY",posY, self.posY)
//        print("Matte native2PulseX",posX, self.posX)
    }
    func nativePosX() -> CGFloat {
        //print("Matte pulse2NativeX",posX, CGFloat(posX + 1)/2)
        return CGFloat(posX + 1)/2
    }
    func nativePosY() -> CGFloat {
        //print("Matte pulse2NativeY",posY, 1 - CGFloat((posY + 1)/2))
        return 1 - CGFloat((posY + 1)/2)
    }
    
}
/**
 线性: center-x center-y rotate diff invert
 镜像: center-x center-y rotate diff invert scale
 圆形: center-x center-y rotate diff invert size-x size-y
 矩形: center-x center-y rotate diff invert size-x size-y radius
 爱心: center-x center-y rotate diff invert size-x size-y
 */
