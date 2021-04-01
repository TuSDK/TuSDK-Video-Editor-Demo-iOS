//
//  TextEditorViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/4.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import RSKGrowingTextView

let defaultText = "请输入文字"

class TextEditorViewController: EditorBaseController {
    
    class TextViewModel {
        static var ModelIndex : Int = 1000
        
        var index: Int                      // 索引
        var vid: Int                        // 唯一标识
        var blendMode: String?              // 混合模式
        var startTs : Int = 0               // 起始时间
        var endTs : Int = 0                 // 结束时间
        var opacity : Float = 1.0           // 图层透明度
        var blendValue : Float = 1.0        // 混合模式
        var textColor : UIColor = .white    // 文字颜色
        
        
        var textClip: TUPVEditorClip?
        var textLayer: TUPVEditorClipLayer?
        var builder = TUPVEText2DClip_PropertyBuilder()
        
        
        init(ctx: TUPVEditorCtx) {
            
            index = TextViewModel.ModelIndex
            vid = index
            TextViewModel.ModelIndex += 1
            
            textLayer = TUPVEditorClipLayer(forVideo: ctx)
            
            textClip = TUPVEditorClip(ctx, withType: TUPVEText2DClip_TYPE_NAME)
            builder.holder.rotation = 0
            builder.holder.text = defaultText
            builder.holder.strokeWidth = 0
            builder.holder.alignment = .alignmentType_LEFT
            builder.holder.fillColor = .white
            builder.holder.bgColor = .clear
            builder.holder.strokeColor = .clear
            builder.holder.font = Bundle.main.path(forResource: "SourceHanSansSC-Normal", ofType: "ttf")!
        }
        
        init(idx : Int){
            index = idx
            vid = idx
            TextViewModel.ModelIndex += idx
        }
        
    }
    
    // 文字item控制view
    private let overlayView = TuTextOverlayView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.width()))
    
    // 文字属性view
    private let tableView = UITableView()
    
    // 文本输入view
    lazy var textView: RSKGrowingTextView = {
        let item = RSKGrowingTextView()
        item.maximumNumberOfLines = 3
        item.minimumNumberOfLines = 1
        //item.returnKeyType = .done
        
        item.growingTextViewDelegate = self
        item.font = .systemFont(ofSize: 17)
        let contentView = UIView(frame: UIScreen.main.bounds)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textDismissAction)))
        view.addSubview(contentView)
        contentView.addSubview(item)
        item.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return item
    }()
    
    // 时间轴view
    lazy var barView : SliderBarView = {
        let barView = SliderBarView(title: "文字起止位置", state: .multi)
        barView.multiSlider.value = [0, 0]
        barView.isUserInteractionEnabled = false
        return barView
    }()
    
    // 所有创建的文字view数组
    var viewItems: [TextViewModel] = []
    
    // 当前选中文字view
    var currentItem: TextViewModel?
    
    var videoDuration: Int = 0
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        
        if viewModel.state == .resource {
            videoDuration = viewModel.getDuration()
        } else {
            videoDuration = viewModel.getDuration()
            for key in viewModel.editor.videoComposition().getAllLayers().keys {
                let layer = viewModel.editor.videoComposition().getLayer(key.intValue) as! TUPVEditorClipLayer
                for (_,clip) in layer.getAllClips() {
                    guard clip.getType() == TUPVEText2DClip_TYPE_NAME else { continue }
                    var builder = TUPVEText2DClip_PropertyBuilder()
                    if let prop = clip.getProperty(TUPVEText2DClip_PROP_PARAM) {
                        let holder = TUPVEText2DClip_PropertyHolder(property: prop)
                        builder = TUPVEText2DClip_PropertyBuilder(holder: holder)
                    }
                    
                    var blendStrength :Float = 1
                    var opacity: Float = 1
                    if let prop = layer.getProperty(TUPVEditorLayer_PROP_OVERLAY) {
                        let holder = TUPVEditorLayer_OverlayPropertyHolder(property: prop)
                        let builder = TUPVEditorLayer_OverlayPropertyBuilder(holder: holder)
                        blendStrength = builder.holder.blendStrength
                        opacity = builder.holder.opacity
                    }
                    
                    let blendMode = layer.getConfig().getString(TUPVEditorLayer_CONFIG_BLEND_MODE, or: "")
                    
                    let startTs = layer.getConfig().getIntNumber(TUPVEditorLayer_CONFIG_START_POS, or: 0)
                    let duration = Int(clip.getStreamInfo()!.duration)
                    
                    let item = TextViewModel(idx: key.intValue)
                    item.blendMode = blendMode
                    item.blendValue = blendStrength
                    item.startTs = startTs
                    item.endTs = startTs + duration
                    
                    item.textLayer = layer
                    item.textClip = clip
                    item.builder = builder
                    item.opacity = opacity
                    item.textColor = builder.holder.fillColor
                    viewItems.append(item)
                }
            }
            
            viewItems.sort { (v0, v1) -> Bool in
                return v0.index < v1.index
            }
            viewModel.build()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        registerNotification()
        
        for item in viewItems {
            guard let info = textStickerUpdateProperty(item: item) else { return }
            
            let rect = CGRect(x:CGFloat(info.posX), y:CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
            
            overlayView.createView(item.vid,startTs:item.startTs,endTs:item.endTs,rect:rect,rotation:info.rotation)
        }
    }
    
    deinit {
        printLog("deinit")
    }
}

