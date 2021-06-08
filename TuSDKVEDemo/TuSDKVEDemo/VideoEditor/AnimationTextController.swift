//
//  AnimationTextController.swift
//  TuSDKVEDemo
//
//  Created by  on 2021/3/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import RSKGrowingTextView
let defaultText = "请输入文字"
class AnimationTextController: EditorStickerController {
    class TextItem {
        let index: Int
        let clip: TUPVEditorClip
        var clipLayer: TUPVEditorClipLayer
        
        var builder = TUPVEAnimationTextClip_PropertyBuilder()
        var overlayBuilder = TUPVEditorLayer_OverlayPropertyBuilder()
        var math = Math()
        struct Math {
            var scale: Float = 1
            var start: Int = 0
            var duration: Int = 0
            var blend: String?
        }
        init(index: Int, ctx: TUPVEditorCtx) {
            self.index = index
            self.clipLayer = TUPVEditorClipLayer(forVideo: ctx)
            self.clip = TUPVEditorClip(ctx, withType: TUPVEAnimationTextClip_TYPE_NAME)
            builder.holder.text = defaultText
            let marshalStr = TUPPathMarshal.marshalPath(Bundle.main.path(forResource: "SourceHanSansSC-Normal", ofType: "ttf")!)
            builder.holder.fonts = [marshalStr]
        }
        init(index: Int, clipLayer: TUPVEditorClipLayer, clip: TUPVEditorClip) {
            self.index = index
            self.clipLayer = clipLayer
            self.clip = clip
        }
        func update(start: Int, duration: Int) {
            math.start = start
            math.duration = duration
            let clipConfig = clip.getConfig()
            clipConfig.setIntNumber(duration, forKey: TUPVEAnimationTextClip_CONFIG_DURATION)
            clip.setConfig(clipConfig)
            if clipLayer.getClip(200) == nil {
                clipLayer.add(clip, at: 200)
            }
            let layerConfig = clipLayer.getConfig()
            layerConfig.setIntNumber(start, forKey: TUPVEditorLayer_CONFIG_START_POS)
            clipLayer.setConfig(layerConfig)
        }
        func updateProperty() {
            clip.setProperty(builder.makeProperty(), forKey: TUPVEAnimationTextClip_PROP_PARAM)
        }
        func updateOverlayProperty() {
            clipLayer.setProperty(overlayBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
        }
        func update(blend mode: String) {
            math.blend = mode
            let blendConfig = clipLayer.getConfig()
            blendConfig.setString(mode, forKey: TUPVEditorLayer_CONFIG_BLEND_MODE)
            clipLayer.setConfig(blendConfig)
        }
        func info() -> TUPVEAnimationTextClip_InteractionInfo? {
            guard let infoProperty = clip.getProperty(TUPVEAnimationTextClip_PROP_INTERACTION_INFO) else { return nil }
            return TUPVEAnimationTextClip_InteractionInfo(infoProperty)
        }
    }
    var sourceItems: [TTTextSourceItem] = TTTextSourceItem.all()
    private var stickerTable:[Int: TextItem] = [:]
    var currentItem: TextItem?
    let sliderView = SliderBarView(title: "文字起止位置", state: .multi)
    var collectionView: UICollectionView!
    lazy var paramView: TTTextParamView = {
        let item = TTTextParamView(frame: CGRect(x: 0, y: collectionView.frame.minY, width: UIScreen.width, height: contentView.frame.height - collectionView.frame.minY))
        item.setup(count: sourceItems.count - 1)
        contentView.addSubview(item)
        item.delegate = self
        item.isHidden = true
        return item
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if viewModel.state == .draft, stickerTable.keys.count > 0 {
            for sticker in stickerTable {
                updateStickerView(item: sticker.value, isInitialize: true, isDraft: true)
            }
        }
    }
    override var currentTs: Int {
        didSet {
            /// 当前进度不在贴纸时间范围内
            guard let item = currentItem, !durationIsValid(item: item) else { return }
            DispatchQueue.main.async {
                self.setupItem(current: nil)
            }
        }
    }
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        if viewModel.state == .draft {
            let layers = viewModel.editor.videoComposition().getAllLayers()
            for layerDict in layers {
                guard let clipLayer = layerDict.value as? TUPVEditorClipLayer else { continue }
                for clipDict in clipLayer.getAllClips() {
                    guard clipDict.value.getType() == TUPVEAnimationTextClip_TYPE_NAME else { continue }
                    let index = layerDict.key.intValue
                    var builder = TUPVEAnimationTextClip_PropertyBuilder()
                    if let prop = clipDict.value.getProperty(TUPVEAnimationTextClip_PROP_PARAM) {
                        let holder = TUPVEAnimationTextClip_PropertyHolder(property: prop)
                        builder = TUPVEAnimationTextClip_PropertyBuilder(holder: holder)
                    }
                    let blendMode = clipLayer.getConfig().getString(TUPVEditorLayer_CONFIG_BLEND_MODE, or: "xxx")
                    var overlayBuilder = TUPVEditorLayer_OverlayPropertyBuilder()
                    if let prop = clipLayer.getProperty(TUPVEditorLayer_PROP_OVERLAY) {
                        let holder = TUPVEditorLayer_OverlayPropertyHolder(property: prop)
                        overlayBuilder = TUPVEditorLayer_OverlayPropertyBuilder(holder: holder)
                    }
                    let startTs = clipLayer.getConfig().getIntNumber(TUPVEditorLayer_CONFIG_START_POS, or: 0)
                    let duration = Int(clipDict.value.getStreamInfo()!.duration)
                    let item = TextItem(index: index, clipLayer: clipLayer, clip: clipDict.value)
                    item.math.start = startTs
                    item.math.duration = duration
                    item.math.scale = Float(builder.holder.fontScale)
                    if blendMode != "xxx" {
                        item.math.blend = blendMode
                    }
                    item.builder = builder
                    item.overlayBuilder = overlayBuilder
                    stickerTable[index] = item
                    stickerLayerIndex = index > stickerLayerIndex ? index : stickerLayerIndex
                }
            }
        }
    }
}

