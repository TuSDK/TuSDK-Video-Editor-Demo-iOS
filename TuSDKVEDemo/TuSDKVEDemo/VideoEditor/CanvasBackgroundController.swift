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
                } else if holder.type == .image {
                    state = .image
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
        case image
    }
    var state: State = .none
    var blurStrength: Float = 1
    var defaultColor = UIColor.black
    
    
    lazy var colorBar : SliderBarView = {
        return SliderBarView(title: "颜色", state: .color)
    }()
    let dimBar = SliderBarView(title: "强度", state: .native)
    lazy var imagePicker: ImagePicker = {
        let picker = ImagePicker()
        picker.state = .image
        return picker
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func setupView() {
        let titles = ["背景添加颜色","背景模糊","图片背景"]
        let space: Float = 10
        let width: Float = (Float(contentView.frame.width) - space * 2 - 2 * space) / Float(titles.count)
        for (index,text) in titles.enumerated() {
            let button = UIButton()
            button.setTitle(text, for: .normal)
            button.tag = index
            button.backgroundColor = .white
            button.titleLabel?.font = .systemFont(ofSize: 15)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.left.equalTo(space + Float(index) * (space + width))
                make.width.equalTo(width)
                make.top.equalTo(30)
                make.height.equalTo(50)
            }
        }
        
        colorBar.isHidden = !(state == .color)
        colorBar.colorSlider.color = defaultColor
        contentView.addSubview(colorBar)
        colorBar.colorSlider.color = defaultColor
        colorBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview();
            make.top.equalTo(105)
            make.height.equalTo(50);
        }
        
        colorBar.colorSliderDownCompleted = { [weak self] (color) in
            guard let `self` = self else {return}
            self.defaultColor = color
            DispatchQueue.main.async {
                self.addBackGroundColorAction()
            }
        }
        
        dimBar.isHidden = !(state == .blur || state == .image)
        dimBar.startValue = blurStrength
        contentView.addSubview(dimBar)
        dimBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview();
            make.top.equalTo(105)
            make.height.equalTo(50);
        }
        dimBar.sliderValueChangedCompleted = {[weak self] (value) in
            guard let `self` = self else {return}
            self.blurStrength = value
            self.dimBackGroundAction()
        }
    }
    @objc func buttonAction(_ sender: UIButton) {
        colorBar.isHidden = true
        dimBar.isHidden = true
        if sender.tag == 0 {
            colorBar.isHidden = false
            builder.holder.type = .color
            addBackGroundColorAction()
        } else if sender.tag == 1 {
            dimBar.isHidden = false
            builder.holder.type = .blur
            dimBackGroundAction()
        } else if sender.tag == 2 {
            imagePicker.show(sender: self) {[weak self] arrs in
                guard let `self` = self, let source = arrs.first else { return }
                self.builder.holder.type = .image
                self.builder.holder.image = source.path().absoluteString
                self.dimBar.isHidden = false
                self.dimBackGroundAction()
            }
        }
    }
    @objc func addBackGroundColorAction() {
        //添加背景颜色
        
        builder.holder.color = defaultColor
        editor()
    }
    
    @objc func dimBackGroundAction() {
        //模糊背景
        builder.holder.blurStrength = Double(blurStrength)
        //builder.holder.color = .clear
        editor()
    }
    @objc func imageAction() {
        
    }
    func editor() {
        effect.setProperty(builder.makeProperty(), forKey: TUPVECanvasResizeEffect_PROP_PARAM)
        if !self.isPlaying {
            player.previewFrame(currentTs)
        }
    }

}
