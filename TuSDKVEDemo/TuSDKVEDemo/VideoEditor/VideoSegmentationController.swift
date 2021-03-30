//
//  VideoSegmentationController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD

class VideoSegmentationController: StitchingController {

    var cutValue: Float = 0
    lazy var segView: UIView = {
        let segView = UIView()
        return segView
    }()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        isAllowAddClip = false
        if viewModel.state == .draft {
            let firstClipDuration = viewModel.clipItems[0].videoClip.getConfig().getIntNumber(TUPVEFileClip_CONFIG_TRIM_DURATION, or: viewModel.getDuration())
            if firstClipDuration == viewModel.getDuration(), viewModel.clipItems.count == 1 {
                cutValue = 0
            } else {
                cutValue = Float(firstClipDuration) / Float(viewModel.getDuration())
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegView()
    }
}

extension VideoSegmentationController {
    func setupSegView() {
        segView.isHidden = !(cutValue == 0)
        segView.backgroundColor = UIColor.black
        contentView.addSubview(segView)
        segView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let msgLabel = UILabel()
        msgLabel.text = "当前分割位置: 00:00"
        msgLabel.font = .systemFont(ofSize: 13)
        msgLabel.textAlignment = .center
        msgLabel.textColor = .white
        msgLabel.isHidden = true
        segView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        let barView = SliderBarView(title: "分割位置", state: .native)
        barView.slider.value = cutValue
        segView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp_bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        barView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.cutValue = value
            msgLabel.isHidden = false
            let time = Int(Float(self.viewModel.getDuration()) * value).formatTime()
            msgLabel.text = "当前分割位置: \(time)"
        }
        
        let cutButton = UIButton()
        cutButton.setTitle("分割", for: .normal)
        cutButton.setTitleColor(.white, for: .normal)
        cutButton.layer.cornerRadius = 7
        cutButton.clipsToBounds = true
        cutButton.titleLabel?.font = .systemFont(ofSize: 15)
        cutButton.backgroundColor = UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1)
        cutButton.addTarget(self, action: #selector(cutAction), for: .touchUpInside)
        segView.addSubview(cutButton)
        cutButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
    }
    @objc func cutAction() {
        if cutValue == 0 || cutValue == 1 {
            SVProgressHUD.showInfo(withStatus: "涂图视频剪辑:视频分割位置不可选择视频起点或视频终点")
            return
        }
        let clipItem = viewModel.clipItems[0]
        let source = clipItem.source
        let firstDuration = Int(cutValue * viewModel.originalDuration)
        let secondDuration = Int(viewModel.originalDuration) - firstDuration
        let firstItem = VideoClipItem(ctx: viewModel.ctx, source: source, index: 0, start: 0, duration: firstDuration)
        let secondItem = VideoClipItem(ctx: viewModel.ctx, source: source, index: 1, start: firstDuration, duration: secondDuration)
        let items = [firstItem, secondItem]
        fetchLock()
        defer {
            fetchUnlock()
        }
        viewModel.clearMainLayer()
        for item in items {
            viewModel.mainAudioLayer.add(item.audioClip, at: item.index)
            viewModel.mainVideoLayer.add(item.videoClip, at: item.index)
            viewModel.clipItems.append(item)
        }
        viewModel.build()
        segView.isHidden = true
        tableView.reloadData()
    }
    override func swap(from i: Int, to j: Int) {
        fetchLock()
        defer {
            fetchUnlock()
            seek(0)
        }
        viewModel.mainVideoLayer.swapClips(viewModel.clipItems[i].index, and: viewModel.clipItems[j].index)
        viewModel.mainAudioLayer.swapClips(viewModel.clipItems[i].index, and: viewModel.clipItems[j].index)
        viewModel.build()
        let temp = viewModel.clipItems[i].index
        viewModel.clipItems[i].index = viewModel.clipItems[j].index
        viewModel.clipItems[j].index = temp
        (viewModel.clipItems[i], viewModel.clipItems[j]) = (viewModel.clipItems[j], viewModel.clipItems[i])
        reloadData()
    }
}
