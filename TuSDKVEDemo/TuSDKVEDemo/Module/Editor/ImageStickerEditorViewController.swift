//
//  ImageStickerEditorViewController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/11.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit

class ImageStickerEditorViewController: EditorViewController {
    
    enum LayerType {
        case picture
        case video
        
    }

    class ImageItem {
        static var ModelIndex : Int = 0
        
        var type: LayerType?            // 文件类型
        var index: Int = 0              // 索引
        var vid: Int = 0                // 唯一标识
        var path: String = ""           // 源文件路径
        var blendMode: String = ""      // 混合模式
        var blendStrength: Float = 0    // 混合模式
        var clipStartTs : Int = 0       // clip起始时间
        var clipEndTs : Int = 0         // clip结束时间
        var layerStartTs : Int = 0      // layer起始时间
        var layerEndTs : Int = 0        // layer结束时间
        var videoDuration: Int = 0      // 资源时长/ms
        var image: UIImage?             // 缩略图
                
        var videoClip: TUPVEditorClip?
        var audioClip: TUPVEditorClip?
        var videoLayer: TUPVEditorClipLayer?
        var audioLayer: TUPVEditorClipLayer?
        var builder = TUPVEditorLayer_OverlayPropertyBuilder()
        
        init(ctx: TUPVEditorCtx,viewModel: SourceViewModel.Item) {
            if viewModel.model.state == .picture {
                type = .picture
                videoClip = TUPVEditorClip(ctx, withType: TUPVEImageClip_TYPE_NAME)
                audioClip = TUPVEditorClip(ctx, withType: TUPVESilenceClip_AUDIO_TYPE_NAME)
                videoLayer = TUPVEditorClipLayer(forVideo: ctx)
                audioLayer = TUPVEditorClipLayer(ctx,forVideo:false)
                path = viewModel.model.path
            }else if viewModel.model.state == .video {
                type = .video
                videoClip = TUPVEditorClip(ctx, withType: TUPVEFileClip_VIDEO_TYPE_NAME)
                audioClip = TUPVEditorClip(ctx, withType: TUPVEFileClip_AUDIO_TYPE_NAME)
                videoLayer = TUPVEditorClipLayer(forVideo: ctx)
                audioLayer = TUPVEditorClipLayer(ctx,forVideo:false)
                path = viewModel.model.path
            }
            
            blendMode = TUPVEditorLayerBlendMode_None
            blendStrength = 1
            self.image = viewModel.model.coverImage!
            vid = (ImageItem.ModelIndex + 1)
            index = vid
            ImageItem.ModelIndex += 1
            
            builder.holder.pzrRotate = 0
        }
        
        init(idx : Int){
            index = idx
            vid = idx
            ImageItem.ModelIndex += idx
        }
        
    }
    