extension TextEditorViewController {
    /// 文字特效
    func textSticker(item: TextEditorViewController.TextViewModel, startTs: Int, endTs: Int) {
        
        let clipConfig = TUPConfig()
        
        clipConfig.setNumber(NSNumber(value: endTs - startTs), forKey: TUPVEText2DClip_CONFIG_DURATION)
        item.textClip!.setConfig(clipConfig)
        
        let layerConfig = TUPConfig()
        layerConfig.setNumber(NSNumber(value: startTs), forKey: TUPVEditorLayer_CONFIG_START_POS)
        item.textLayer!.add(item.textClip!, at: 500)
        item.textLayer!.setConfig(layerConfig)
        
        viewModel.editor.videoComposition().add(item.textLayer!, at: item.index)
        
        viewModel.build()
    }
    
    /// 移除文字
    func textSticker(remove item: TextEditorViewController.TextViewModel) {
        let ret = viewModel.editor.videoComposition().deleteLayer(at: item.index)
        viewModel.build()
    }
    
    /// 文字编辑
    func textStickerUpdateProperty(item: TextEditorViewController.TextViewModel) -> TUPVEText2DClip_InteractionInfo? {
        item.textClip!.setProperty(item.builder.makeProperty(), forKey: TUPVEText2DClip_PROP_PARAM)
        guard let resultProperty = item.textClip!.getProperty(TUPVEText2DClip_PROP_INTERACTION_INFO) else { return  nil}
        return TUPVEText2DClip_InteractionInfo(resultProperty)
    }
    /// 文字起止时间
    func textStickerUpdateDuration(item: TextEditorViewController.TextViewModel, begin: Float, end: Float) {

        let config = TUPConfig()
        config.setNumber(NSNumber(value: Int(Float(videoDuration) * begin)), forKey: TUPVEditorLayer_CONFIG_START_POS)
        viewModel.editor.videoComposition().getLayer(item.index)?.setConfig(config)
        let textClipConfig = TUPConfig()
        textClipConfig.setNumber(NSNumber(value: Int(Float(videoDuration) * (end - begin))), forKey: "duration")
        item.textClip!.setConfig(textClipConfig)
        viewModel.build()
    }
    /// 混合模式
    func textStrickerBlend(item: TextEditorViewController.TextViewModel) {
        let config = TUPConfig()
        config.setString(item.blendMode!, forKey: TUPVEditorLayer_CONFIG_BLEND_MODE)
        viewModel.editor.videoComposition().getLayer(item.index)?.setConfig(config)
        viewModel.build()
    }
    /// 混合强度
    func textStrickerUpdateBlend(item: TextEditorViewController.TextViewModel, value: Float) {
        let builder = TUPVEditorLayer_OverlayPropertyBuilder()
        builder.holder.blendStrength = value
        viewModel.editor.videoComposition().getLayer(item.index)?.setProperty(builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
    }
}

extension TextEditorViewController: TuTextOverlayViewDelegate {
    
    /**
     *  创建文字view
     */
    private func initializeTextSticker() {
        
        fetchLock()
        defer {
            fetchUnlock(autoPlay: false)
        }
        
        let videoItem = TextViewModel(ctx: viewModel.ctx)
        videoItem.startTs = Int(controlView.currentProg() * Float(videoDuration))
        videoItem.endTs = videoDuration

        
        viewItems.append(videoItem)
        currentItem = videoItem
        
        textSticker(item: videoItem, startTs: videoItem.startTs, endTs: videoItem.endTs)
        overlayView.createView(videoItem.vid,startTs:videoItem.startTs,endTs:videoItem.endTs)
        
        openBarView()
        tableView.reloadData()
        
    }
    
