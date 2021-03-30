//
//  EditorSourceItem.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class EditorSourceItem: NSObject {
    var isSelected = false
    var code: String = ""
    var name: String = ""
    init(code: String, name: String) {
        super.init()
        self.code = code
        self.name = name
    }
    class func audioPitchAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: TUPVEPitchEffect_TYPE_Monster, name: "怪兽"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Uncle, name: "大叔"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Normal, name: "正常"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Girl, name: "女生"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Lolita, name: "萝莉")]
    }
}
class MVSourceItem:EditorSourceItem {
    var group = TuStickerGroup()
}

class RatioSourceItem: EditorSourceItem {
    var width: Int = 16
    var height: Int = 9
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        super.init(code: "", name: "")
        self.isSelected = false
        
    }
    class func all() -> [RatioSourceItem] {
        [RatioSourceItem(width: 16, height: 9),
         RatioSourceItem(width: 3, height: 2),
         RatioSourceItem(width: 4, height: 3),
         RatioSourceItem(width: 1, height: 1),
         RatioSourceItem(width: 3, height: 4),
         RatioSourceItem(width: 2, height: 3),
         RatioSourceItem(width: 9, height: 16)]
    }
}

class ColorAdjustSourceItem: NSObject {
    var code: String = ""
    var title: String = ""
    var properties: [PropertyItem] = []
    class PropertyItem {
        var title: String = ""
        var min: Float = 0
        var max: Float = 1
        var value: Float = 0
        init(title: String = "强度", min: Float = 0) {
            self.title = title
            self.min = min
        }
    }
    init(code: String, values:[NSNumber] = [NSNumber(value: 0),NSNumber(value: 0)]) {
        self.code = code
        switch code {
        case TUPVEColorAdjustEffect_PROP_TYPE_WhiteBalance:
            title = "白平衡"
            properties = [PropertyItem(title: "色温", min: -1), PropertyItem(title: "色彩")]
            properties[0].value = values[0].floatValue
            properties[1].value = values[1].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_HighlightShadow:
            title = "高亮阴影"
            properties = [PropertyItem(title: "高亮"), PropertyItem(title: "阴影")]
            properties[0].value = values[0].floatValue
            properties[1].value = values[1].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_Sharpen:
            title = "锐化"
            properties = [PropertyItem(min: -1)]
            properties[0].value = values[0].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_Brightness:
            title = "亮度"
            properties = [PropertyItem(min: -1)]
            properties[0].value = values[0].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_Contrast:
            title = "对比度"
            properties = [PropertyItem()]
            properties[0].value = values[0].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_Saturation:
            title = "饱和度"
            properties = [PropertyItem(min: -1)]
            properties[0].value = values[0].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_Exposure:
            title = "曝光度"
            self.properties = [PropertyItem(min: -1)]
            properties[0].value = values[0].floatValue
        default:
            self.properties = []
        }
    }
    func valueFormat() ->[NSNumber] {
        properties.compactMap {NSNumber(value: $0.value)}
    }
    class func all() -> [ColorAdjustSourceItem] {
        [ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_WhiteBalance),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_HighlightShadow),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_Sharpen),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_Brightness),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_Contrast),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_Saturation),
         ColorAdjustSourceItem(code: TUPVEColorAdjustEffect_PROP_TYPE_Exposure)]
    }
}

class TransitionSourceItem: EditorSourceItem {
    
    class func all() -> [TransitionSourceItem] {
        [TransitionSourceItem(code: "", name: "无"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Fade, name: "淡化"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_FadeColor, name: "颜色淡化"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_WipeLeft, name: "向左擦除"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_WipeRight, name: "向右擦除"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_WipeUp, name: "向上擦除"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_WipeDown, name: "向下擦除"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_PullLeft, name: "向左滑动"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_PullRight, name: "向右滑动"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_PullUp, name: "向上滑动"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_PullDown, name: "向下滑动"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Swap, name: "交换"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Doorway, name: "开幕"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_CrossZoom, name: "交叉缩放"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_CrossWarp, name: "交叉扭曲"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_PinWheel, name: "风车"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Radial, name: "雷达"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_SimpleZoom, name: "放大"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_DreamyZoom, name: "梦境"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Perlin, name: "褪去"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Circle, name: "圆圈"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_CircleClose, name: "圆圈关闭"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_CircleOpen, name: "圆圈打开"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_LinearBlur, name: "线性模糊"),
         TransitionSourceItem(code: TUPVEditorClipLayer_Transition_NAME_Heart, name: "爱心"),
        ]
    }
}