    // 触控view
    private let overlayView = TuImageOverlayView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.width()))
    
    // 属性标题view
    private let titleTableView = UITableView()
    
    // 图层列表view
    private let layerTableView = UITableView()
    
    // 时间轴view
    private let timeLineView = UIView()

    private let timeLineBar = SliderBarView(title: "素材起止位置", state: .multi)

    private lazy var timeLineTitle : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    // 混合模式view
    let blendView = UIView()

    // 混合模式强度
    let blendSlider = SliderBarView(title: "混合强度", state: .native)

    // 混合模式subview
    var collectionView : UICollectionView?

    
    enum TitlesState {
        case unselected
        case selected
        case edit
    }
    let titles = ["图层列表", "素材混合模式", "素材时长", "添加一张图片/视频","返回首页"]
    
    var titlesToggle = [true, true, true, true,false]
    
    var blendItems:[(String, String, Bool)] = [(TUPVEditorLayerBlendMode_None,"无",true),
                                               (TUPVEditorLayerBlendMode_Normal,"正常",false),
                                               (TUPVEditorLayerBlendMode_Overlay,"叠加",false),
                                               (TUPVEditorLayerBlendMode_Add, "相加", false),
                                               (TUPVEditorLayerBlendMode_Subtract, "减去", false),
                                               (TUPVEditorLayerBlendMode_Negation, "反色", false),
                                               (TUPVEditorLayerBlendMode_Average, "均值", false),
                                               (TUPVEditorLayerBlendMode_Multiply,"正片叠底", false),
                                               (TUPVEditorLayerBlendMode_Difference, "差值", false),
                                               (TUPVEditorLayerBlendMode_Screen, "滤色", false),
                                               (TUPVEditorLayerBlendMode_Softlight, "柔光", false),
                                               (TUPVEditorLayerBlendMode_Hardlight, "强光", false),
                                               (TUPVEditorLayerBlendMode_Linearlight,"线性光",false),
                                               (TUPVEditorLayerBlendMode_Pinlight,"点亮",false),
                                               (TUPVEditorLayerBlendMode_Lighten, "变亮",false),
                                               (TUPVEditorLayerBlendMode_Darken,"变暗", false),
                                               (TUPVEditorLayerBlendMode_Exclusion, "排除", false)]
    
    
    // 所有image数组
    var viewItems: [ImageItem] = []
    
    // 当前选中image
    var currentItem: ImageItem?
    
    // 记录上一次播放进度
    var lastTs : Int = 0
    
    lazy var imagePicker: ImagePicker = {
        let ip = ImagePicker()
        ip.maxCount = 1
        ip.state = .both
        return ip
    }()
    
    override init(scene: Navigator.Scene, viewModel: SourceViewModel) {
        super.init(scene: scene, viewModel: viewModel)

        // 重写父类构造函数
        let item = ImageItem(ctx: adapter.ctx,viewModel:viewModel.items[0])

        if item.type == .picture {
            // 图片默认时长
            item.clipStartTs = 0
            item.clipEndTs = 3000
            item.videoDuration = 3000
            item.layerStartTs = 0
            item.layerEndTs = 3000
            
            let iClipConfig = TUPConfig()
            iClipConfig.setString(TuFileManager.absolute(state: .images, name: item.path), forKey: TUPVEImageClip_CONFIG_PATH)
            
            iClipConfig.setNumber(NSNumber(value: Int(adapter.naturalSize.height)), forKey: TUPVEImageClip_CONFIG_MAX_SIDE)
            iClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey: TUPVEImageClip_CONFIG_DURATION)
            item.videoClip!.setConfig(iClipConfig)
            var ret = item.videoClip!.activate()
            printResult("activate image clip", result: ret)
            item.videoLayer!.add(item.videoClip!, at: 600)
            adapter.videoComp.add(item.videoLayer!, at: item.index)
            
            let aClipConfig = TUPConfig()
            aClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey:TUPVESilenceClip_CONFIG_DURATION)
            item.audioClip!.setConfig(aClipConfig)
            ret = item.audioClip!.activate()
            printResult("activate audio clip", result: ret)
            item.audioLayer!.add(item.audioClip!, at: 600)
            adapter.audioComp.add(item.audioLayer!, at: item.index)
            
        }else if item.type == .video {
            let config = TUPConfig()
            config.setString(item.path, forKey: TUPVEFileClip_CONFIG_PATH)
            
            item.videoClip!.setConfig(config)
            var ret = item.videoClip!.activate()
            printResult("activate video clip", result: ret)
            item.videoLayer!.add(item.videoClip!, at: 600)
            adapter.videoComp.add(item.videoLayer!, at: item.index)
            
            item.audioClip!.setConfig(config)
            ret = item.audioClip!.activate()
            printResult("activate audio clip", result: ret)
            item.audioLayer!.add(item.audioClip!, at: 600)
            adapter.audioComp.add(item.audioLayer!, at: item.index)
            
            // 加载视频后获取时长
            item.clipStartTs = 0
            item.clipEndTs = Int(item.videoClip!.getStreamInfo()!.duration)
            item.videoDuration = item.clipEndTs
            item.layerStartTs = 0
            item.layerEndTs = item.clipEndTs
        }

        adapter.build()
        
        currentItem = item
        viewItems.append(item)
        
    }
    
    override init(scene: Navigator.Scene, draftPath: String) {
        super.init(scene: scene, draftPath: draftPath)
        
        let audioComp = adapter.editor.audioComposition()
        let videoComp = adapter.editor.videoComposition()

        for key in videoComp.getAllLayers().keys {
            let audioLayer = audioComp.getLayer(Int(key)) as! TUPVEditorClipLayer
            let videoLayer = videoComp.getLayer(Int(key)) as! TUPVEditorClipLayer
            let audioClip = audioLayer.getClip(600)
            let videoClip = videoLayer.getClip(600)!
            
            var builder = TUPVEditorLayer_OverlayPropertyBuilder()
            if let prop = videoLayer.getProperty(TUPVEditorLayer_PROP_OVERLAY) {
                let holder = TUPVEditorLayer_OverlayPropertyHolder(property: prop)
                builder = TUPVEditorLayer_OverlayPropertyBuilder(holder: holder)
            }

            
            let typeName = videoClip.getType()
            let type = typeName == "v:FILE" ? LayerType.video : LayerType.picture
            
            let path = videoClip.getConfig().getString(TUPVEFileClip_CONFIG_PATH)
            
            let image = ImagePicker.fetchShotImage(filePath: path)
            
            let blendMode = videoLayer.getConfig().getString(TUPVEditorLayer_CONFIG_BLEND_MODE, or: "")
            
            let layerStartTs = videoLayer.getConfig().getIntNumber(TUPVEditorLayer_CONFIG_START_POS, or: 0)


            let item = ImageItem(idx: Int(key))
            item.type = type
            item.path = path
            item.image = image
            item.blendMode = blendMode
            item.blendStrength = builder.holder.blendStrength
            

            if type == .picture {
                let duration = videoClip.getConfig().getIntNumber(TUPVEImageClip_CONFIG_DURATION, or: 0)
                
                item.clipStartTs = 0
                item.clipEndTs = duration
                item.videoDuration = duration
                item.layerStartTs = layerStartTs
                item.layerEndTs = layerStartTs + duration

            }else if type == .video {
                let clipStartTs = videoClip.getConfig().getIntNumber(TUPVEFileClip_CONFIG_TRIM_START, or: 0)
                let duration = videoClip.getConfig().getIntNumber(TUPVEFileClip_CONFIG_TRIM_DURATION, or: 0)

                item.clipStartTs = clipStartTs
                item.clipEndTs = clipStartTs + duration
                item.videoDuration = Int(TUPMediaInspector.shared().inspect(path).streams[0].duration)
                item.layerStartTs = layerStartTs
                item.layerEndTs = layerStartTs + duration
            }


            item.audioLayer = audioLayer
            item.videoLayer = videoLayer
            item.audioClip = audioClip
            item.videoClip = videoClip
            item.builder = builder
            
            viewItems.append(item)
        }
        
        viewItems.sort { (item1, item2) -> Bool in
            return item1.index < item2.index
        }
        
        adapter.build()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {

        super.originalDuration = adapter.getDuration()
        super.audioDuration = adapter.getAuidoDuration()
        super.initView()
        
        setupView()
        createTimeLineView()
        createBlendView()
        registerNotification()
        
        for item in viewItems {

            if(isDraft){
                guard let info = updateProperty(item: item) else { return }
                let rect = CGRect(x:CGFloat(info.posX), y:CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
                overlayView.createView(item.vid,startTs:item.layerStartTs,endTs:item.layerEndTs, scale: item.builder.holder.pzrZoom,rect:rect,rotation:Int32(info.rotation));
            }else{
                overlayView.createView(item.vid, startTs:item.layerStartTs, endTs:item.layerEndTs, scale: item.builder.holder.pzrZoom)
            }
        }
        
        if currentItem == nil {
            updateTitlesToggle(state: .unselected)
        }

    }
    
    deinit {
        printLog("deinit")
    }
}

extension ImageStickerEditorViewController: TuImageOverlayViewDelegate {
    @objc func addAction() {
        
        imagePicker.showImagePicker(sender: self) {[weak self] (result) in
            guard let `self` = self, let result = result else { return }
            self.appendImageView(viewModel: result.items[0])
        }
    }
    
    /**
     *  添加一个image view
     *
     *  @param item image item
     */
    private func appendImageView(viewModel: SourceViewModel.Item) {
        
        fetchLock()
        defer {
            fetchUnlock(autoPlay: false)
        }
        
        let item = ImageItem(ctx: adapter.ctx,viewModel:viewModel)

        
        if item.type == .picture {
            
            // 图片默认时长
            item.clipStartTs = 0
            item.clipEndTs = 3000
            item.videoDuration = 3000
            item.layerStartTs = currentTs
            item.layerEndTs = currentTs + 3000
            
            let iClipConfig = TUPConfig()
            iClipConfig.setString(TuFileManager.absolute(state: .images, name: item.path), forKey: TUPVEImageClip_CONFIG_PATH)
            
            iClipConfig.setNumber(NSNumber(value: Int(adapter.naturalSize.height)), forKey: TUPVEImageClip_CONFIG_MAX_SIDE)
            iClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey: TUPVEImageClip_CONFIG_DURATION)
            item.videoClip!.setConfig(iClipConfig)
            var ret = item.videoClip!.activate()
            printResult("activate image clip", result: ret)
            item.videoLayer!.add(item.videoClip!, at: 600)
            adapter.videoComp.add(item.videoLayer!, at: item.index)
            
            let aClipConfig = TUPConfig()
            aClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey:TUPVESilenceClip_CONFIG_DURATION)
            item.audioClip!.setConfig(aClipConfig)
            ret = item.audioClip!.activate()
            printResult("activate audio clip", result: ret)
            item.audioLayer!.add(item.audioClip!, at: 600)
            adapter.audioComp.add(item.audioLayer!, at: item.index)
            
        }else if item.type == .video {
            let config = TUPConfig()
            config.setString(item.path, forKey: TUPVEFileClip_CONFIG_PATH)
            
            item.videoClip!.setConfig(config)
            var ret = item.videoClip!.activate()
            printResult("activate video clip", result: ret)
            item.videoLayer!.add(item.videoClip!, at: 600)
            adapter.videoComp.add(item.videoLayer!, at: item.index)
            
            item.audioClip!.setConfig(config)
            ret = item.audioClip!.activate()
            printResult("activate audio clip", result: ret)
            item.audioLayer!.add(item.audioClip!, at: 600)
            adapter.audioComp.add(item.audioLayer!, at: item.index)
            
            // 加载视频后获取时长
            item.clipStartTs = 0
            item.clipEndTs = Int(item.videoClip!.getStreamInfo()!.duration)
            item.videoDuration = item.clipEndTs
            item.layerStartTs = currentTs
            item.layerEndTs = currentTs + item.clipEndTs
        }
        
        // 第一个为背景素材，后面的素材size缩小0.5,layer 起始点从当前播放进度开始算
        var isFirst: Bool = viewItems.count == 0 ? true : false
        
        if !isFirst {
            
            let vLayer = item.videoLayer!

            item.builder.holder.pzrZoom = 0.5
            vLayer.setProperty(item.builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
            
            let vConfig = vLayer.getConfig()
            vConfig.setNumber(NSNumber(value: currentTs), forKey: TUPVEditorLayer_CONFIG_START_POS)
            vLayer.setConfig(vConfig)
            
            let aLayer = item.audioLayer!

            let aConfig = aLayer.getConfig()
            aConfig.setNumber(NSNumber(value: currentTs), forKey: TUPVEditorLayer_CONFIG_START_POS)
            aLayer.setConfig(aConfig)
            
        }

        adapter.build()

        currentItem = item
        
        viewItems.append(item)
        
        overlayView.createView(item.vid, startTs:item.layerStartTs, endTs:item.layerEndTs, scale: item.builder.holder.pzrZoom)
        
        updatePlayProgress()
        
        updateTitlesToggle(state: .selected)
        
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
                
                if !layerTableView.isHidden {
                    layerTableView.reloadData()
                }else if !timeLineView.isHidden {
                    timeLineBar.multiSlider.value[0] = CGFloat(item.clipStartTs) / CGFloat(item.videoDuration)
                    timeLineBar.multiSlider.value[1] = CGFloat(item.clipEndTs) / CGFloat(item.videoDuration)
                    
                    timeLineTitle.text = "当前片段开始时间\(item.clipStartTs.formatTime()) 结束时间\(item.clipEndTs.formatTime()) \n当前图片偏移:\(item.layerStartTs.formatTime())"

                }else if !blendView.isHidden {
                    blendSlider.slider.value = item.blendStrength
                    for(index, blend) in blendItems.enumerated() {
                        blendItems[index].2 = blend.0 == item.blendMode ? true : false
                    }
                    collectionView?.reloadData()
                }else {
                    updateTitlesToggle(state: .selected)
                }
                
                
                // 暂停播放
                applyPause()
            }
        }
    }
    
    /**
     *  未选中状态
     *
     */
    func onUnSelected() {
        
        currentItem = nil
        
        closePropEditVIew()
        
        updateTitlesToggle(state: .unselected)
        
    }
    
    /**
     *  更新图像属性
     *
     *  @param builder 数据
     */
    func updatePropBuilder(_ vid : Int, info : TuImageItemInfo) {
        
        
        for (_,item) in viewItems.enumerated() {
            if item.vid == vid {
                
                if info.type ==  TuImageItemView_TransformType(rawValue: 1){// 平移
                    item.builder.holder.pzrPanX = Float(info.pos.x)
                    item.builder.holder.pzrPanY = Float(info.pos.y)
                }else if info.type ==  TuImageItemView_TransformType(rawValue: 2){// 缩放
                    item.builder.holder.pzrZoom = Float(info.scale)
                }else if info.type ==  TuImageItemView_TransformType(rawValue: 3){// 旋转
                    item.builder.holder.pzrRotate = Double(info.rotation)
                }
                updateEditor(item : item)
            }
        }

    }
    
    /**
     *  获取当前预览进度
     *
     *  @param builder 数据
     */
    func presentTs() -> Int {
        return Int(controlView.currentProg() * Float(currentMaxDuration()))
    }
    
    private func updateEditor(item : ImageItem) {

        guard let info = updateProperty(item: item) else { return }
        
        let rect = CGRect(x:CGFloat(info.posX), y:CGFloat(info.posY), width: CGFloat(info.width), height: CGFloat(info.height))
        
        overlayView.redraw(item.vid,rect:rect,rotation:Int32(info.rotation))
        
        player.previewFrame(currentTs)
    }
    
    func updateProperty(item : ImageItem) -> TUPVEditorLayer_InteractionInfo? {
        if item.type == .picture {
            item.videoLayer!.setProperty(item.builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
            guard let resultProperty = item.videoLayer!.getProperty(TUPVEditorLayer_PROP_INTERACTION_INFO) else { return  nil}
            return TUPVEditorLayer_InteractionInfo(resultProperty)
        }else if item.type == .video {
            item.videoLayer!.setProperty(item.builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
            guard let resultProperty = item.videoLayer!.getProperty(TUPVEditorLayer_PROP_INTERACTION_INFO) else { return  nil}
            return TUPVEditorLayer_InteractionInfo(resultProperty)
        }
        return nil
    }
    
    private func updateBlend(mode: String) {
        guard let item = currentItem else { return }
        item.blendMode = mode
        fetchLock()
        
        if let vlayer = item.videoLayer {
            var vlayerConfig = vlayer.getConfig()
            
            vlayerConfig.setString(item.blendMode, forKey: TUPVEditorLayer_CONFIG_BLEND_MODE)
            vlayer.setConfig(vlayerConfig)
            adapter.build()
        }

        
        fetchUnlock(autoPlay: false)
        
        player.previewFrame(currentTs)
    }
    
    private func updateBlend(value: Float) {
        guard let item = currentItem else { return }
        fetchLock()
        
        item.blendStrength = value
        
        if let vlayer = item.videoLayer {
            item.builder.holder.blendStrength = value
            vlayer.setProperty(item.builder.makeProperty(), forKey: TUPVEditorLayer_PROP_OVERLAY)
        }
        
        fetchUnlock(autoPlay: false)

        player.previewFrame(currentTs)
    }

    
    /**
     *  更新时间轴
     *
     *  @param begin 开始点
     *  @param end   结束点
     */
    private func updateDuration(begin: Float, end: Float) {
        guard let item = currentItem else { return }
        
        item.clipStartTs = Int(begin * Float(item.videoDuration))
        item.clipEndTs = Int(end * Float(item.videoDuration))
        item.layerEndTs = item.layerStartTs + item.clipEndTs - item.clipStartTs
        
        fetchLock()
        
        if item.type == .picture {
            let iClipConfig = item.videoClip!.getConfig();
            iClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey: TUPVEImageClip_CONFIG_DURATION)
            item.videoClip!.setConfig(iClipConfig)
            
            let ilayer = adapter.audioComp.getLayer(item.index)!
            let ilayerConfig = ilayer.getConfig()

            ilayerConfig.setNumber(NSNumber(value: item.layerStartTs), forKey: TUPVEditorLayer_CONFIG_START_POS)
            ilayer.setConfig(ilayerConfig)
        }else if item.type == .video {
            
            let vClipConfig = item.videoClip!.getConfig();
            let aClipConfig = item.audioClip!.getConfig();
            
            let vlayer = adapter.videoComp.getLayer(item.index)!
            let vlayerConfig = vlayer.getConfig()
            
            let alayer = adapter.audioComp.getLayer(item.index)!
            let alayerConfig = alayer.getConfig()
            
            vClipConfig.setNumber(NSNumber(value: item.clipStartTs), forKey: TUPVEFileClip_CONFIG_TRIM_START)
            vClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey: TUPVEFileClip_CONFIG_TRIM_DURATION)
            aClipConfig.setNumber(NSNumber(value: item.clipStartTs), forKey: TUPVEFileClip_CONFIG_TRIM_START)
            aClipConfig.setNumber(NSNumber(value: item.clipEndTs - item.clipStartTs), forKey: TUPVEFileClip_CONFIG_TRIM_DURATION)

            item.videoClip!.setConfig(vClipConfig)
            vlayer.setConfig(vlayerConfig)
            
            
            item.audioClip!.setConfig(vClipConfig)
            alayer.setConfig(alayerConfig)
        }
        
        adapter.build()
        
        fetchUnlock(autoPlay: false)
        
        overlayView.setTimeline(item.vid,startTs:item.layerStartTs,endTs:item.layerEndTs)
        
        controlView.updateProgress(current: item.layerStartTs, duration: currentMaxDuration())
        
        self.player.previewFrame(item.layerStartTs)
        
        timeLineTitle.text = "当前片段开始时间\(item.clipStartTs.formatTime()) 结束时间\(item.clipEndTs.formatTime()) \n当前图片偏移:\(item.layerStartTs.formatTime())"

    }

    
    /**
     *  更新播放进度条
     */
    func updatePlayProgress() {
        
        // 没有image view,设置默认时长30s
        if viewItems.count == 0 {
            controlView.updateProgress(current: currentTs, duration: Int(30000))
            return
        }
        
        var maxDuring = currentMaxDuration()
        
        if currentTs > maxDuring {
            currentTs = maxDuring
        }
        controlView.updateProgress(current: currentTs, duration: Int(maxDuring))
    }
    
    /**
     *  更新属性标题开关
     *
     *  @param show 开关
     */
    func updateTitlesToggle(state : TitlesState) {
        
        switch state {
        case .unselected:
            titlesToggle = [true, false, false, true, false]
            titleTableView.snp.updateConstraints { (make) in
                make.height.equalTo(80)
            }
        case .selected:
            titlesToggle = [true, true, true, true, false]
            titleTableView.snp.updateConstraints { (make) in
                make.height.equalTo(160)
            }
        case .edit:
            titlesToggle = [false, false, false, false, true]
            titleTableView.snp.updateConstraints { (make) in
                make.height.equalTo(40)
            }
        default:
            ()
        }
        titleTableView.reloadData()
        
    }
    
    /**
     *  关闭属性编辑view
     *
     */
    func  closePropEditVIew() {
        timeLineView.isHidden = true
        blendView.isHidden = true
        layerTableView.isHidden = true
    }
    
    /**
     *  删除图像view
     */
    private func removeImageView() {
        guard let item = self.currentItem else {return}
        fetchLock()
        defer {
            fetchUnlock(autoPlay: false)
        }
        
        if item.type == .picture {
            adapter.videoComp.deleteLayer(at: item.index)
        }else if item.type == .video {
            adapter.videoComp.deleteLayer(at: item.index)
            adapter.audioComp.deleteLayer(at: item.index)
        }
        adapter.build()
        
        if let index = viewItems.firstIndex(where: { i -> Bool in
            return i.vid == item.vid
        }){
            viewItems.remove(at: index)
        }
        
        currentItem = nil
        
        updatePlayProgress()
        
        if viewItems.count == 0 {
            updateTitlesToggle(state: .unselected)
        }
        
        DispatchQueue.main.async {
            self.player.previewFrame(self.currentTs)
        }
    }
    
    /**
     *  更新播放进度条
     */
    func currentMaxDuration()-> Int {
        
        // 遍历获取最大时长并更新
        var maxDuring :Int = 0
        for item in viewItems {
            if maxDuring < item.layerEndTs {
                maxDuring = item.layerEndTs
            }
        }
        return maxDuring
    }
    
    func swapItem(idx0: Int, idx1: Int) {
        
        if idx0 == idx1 {
            return
        }
        
        fetchLock()
        
        let srcIndex = viewItems.count - idx0 - 1
        let destIndex = viewItems.count - idx1 - 1
                
        var step : Int = 1

        if destIndex > srcIndex  {
            step = 1
        }else if destIndex < srcIndex {
            step = -1
        }
        
        for index in stride(from: srcIndex, to: destIndex, by: step) {
            let next = index + step
            let srcModel = viewItems[index]
            let destModel = viewItems[next]

            let vSrclayer = adapter.videoComp.getLayer(srcModel.index)!
            let vDestlayer = adapter.videoComp.getLayer(destModel.index)!
            
            let aSrclayer = adapter.audioComp.getLayer(srcModel.index)!
            let aDestlayer = adapter.audioComp.getLayer(destModel.index)!
            
            adapter.videoComp.swapLayer(vSrclayer,and:vDestlayer)
            adapter.audioComp.swapLayer(aSrclayer,and:aDestlayer)
            adapter.build()
        }
        
        for index in stride(from: srcIndex, to: destIndex, by: step) {
            let next = index + step

            overlayView.swapview(viewItems[index].vid,dest:viewItems[next].vid)
            
            viewItems.swapAt(index, next)

            var tmp = viewItems[index].index
            viewItems[index].index = viewItems[next].index
            viewItems[next].index = tmp
        }
        
        fetchUnlock(autoPlay: false)
        
        self.player.previewFrame(self.currentTs)
    }
}

