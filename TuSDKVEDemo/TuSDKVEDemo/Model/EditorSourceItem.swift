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
    
    init(code: String, name: String, isSelected: Bool = false) {
        super.init()
        self.code = code
        self.name = name
        self.isSelected = isSelected
    }
    
    class func audioPitchAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: TUPVEPitchEffect_TYPE_Monster, name: "怪兽"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Uncle, name: "大叔"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Normal, name: "正常"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Girl, name: "女生"),
         EditorSourceItem(code: TUPVEPitchEffect_TYPE_Lolita, name: "萝莉")]
    }
}
class EditorSourceImageItem: EditorSourceItem {
    var imageName: String = ""
    
    init(code: String, name: String, imageName: String, isSelected: Bool = false) {
        super.init(code: code, name: name, isSelected: isSelected)
        self.imageName = imageName
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
            properties = [PropertyItem(title: "色温", min: -1), PropertyItem(title: "色彩", min: -1)]
            properties[0].value = values[0].floatValue
            properties[1].value = values[1].floatValue
        case TUPVEColorAdjustEffect_PROP_TYPE_HighlightShadow:
            title = "高亮阴影"
            properties = [PropertyItem(title: "高亮", min: -1), PropertyItem(title: "阴影", min: -1)]
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
            properties = [PropertyItem(min: -1)]
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

class TTBlendSourceItem: EditorSourceItem {
    class func all() -> [TTBlendSourceItem] {
        [TTBlendSourceItem(code: TUPVEditorLayerBlendMode_None, name: "无"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Normal, name: "正常"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Overlay, name: "叠加"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Add, name: "相加"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Subtract, name: "减去"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Negation, name: "反色"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Average, name: "均值"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Multiply, name: "正片叠底"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Difference, name: "差值"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Screen, name: "滤色"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Softlight, name: "柔光"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Hardlight, name: "强光"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Linearlight, name: "线性光"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Pinlight, name: "点亮"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Lighten, name: "变亮"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Darken, name: "变暗"),
         TTBlendSourceItem(code: TUPVEditorLayerBlendMode_Exclusion, name: "排除"),
        ]
    }
}

class TTTextSourceItem: EditorSourceItem {
    enum State: String {
        case add = "新增"
        case animation = "动画"
        case shadow = "阴影"
        case color = "颜色"
        case opacity = "不透明度"
        case stroke = "描边"
        case background = "背景"
        case space = "间距"
        case align = "对齐"
        case order = "排列"
        case style = "样式"
        case blend = "混合模式"
    }
    
    var state: State = .color
    init(code: String, state: State) {
        super.init(code: code, name: state.rawValue)
        self.state = state
    }
    override init(code: String, name: String, isSelected: Bool = false) {
        super.init(code: code, name: name)
    }
    class func all() -> [TTTextSourceItem] {
        [TTTextSourceItem(code: "edit_ic_add", state: .add),
         TTTextSourceItem(code: "mix_movement_ic", state: .animation),
         TTTextSourceItem(code: "txt_shadow_ic", state: .shadow),
         TTTextSourceItem(code: "edit_ic_colour", state: .color),
         TTTextSourceItem(code: "t_ic_transparency", state: .opacity),
         TTTextSourceItem(code: "t_ic_stroke", state: .stroke),
         TTTextSourceItem(code: "t_ic_bg", state: .background),
         TTTextSourceItem(code: "t_ic_space", state: .space),
         TTTextSourceItem(code: "t_ic_align", state: .align),
         TTTextSourceItem(code: "t_ic_array", state: .order),
         TTTextSourceItem(code: "edit_ic_style", state: .style),
         TTTextSourceItem(code: "t_ic_transparency", state: .blend)]
    }
    class func alignAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: "edit_text_ic_left", name: "左对齐"),
         EditorSourceItem(code: "edit_text_ic_center", name: "居中对齐"),
         EditorSourceItem(code: "edit_text_ic_right", name: "右对齐")]
    }
    class func orderAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: "edit_text_ic_smooth", name: "正常"),
         EditorSourceItem(code: "edit_text_ic_inverse", name: "倒转")]
    }
    class func styleAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: "t_ic_nor_nor", name: "正常"),
         EditorSourceItem(code: "t_ic_underline_nor", name: "下划线")]
    }
    class func animationStateAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: "", name: "进入动画", isSelected: true),
         EditorSourceItem(code: "", name: "退出动画"),
         EditorSourceItem(code: "", name: "整体动画")]
    }
    class func animationInAll() -> [EditorSourceItem] {
        [EditorSourceItem(code: "lsq_animation_text_0", name: "无", isSelected: true),
         EditorSourceItem(code: "lsq_animation_text_1", name: "模糊"),
         EditorSourceItem(code: "lsq_animation_text_2", name: "波浪弹入"),
         EditorSourceItem(code: "lsq_animation_text_3", name: "螺旋上升"),
         EditorSourceItem(code: "lsq_animation_text_4", name: "收拢"),
         EditorSourceItem(code: "lsq_animation_text_5", name: "弹弓"),
         EditorSourceItem(code: "lsq_animation_text_6", name: "空翻"),
         EditorSourceItem(code: "lsq_animation_text_7", name: "弹性伸缩"),
         EditorSourceItem(code: "lsq_animation_text_8", name: "弹簧"),
         EditorSourceItem(code: "lsq_animation_text_9", name: "渐显"),
         EditorSourceItem(code: "lsq_animation_text_10", name: "生长"),
         EditorSourceItem(code: "lsq_animation_text_11", name: "轻微放大"),
         EditorSourceItem(code: "lsq_animation_text_12", name: "缩小"),
         EditorSourceItem(code: "lsq_animation_text_13", name: "放大"),
         EditorSourceItem(code: "lsq_animation_text_14", name: "随机飞入"),
         EditorSourceItem(code: "lsq_animation_text_15", name: "旋入"),
         EditorSourceItem(code: "lsq_animation_text_16", name: "旋转飞人"),
         EditorSourceItem(code: "lsq_animation_text_17", name: "打字机1"),
         EditorSourceItem(code: "lsq_animation_text_18", name: "打字机2"),
         EditorSourceItem(code: "lsq_animation_text_19", name: "打字机3"),
         EditorSourceItem(code: "lsq_animation_text_20", name: "向左移动"),
         EditorSourceItem(code: "lsq_animation_text_21", name: "向右移动"),
         EditorSourceItem(code: "lsq_animation_text_22", name: "向上移动"),
         EditorSourceItem(code: "lsq_animation_text_23", name: "向下移动"),
         EditorSourceItem(code: "lsq_animation_text_24", name: "向左擦除"),
         EditorSourceItem(code: "lsq_animation_text_25", name: "向右擦除"),
         EditorSourceItem(code: "lsq_animation_text_26", name: "向上擦除"),
         EditorSourceItem(code: "lsq_animation_text_27", name: "向下擦除"),
         EditorSourceItem(code: "lsq_animation_text_28", name: "羽化向左擦开"),
         EditorSourceItem(code: "lsq_animation_text_29", name: "羽化向右擦开"),
         EditorSourceItem(code: "lsq_animation_text_30", name: "开幕"),
         EditorSourceItem(code: "lsq_animation_text_31", name: "羽化竖直线性擦除"),
         EditorSourceItem(code: "lsq_animation_text_32", name: "向左辐射擦除"),
         EditorSourceItem(code: "lsq_animation_text_33", name: "向右辐射擦除"),
         EditorSourceItem(code: "lsq_animation_text_34", name: "弹入"),
         EditorSourceItem(code: "lsq_animation_text_84", name: "爱心弹跳"),
         EditorSourceItem(code: "lsq_animation_text_85", name: "音符弹跳")
        ]
    }
    class func animationOutAll() -> [EditorSourceItem] {
        [
            EditorSourceItem(code: "lsq_animation_text_0", name: "无", isSelected: true),
            EditorSourceItem(code: "lsq_animation_text_35", name: "模糊"),
            EditorSourceItem(code: "lsq_animation_text_36", name: "波浪弹出"),
            EditorSourceItem(code: "lsq_animation_text_37", name: "螺旋下降"),
            EditorSourceItem(code: "lsq_animation_text_38", name: "展开"),
            EditorSourceItem(code: "lsq_animation_text_39", name: "弹弓"),
            EditorSourceItem(code: "lsq_animation_text_40", name: "空翻"),
            EditorSourceItem(code: "lsq_animation_text_41", name: "弹性伸缩"),
            EditorSourceItem(code: "lsq_animation_text_42", name: "弹簧"),
            EditorSourceItem(code: "lsq_animation_text_43", name: "渐隐"),
            EditorSourceItem(code: "lsq_animation_text_44", name: "生长"),
            EditorSourceItem(code: "lsq_animation_text_45", name: "轻微放大"),
            EditorSourceItem(code: "lsq_animation_text_46", name: "缩小"),
            EditorSourceItem(code: "lsq_animation_text_47", name: "放大"),
            EditorSourceItem(code: "lsq_animation_text_48", name: "随机飞出"),
            EditorSourceItem(code: "lsq_animation_text_49", name: "旋出"),
            EditorSourceItem(code: "lsq_animation_text_50", name: "旋转飞出"),
            EditorSourceItem(code: "lsq_animation_text_51", name: "打字机1"),
            EditorSourceItem(code: "lsq_animation_text_52", name: "打字机2"),
            EditorSourceItem(code: "lsq_animation_text_53", name: "打字机3"),
            EditorSourceItem(code: "lsq_animation_text_54", name: "向左移动"),
            EditorSourceItem(code: "lsq_animation_text_55", name: "向右移动"),
            EditorSourceItem(code: "lsq_animation_text_56", name: "向上移动"),
            EditorSourceItem(code: "lsq_animation_text_57", name: "向下移动"),
            EditorSourceItem(code: "lsq_animation_text_58", name: "向左擦除"),
            EditorSourceItem(code: "lsq_animation_text_59", name: "向右擦除"),
            EditorSourceItem(code: "lsq_animation_text_60", name: "向上擦除"),
            EditorSourceItem(code: "lsq_animation_text_61", name: "向下擦除"),
            EditorSourceItem(code: "lsq_animation_text_62", name: "羽化向左擦开"),
            EditorSourceItem(code: "lsq_animation_text_63", name: "羽化向右擦开"),
            EditorSourceItem(code: "lsq_animation_text_64", name: "闭幕"),
            EditorSourceItem(code: "lsq_animation_text_65", name: "羽化竖直线性擦除"),
            EditorSourceItem(code: "lsq_animation_text_66", name: "向左辐射擦除"),
            EditorSourceItem(code: "lsq_animation_text_67", name: "向右辐射擦除"),
            EditorSourceItem(code: "lsq_animation_text_68", name: "弹出")
        ]
    }
    class func animationOverall() -> [EditorSourceItem] {
        [
            EditorSourceItem(code: "lsq_animation_text_0", name: "无", isSelected: true),
            EditorSourceItem(code: "lsq_animation_text_69", name: "水平翻转"),
            EditorSourceItem(code: "lsq_animation_text_70", name: "垂直翻转"),
            EditorSourceItem(code: "lsq_animation_text_71", name: "弹幕"),
            EditorSourceItem(code: "lsq_animation_text_72", name: "字幕"),
            EditorSourceItem(code: "lsq_animation_text_73", name: "摇摆"),
            EditorSourceItem(code: "lsq_animation_text_74", name: "钟摆"),
            EditorSourceItem(code: "lsq_animation_text_75", name: "雨刷"),
            EditorSourceItem(code: "lsq_animation_text_76", name: "调皮"),
            EditorSourceItem(code: "lsq_animation_text_77", name: "逐字放大"),
            EditorSourceItem(code: "lsq_animation_text_78", name: "心跳"),
            EditorSourceItem(code: "lsq_animation_text_79", name: "故障闪动"),
            EditorSourceItem(code: "lsq_animation_text_80", name: "闪烁"),
            EditorSourceItem(code: "lsq_animation_text_81", name: "摇荡"),
            EditorSourceItem(code: "lsq_animation_text_82", name: "颤抖"),
            EditorSourceItem(code: "lsq_animation_text_83", name: "跳动")
        ]
    }
}
class TTMosaicSourceItem: EditorSourceItem {
    class func all() -> [TTMosaicSourceItem] {
        [TTMosaicSourceItem(code: TUPVEMosaicEffect_CODE_FILL, name: "马赛克"),
         TTMosaicSourceItem(code: TUPVEMosaicEffect_CODE_ERASER, name: "橡皮擦")]
    }
}

class TTMatteSourceItem: EditorSourceImageItem {
    
    class func all() -> [TTMatteSourceItem] {
        [TTMatteSourceItem(code: "", name: "无", imageName: "mask_matte_close", isSelected: true),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_LINEAR, name: "线性", imageName: "mask_linear_ic"),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_MIRROR, name: "镜面", imageName: "mask_mirror_ic"),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_CIRCLE, name: "圆形", imageName: "mask_radial_ic"),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE, name: "矩形", imageName: "mask_rectangular_ic"),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_LOVE, name: "爱心", imageName: "mask_heart_ic"),
         TTMatteSourceItem(code: TUPVEMatteEffect_CONFIG_TYPE_STAR, name: "星形", imageName: "mask_star_ic")]
    }
}