    /**
     *  删除文字view
     */
    private func removeTextView() {
        guard let curItem = self.currentItem else {return}
        fetchLock()
        
        textSticker(remove: curItem)
        
        if let index = viewItems.firstIndex(where: { item -> Bool in
            return item.vid == curItem.vid
        }){
            viewItems.remove(at: index)
        }
        
        fetchUnlock(autoPlay: false)
        
        self.player.seek(to: self.currentTs)
        self.player.previewFrame(self.currentTs)
        
        currentItem = nil
        
        cancelBarView()
        
        tableView.reloadData()
        
    }
    
    /**
     *  设置当前选中item状态
     *
     *  @param vid 唯一标识
     */
    func onSelectItem(_ vid: Int){
        // 便利所有文字view,把“选择”状态的view设置给currentItem
        for (_,item) in viewItems.enumerated() {
            if item.vid == vid {
                currentItem = item
                openBarView()
                tableView.reloadData()
                // 暂停播放
                if isPlaying {
                    pause()
                }
                
            }
        }
    }
    
    /**
     *  未选中状态
     *
     */
    func onUnSelected() {
        
        currentItem = nil
        
        cancelBarView()
        
        tableView.reloadData()
    }
    
    /**
     *  更新文字属性
     *
     *  @param builder 数据
     */
    func updatePropBuilder(_ vid:Int, info: TuTextItemInfo) {
                
        for (_,item) in viewItems.enumerated() {
            if item.vid == vid {
                
                if info.type ==  TuTextItemView_TransformType(rawValue: 1){// 平移
                    item.builder.holder.posX = Double(info.pos.x)
                    item.builder.holder.posY = Double(info.pos.y)
                }else if info.type ==  TuTextItemView_TransformType(rawValue: 2){// 缩放
                    item.builder.holder.fontScale = Double(info.scale)
                }else if info.type ==  TuTextItemView_TransformType(rawValue: 3){// 旋转
                    item.builder.holder.rotation = Int32(info.rotation)
                }
                updateTextView(item: item)
            }
        }
        

    }
    
    /**
     *  获取当前预览进度
     *
     *  @param builder 数据
     */
    func presentProgress() -> Int {
        return Int(controlView.currentProg() * Float(videoDuration))
    }
    
    
    @objc private func paramChangeNotification(_ notification: Notification) {
        guard let builder = notification.object as? TUPVEText2DClip_PropertyBuilder else { return }
        currentItem?.builder.holder.textScaleX  = builder.holder.textScaleX
        currentItem?.builder.holder.textScaleY  = builder.holder.textScaleY
        currentItem?.builder.holder.strokeColor = builder.holder.strokeColor
        currentItem?.builder.holder.strokeWidth = builder.holder.strokeWidth
        currentItem?.builder.holder.fillColor   = builder.holder.fillColor
        currentItem?.builder.holder.bgColor     = builder.holder.bgColor
        currentItem?.builder.holder.underline   = builder.holder.underline
        currentItem?.builder.holder.alignment   = builder.holder.alignment
        updateTextView(item: currentItem!)
    }
    
    @objc private func paramValueChangeNotification(_ notification: Notification) {
        guard let item = notification.object as? TextViewModel else { return }
        currentItem = item
        updateBlend(value: currentItem!.blendValue)
    }
    
    @objc private func paramOrderChangeNotification(_ notification: Notification) {
        guard let item = currentItem else {return}
        updateTextContent(String(item.builder.holder.text.reversed()))
    }
    