extension ImageStickerEditorViewController {
    func registerNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeChangeNotification(_:)), name: NSNotification.Name.init("ImageEditorTimeChangeNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(doPlayNotification(_:)), name: NSNotification.Name.init("ImageEditorDoPlayNotification"), object: nil)
    }
    
    /**
     *  预览播放通知
     *
     *  @param notification
     */
    @objc private func doPlayNotification(_ notification: Notification) {
        guard let time = notification.object as? Int else { return }
        
        DispatchQueue.main.async {
            if let item = self.currentItem {
                self.overlayView.presentview(item.vid,show:false)
            }
            
            self.currentItem = nil
            self.titleTableView.reloadData()
        }
    }
    
    /**
     *  播放进度通知
     *
     *  @param notification
     */
    @objc private func timeChangeNotification(_ notification: Notification) {
        guard let time = notification.object as? Int else { return }
        
        guard let item = currentItem  else { return }
        
        if time < item.layerStartTs || time > item.layerEndTs {
            DispatchQueue.main.async {
                self.overlayView.presentview(item.vid,show:false)
                self.currentItem = nil
                self.titleTableView.reloadData()
            }
        }
    }
}

extension ImageStickerEditorViewController {
    
    func setupView() {
        
        overlayView.delegate = self
        overlayView.interactionRect = interactionRect
        overlayView.interactionRatio = adapter.naturalSize.height / interactionRect.height
        displayView.insertSubview(overlayView,at: 0)
        
        overlayView.closeBlock = {[weak self] in
            guard let `self` = self else { return }
            self.removeImageView()
        }
        
        titleTableView.backgroundColor = .black
        titleTableView.dataSource = self
        titleTableView.delegate = self
        titleTableView.bounces = false
        titleTableView.showsVerticalScrollIndicator = false
        titleTableView.separatorStyle = .none
        titleTableView.register(TitleEditorNormalCell.self, forCellReuseIdentifier: "TitleEditorNormalCell")
        view.addSubview(titleTableView)
        
        layerTableView.backgroundColor = .black
        layerTableView.dataSource = self
        layerTableView.delegate = self
        layerTableView.bounces = false
        layerTableView.showsVerticalScrollIndicator = false
        layerTableView.separatorStyle = .none
        layerTableView.isHidden = true
        layerTableView.isEditing = true
        layerTableView.register(LayerEditorNormalCell.self, forCellReuseIdentifier: "LayerEditorNormalCell")
        view.addSubview(layerTableView)
        layerTableView.snp.makeConstraints { (make) in
            
            make.left.right.equalToSuperview()
            make.top.equalTo(Math.displayY + Math.displaySpace)
            make.bottom.equalTo(-CGFloat.safeBottom - 50)
        }
        
        
        titleTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            
            make.height.equalTo(200)
            make.bottom.equalTo(-CGFloat.safeBottom)
        }
    }
    
    func createTimeLineView(){
        //素材起止时长
        view.addSubview(timeLineView)
        timeLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(Math.displayY + 10)
            make.height.equalTo(100)
        }
        timeLineView.isHidden = true
        
        timeLineView.addSubview(timeLineBar)
        timeLineBar.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalToSuperview()
            make.top.equalTo(10)
            make.height.equalTo(40)
        }
        timeLineBar.multiDragEndedCompleted = {[weak self] begin,end in
            guard let `self` = self else { return }
            self.updateDuration(begin: begin, end: end)
        }
        
        timeLineView.addSubview(timeLineTitle)
        timeLineTitle.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalToSuperview()
            make.top.equalTo(60)
            make.height.equalTo(40)
        }
        if let item = currentItem{
            timeLineTitle.text = "当前片段开始时间\(item.clipStartTs.formatTime()) 结束时间\(item.clipEndTs.formatTime()) \n当前图片偏移:\(item.layerStartTs.formatTime())"
        }
    }
    
    func createBlendView() {
        view.addSubview(blendView)
        blendView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(Math.displayY + 20)
            make.height.equalTo(120)
        }
        blendView.isHidden = true
        
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "混合模式"
        blendView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.left.equalTo(10)
            make.width.equalTo(80)
            make.top.equalTo(0)
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75, height: 40)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(PresentListCell.self, forCellWithReuseIdentifier: "ReuseIdentifier")
        blendView.addSubview(collectionView!)
        collectionView!.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.right.equalToSuperview()
            make.left.equalTo(100)
            make.top.equalTo(0)
        }
        
        
        blendSlider.startValue = 1
        blendView.addSubview(blendSlider)
        blendSlider.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionView!.snp.bottom)
            make.height.equalTo(50)
        }
        blendSlider.sliderValueChangedCompleted = {[weak self] value in
            
            guard let `self` = self else { return }
            self.updateBlend(value: value)
        }
    }
}
extension ImageStickerEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == layerTableView {
            return viewItems.count
        } else if tableView == titleTableView {
            return titles.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == layerTableView {
            return 50
        }else if tableView == titleTableView {
            if titlesToggle[indexPath.row] {
                return 40
            }else {
                return 0
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == layerTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LayerEditorNormalCell") as! LayerEditorNormalCell
            
            let item = viewItems[viewItems.count - indexPath.row - 1]
            //print("hecc--table--[\(indexPath.row)]:vid=\(item.vid!), idx=\(item.index)")
            cell.selectionStyle = .none
            cell.textLabel?.text = "\(item.index)"
            cell.imageView?.image = item.image
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.clipsToBounds = true
            return cell
            
        } else if tableView == titleTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleEditorNormalCell") as! TitleEditorNormalCell
            cell.label.text = titles[indexPath.row]
            cell.isHidden = !titlesToggle[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:// 图层列表
            layerTableView.isHidden = false
            updateTitlesToggle(state: .edit)
            layerTableView.reloadData()
            
        case 1:// 混合模式
            if let item = currentItem {
                blendView.isHidden = false
                updateTitlesToggle(state: .edit)
                blendSlider.slider.value = item.blendStrength

            }
        case 2:// 素材时长
            if let item = currentItem {
                timeLineView.isHidden = false
                updateTitlesToggle(state: .edit)
                timeLineBar.multiSlider.value[0] = CGFloat(item.clipStartTs) / CGFloat(item.videoDuration)
                timeLineBar.multiSlider.value[1] = CGFloat(item.clipEndTs) / CGFloat(item.videoDuration)
                timeLineTitle.text = "当前片段开始时间\(item.clipStartTs.formatTime()) 结束时间\(item.clipEndTs.formatTime()) \n当前图片偏移:\(item.layerStartTs.formatTime())"
            }
        case 3:// 添加一张图片/视频
            addAction()
        case 4:// 返回首页
            if let item = currentItem {
                updateTitlesToggle(state: .selected)
            }else {
                updateTitlesToggle(state: .unselected)
            }
            
            closePropEditVIew()
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewItems.count > 1
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        DispatchQueue.main.async {
            self.swapItem(idx0: sourceIndexPath.row, idx1: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none//UITableViewCellEditingStyleDelete
    }
}

extension ImageStickerEditorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        blendItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath) as! PresentListCell
        cell.multiItem = blendItems[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        blendItems = blendItems.map { ($0.0,$0.1, false) }
        blendItems[indexPath.item].2 = true
        collectionView.reloadData()
        self.updateBlend(mode: blendItems[indexPath.item].0)
    }
}

class TitleEditorNormalCell: UITableViewCell {
    
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .black
        let containerView = UIView()
        containerView.layer.cornerRadius = 3
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .lightGray
        contentView.addSubview(containerView)
        
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        containerView.addSubview(label)
        
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LayerEditorNormalCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = .white
        self.textLabel?.frame = CGRect(x: 15, y: 0, width: 20, height: 50)
        self.imageView?.frame = CGRect(x: 35, y: 2, width: 50, height: 46)
        self.backgroundColor = .gray

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




