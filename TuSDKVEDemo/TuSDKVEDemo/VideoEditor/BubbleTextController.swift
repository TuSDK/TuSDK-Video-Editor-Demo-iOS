//
//  BubbleTextController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/27.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
class BubbleTextController: EditorStickerController {

    enum BubbleEvents: String {
        case blend = "素材混合模式"
        case duration = "素材时长"
        case add = "添加气泡文字"
        case back = "返回"
    }
    enum ListStyle: Int {
        case unselected // 当前无气泡文字
        case selected // 当前有气泡文字
        case detail // 返回首页
    }
    class BubbleItem {
        let index: Int
        let clip: TUPVEditorClip
        let clipLayer: TUPVEditorClipLayer
        var start: Int = 0
        var duration: Int = 0
        var blendMode: String?
        var blendStrength: Float = 1
        var scale: Float = 0.5
        lazy var builder: TUPVEBubbleTextClip_PropertyBuilder = {
            let builder = TUPVEBubbleTextClip_PropertyBuilder()
            builder.holder.scale = Double(scale)
            return builder
        }()
        lazy var blendBuilder: TUPVEditorLayer_OverlayPropertyBuilder = {
            return TUPVEditorLayer_OverlayPropertyBuilder()
        }()
        init(index: Int, ctx: TUPVEditorCtx) {
            self.index = index
            self.clipLayer = TUPVEditorClipLayer(forVideo: ctx)
            self.clip = TUPVEBubbleTextClip(ctx, withType: TUPVEBubbleTextClip_TYPE_NAME)
        }
        init(index: Int, clipLayer: TUPVEditorClipLayer, clip: TUPVEditorClip) {
            self.index = index
            self.clipLayer = clipLayer
            self.clip = clip
        }
        func add(bubble: String, fontPath: String, start:Int, duration: Int) {
            self.start = start
            self.duration = duration
            let layerConfig = clipLayer.getConfig()
            layerConfig.setIntNumber(start, forKey: TUPVEditorLayer_CONFIG_START_POS)
            clipLayer.setConfig(layerConfig)
            
            let config = clip.getConfig()
            config.setIntNumber(duration, forKey: TUPVEBubbleTextClip_CONFIG_DURATION)
            config.setStringWithMarshal(bubble, forKey: TUPVEBubbleTextClip_CONFIG_MODEL)
            config.setStringWithMarshal(fontPath, forKey:TUPVEBubbleTextClip_CONFIG_FONT_DIR)
            clip.setConfig(config)
            if clipLayer.getClip(200) == nil {
                clipLayer.add(clip, at: 200)
            }
        }
        func update() {
            clip.setProperty(builder.makeProperty(), forKey: TUPVEBubbleTextClip_PROP_PARAM)
        }
        func update(start: Int, duration: Int) {
            self.start = start
            self.duration = duration
            let layerConfig = clipLayer.getConfig()
            layerConfig.setIntNumber(start, forKey: TUPVEditorLayer_CONFIG_START_POS)
            clipLayer.setConfig(layerConfig)
            
            let config = clip.getConfig()
            config.setIntNumber(duration, forKey: TUPVEBubbleTextClip_CONFIG_DURATION)
            clip.setConfig(config)
        }
        func update(blend mode: String) {
            blendMode = mode
            let blendConfig = clipLayer.getConfig()
            blendConfig.setString(mode, forKey: TUPVEditorLayer_CONFIG_BLEND_MODE)
            clipLayer.setConfig(blendConfig)
        }
        func update(blend strength: Float) {
            blendStrength = strength
            blendBuilder.holder.blendStrength = strength
            clipLayer.setProperty(blendBuilder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
        }
        
        func info() -> TUPVEBubbleTextClip_InteractionInfo? {
            guard let property = clip.getProperty(TUPVEBubbleTextClip_PROP_INTERACTION_INFO) else { return nil }
            return TUPVEBubbleTextClip_InteractionInfo(property: property)
        }
    }
    private let tableView = UITableView()
    private let titles:[[BubbleEvents]] = [[.add], [.add, .duration, .blend], [.back]]
    private var viewStyle: ListStyle = .unselected
    private let detailView = UIView()
    private var blendView: TTBlendView!
    private var sliderView: SliderBarView!
    private var bubbleStyleView: UIView!
    private var stickerTable:[Int: BubbleItem] = [:]
    private var currentStickerItem: BubbleItem?
    lazy var sourceManager: TTSourceManager = {
        return TTSourceManager()
    }()
    override var currentTs: Int {
        didSet {
            if let item = currentStickerItem, !stickerDurationValid(item: item) {
                // 时间无效 取消选中
                updateCurrentSticker(item: nil)
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
                    guard clipDict.value.getType() == TUPVEBubbleTextClip_TYPE_NAME else { continue }
                    let index = layerDict.key.intValue
                    var builder = TUPVEBubbleTextClip_PropertyBuilder()
                    if let prop = clipDict.value.getProperty(TUPVEBubbleTextClip_PROP_PARAM) {
                        let holder = TUPVEBubbleTextClip_PropertyHolder(property: prop)
                        builder = TUPVEBubbleTextClip_PropertyBuilder(holder: holder)
                    }
                    let blendMode = clipLayer.getConfig().getString(TUPVEditorLayer_CONFIG_BLEND_MODE, or: "xxx")
                    var blendStrength :Float = 1
                    if let prop = clipLayer.getProperty(TUPVEditorLayer_PROP_OVERLAY) {
                        let holder = TUPVEditorLayer_OverlayPropertyHolder(property: prop)
                        let builder = TUPVEditorLayer_OverlayPropertyBuilder(holder: holder)
                        blendStrength = builder.holder.blendStrength
                    }
                    let startTs = clipLayer.getConfig().getIntNumber(TUPVEditorLayer_CONFIG_START_POS, or: 0)
                    let duration = Int(clipDict.value.getStreamInfo()!.duration)
                    let bubbleItem = BubbleItem(index: index, clipLayer: clipLayer, clip: clipDict.value)
                    bubbleItem.start = startTs
                    bubbleItem.duration = duration
                    bubbleItem.blendMode = blendMode
                    bubbleItem.blendStrength = blendStrength
                    bubbleItem.scale = Float(builder.holder.scale)
                    bubbleItem.builder = builder
                    stickerTable[index] = bubbleItem
                    stickerLayerIndex = index > stickerLayerIndex ? index : stickerLayerIndex
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerDisplayView.delegate = self
        setupView()
        addDraftStickerItemView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let touchView = touch.view else { return }
        if touchView.isDescendant(of: contentView), let _ = currentStickerItem {
            updateCurrentSticker(item: nil)
        }
    }
}

extension BubbleTextController {
    /// 气泡按钮事件
    @objc func bubbleAddAction(_ sender: UIButton) {
        guard let bubblePath = sourceManager.bubble(sender.tag) else { return }
        let item = addSticker(bubble: bubblePath)
        item.update()
        addStickerItemView(item: item)
    }
    /// 添加气泡文字
    func addSticker(bubble: String) -> BubbleItem {
        fetchLock()
        defer {
            fetchUnlock()
        }
        stickerLayerIndex += 1
        let item = BubbleItem(index: stickerLayerIndex, ctx: viewModel.ctx)
        item.add(bubble: bubble, fontPath: sourceManager.bubbleFont(), start: currentTs, duration: (viewModel.getDuration() - currentTs))
        viewModel.editor.videoComposition().add(item.clipLayer, at: item.index)
        viewModel.build()
        updateCurrentSticker(item: item)
        stickerTable[item.index] = item
        return item
    }
    /// 添加气泡视图
    /// - Parameters:
    ///   - item: item
    ///   - isInitialize: 草稿箱初始化视图
    func addStickerItemView(item: BubbleItem, isInitialize: Bool = false) {
        player.previewFrame(currentTs)
        guard let info = item.info() else { return }
        let rect = stickerFrame(info: info)
        if let infoItems = info.items as? [TUPVEBubbleTextClip_InteractionInfo_Item] {
            item.builder.holder.texts = infoItems.compactMap { $0.text }
        }
        stickerDisplayView.addItemView(item.index, frame: rect.0, angle: CGFloat(info.rotation), multi: rect.1, isSelected: !isInitialize)
    }
    func addDraftStickerItemView() {
        guard viewModel.state == .draft, stickerTable.keys.count > 0 else { return }
        for sticker in stickerTable {
            addStickerItemView(item: sticker.value, isInitialize: true)
        }
    }
    /// 更新气泡文字
    func updateStickerItem() {
        guard let item = currentStickerItem else { return }
        item.update()
        guard let info = item.info() else { return }
        let rect = stickerFrame(info: info)
        stickerDisplayView.updateItemView(item.index, frame: rect.0, angle: CGFloat(info.rotation), multi: rect.1)
        player.previewFrame(currentTs)
    }
    /// 更新时长
    func updateStickerItem(begin: Float, end: Float) {
        guard let item = currentStickerItem else { return }
        let start = Int(begin * viewModel.originalDuration)
        fetchLock()
        item.update(start: start, duration: Int((end - begin) * viewModel.originalDuration))
        fetchUnlock()
        seek(start)
    }
    /// 混合模式
    func updateStickerItem(blend mode: String, strength: Float) {
        guard let item = currentStickerItem else { return }
        fetchLock()
        item.update(blend: mode)
        fetchUnlock()
        updateStickerItem(blend: strength)
    }
    /// 混合强度
    func updateStickerItem(blend strength: Float) {
        guard let item = currentStickerItem else { return }
        item.update(blend: strength)
        player.previewFrame(currentTs)
    }
    /// 更新当前气泡
    func updateCurrentSticker(item: BubbleItem?) {
        if item == nil, let currentItem = currentStickerItem {
            stickerDisplayView.updateItemView(currentItem.index, selected: false)
        }
        currentStickerItem = item
        updateViewParam()
        if viewStyle != .detail {
            viewStyle = (item == nil) ? .unselected : .selected
            tableView.reloadData()
        }
    }
    /// 气泡时间是否有效
    func stickerDurationValid(item: BubbleItem?) -> Bool {
        guard let item = item else { return false }
        return (currentTs >= item.start && currentTs <= (item.start + item.duration))
    }
    /// 气泡文字坐标
    func stickerFrame(info: TUPVEBubbleTextClip_InteractionInfo) -> (CGRect,[NSValue]) {
        var arrs:[NSValue] = []
        if let rects = info.items as? [TUPVEBubbleTextClip_InteractionInfo_Item] {
            arrs = rects.compactMap {NSValue(cgRect: $0.rect)}
        }
        let displayRect = stickerFrame(posX: CGFloat(info.posX), posY: CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
        return (displayRect, arrs)
    }
    private func convert(begin: Float, end: Float) -> (Int, Int) {
        let start = Int(begin * viewModel.originalDuration)
        let duration = Int((end - begin) * viewModel.originalDuration)
        return (start, duration)
    }
}
extension BubbleTextController: TTStickerDisplayDelegate {
    func displayView(_ displayView: TTStickerDisplayView, index: Int, position: CGPoint, scale: CGFloat, rotation: CGFloat) {
        guard let item = currentStickerItem, item.index == index else { return }
        //printTu("偏移:\(position) 缩放:\(scale) 旋转:\(rotation)")
        item.builder.holder.posX = Double((displayView.frame.width * position.x - interactionRect.origin.x) / interactionRect.width)
        item.builder.holder.posY = Double((displayView.frame.height * position.y - interactionRect.origin.y) / interactionRect.height)
        item.builder.holder.scale = Double(scale) * Double(item.scale)
        item.builder.holder.rotation = Int32(rotation)
        updateStickerItem()
    }
    func displayView(_ displayView: TTStickerDisplayView, didSelectItemAt index: Int) -> Bool {
        guard let item = stickerTable[index] else { return false }
        let durationValid = stickerDurationValid(item: item)
        if durationValid {
            updateCurrentSticker(item: item)
            pause()
        }
        return durationValid
    }
    func displayView(_ displayView: TTStickerDisplayView, didEditItemAt index: Int, didSelectInputAt inputIndex: Int) {
        guard let currentItem = currentStickerItem, currentItem.index == index else { return }
        textInputView.show()
        if inputIndex < currentItem.builder.holder.texts.count {
            textInputView.textView.text = currentItem.builder.holder.texts[inputIndex]
        }
        textInputView.textDidChange = {[weak self] text in
            guard let `self` = self else { return }
            let title = text.trimmingCharacters(in: .whitespaces)
            currentItem.builder.holder.texts[inputIndex] = title
            self.updateStickerItem()
        }
    }
    func displayViewCancelSelect(_ displayView: TTStickerDisplayView) {
        updateCurrentSticker(item: nil)
    }
    func displayView(_ displayView: TTStickerDisplayView, didRemovedItemAt index: Int) {
        removeStickerItem(index)
        stickerTable.removeValue(forKey: index)
        updateCurrentSticker(item: nil)
    }
}
extension BubbleTextController: UITableViewDelegate, UITableViewDataSource {
    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 49
        tableView.isScrollEnabled = false
        tableView.register(TTReverseTableViewCell.self, forCellReuseIdentifier: "BubbleText")
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .black
        tableView.transform = CGAffineTransform(rotationAngle: .pi) // 倒转
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
        detailView.isHidden = true
        contentView.addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(30)
            make.bottom.equalTo(-CGFloat.safeBottom - 60)
        }
        blendView = TTBlendView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 150))
        blendView.blendCompletion = {[weak self] (mode,strength) in
            guard let `self` = self else { return }
            self.updateStickerItem(blend: mode, strength: strength)
        }
        blendView.strengthCompletion = {[weak self] (strength) in
            guard let `self` = self else { return }
            self.updateStickerItem(blend: strength)
        }
        detailView.addSubview(blendView)
        
