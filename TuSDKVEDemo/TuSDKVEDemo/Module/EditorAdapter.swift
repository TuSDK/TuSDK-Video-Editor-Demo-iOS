//
//  EditorAdapter.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/26.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
class EditorAdapter: NSObject, TUPVEditorEditorModelEditorDelegate {
   
    
    
    let editor = TUPVEditor()
    let config = TUPConfig()
    lazy var videoComp: TUPVEditorComposition = {
        return editor.videoComposition()
    }()
    lazy var audioComp: TUPVEditorComposition = {
        return editor.audioComposition()
    }()
    lazy var audioLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forAudio: ctx)
    }()
    lazy var videoLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forVideo: ctx)
    }()
    lazy var producer: TUPVEditorProducer = {
        let item = editor.newProducer() as! TUPVEditorProducer
        item.delegate = self
        return item
    }()
    lazy var ctx: TUPVEditorCtx = {
        return  editor.getContext()
    }()
    lazy var player: TUPVEditorPlayer = {
        return editor.newPlayer() as! TUPVEditorPlayer
    }()
    public var groups: [Group] = []
    public let naturalSize = CGSize(width: 800, height: 800)
    private var ret = true
    public var beginTotalDuration: Int?
    private(set) var maxSideLength = 800
    private var saveCompleted: (()->Void)?
    private var saveURL: URL?
    private var producerState : TUPProducerState = TUPProducerState.END
    
    override init() {
        super.init()
        
        let config = TUPVEditor_Config()
        config.width = Int(naturalSize.width)
        config.height = Int(naturalSize.height)
        let ret = editor.create(with: config)
        printResult("editor create", result: ret)
    }
    
    init(path: String) {
        super.init()
        let model = TUPVEditorEditorModel(string: path)
        
        let modelEditor = TUPVEditorEditorModelEditor(model);
        modelEditor.delegate = self;
        modelEditor.modifyClipPath();
        
        model.dump();
        
        let ret = editor.create(with: model)
        printResult("editor create with editorModel", result: ret)
    }
    
    
    func onModifyClipPath(_ path: String, forName name: String, andType type: String) -> String {
        if path.contains("Bundle") {
            let items = path.components(separatedBy: "/").last?.components(separatedBy: ".")
            return Bundle.main.url(forResource: items?.first, withExtension: items?.last)?.absoluteString ?? ""
        }
        print("onModifyClipPath:" + path + name + type)
        return ""
    }
    
    
    func start(viewModel: SourceViewModel, scene: Navigator.Scene) {
        if  viewModel.state == .image {
            pictures(viewModel: viewModel, isFirst: true)
        } else {
            append(viewModel: viewModel, isFirst: true)
        }
    }
    func startDraft(scene: Navigator.Scene) {
        audioLayer = editor.audioComposition().getAllLayers()[200] as! TUPVEditorClipLayer
        videoLayer = editor.videoComposition().getAllLayers()[200] as! TUPVEditorClipLayer
        groups = []
        for item in videoLayer.getAllClips() {
            let group = Group(editor: editor)
            group.videoClip = item.value
            if let audioClip = audioLayer.getClip(item.key.intValue) {
                group.audioClip = audioClip
            }
            group.videoClipIndex = item.key.intValue
            groups.append(group)
        }
        build()
    }
    deinit {
        printLog("deinit")
    }
    
}
extension EditorAdapter {
    public func getDuration() -> Int {
        return editor.getDuration()
        
    }
    public func getAuidoDuration() ->Int {
        return Int(editor.audioComposition().getStreamInfo()!.duration)
    }
    public func build() {
        let ret = editor.build()
        printResult("editor build", result: ret)
        assert(ret)
    }
    public func destroy() {
        editor.resetPlayer()
        editor.destroy()
    }
    