extension AnimationTextController {
    func addItem() {
        fetchLock()
        stickerLayerIndex += 1
        let item = TextItem(index: stickerLayerIndex, ctx: viewModel.ctx)
        item.update(start: currentTs, duration: viewModel.getDuration())
        viewModel.editor.videoComposition().add(item.clipLayer, at: item.index)
        viewModel.build()
        fetchUnlock()
        // 数据源
        stickerTable[item.index] = item
        setupItem(current: item)
        // 添加贴纸
        updateStickerView(item: item, isInitialize: true)
    }
    func setupItem(current item: TextItem?) {
        if item == nil, let currentItem = currentItem {
            stickerDisplayView.updateItemView(currentItem.index, selected: false)
        }
        currentItem = item
        paramView.update(textItem: item)
        updateSliderView()
    }
    /// 添加/更新贴纸
    func updateStickerView(item: TextItem, isInitialize: Bool = false, isDraft: Bool = false) {
        if !isDraft { // 草稿箱初始化不需要更新
            item.updateProperty()
        }
        player.previewFrame(currentTs)
        guard let info = item.info() else { return }
        let rect = stickerFrame(info: info)
        if isInitialize {
            stickerDisplayView.addItemView(item.index, frame: rect, angle: CGFloat(info.rotation), multi: nil, isSelected: isDraft ? false : true)
        } else {
            stickerDisplayView.updateItemView(item.index, frame: rect, angle: CGFloat(info.rotation))
        }
    }
    func updateProperty() {
        guard let item = currentItem else { return }
        item.updateProperty()
        player.previewFrame(currentTs)
    }
    /// 更新时长
    func updateItem(begin: Float, end: Float) {
        guard let item = currentItem else { return }
        let start = Int(begin * viewModel.originalDuration)
        let duration = Int((end - begin) * viewModel.originalDuration)
        fetchLock()
        item.update(start: start, duration: duration)
        fetchUnlock()
        seek(start)
        NotificationCenter.default.post(name: .init(rawValue: "TextUpdateDuration"), object: (start, duration))
    }
    /// 贴纸 坐标
    func stickerFrame(info: TUPVEAnimationTextClip_InteractionInfo) -> CGRect {
        stickerFrame(posX: CGFloat(info.posX), posY: CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
    }
    /// 贴纸 时间是否有效
    func durationIsValid(item: TextItem?) -> Bool {
        guard let item = item else { return false }
        return (currentTs >= item.math.start && currentTs <= (item.math.start + item.math.duration))
    }
}
extension AnimationTextController: TTStickerDisplayDelegate {
    func displayView(_ displayView: TTStickerDisplayView, index: Int, position: CGPoint, scale: CGFloat, rotation: CGFloat) {
        guard let item = currentItem, item.index == index else { return }
        item.builder.holder.posX = Double((displayView.frame.width * position.x - interactionRect.origin.x) / interactionRect.width)
        item.builder.holder.posY = Double((displayView.frame.height * position.y - interactionRect.origin.y) / interactionRect.height)
        item.builder.holder.fontScale = Double(scale) * Double(item.math.scale)
        item.builder.holder.rotation = Int32(rotation)
        updateStickerView(item: item)
    }
    func displayView(_ displayView: TTStickerDisplayView, didSelectItemAt index: Int) -> Bool {
        guard let item = stickerTable[index] else { return false }
        let durationValid = durationIsValid(item: item)
        if durationValid {
            if currentItem?.index != item.index {
                setupItem(current: item)
            }
            pause()
        }
        return durationValid
    }
    func displayView(_ displayView: TTStickerDisplayView, didEditItemAt index: Int) {
        guard let item = currentItem, item.index == index else { return }
        textInputView.show()
        textInputView.textDidChange = {[weak self] text in
            guard let `self` = self else { return }
            var title = text.trimmingCharacters(in: .whitespaces)
            if title.count == 0 {
                title = defaultText
            }
            item.builder.holder.text = title
            self.updateStickerView(item: item)
        }
    }
    func displayViewCancelSelect(_ displayView: TTStickerDisplayView) {
        setupItem(current: nil)
    }
    func displayView(_ displayView: TTStickerDisplayView, didRemovedItemAt index: Int) {
        removeStickerItem(index)
        stickerTable.removeValue(forKey: index)
        setupItem(current: nil)
    }
}
extension AnimationTextController: UICollectionViewDataSource, UICollectionViewDelegate {
    func setupView() {
        stickerDisplayView.delegate = self
        
        sliderView.multiBetweenThumbs(distance: minTimeInterval * 10 / viewModel.originalDuration)
        updateSliderView()
        contentView.addSubview(sliderView)
        sliderView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.updateItem(begin: begin, end: end)
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: sliderView.frame.maxY + 10, width: UIScreen.width, height: 110), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TTCollectionViewvalue1Cell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        collectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(collectionView)
        
    }
    func updateSliderView() {
        if let item = currentItem {
            sliderView.multiSlider.value = [CGFloat(Float(item.math.start)/viewModel.originalDuration),CGFloat(Float(item.math.start+item.math.duration)/viewModel.originalDuration)]
            sliderView.isUserInteractionEnabled = true
        } else {
            sliderView.multiSlider.value = [0, 0]
            sliderView.isUserInteractionEnabled = false
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sourceItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! TTCollectionViewvalue1Cell
        cell.item = sourceItems[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addItem()
        } else {
            guard let _ = currentItem else { return }
            collectionView.isHidden = true
            pause()
            paramView.show(state: sourceItems[indexPath.row].state, index: indexPath.row - 1)
        }
    }
}
extension AnimationTextController: TTTextParamViewDelegate {
    func paramView(_ paramView: TTTextParamView, update index: Int) {
        guard let item = self.currentItem, item.index == index else { return }
        pause()
        updateProperty()
    }
    func paramView(_ paramView: TTTextParamView, updateFrame index: Int) {
        guard let item = self.currentItem, item.index == index else { return }
        updateStickerView(item: item)
    }
    func paramView(_ paramView: TTTextParamView, blend mode: String) {
        guard let item = self.currentItem else { return }
        fetchLock()
        item.update(blend: mode)
        fetchUnlock()
        previewFrame()
    }
    func paramView(_ paramView: TTTextParamView, updateOverlay index: Int) {
        guard let item = self.currentItem, item.index == index else { return }
        pause()
        item.updateOverlayProperty()
        previewFrame()
    }
    func didHiddenParamView(_ paramView: TTTextParamView) {
        collectionView.isHidden = false
    }
}
