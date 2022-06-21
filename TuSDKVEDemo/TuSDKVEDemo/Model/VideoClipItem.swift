//
//  VideoClipItem.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/15.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
let imageClipDuration = 3000
class VideoClipItem {
    var index: Int = 1
    let config: TUPConfig
    let source: ResourceModel
    let audioClip: TUPVEditorClip
    let videoClip: TUPVEditorClip
    
    /// 草稿初始化
    init(index: Int, audioClip: TUPVEditorClip, videoClip: TUPVEditorClip) {
        self.index = index
        config = videoClip.getConfig()
        let sourcePath = config.getString(TUPVEFileClip_CONFIG_PATH)
        self.source = ResourceModel(sandbox: sourcePath)
        self.audioClip = audioClip
        self.videoClip = videoClip
    }
    /// 资源初始化 并设置时间
    init(ctx: TUPVEditorCtx, source: ResourceModel, index: Int, start: Int? = nil, duration: Int? = nil) {
        self.index += index
        self.source = source
        let sourcePath = source.path().absoluteString
        // 使用外部导入绝对路径
//        let sourcePath = source.filename
        config = TUPConfig()
        if source.state == .image {
            audioClip = TUPVEditorClip(ctx, withType: TUPVESilenceClip_AUDIO_TYPE_NAME)
            videoClip = TUPVEditorClip(ctx, withType: TUPVEImageClip_TYPE_NAME)
            config.setString(sourcePath, forKey: TUPVEImageClip_CONFIG_PATH)
            config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVEImageClip_CONFIG_DURATION)
            let audioConfig = TUPConfig()
            audioConfig.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVESilenceClip_CONFIG_DURATION)
            audioClip.setConfig(audioConfig)
        } else if source.state == .gif {
            audioClip = TUPVEditorClip(ctx, withType: TUPVESilenceClip_AUDIO_TYPE_NAME)
            videoClip = TUPVEditorClip(ctx, withType: TUPVEGifClip_TYPE_NAME)
            config.setString(sourcePath, forKey: TUPVEGifClip_CONFIG_PATH)
            config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVEGifClip_CONFIG_DURATION)
            let audioConfig = TUPConfig()
            audioConfig.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVESilenceClip_CONFIG_DURATION)
            audioClip.setConfig(audioConfig)
        } else {
            videoClip = TUPVEditorClip(ctx, withType: TUPVEFileClip_VIDEO_TYPE_NAME)
            audioClip = TUPVEditorClip(ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
            config.setString(sourcePath, forKey: TUPVEFileClip_CONFIG_PATH)
            if let start = start, let duration = duration {
                config.setNumber(NSNumber(value: start), forKey: TUPVEFileClip_CONFIG_TRIM_START)
                config.setNumber(NSNumber(value: duration), forKey: TUPVEFileClip_CONFIG_TRIM_DURATION)
            }
            audioClip.setConfig(config)
        }
        var ret = audioClip.activate()
        printResult("activate audio clip", result: ret)
        
        videoClip.setConfig(config)
        ret = videoClip.activate()
        printResult("activate video clip", result: ret)
    }
    
    /// 编辑过的时长
    func duration() -> Int {
        Int(videoClip.getStreamInfo()?.duration ?? 0)
    }
    /// 素材时长
    func originalDuration() -> Int {
//        if source.state == .image {
//            return imageClipDuration
//        }
//        let streams = TUPMediaInspector.shared().inspect(source.path().absoluteString).streams
//        var duration = 0
//        for item in streams {
//            duration = max(Int(item.duration), duration)
//        }
        return Int(videoClip.getOriginStreamInfo()?.duration ?? 0)
    }
//    func xxDuration() -> Int {
//        let frame = ceil(Float(originalDuration()) / (1000.0/framerate))
//        return Int(ceil(frame * (1000.0/framerate)))
//    }
}