        sliderView = SliderBarView(title: "气泡起止位置", state: .multi)
        sliderView.multiBetweenThumbs(distance: minTimeInterval * 10 / viewModel.originalDuration)
        detailView.addSubview(sliderView)
        sliderView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.updateStickerItem(begin: begin, end: end)
        }
        bubbleStyleView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 100))
        detailView.addSubview(bubbleStyleView)
        for (index,item) in sourceManager.bubbleImages.enumerated() {
            let button = UIButton(frame: CGRect(x: 15 + 95 * index, y: 0, width: 80, height: 40))
            button.setImage(UIImage(named: item), for: .normal)
            button.tag = index
            bubbleStyleView.addSubview(button)
            button.addTarget(self, action: #selector(bubbleAddAction(_:)), for: .touchUpInside)
        }
    }
    
    /// 显示修改参数页面
    func updateView(event: BubbleEvents) {
        detailView.isHidden = false
        blendView.isHidden = true
        sliderView.isHidden = true
        bubbleStyleView.isHidden = true
        switch event {
        case .blend:
            blendView.isHidden = false
        case .duration:
            sliderView.isHidden = false
        case .add:
            bubbleStyleView.isHidden = false
        case .back:
            detailView.isHidden = true
            break
        }
    }
    /// 更新参数
    func updateViewParam() {
        guard let currentItem = currentStickerItem else { return }
        let begin = CGFloat(currentItem.start)/CGFloat(viewModel.originalDuration)
        let duration = CGFloat(currentItem.duration)/CGFloat(viewModel.originalDuration)
        let end = begin + duration
        sliderView.multiSlider.value = [begin, end]
        blendView.setup(mode: currentItem.blendMode, strength: currentItem.blendStrength)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles[viewStyle.rawValue].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BubbleText", for: indexPath)
        cell.textLabel?.text = titles[viewStyle.rawValue][indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = titles[viewStyle.rawValue][indexPath.row]
        if viewStyle != .detail {
            viewStyle = .detail
        } else {
            viewStyle = (currentStickerItem == nil) ? .unselected : .selected
        }
        updateView(event: event)
        tableView.reloadData()
    }
}
