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
        var mode = TUPVETransformEffect_MODE_None
        
        var effect: TUPVEditorEffect
        let rorateIndex = 3000
        var transfer = TUPVETransformEffect_ModeTransfer()
        init(viewModel: EditorViewModel) {
            if viewModel.state == .resource {
                let config = TUPConfig()
                effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVETransformEffect_TYPE_NAME)
                
                
                config.setString(TUPVETransformEffect_MODE_None, forKey: TUPVETransformEffect_CONFIG_MODE)
                effect.setConfig(config)
                
                viewModel.clipItems[0].videoClip.effects().add(effect, at: rorateIndex)
            } else {
                effect = viewModel.clipItems[0].videoClip.effects().getEffect(rorateIndex)!
                
                mode = effect.getConfig().getString(TUPVETransformEffect_CONFIG_MODE, or: TUPVETransformEffect_MODE_None)
                transfer = TUPVETransformEffect_ModeTransfer(mode)

            }
            
        }
        func editor() {
            let config = effect.getConfig()
            config.setString(mode, forKey: TUPVETransformEffect_CONFIG_MODE)
            effect.setConfig(config)
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
    func editor() {
        fetchLock()
        defer {
            fetchUnlock()
            previewFrame()
        }
        videoItem.editor()
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
        videoItem.mode = videoItem.transfer.applyRotateCW()
        editor()
    }
    @objc private func verticalAction(_ sender : UIButton) {
        videoItem.mode = videoItem.transfer.applyFlip()
        editor()
    }
    @objc private func horizontalAction(_ sender : UIButton) {
        videoItem.mode = videoItem.transfer.applyMirror()
        editor()
    }
}