    /// 多视频拼接
    public func append(viewModel: SourceViewModel, isFirst: Bool = false) {
        clearLayer()
        groups = []
        for (index,item) in viewModel.items.enumerated() {
            let isImage = item.model.state == .picture
            let group = Group(editor: editor, isImage: isImage)
            groups.append(group)
            if isImage {
                let path = TuFileManager.absolute(state: .images, name: item.model.path)
                config.setString(path, forKey: TUPVEImageClip_CONFIG_PATH)
                config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVEImageClip_CONFIG_DURATION)
                config.setNumber(NSNumber(value: imageClipDuration), forKey: TUPVESilenceClip_CONFIG_DURATION)
            } else {
                config.setString(item.model.path, forKey: TUPVEFileClip_CONFIG_PATH)
            }
            
            group.audioClip.setConfig(config)
            ret = group.audioClip.activate() // 参数/文件错误
            printResult("activate audio clip", result: ret)
            audioLayer.add(group.audioClip, at: (index + 1))
            
            group.videoClip.effects().add(group.effect, at: (index + 1))
            group.videoClip.setConfig(config)
            ret = group.videoClip.activate()
            printResult("activate video clip", result: ret)
            group.videoClipIndex = index + 1
            videoLayer.add(group.videoClip, at: (index + 1))
        }
        if isFirst {
            audioComp.add(audioLayer, at: 200)
            videoComp.add(videoLayer, at: 200)
            if let duration = groups[0].videoClip.getStreamInfo()?.duration {
                beginTotalDuration = Int(duration)
            }
        }
        build()
    }
    
    /// 图片合成视频
    public func pictures(viewModel: SourceViewModel, isFirst: Bool = false) {
        clearLayer()
        for (index,item) in viewModel.items.enumerated() {
            let imageClip = TUPVEditorClip(editor.getContext(), withType: TUPVEImageClip_TYPE_NAME)
            let effect = TUPVEditorEffect(editor.getContext(), withType: TUPVECanvasResizeEffect_TYPE_NAME)
            imageClip.effects().add(effect, at: (index + 1) * 20)
            config.setString(TuFileManager.absolute(state: .images, name: item.model.path), forKey: TUPVEImageClip_CONFIG_PATH)
            config.setNumber(NSNumber(value: 3000), forKey: TUPVEImageClip_CONFIG_DURATION)
            imageClip.setConfig(config)
            ret = imageClip.activate()
            printResult("activate image clip", result: ret)
            videoLayer.add(imageClip, at: (index + 1) * 20)
        }
        if isFirst {
            videoComp.add(videoLayer, at: 20)
            var effect = audioComp.effects().getEffect(20)
            if effect == nil {

                effect = TUPVEditorEffect(editor.getContext(), withType: TUPVETrimEffect_AUDIO_TYPE_NAME)
                let config = TUPConfig()
                config.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
                config.setNumber(NSNumber(value: videoComp.getStreamInfo()?.duration ?? 0), forKey: TUPVETrimEffect_CONFIG_END)
                effect!.setConfig(config)
            } else {
                let config = TUPConfig()
                config.setNumber(NSNumber(value: 0), forKey: TUPVETrimEffect_CONFIG_BEGIN)
                config.setNumber(NSNumber(value: videoComp.getStreamInfo()?.duration ?? 0), forKey: TUPVETrimEffect_CONFIG_END)
                effect!.setConfig(config)
            }
            audioComp.effects().add(effect!, at: 20)
            
        
        }
        build()
    }
    
    
    
    ///保存草稿箱
    public func saveToDraft(path: String)
    {
        let model = editor.getModel()
//
//        let savePath = path.components(separatedBy: "file://").last!
//        print("路径 : \(savePath)")
        print("路径 : \(path)")
        
        let saveRet = model.save(path)
        printResult("model save", result: saveRet)
        
    }
    
    
    
    /// 视频保存
    public func saveVideo(completed: (()->Void)?) {
        self.saveCompleted = completed

        DispatchQueue.global().async {
            /**
             导出配置，默认全部导出
             如果导出部分视频则需要配置 rangeStart 和 rangeDuration
             rangeStart ：导出起始时间
             rangeDuration ：导出视频长度
             */
                        
            let config = TUPProducer_OutputConfig()
            config.rangeStart = 0
            config.rangeDuration = -1
            config.watermark = UIImage.init(named: "sample_watermark")!
            config.watermarkPosition = -1
            config.scale = 0
        
            
            let item = self.editor.newProducer() as! TUPVEditorProducer
            item.delegate = self
            self.saveURL = TuFileManager.createURL(state: .drafts, name: String.currentTimestamp + ".mov")
            item.savePath = self.saveURL!.absoluteString
            item.setOutputConfig(config)
            item.open()
            item.start()
        }
    }
    //取消导出
    public func cancelProducter() {
        
        if self.producerState == .DO_START || self.producerState == .WRITING {
            
            self.producer.close()
            self.editor.resetProducer()
            SVProgressHUD.dismiss()
        }
    }
    
    public func clearLayer() {
        clearVideoLayer()
        for key in audioLayer.getAllClips().keys {
            audioLayer.deleteClip(key.intValue)
        }
    }
    private func clearVideoLayer() {
        for key in videoLayer.getAllClips().keys {
            videoLayer.deleteClip(key.intValue)
        }
    }
}
extension EditorAdapter: TUPProducerDelegate{
    func onProducerEvent(_ state: TUPProducerState, withTimestamp ts: Int) {
        self.producerState = state
        if case state = TUPProducerState.END {
            DispatchQueue.main.async {
                self.producer.close()
                TZImageManager.default()?.saveVideo(with: self.saveURL, completion: {[weak self] (asset, error) in
                    guard let `self` = self else { return }
                    if let error = error {
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "保存成功")
                        self.saveCompleted?()
                    }
                })
            }
        }
        if state == .DO_START || state == .WRITING {
            DispatchQueue.main.async {
                SVProgressHUD.showProgress(Float(ts)/Float(self.getDuration()))
            }
        }
    }
}
extension EditorAdapter {
    // MARK: - initialize
    class Group {
        let editor: TUPVEditor
        var audioClip: TUPVEditorClip
        var videoClip: TUPVEditorClip
        var videoClipIndex: Int = 0
        //let effect: TUPVEditorEffect
        lazy var effect: TUPVEditorEffect = {// 视频拼接使用
            return TUPVEditorEffect(editor.getContext(), withType: TUPVECanvasResizeEffect_TYPE_NAME)
        }()
        
        
        
        init(editor: TUPVEditor, isImage: Bool = false) {
            self.editor = editor
            
            if isImage {
                audioClip = TUPVEditorClip(editor.getContext(), withType: TUPVESilenceClip_AUDIO_TYPE_NAME)
                videoClip = TUPVEditorClip(editor.getContext(), withType: TUPVEImageClip_TYPE_NAME)
            } else {
                audioClip = TUPVEditorClip(editor.getContext(), withType: TUPVEFileClip_AUDIO_TYPE_NAME)
                videoClip = TUPVEditorClip(editor.getContext(), withType: TUPVEFileClip_VIDEO_TYPE_NAME)
            }
        }
    }
}

