//
//  EditorManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/23.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class EditorManager: NSObject {
    let scene: Router.Scene
    let state: EditorState
    private let editor = TUPVEditor()
    // clips
    private(set) var clipItems: [JMClipItem] = []
    lazy var beginClipItem: JMClipItem = {
        return clipItems[0]
    }()
    // 上下文
    lazy var ctx: TUPVEditorCtx = {
        return editor.getContext()
    }()
    private let layerIndex = 100
    lazy var audioLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forAudio: editor.getContext())
    }()
    lazy var videoLayer: TUPVEditorClipLayer = {
        return TUPVEditorClipLayer(forVideo: editor.getContext())
    }()
    public lazy var player: TUPVEditorPlayer = {
        return editor.newPlayer() as! TUPVEditorPlayer
    }()
    /// 画布尺寸
    public let naturalSize = CGSize(width: 800, height: 800)
    init(source items:[JMSource], segue: Router.Scene) {
        scene = segue
        state = .resource
        super.init()
        create(sourceItems: items)
    }
    
    init(drafts path: String, segue: Router.Scene) {
        scene = segue
        state = .draft
        super.init()
        create(draft: path)
    }
}
// MARK: - create editor
extension EditorManager: TUPVEditorEditorModelEditorDelegate {
    /// 素材创建
    private func create(sourceItems: [JMSource]) {
        let config = TUPVEditor_Config()
        config.width = Int(naturalSize.width)
        config.height = Int(naturalSize.height)
        editor.create(with: config)
        
        for (index, source) in sourceItems.enumerated() {
            let item = JMClipItem(index: index, source: source, ctx: editor.getContext())
            printTu(item.debugDescription)
            guard item.valid() else { continue }
            clipItems.append(item)
            audioLayer.add(item.audio, at: item.index)
            videoLayer.add(item.video, at: item.index)
        }
        editor.audioComposition().add(audioLayer, at: layerIndex)
        editor.videoComposition().add(videoLayer, at: layerIndex)
        build()
    }
    /// 草稿创建
    private func create(draft path: String) {
        let editorModel = TUPVEditorEditorModel(string: path)
        let draftModel = TUPVEditorEditorModelEditor(editorModel)
        draftModel.delegate = self
        draftModel.modifyClipPath()
        editor.create(with: editorModel)
        audioLayer = editor.audioComposition().getLayer(layerIndex) as! TUPVEditorClipLayer
        videoLayer = editor.videoComposition().getLayer(layerIndex) as! TUPVEditorClipLayer
        
        for item in videoLayer.getAllClips() {
            let index = item.key.intValue
            if let audioClip = audioLayer.getClip(index), let videoClip = videoLayer.getClip(index) {
                let clipItem = JMClipItem(index: index, audio: audioClip, video: videoClip)
                printTu(clipItem.debugDescription)
                clipItems.append(clipItem)
            }
        }
        build()
    }
    /// Bundle 素材文件地址替换
    func onModifyClipPath(_ path: String, forName name: String, andType type: String) -> String {
        print("onModifyClipPath:" + path + name + type)
        if path.contains("Bundle") {
            let items = path.components(separatedBy: "/").last?.components(separatedBy: ".")
            return Bundle.main.url(forResource: items?.first, withExtension: items?.last)?.absoluteString ?? ""
        }
        if path.contains("Documents") {
            guard let item = path.components(separatedBy: "Documents").last else {return ""}
            return TuFileManager.documents().path + item
        }
        return ""
    }
}
extension EditorManager {
    @discardableResult
    public func build() -> Bool {
        let result = editor.build()
        printResult("build failure", result: result)
        return result
    }
    /// 编辑时长 build后会改变
    public func duration() -> Int {
        editor.getDuration()
    }
    /// 编辑Json
    public func getModel() -> TUPVEditorEditorModel {
        editor.getModel()
    }
    /// 素材列表
    public func getSources() -> [JMSource] {
        clipItems.map {$0.source}
    }
    /// 替换沙盒地址
    public func repleaceSourcePath() {
        for item in clipItems {
            item.fetchPath()
        }
        build()
    }
    /// 创建视频生成器
    public func createProducer() -> TUPVEditorProducer {
        let config = TUPProducer_OutputConfig()
        config.watermark = UIImage.init(named: "sample_watermark")!
        config.watermarkPosition = -1
        config.scale = 0
        let producer = self.editor.newProducer() as! TUPVEditorProducer
        producer.setOutputConfig(config)
        return producer
    }
    /// 销毁视频合成器
    public func destroyProducer() {
        editor.resetProducer()
    }
    /// 销毁
    public func destroy() {
        player.close()
        editor.resetPlayer()
        editor.destroy()
    }
}



/**
 index:
 layer 100
 clip 200
 effect 300
 */
