//
//  CropController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class CropController: EditorBaseController {
    class CropItem {
        var top: Float = 0
        var bottom: Float = 1
        var left: Float = 0
        var right: Float = 1
        let cropConfig = TUPConfig()
        var effect: TUPVEditorEffect
        private let index = 3000
        init(viewModel: EditorViewModel) {
            if viewModel.state == .resource {
                effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVECropEffect_TYPE_NAME)
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
                viewModel.build()
                //viewModel.clipItems[0].videoClip.effects().deleteEffect(viewModel.clipItems[0].index)
            } else {
                effect = viewModel.clipItems[0].videoClip.effects().getEffect(index)!
                let effectConfig = effect.getConfig()
                top = effectConfig.getNumber(TUPVECropEffect_CONFIG_TOP).floatValue
                bottom = Float(effectConfig.getDoubleNumber(TUPVECropEffect_CONFIG_BOTTOM, or: 1))
                left = effectConfig.getNumber(TUPVECropEffect_CONFIG_LEFT).floatValue
                right = Float(effectConfig.getDoubleNumber(TUPVECropEffect_CONFIG_RIGHT, or: 1))
            }
        }
        func crop() {
            bottom = min(1, bottom)
            right = min(1, right)
            let cropConfig = TUPConfig()
            cropConfig.setNumber(NSNumber(value: top), forKey: TUPVECropEffect_CONFIG_TOP)
            cropConfig.setNumber(NSNumber(value: bottom), forKey: TUPVECropEffect_CONFIG_BOTTOM)
            cropConfig.setNumber(NSNumber(value: left), forKey: TUPVECropEffect_CONFIG_LEFT)
            cropConfig.setNumber(NSNumber(value: right), forKey: TUPVECropEffect_CONFIG_RIGHT)
            effect.setConfig(cropConfig)
        }
    }
    var videoItem: CropItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = CropItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func editor() {
        fetchLock()
        defer {
            fetchUnlock()
            player.previewFrame(currentTs)
        }
        videoItem.crop()
        let res = viewModel.build()
        printTu(res)
    }
    private let titleLabel = UILabel()
}

extension CropController {
    func setupView() {

        updateTitle()
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(20)
        }
                
        let cutVertyView = SliderBarView(title: "裁剪区间\n(上-下)", state: .multi)
        cutVertyView.multiBetweenThumbs(distance: 0.1)
        cutVertyView.multiSlider.value = [CGFloat(videoItem.top),CGFloat(videoItem.bottom)]
        contentView.addSubview(cutVertyView)
        cutVertyView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        let cutHorView = SliderBarView(title: "裁剪区间\n(左-右)", state: .multi)
        cutHorView.multiBetweenThumbs(distance: 0.1)
        cutHorView.multiSlider.value = [CGFloat(videoItem.left),CGFloat(videoItem.right)]
        contentView.addSubview(cutHorView)
        cutHorView.snp.makeConstraints { (make) in
            make.top.equalTo(cutVertyView.snp_bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        cutVertyView.multiValueChangedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.videoItem.top = begin
            self.videoItem.bottom = end
            self.updateTitle()
        }
        
        cutVertyView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.editor()
        }

        cutHorView.multiValueChangedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.videoItem.left = begin
            self.videoItem.right = end
            self.updateTitle()
        }
        cutHorView.multiDragEndedCompleted = {[weak self] begin, end in
            guard let `self` = self else { return }
            self.editor()
        }
        
    }
    private func updateTitle() {
        self.titleLabel.text = "当前视频属性\n" + "上: \(videoItem.top.titleFormat()) 下: \(videoItem.bottom.titleFormat()) 左: \(videoItem.left.titleFormat()) 右: \(videoItem.right.titleFormat())"
    }
}
