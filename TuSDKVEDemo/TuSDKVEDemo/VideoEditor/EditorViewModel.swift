//
//  EditorViewModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/10.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import TuSDKPulse
import TuSDKPulseEditor
import SVProgressHUD
import HandyJSON

// 最小时间间隔ms
let minTimeInterval: Float = 100
let framerate: Float = 25
let editorVideoSize = CGSize(width: 800, height: 800)
class EditorViewModel: NSObject {
    
    public let scene: Navigator.Scene
    public let state: EditorState
    public let editor = TUPVEditor()
    /// 视频尺寸
    public let videoNaturalSize = editorVideoSize
    /// 是否构造过
    public var isBuilt = false
    /// 视频原始时长(ms)
    public var originalDuration: Float = 0
    lazy var ctx: TUPVEditorCtx = {
        return editor.getContext()
    }()
    lazy var mainAudioLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forAudio: ctx)
    }()
    lazy var mainVideoLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forVideo: ctx)
    }()
    let mainLayerIndex = 900
    var clipItems: [VideoClipItem] = []
    
    var producer: TUPVEditorProducer?
    var saveVideoURL: URL?
    private var producerIsCancel = false
    /// 草稿箱初始化
    init(scene: Navigator.Scene, draft path: String) {
        self.state = .draft
        self.scene = scene
        super.init()
        setupDraft(path)
    }
    /// 资源文件初始化
    init(scene: Navigator.Scene, sources: [ResourceModel]) {
        self.state = .resource
        self.scene = scene
        super.init()
        setupResource(sources: sources)
    }
    @discardableResult
    public func build() -> Bool {
        isBuilt = editor.build()
        return isBuilt
    }
    public func getDuration() -> Int {
        editor.getDuration()
    }
    public func getSourceDuration() -> Int {
        if let info = editor.videoComposition().getStreamInfo() {
            return Int(info.duration)
        }
        return getDuration()
    }
    public func clearMainLayer() {
        for key in mainVideoLayer.getAllClips().keys {
            mainVideoLayer.deleteClip(key.intValue)
        }
        for key in mainAudioLayer.getAllClips().keys {
            mainAudioLayer.deleteClip(key.intValue)
        }
        clipItems = []
    }
    public func destroy() {
        editor.resetPlayer()
        editor.destroy()
    }
}
// MARK: - 相册资源
extension EditorViewModel {
    func setupResource(sources: [ResourceModel]) {
        let editorConfig = TUPVEditor_Config()
        editorConfig.width = Int(videoNaturalSize.width)
        editorConfig.height = Int(videoNaturalSize.height)
        //editorConfig.framerate = Double(framerate)
        editor.create(with: editorConfig)
        for (index, item) in sources.enumerated() {
            let clipItem = VideoClipItem(ctx: ctx, source: item, index: index)
            /// 拼接
            let appendEffect = TUPVEditorEffect(ctx, withType: TUPVECanvasResizeEffect_TYPE_NAME)
            var appendEffectIndex = clipItem.index
            if scene == .color { // CanvasResizeEffect 需添加 ColorAdjustEffect 之后
                appendEffectIndex = clipItem.index + 4000
            }
            if scene != .matte {
                clipItem.videoClip.effects().add(appendEffect, at: appendEffectIndex)
            }
            
            mainAudioLayer.add(clipItem.audioClip, at: clipItem.index)
            mainVideoLayer.add(clipItem.videoClip, at: clipItem.index)
            clipItems.append(clipItem)
        }
        editor.audioComposition().add(mainAudioLayer, at: mainLayerIndex)
        editor.videoComposition().add(mainVideoLayer, at: mainLayerIndex)
        
        build()
        originalDuration = Float(editor.getDuration())
        print("视频时长：",originalDuration)
    }
}
// MARK: - 草稿箱
extension EditorViewModel: TUPVEditorEditorModelEditorDelegate {
    func setupDraft(_ path: String) {
        let editorModel = TUPVEditorEditorModel(string: path)
        let draftModel = TUPVEditorEditorModelEditor(editorModel)
        draftModel.delegate = self
        draftModel.modifyClipPath()
        editor.create(with: editorModel)
        mainVideoLayer = editor.videoComposition().getLayer(mainLayerIndex) as! TUPVEditorClipLayer
        mainAudioLayer = editor.audioComposition().getLayer(mainLayerIndex) as! TUPVEditorClipLayer
        for item in mainVideoLayer.getAllClips() {
            let index = item.key.intValue
            if let videoClip = mainVideoLayer.getClip(index), let audioClip = mainAudioLayer.getClip(index) {
                let clipItem = VideoClipItem(index: index, audioClip: audioClip, videoClip: videoClip)
                clipItems.append(clipItem)
            }
        }
        build()
        originalDuration = Float(editor.getDuration())
        print("视频时长：",originalDuration)
    }
    /// Bundle资源文件地址替换
    func onModifyClipPath(_ path: String, forName name: String, andType type: String) -> String {
        print("onModifyClipPath:" + path + name + type)
        if path.contains("Bundle") {
            let items = path.components(separatedBy: "/").last?.components(separatedBy: ".")
            return Bundle.main.url(forResource: items?.first, withExtension: items?.last)?.absoluteString ?? ""
        }
        if path.contains(TuFileManager.State.resource.rawValue) {
            guard let item = path.components(separatedBy: "/").last else {return ""}
            return TuFileManager.absolute(state: .resource, name: item)
        }
        return ""
    }
    
}
// MARK: - 保存视频
extension EditorViewModel: TUPProducerDelegate {
    /// 保存相册
    public func saveToAlbum() {
        DispatchQueue.global().async {
            let config = TUPProducer_OutputConfig()
            config.watermark = UIImage.init(named: "sample_watermark")!
            config.watermarkPosition = -1
            config.scale = 0
            let sandboxURL = TuFileManager.createURL(state: .video, name: String.currentTimestamp + ".mov")
            
            let producer = self.editor.newProducer() as! TUPVEditorProducer
            producer.delegate = self
            producer.savePath = sandboxURL.absoluteString
            producer.setOutputConfig(config)
            producer.open()
            producer.start()
            
            self.producer = producer
            self.producerIsCancel = false
            self.saveVideoURL = sandboxURL
        }
    }
    func onProducerEvent(_ state: TUPProducerState, withTimestamp ts: Int) {
        
        switch state {
        case .DO_START, .WRITING:
            DispatchQueue.main.async {
                if !self.producerIsCancel, state != .END {
                    SVProgressHUD.showProgress(Float(ts)/Float(self.editor.getDuration()))
                }
            }
        case .END:
            if producerIsCancel {
                removeTempFile()
                SVProgressHUD.dismiss()
                return
            }
            ImagePicker.saveVideo(saveVideoURL) {[weak self] (success, msg) in
                guard let `self` = self else { return }
                SVProgressHUD.showSuccess(success, text: msg)
                self.removeTempFile()
                self.resetProducer()
            }
        default:
            break
        }
    }
    
    func resetProducer(isCancel: Bool = false) {
        guard let _ = producer else { return }
        producerIsCancel = isCancel
        producer?.close()
        editor.resetProducer()
        producer = nil
    }
    func removeTempFile() {
        TuFileManager.remove(path: saveVideoURL?.path)
        saveVideoURL = nil
        NotificationCenter.default.post(name: .init("saveAlbumFinished"), object: nil)
    }
}