    @objc private func paramBlendChangeNotification(_ notification: Notification) {
        guard let mode = notification.object as? String else { return }
        self.updateBlend(mode: mode)
    }
    @objc private func paramAlphaChangeNotification(_ notification: Notification) {
        guard let item = notification.object as? TextViewModel else { return }
        let builder = TUPVEditorLayer_OverlayPropertyBuilder()
        builder.holder.opacity = item.opacity
        viewModel.editor.videoComposition().getLayer(item.index)?.setProperty(builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
        player.previewFrame(currentTs)
    }
    /**
     *  预览播放通知
     *
     *  @param notification
     */
    @objc private func doPlayNotification(_ notification: Notification) {
        //guard let time = notification.object as? Int else { return }
        
        DispatchQueue.main.async {
            if let item = self.currentItem {
                self.overlayView.presentview(item.vid,show:false)
            }
            
            self.cancelBarView()
            self.currentItem = nil
            self.tableView.reloadData()
        }
        
    }
    
    /**
     *  播放进度通知
     *
     *  @param notification
     */
    @objc private func timeChangeNotification(_ notification: Notification) {
        guard let ts = notification.object as? Int else { return }
        
        guard let item = currentItem  else { return }
        printTu(ts, item.startTs, item.endTs)
        
        if ts < item.startTs || ts > item.endTs {
            DispatchQueue.main.async {
                self.overlayView.presentview(item.vid,show:false)
                self.currentItem = nil
                self.cancelBarView()
                self.tableView.reloadData()
            }
        }
    }
    
    /**
     *  更新文本
     *
     *  @param title 文本
     */
    private func updateTextContent(_ title: String) {
        currentItem?.builder.holder.text = title
        updateTextView(item: currentItem!)
    }
    
    /**
     *  更新文字view
     */
    private func updateTextView(item : TextViewModel) {
        
        guard let info = textStickerUpdateProperty(item: item) else { return }
        
        let rect = CGRect(x:CGFloat(info.posX), y:CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
        
        overlayView.redraw(item.vid,rect:rect,rotation:info.rotation)
        
        player.previewFrame(currentTs)
    }
    
    private func updateBlend(mode: String) {
        guard let currentItem = currentItem else { return }
        
        currentItem.blendMode = mode
        fetchLock()
        
        textStrickerBlend(item: currentItem)
        
        fetchUnlock(autoPlay: false)
        
        player.seek(to: currentTs)
        
        player.previewFrame(currentTs)
    }
    private func updateBlend(value: Float) {
        guard let currentItem = currentItem else { return }
        
        fetchLock()
        
        textStrickerUpdateBlend(item: currentItem, value: value)
        
        fetchUnlock(autoPlay: false)
        
        player.seek(to: currentTs)
        
        player.previewFrame(currentTs)
    }
    
    /**
     *  更新文字显示时间轴
     *
     *  @param begin 起始时间点
     *  @param end   结束时间点
     */
    private func updateDuration(begin: Float, end: Float) {
        guard let item = currentItem else { return }
        
        fetchLock()
        
        textStickerUpdateDuration(item: item, begin: begin, end: end)
        
        fetchUnlock(autoPlay: false)
        
        item.startTs = Int(begin * Float(videoDuration))
        item.endTs = Int(end * Float(videoDuration))
        
        overlayView.setTimeline(item.vid, startTs:item.startTs, endTs:item.endTs)
        
        controlView.updateProgress(current: item.startTs, duration: videoDuration)
        self.player.seek(to: item.startTs)
        self.player.previewFrame(item.startTs)

        
    }
    
}
extension TextEditorViewController {
    func setupView() {
        overlayView.delegate = self
        overlayView.interactionRect = interactionRect
        overlayView.interactionRatio = viewModel.videoNaturalSize.height / interactionRect.height
//        displayView.addSubview(overlayView)
//        displayView.bringSubviewToFront(overlayView)
        displayView.insertSubview(overlayView, at: 0)

        overlayView.editBlock = {[weak self] in
            guard let `self` = self else { return }
            var text = self.currentItem?.builder.holder.text
            if text == defaultText {
                self.textView.placeholder = defaultText as NSString
                text = ""
            }
            self.textView.text = text
            self.textView.superview?.isHidden = false
            self.textView.becomeFirstResponder()
        }
        overlayView.closeBlock = {[weak self] in
            guard let `self` = self else { return }
            self.removeTextView()
        }
        
        barView.multiBetweenThumbs(distance: minTimeInterval/Float(videoDuration))
        contentView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(10)
            make.height.equalTo(60)
        }
        barView.multiDragEndedCompleted = {[weak self] begin,end in
            guard let `self` = self else { return }
            self.updateDuration(begin: begin, end: end)
        }
        
        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(TextEditorParamCell.self, forCellReuseIdentifier: "TextEditorParamCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp_bottom)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
    }
    
    /**
     *  文字时间轴view，设置为不可编辑状态
     */
    @objc func cancelBarView() {
        barView.multiSlider.value = [0, 0]
        barView.isUserInteractionEnabled = false
    }
    
    /**
     *  文字时间轴view，设置为可编辑状态，
     *   并设置当前选中的文字view
     */
    func openBarView() {
        guard let item = currentItem else {
            return
        }
        
        barView.isUserInteractionEnabled = true
        let v0 = CGFloat(item.startTs) / CGFloat(videoDuration)
        let v1 = CGFloat(item.endTs) / CGFloat(videoDuration)

        barView.multiSlider.value = [v0, v1]
    }
    
}
extension TextEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextEditorParamCell") as! TextEditorParamCell
        cell.builder = currentItem?.builder
        cell.textItem = currentItem
        cell.addTextEditorCompleted = {[weak self] in
            guard let `self` = self else { return }
            self.initializeTextSticker()
            
        }
        return cell
    }
}

extension TextEditorViewController: RSKGrowingTextViewDelegate {
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(paramChangeNotification(_:)), name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paramValueChangeNotification(_:)), name: NSNotification.Name.init("TextEditorParamVlaueChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paramOrderChangeNotification(_:)), name: NSNotification.Name.init("TextEditorParamOrderNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paramBlendChangeNotification(_:)), name: NSNotification.Name.init("TextEditorParamBlendChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paramAlphaChangeNotification(_:)), name: NSNotification.Name.init("TextEditorAlphaChangeNotification"), object: nil)

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeChangeNotification(_:)), name: NSNotification.Name.init("EditorTimeChangeNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(doPlayNotification(_:)), name: NSNotification.Name.init("EditorDoPlayNotification"), object: nil)
        
        
    }
    //MARK:键盘通知相关操作
    @objc func keyBoardWillShow(_ notification:Notification){
        DispatchQueue.main.async {
            let user_info = notification.userInfo
            let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardHeight = keyboardRect.height
            self.textView.snp.updateConstraints { (make) in
                make.bottom.equalTo(-keyboardHeight)
            }
            //动画
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc private func textDismissAction() {
        textView.resignFirstResponder()
        textView.superview?.isHidden = true
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        if textView.text == "请输入文字" {
//            textView.text = ""
//            //updateTextContent(textView.text)
//        }
        return true
    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text == "" {
//            textView.text = "请输入文字"
//        }
//        updateTextContent(textView.text)
//        
//    }
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let textArray = textView.text.components(separatedBy: CharacterSet.whitespaces)
//        let inputText = textArray.joined()
//        updateTextContent(inputText)
//        return true
//    }
    func textViewDidChange(_ textView: UITextView) {
        //        let inputText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let textArray = textView.text.components(separatedBy: CharacterSet.whitespaces)
        var inputText = textArray.joined()
        if inputText == "" {
            inputText = defaultText
        }
        updateTextContent(inputText)
    }
}



class TextEditorParamCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items:[(String, String)] = [("新增","edit_ic_add"),("颜色","edit_ic_colour"),("不透明度","t_ic_transparency"),("描边","t_ic_stroke"),("背景","t_ic_bg"),("间距","t_ic_space"),("对齐","t_ic_align"),("排列","t_ic_array"),("样式","edit_ic_style"),("混合模式","t_ic_transparency")]
    lazy var paramView: TextEditorParamView = {
        return TextEditorParamView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 200))
    }()
    var addTextEditorCompleted:(()->Void)?
    var builder: TUPVEText2DClip_PropertyBuilder? {
        didSet {
            paramView.builder = builder
        }
    }
    var lastIndex : Int?
    var textItem: TextEditorViewController.TextViewModel? {
        didSet {
            
            paramView.textItem = textItem
            
            if textItem == nil {
                cancelParamView()
            }else {
                if  let index = lastIndex {
                    paramView.show(index: index)
                }
            }
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .black
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterListCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        collectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
            make.top.equalTo(10)
        }
        paramView.isHidden = true
        self.addSubview(paramView)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! FilterListCell
        cell.textItem = items[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 添加文字view
            addTextEditorCompleted?()
        } else {
            // 打开文字属性view
            openParamView(index : indexPath.row)
        }
    }
    
    /**
     *  关闭文字属性view
     */
    func cancelParamView() {
        paramView.isHidden = true
    }
    
    /**
     *  打开文字属性view
     *   并设置当前选择文字
     */
    func openParamView(index : Int) {
        guard let _ = textItem else {
            return
        }
        
        paramView.isHidden = false
        paramView.show(index: index)
        lastIndex = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

