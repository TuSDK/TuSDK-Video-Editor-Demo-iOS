//
//  JMClipItem.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class JMClipItem: NSObject {
    /// 下标
    public let index: Int
    /// 素材
    public let source: JMSource
    public let audio: TUPVEditorClip
    public let video: TUPVEditorClip
    private var config = TUPConfig()
    private var state: EditorState = .resource
    init(index: Int, source: JMSource, ctx: TUPVEditorCtx) {
        self.index = index + 200
        self.source = source
        
        let sourcePath = source.url.path
        if source.state == .image {
            audio = TUPVEditorClip(ctx, withType: TUPVESilenceClip_AUDIO_TYPE_NAME)
            video = TUPVEditorClip(ctx, withType: TUPVEImageClip_TYPE_NAME)
            // config
            config.setString(sourcePath, forKey: TUPVEImageClip_CONFIG_PATH)
            config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVEImageClip_CONFIG_DURATION)
            config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVESilenceClip_CONFIG_DURATION)
        } else {
            audio = TUPVEditorClip(ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
            video = TUPVEditorClip(ctx, withType: TUPVEFileClip_VIDEO_TYPE_NAME)
            // config
            config.setString(sourcePath, forKey: TUPVEFileClip_CONFIG_PATH)
        }
        audio.setConfig(config)
        video.setConfig(config)
        // 拼接画布适配
        let resizeEffect = TUPVEditorEffect(ctx, withType: TUPVECanvasResizeEffect_TYPE_NAME)
        // resizeEffect index 尽量大于其他 effect index
        video.effects().add(resizeEffect, at: 400)
    }
    /// 有效性
    public func valid() -> Bool {
        let audioValid = audio.activate()
        let videoValid = video.activate()
        if audioValid, videoValid {
            return true
        }
        printTu(debugDescription, "activate failure; video:\(videoValid) audio:\(audioValid)")
        return false
    }
    /// 草稿初始化
    init(index: Int, audio: TUPVEditorClip, video: TUPVEditorClip) {
        self.index = index
        self.audio = audio
        self.video = video
        self.state = .draft
        config = video.getConfig()
        let path = config.getString(TUPVEFileClip_CONFIG_PATH)
        self.source = JMSource(sandbox: path)
    }
    /// 替换素材路径
    public func fetchPath(){
        guard source.state == .video, source.editorState == .resource, source.isReplaced else {return}
        let audioConfig = audio.getConfig()
        audioConfig.setString(source.url.path, forKey: TUPVEFileClip_CONFIG_PATH)
        let videoConfig = video.getConfig()
        printTu("素材地址替换：\(videoConfig.getString(TUPVEFileClip_CONFIG_PATH)) -> \(source.url.path)")
        videoConfig.setString(source.url.path, forKey: TUPVEFileClip_CONFIG_PATH)
        audio.setConfig(audioConfig)
        video.setConfig(videoConfig)
        
    }
    /// 资源时长
    func sourceDuration() -> Int {
        let streams = TUPMediaInspector.shared().inspect(source.url.path).streams
        var duration = 0
        for item in streams {
            duration = max(Int(item.duration), duration)
        }
        return duration
    }
    /// get audio effect
    public func audioEffect(_ idx: Int) -> TUPVEditorEffect? {
        audio.effects().getEffect(idx)
    }
    /// get video effect
    public func videoEffect(_ idx: Int) -> TUPVEditorEffect? {
        video.effects().getEffect(idx)
    }
    @discardableResult
    public func addAudioEffect(_ effect: TUPVEditorEffect, at idx: Int) -> Bool {
        guard audioEffect(idx) == nil else { return true }
        let result = audio.effects().add(effect, at: idx)
        printResult("\(debugDescription) audio effect index: \(idx)", result: result)
        return result
    }
    @discardableResult
    public func addVideoEffect(_ effect: TUPVEditorEffect, at idx: Int) -> Bool {
        guard videoEffect(idx) == nil else { return true }
        let result = video.effects().add(effect, at: idx)
        printResult("\(debugDescription) video effect index: \(idx)", result: result)
        return result
    }
    override var debugDescription: String {
        return "clipItem state:\(state.rawValue), filename: \(source.filename), index:\(index)"
    }
}
