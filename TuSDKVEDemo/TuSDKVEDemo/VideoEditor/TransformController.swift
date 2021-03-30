//
//  TransformController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TransformController: EditorBaseController {

    class TransformItem {
        var rorate = TUPVETransformEffect_MODE_None
        var ver = TUPVETransformEffect_MODE_None
        var hor = TUPVETransformEffect_MODE_None
        var rorateEffect: TUPVEditorEffect
        var verEffect: TUPVEditorEffect
        var horEffect: TUPVEditorEffect
        let rorateIndex = 3000
        let verIndex = 3001
        let horIndex = 3002
        
        init(viewModel: EditorViewModel) {
            if viewModel.state == .resource {
                let config = TUPConfig()
                rorateEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETransformEffect_TYPE_NAME)
                verEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETransformEffect_TYPE_NAME)
                horEffect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETransformEffect_TYPE_NAME)
                
                config.setString(TUPVETransformEffect_MODE_None, forKey: TUPVETransformEffect_CONFIG_MODE)
                rorateEffect.setConfig(config)
                verEffect.setConfig(config)
                horEffect.setConfig(config)
                viewModel.clipItems[0].videoClip.effects().add(rorateEffect, at: rorateIndex)
                viewModel.clipItems[0].videoClip.effects().add(verEffect, at: verIndex)
                viewModel.clipItems[0].videoClip.effects().add(horEffect, at: horIndex)
            } else {
                rorateEffect = viewModel.clipItems[0].videoClip.effects().getEffect(rorateIndex)!
                verEffect = viewModel.clipItems[0].videoClip.effects().getEffect(verIndex)!
                horEffect = viewModel.clipItems[0].videoClip.effects().getEffect(horIndex)!
                rorate = rorateEffect.getConfig().getString(TUPVETransformEffect_CONFIG_MODE, or: TUPVETransformEffect_MODE_None)
                ver = verEffect.getConfig().getString(TUPVETransformEffect_CONFIG_MODE, or: TUPVETransformEffect_MODE_None)
                hor = horEffect.getConfig().getString(TUPVETransformEffect_CONFIG_MODE, or: TUPVETransformEffect_MODE_None)

            }
            
        }
        func editor(isFlip: Bool) {
            let config = TUPConfig()
            if isFlip {
                config.setString(ver, forKey: TUPVETransformEffect_CONFIG_MODE)
                verEffect.setConfig(config)
                config.setString(hor, forKey: TUPVETransformEffect_CONFIG_MODE)
                horEffect.setConfig(config)
            } else {
                config.setString(rorate, forKey: TUPVETransformEffect_CONFIG_MODE)
                rorateEffect.setConfig(config)
            }
        }
    }
    var videoItem: TransformItem!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = TransformItem(viewModel: viewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    func editor(isFlip: Bool) {
        fetchLock()
        defer {
            fetchUnlock()
            player.previewFrame(currentTs)
        }
        videoItem.editor(isFlip: isFlip)
        viewModel.build()
    }
}

extension TransformController {
    func setupView() {
        let rorateButton = UIButton()
        rorateButton.setTitle("旋转", for: .normal)
        rorateButton.backgroundColor = .white
        rorateButton.titleLabel?.font = .systemFont(ofSize: 15)
        rorateButton.setTitleColor(.black, for: .normal)
        rorateButton.layer.cornerRadius = 5
        rorateButton.addTarget(self, action: #selector(rorateAction(_:)), for: .touchUpInside)
        contentView.addSubview(rorateButton)
        
        let verticalButton = UIButton()
        verticalButton.setTitle("垂直翻转", for: .normal)
        verticalButton.backgroundColor = .white
        verticalButton.titleLabel?.font = .systemFont(ofSize: 15)
        verticalButton.setTitleColor(.black, for: .normal)
        verticalButton.layer.cornerRadius = 5
        verticalButton.addTarget(self, action: #selector(verticalAction(_:)), for: .touchUpInside)
        contentView.addSubview(verticalButton)
        
        let horizontalButton = UIButton()
        horizontalButton.setTitle("水平翻转", for: .normal)
        horizontalButton.backgroundColor = .white
        horizontalButton.titleLabel?.font = .systemFont(ofSize: 15)
        horizontalButton.setTitleColor(.black, for: .normal)
        horizontalButton.layer.cornerRadius = 5
        horizontalButton.addTarget(self, action: #selector(horizontalAction(_:)), for: .touchUpInside)
        contentView.addSubview(horizontalButton)
        
        rorateButton.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(30)
            make.height.equalTo(50)
        }
        
        verticalButton.snp.makeConstraints { (make) in
            make.left.height.equalTo(rorateButton)
            make.top.equalTo(rorateButton.snp.bottom).offset(10)
            make.right.equalTo(view.snp.centerX).offset(-5)
        }
        
        horizontalButton.snp.makeConstraints { (make) in
            make.right.height.equalTo(rorateButton)
            make.top.equalTo(verticalButton)
            make.left.equalTo(view.snp.centerX).offset(5)
        }
    }
    @objc private func rorateAction(_ sender : UIButton) {
        if videoItem.rorate == TUPVETransformEffect_MODE_None {
            videoItem.rorate = TUPVETransformEffect_MODE_K90
        }
        else if videoItem.rorate == TUPVETransformEffect_MODE_K90 {
            videoItem.rorate = TUPVETransformEffect_MODE_K180
        }
        else if videoItem.rorate == TUPVETransformEffect_MODE_K180 {
            videoItem.rorate = TUPVETransformEffect_MODE_K270
        } else {
            videoItem.rorate = TUPVETransformEffect_MODE_None
        }
        editor(isFlip: false)
    }
    @objc private func verticalAction(_ sender : UIButton) {
        if videoItem.ver == TUPVETransformEffect_MODE_None {
            videoItem.ver = TUPVETransformEffect_MODE_VFlip
        } else {
            videoItem.ver = TUPVETransformEffect_MODE_None
        }
        editor(isFlip: true)
    }
    @objc private func horizontalAction(_ sender : UIButton) {
        if videoItem.hor == TUPVETransformEffect_MODE_None {
            videoItem.hor = TUPVETransformEffect_MODE_HFlip
        } else {
            videoItem.hor = TUPVETransformEffect_MODE_None
        }
        editor(isFlip: true)
    }
}
