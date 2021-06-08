//
//  GraffitiController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/8.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

let startIndex = 10000
class GraffitiController: EditorBaseController {

    class GraffitiItem {
        let index: Int
        let clip: TUPVEditorClip
        let clipLayer: TUPVEditorClipLayer
        var color = UIColor.blue
        var width: Float = 2
        var info = TUPVEGraffitiClip_PathInfo()
        var pathIndex = -1
        var start: Int = 0
        var duration: Int = 0
        lazy var builder: TUPVEGraffitiClip_PropertyBuilder = {
            return TUPVEGraffitiClip_PropertyBuilder()
        }()
        init(index: Int, ctx: TUPVEditorCtx) {
            self.index = index
            self.clipLayer = TUPVEditorClipLayer(forVideo: ctx)
            self.clip = TUPVEditorClip(ctx, withType: TUPVEGraffitiClip_TYPE_NAME)
        }
        init(index: Int, clipLayer: TUPVEditorClipLayer, clip: TUPVEditorClip) {
            self.index = index
            self.clipLayer = clipLayer
            self.clip = clip
        }
        
        func update(start: Int, duration: Int) {
            self.start = start
            self.duration = duration
            let layerConfig = clipLayer.getConfig()
            layerConfig.setIntNumber(start, forKey: TUPVEditorLayer_CONFIG_START_POS)
            clipLayer.setConfig(layerConfig)
            
            let config = clip.getConfig()
            config.setIntNumber(duration, forKey: TUPVEGraffitiClip_CONFIG_DURATION)
            clip.setConfig(config)
            if clipLayer.getClip(200) == nil {
                clipLayer.add(clip, at: 200)
            }
        }
        func append(point: CGPoint) {
            pathIndex += 1
            info = TUPVEGraffitiClip_PathInfo()
            info.points.add(NSValue(cgPoint: point))
            info.color = color
            info.width = Double(width)
            info.index = Int32(pathIndex)
            builder.holder.paths.add(info)
            
            clip.setProperty(builder.makeAppendProperty(Double(point.x), posY: Double(point.y), color: color, width: Double(width), index: Int32(pathIndex)), forKey: TUPVEGraffitiClip_PROP_APPEND_PARAM)
        }
        func move(point: CGPoint) {
            info.points.add(NSValue(cgPoint: point))
            clip.setProperty(builder.makeExtendProperty(Double(point.x), posY: Double(point.y), index: Int32(pathIndex)), forKey: TUPVEGraffitiClip_PROP_EXTEND_PARAM)
        }
        func end() {
            clip.setProperty(builder.makeDeleteProperty(Int32(pathIndex)), forKey: TUPVEGraffitiClip_PROP_DELETE_PARAM)
            clip.setProperty(builder.makeProperty(), forKey: TUPVEGraffitiClip_PROP_PARAM)
        }
        func revoke() {
            guard builder.holder.paths.count > 0 else { return }
            builder.holder.paths.removeLastObject()
            clip.setProperty(builder.makeDeleteProperty(Int32(pathIndex)), forKey: TUPVEGraffitiClip_PROP_DELETE_PARAM)
            clip.setProperty(builder.makeProperty(), forKey: TUPVEGraffitiClip_PROP_PARAM)
            pathIndex -= 1
        }
    }
    var layerIndex: Int = startIndex
    private var currentItem: GraffitiItem?
    private var items:[GraffitiItem] = []
    private var revokeIndexs:[Int] = []
    private let barView = SliderBarView(title: "涂鸦起止位置", state: .multi)
    private let colorBarView = SliderBarView(title: "颜色", state: .color)
    private let widthBarView = SliderBarView(title: "大小", state: .native)
    private let drawButton = UIButton()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        if viewModel.state == .draft {
            let layers = viewModel.editor.videoComposition().getAllLayers()
            for layerDict in layers {
                guard let _ = layerDict.value as? TUPVEditorClipLayer else { continue }
                let index = layerDict.key.intValue
                guard let layer = layerDict.value as? TUPVEditorClipLayer, let clip = layer.getClip(200), clip.getType() == TUPVEGraffitiClip_TYPE_NAME else { continue }
                if index > layerIndex {
                    layerIndex = index
                }
                let item = GraffitiItem(index: index, clipLayer: layer, clip: clip)
                items.insert(item, at: 0)
                if let prop = clip.getProperty(TUPVEGraffitiClip_PROP_PARAM) {
                    let holder = TUPVEGraffitiClip_PropertyHolder(property: prop)
                    item.builder = TUPVEGraffitiClip_PropertyBuilder(holder: holder)
                    item.pathIndex = holder.paths.count - 1
                    for _ in holder.paths {
                        revokeIndexs.append(index)
                    }
                }
            }
            revokeIndexs = revokeIndexs.sorted {$0 < $1}
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    private func addItem() {
        fetchLock()
        defer {
            fetchUnlockToSeekTime(currentTs)
        }
        layerIndex += 1
        let item = GraffitiItem(index: layerIndex, ctx: viewModel.ctx)
        
        let begin = Float(currentTs)/viewModel.originalDuration
        barView.multiSlider.value[0] = CGFloat(begin)
        let convert = self.convert(begin: Float(barView.multiSlider.value[0]), end: Float(barView.multiSlider.value[1]))
        item.update(start: convert.0, duration: convert.1)
        viewModel.editor.videoComposition().add(item.clipLayer, at: item.index)
        viewModel.build()
        currentItem = item
        items.append(item)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let item = currentItem, drawButton.isSelected else { return }
        let point = touch.location(in: view)
        let displayePoint = displayView.layer.convert(point, from: view.layer)
        guard displayView.layer.contains(displayePoint) else { return }
        pause()
        let convertPoint = convert(point: point)
        item.color = colorBarView.colorSlider.color
        item.width = widthBarView.slider.value
        item.append(point: convertPoint)
        previewFrame()
        revokeIndexs.append(item.index)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let item = currentItem, drawButton.isSelected else { return }
        let point = touch.location(in: view)
        let displayePoint = displayView.layer.convert(point, from: view.layer)
        guard displayView.layer.contains(displayePoint) else { return }
        let convertPoint = convert(point: point)
        item.move(point: convertPoint)
        previewFrame()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first, let item = currentItem, drawButton.isSelected else { return }
        item.end()
        previewFrame()
    }
    private func convert(point: CGPoint) -> CGPoint {
        let naturalPoint = CGPoint(x: point.x - interactionRect.origin.x, y: point.y - interactionRect.origin.y-CGFloat.naviHeight)
        let posX = naturalPoint.x/interactionRect.width
        let posY = naturalPoint.y/interactionRect.height
        return CGPoint(x: posX, y: posY)
    }
    private func convert(begin: Float, end: Float) -> (Int, Int) {
        let start = Int(begin * viewModel.originalDuration)
        let duration = Int((end - begin) * viewModel.originalDuration)
        return (start, duration)
    }
}
extension GraffitiController {
    func setupView() {
        barView.multiBetweenThumbs(distance: minTimeInterval * 10 / viewModel.originalDuration)
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
       
        barView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            let convert = self.convert(begin: begin, end: end)
            if let item = self.currentItem {
                self.fetchLock()
                item.update(start: convert.0, duration: convert.1)
                self.fetchUnlock()
            }            
            self.seek(convert.0)
        }
        colorBarView.colorSlider.color = UIColor.blue
        contentView.addSubview(colorBarView)
        colorBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(5)
            make.height.equalTo(50)
        }
        widthBarView.slider.minimumValue = 2
        widthBarView.slider.maximumValue = 24
        widthBarView.startValue = 8
        contentView.addSubview(widthBarView)
        widthBarView.snp.makeConstraints { (make) in
            make.top.equalTo(colorBarView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        drawButton.setTitle("添加新的涂鸦", for: .normal)
        drawButton.setTitle("停止绘制", for: .selected)
        drawButton.addTarget(self, action: #selector(drawAction(_:)), for: .touchUpInside)
        drawButton.layer.cornerRadius = 3
        drawButton.clipsToBounds = true
        drawButton.backgroundColor = .lightGray
        drawButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(drawButton)
        drawButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo((UIScreen.width-45)/2)
            make.height.equalTo(49)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
        let revokeButton = UIButton()
        revokeButton.setTitle("撤销", for: .normal)
        revokeButton.addTarget(self, action: #selector(revokeAction), for: .touchUpInside)
        revokeButton.layer.cornerRadius = 3
        revokeButton.clipsToBounds = true
        revokeButton.backgroundColor = .lightGray
        revokeButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(revokeButton)
        revokeButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo((UIScreen.width-45)/2)
            make.height.equalTo(49)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
    }
    @objc func drawAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            addItem()
        } else {
            currentItem = nil
        }
    }
    @objc func revokeAction() {
        guard revokeIndexs.count > 0, let index = revokeIndexs.last else { return }
        
        var item: GraffitiItem?
        for value in items {
            if index == value.index {
                item = value
                break
            }
        }
        guard let item = item else { return }
        pause()
        item.revoke()
        revokeIndexs.removeLast()
        if item.index != currentItem?.index, item.builder.holder.paths.count == 0 {
            fetchLock()
            viewModel.editor.videoComposition().deleteLayer(at: item.index)
            fetchUnlock()
        }
        previewFrame()
    }
    
}
