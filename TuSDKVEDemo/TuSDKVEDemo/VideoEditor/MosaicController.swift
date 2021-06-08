//
//  MosaicController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/13.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
let borderSize = CGSize(width: 260, height: 75)

class MosaicController: EditorStickerController, TTReverseViewDelegate {
    enum MosaicStyle {
        case none
        case brush
        case border
    }
    class MosaicItem {
        let index: Int
        let effect: TUPVEditorEffect
        var start: Int = 0
        var duration: Int = 0
        
        var builder = TUPVEMosaicEffect_PathPropertyBuilder()
        var info = TUPVEMosaicEffect_PathInfo()
        var width: Float = 0.1
        
        var rectInfo = TUPVEMosaicEffect_RectInfo()
        var borderBuilder = TUPVEMosaicEffect_RectPropertyBuilder()
        var scale: Double = 1
        
        init(index: Int, ctx: TUPVEditorCtx) {
            self.index = index
            self.effect = TUPVEMosaicEffect(ctx: ctx)
        }
        init(index: Int, effect: TUPVEditorEffect) {
            self.index = index
            self.effect = effect
        }
        func update(start: Int, duration: Int) {
            self.start = start
            self.duration = duration
            let config = effect.getConfig()
            config.setNumber(NSNumber(value: start), forKey: TUPVEMosaicEffect_CONFIG_POS)
            config.setNumber(NSNumber(value: (start + duration)), forKey: TUPVEMosaicEffect_CONFIG_DURATION)
            effect.setConfig(config)
        }
        func append(point: CGPoint) {
            info = TUPVEMosaicEffect_PathInfo()
            info.points.add(NSValue(cgPoint: point))
            info.thickness = Double(width)
            info.index = 1
            info.code = TUPVEMosaicEffect_CODE_FILL
            builder.holder.paths.add(info)
            
            effect.setProperty(builder.makeAppendProperty(Double(point.x), posY: Double(point.y), index: 1, thickness: Double(width), code: TUPVEMosaicEffect_CODE_FILL), forKey: TUPVEMosaicEffect_PROP_APPEND_PARAM)
        }
        func move(point: CGPoint) {
            info.points.add(NSValue(cgPoint: point))
            effect.setProperty(builder.makeExtendProperty(Double(point.x), posY: Double(point.y), index: 1), forKey: TUPVEMosaicEffect_PROP_EXTEND_PARAM)
            effect.setProperty(builder.makeProperty(), forKey: TUPVEMosaicEffect_PATH_PROP_PARAM)
        }
        
        func append(rect: CGRect) {
            rectInfo = TUPVEMosaicEffect_RectInfo()
            scale = rectInfo.scale
            rectInfo.x = Double(rect.origin.x)
            rectInfo.y = Double(rect.origin.y)
            rectInfo.width = Double(rect.width)
            rectInfo.height = Double(rect.height)
            borderBuilder.holder.rects.add(rectInfo)
            effect.setProperty(borderBuilder.makeAppendProperty(rectInfo.x, rectY: rectInfo.y, rectW: Double(rectInfo.width), rectH: Double(rectInfo.height), index: 1), forKey: TUPVEMosaicEffect_PROP_APPEND_PARAM)
            effect.setProperty(borderBuilder.makeProperty(), forKey: TUPVEMosaicEffect_RECT_PROP_PARAM)
        }
        
