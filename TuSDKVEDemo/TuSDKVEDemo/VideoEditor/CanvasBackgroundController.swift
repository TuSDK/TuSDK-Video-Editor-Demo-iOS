//
//  CanvasBackgroundController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class CanvasBackgroundController: EditorBaseController {

    lazy var builder: TUPVECanvasResizeEffect_PropertyBuilder = {
        let builder = TUPVECanvasResizeEffect_PropertyBuilder()
        builder.holder.panX = 0.5
        builder.holder.panY = 0.5
        builder.holder.zoom = 1
        builder.holder.rotate = 0
        return builder
    }()
    var effect: TUPVEditorEffect!
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        let clipItem = viewModel.clipItems[0]
        effect = clipItem.videoClip.effects().getEffect(clipItem.index)!
        if viewModel.state == .draft {
            if let prop = effect.getProperty(TUPVECanvasResizeEffect_PROP_PARAM) {
                let holder = TUPVECanvasResizeEffect_PropertyHolder(property: prop)
                if holder.type == .color {
                    defaultColor = holder.color
                    state = .color
                } else if holder.type == .blur {
                    state = .blur
                    blurStrength = Float(holder.blurStrength)
                }
                builder = TUPVECanvasResizeEffect_PropertyBuilder(holder: holder)
            }
        }
    }
    enum State {
        case none
        case color
        case blur
    }
    var state: State = .none
    var blurStrength: Float = 1
    var defaultColor = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
        
    lazy var colorBar : SliderBarView = {
        return SliderBarView(title: "颜色", state: .color)
    }()
    let dimBar = SliderBarView(title: "强度", state: .native)
    func setupView() {
        let addColorButton = UIButton()
        addColorButton.setTitle("背景添加颜色", for: .normal)
        addColorButton.backgroundColor = .white
        addColorButton.titleLabel?.font = .systemFont(ofSize: 15)
        addColorButton.setTitleColor(.black, for: .normal)
        addColorButton.layer.cornerRadius = 5
        addColorButton.addTarget(self, action: #selector(addBackGroundColorAction), for: .touchUpInside)
        contentView.addSubview(addColorButton)
        addColorButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(view.snp.centerX).offset(-5)
            make.top.equalTo(30)
            make.height.equalTo(50)
        }
        let dimButton = UIButton()
        dimButton.setTitle("背景模糊", for: .normal)
        dimButton.backgroundColor = .white
        dimButton.titleLabel?.font = .systemFont(ofSize: 15)
        dimButton.setTitleColor(.black, for: .normal)
        dimButton.layer.cornerRadius = 5
        dimButton.addTarget(self, action: #selector(dimBackGroundAction), for: .touchUpInside)
        contentView.addSubview(dimButton)
        dimButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.left.equalTo(view.snp.centerX).offset(5)
            make.top.equalTo(30)
            make.height.equalTo(50)
        }
        
        colorBar.isHidden = !(state == .color)
        colorBar.colorSlider.color = defaultColor
        contentView.addSubview(colorBar)
        colorBar.colorSlider.color = defaultColor
        colorBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview();
            make.top.equalTo(addColorButton.snp_bottom).offset(25)
            make.height.equalTo(50);
        }
        
        colorBar.colorSliderDownCompleted = { [weak self] (color) in
            guard let `self` = self else {return}
            self.defaultColor = color
            DispatchQueue.main.async {
                self.addBackGroundColorAction()
            }
        }
        
        dimBar.isHidden = !(state == .blur)
        dimBar.startValue = blurStrength
        contentView.addSubview(dimBar)
        dimBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview();
            make.top.equalTo(dimButton.snp_bottom).offset(25)
            make.height.equalTo(50);
        }
        dimBar.sliderValueChangedCompleted = {[weak self] (value) in
            guard let `self` = self else {return}
            self.blurStrength = value
            self.dimBackGroundAction()
        }
    }
    @objc func addBackGroundColorAction() {
        //添加背景颜色
        colorBar.isHidden = false
        dimBar.isHidden = true
        builder.holder.type = .color
        builder.holder.color = defaultColor
        editor()
    }
    
    @objc func dimBackGroundAction() {
        //模糊背景
        dimBar.isHidden = false
        colorBar.isHidden = true
        builder.holder.type = .blur
        builder.holder.blurStrength = Double(blurStrength)
        builder.holder.color = .clear
        editor()
    }
    func editor() {
        effect.setProperty(builder.makeProperty(), forKey: TUPVECanvasResizeEffect_PROP_PARAM)
        if !self.isPlaying {
            player.previewFrame(currentTs)
        }
    }

}