        func move() {
            effect.setProperty(borderBuilder.makeAppendProperty(rectInfo.x, rectY: rectInfo.y, rectW: Double(rectInfo.width), rectH: Double(rectInfo.height), index: 1), forKey: TUPVEMosaicEffect_PROP_APPEND_PARAM)
            effect.setProperty(borderBuilder.makeProperty(), forKey: TUPVEMosaicEffect_RECT_PROP_PARAM)
        }
    }
    let reverseView = TTReverseView()
    let barView = SliderBarView(title: "持续时长", state: .multi)
    let widthBarView = SliderBarView(title: "笔触宽度", state: .native)
    var brushItem: MosaicItem?
    var borderItem: MosaicItem?
    var style: MosaicStyle = .none
    var borderItemTable: [Int: MosaicItem] = [:]
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        setupDraftItem()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDraftStickerView()
    }
    
    func setupView() {
        barView.multiBetweenThumbs(distance: minTimeInterval * 10 / viewModel.originalDuration)
        barView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            let convert = self.convertPts(begin: begin, end: end)
            self.update(begin: convert.0, duration: convert.1)
        }
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(15)
            make.height.equalTo(50)
        }
        widthBarView.isHidden = true
        widthBarView.slider.minimumValue = 0
        widthBarView.slider.maximumValue = 0.2
        widthBarView.slider.value = brushItem?.width ?? 0.1
        contentView.addSubview(widthBarView)
        widthBarView.snp.makeConstraints { (make) in
            make.top.equalTo(barView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        reverseView.events = mosaicEventItems
        reverseView.update(section: effectIndex > 3000 ? 1 : 0)
        reverseView.delegate = self
        contentView.addSubview(reverseView)
        reverseView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
        stickerDisplayView.delegate = self
        stickerDisplayView.isHidden = borderItemTable.count == 0
        stickerDisplayView.isRemoveUsable = false
        stickerDisplayView.gestureAutoTransform = true
    }
    func reverseView(_ reverseView: TTReverseView, didSelectIndexAt section: Int, event: TTReverseEvents) {
        switch event {
        case .bc:
            style = .brush
            stickerDisplayView.isHidden = true
            widthBarView.isHidden = false
            reverseView.update(section: effectIndex > 3000 ? 3 : 2)
        case .jxk:
            pause()
            style = .border
            stickerDisplayView.isHidden = false
            borderItem = addItem()
            borderItemTable[effectIndex] = borderItem!
            appendBorder()
            reverseView.update(section: 1)
        case .cx:
            revoke()
            if effectIndex == 3000 {
                reverseView.update(section: section == 1 ? 0 : 2)
            }
        case .back:
            widthBarView.isHidden = true
            style = .none
            reverseView.update(section: effectIndex == 3000 ? 0 : 1)
        default:
            break
        }
    }
    func addItem() -> MosaicItem {
        fetchLock()
        defer {
            fetchUnlock()
            seek(currentTs)
        }
        effectIndex += 1
        let begin = Float(currentTs)/viewModel.originalDuration
        barView.multiSlider.value[0] = CGFloat(begin)
        let convert = self.convertPts(begin: Float(barView.multiSlider.value[0]), end: Float(barView.multiSlider.value[1]))
        let item = MosaicItem(index: effectIndex, ctx: viewModel.ctx)
        item.update(start: convert.0, duration: convert.1)
        viewModel.clipItems[0].videoClip.effects().add(item.effect, at: item.index)
        viewModel.build()
        return item
    }
    func revoke() {
        guard effectIndex > 3000 else { return }
        fetchLock()
        defer {
            fetchUnlock()
            previewFrame()
        }
        viewModel.clipItems[0].videoClip.effects().deleteEffect(effectIndex)
        viewModel.build()
        
        if style == .brush {
            brushItem = nil
        } else {
            stickerDisplayView.removeItemView(effectIndex)
            borderItemTable.removeValue(forKey: effectIndex)
            borderItem = nil
        }
        effectIndex -= 1
    }
    override var currentTs: Int {
        didSet {
            if style == .border, let item = borderItem, !borderPtsValid(item: item) {
                borderItem = nil
                stickerDisplayView.updateItemView(item.index, selected: false)
            }
        }
    }
}
// MARK: - 笔触
extension MosaicController {
    func update(begin: Int, duration: Int) {
        var item: MosaicItem?
        if style == .brush {
            item = brushItem
        } else {
            item = borderItem
        }
        guard let item = item else {
            seek(begin)
            return }
        fetchLock()
        defer {
            fetchUnlock()
            seek(begin)
        }
        item.update(start: begin, duration: duration)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, style == .brush else { return }
        let point = touch.location(in: view)
        let displayePoint = displayView.layer.convert(point, from: view.layer)
        guard displayView.layer.contains(displayePoint) else { return }
        pause()
        brushItem = addItem()
        let convertPoint = convert(point: point)
        brushItem?.width = widthBarView.slider.value
        brushItem?.append(point: convertPoint)
        previewFrame()
        reverseView.update(section: 3)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let item = brushItem, style == .brush else { return }
        let point = touch.location(in: view)
        let displayePoint = displayView.layer.convert(point, from: view.layer)
        guard displayView.layer.contains(displayePoint) else { return }
        let convertPoint = convert(point: point)
        item.move(point: convertPoint)
        previewFrame()
    }
    private func convert(point: CGPoint) -> CGPoint {
        let naturalPoint = CGPoint(x: point.x - interactionRect.origin.x, y: point.y - interactionRect.origin.y-CGFloat.naviHeight)
        let posX = naturalPoint.x/interactionRect.width
        let posY = naturalPoint.y/interactionRect.height
        return CGPoint(x: posX, y: posY)
    }
}
// MARK: - 矩形框
extension MosaicController: TTStickerDisplayDelegate {
    func appendBorder() {
        guard let item = borderItem else { return }
        item.append(rect: CGRect(x: 0.5, y: 0.5, width: borderSize.width/naturalRatio/editorVideoSize.width, height: borderSize.height/naturalRatio/editorVideoSize.height))
        previewFrame()
        stickerDisplayView.addItemView(item.index, size: borderSize)
    }
    func borderPtsValid(item: MosaicItem) -> Bool {
        return (currentTs >= item.start && currentTs <= (item.start + item.duration))
    }
    func displayView(_ displayView: TTStickerDisplayView, index: Int, position: CGPoint, scale: CGFloat, rotation: CGFloat) {
        guard let item = borderItem, style == .border, item.index == index else { return }
        item.rectInfo.x = Double((displayView.frame.width * position.x - interactionRect.origin.x) / interactionRect.width)
        item.rectInfo.y = Double((displayView.frame.height * position.y - interactionRect.origin.y) / interactionRect.height)
        let infoScale = Double(scale) * item.scale
        item.rectInfo.scale = infoScale
        item.rectInfo.width = Double(borderSize.width/naturalRatio/editorVideoSize.width)*infoScale
        item.rectInfo.height = Double(borderSize.height/naturalRatio/editorVideoSize.height)*infoScale
        item.rectInfo.rotation = Double(rotation)
        item.move()
        previewFrame()
    }
    func displayView(_ displayView: TTStickerDisplayView, didSelectItemAt index: Int) -> Bool {
        guard style == .border, let item = borderItemTable[index] else { return false }
        let isValid = borderPtsValid(item: item)
        if isValid {
            borderItem = item
            let convert = convertProgress(start: item.start, duration: item.duration)
            barView.multiSlider.value = [convert.0, convert.1]
        }
        return isValid
    }
    
}
// MARK: - 草稿
extension MosaicController {
    func setupDraftItem() {
        guard viewModel.state == .draft else { return }
        let effects = viewModel.clipItems[0].videoClip.effects().getAllEffects()
        for item in effects {
            let index = item.key.intValue
            let effect = item.value
            guard effect.getType() == TUPVEMosaicEffect_TYPE_NAME else {continue}
            if index > effectIndex {
                effectIndex = index
            }
            
            if let borderPro = effect.getProperty(TUPVEMosaicEffect_RECT_PROP_PARAM) {
                let item = MosaicItem(index: index, effect: effect)
                let config = effect.getConfig()
                item.start = config.getIntNumber(TUPVEMosaicEffect_CONFIG_POS)
                item.duration = config.getIntNumber(TUPVEMosaicEffect_CONFIG_DURATION)
                
                let holder = TUPVEMosaicEffect_RectPropertyHolder(property: borderPro)
                let builder = TUPVEMosaicEffect_RectPropertyBuilder(holder: holder)
                item.borderBuilder = builder
                if let rect = holder.rects.lastObject as? TUPVEMosaicEffect_RectInfo {
                    item.rectInfo = rect
                    item.scale = rect.scale
                }
                borderItemTable[index] = item
                style = .border
            }
        }
        
    }
    func setupDraftStickerView(){
        guard borderItemTable.count > 0 else { return }
        for item in borderItemTable {
            let frame = stickerFrame(posX: CGFloat(item.value.rectInfo.x), posY: CGFloat(item.value.rectInfo.y), width: CGFloat(item.value.rectInfo.width) * editorVideoSize.width, height: CGFloat(item.value.rectInfo.height) * editorVideoSize.height)
            stickerDisplayView.addItemView(item.key, frame: frame, angle: CGFloat(item.value.rectInfo.rotation), multi: nil, isSelected: false)
        }
    }
}
