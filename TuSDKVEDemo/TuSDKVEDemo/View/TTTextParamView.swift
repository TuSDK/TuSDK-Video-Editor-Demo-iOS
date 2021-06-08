//
//  TTTextParamView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

protocol TTTextParamViewDelegate: NSObjectProtocol {
    func paramView(_ paramView: TTTextParamView, update index: Int)
    func paramView(_ paramView: TTTextParamView, updateFrame index: Int)
    func paramView(_ paramView: TTTextParamView, blend mode: String)
    func paramView(_ paramView: TTTextParamView, updateOverlay index: Int)
    func didHiddenParamView(_ paramView: TTTextParamView)
}

class TTTextParamView: UIView {

    private let contentView = UIScrollView()
    private let backButton = UIButton()
    private var textColorView: SliderBarView? // 文字颜色
    private var textOpacityView: SliderBarView? // 文字不透明度
    private var strokeView: TTColorStrengthView? // 描边
    private var backgroundView: TTColorStrengthView? // 背景
    private var shadowView: TTShadowView? // 阴影
    private var spaceView: TTSpaceView? // 间距
    private var alignView: TTButtonsView? // 对齐
    private var orderView: TTButtonsView? // 排列
    private var styleView: TTButtonsView? // 样式
    private var blendView: TTBlendView? // 混合模式
    private var animationView: TTTextAnimationView?
    private var currentItem: AnimationTextController.TextItem?
    private var currentState: TTTextSourceItem.State?
    private var isChanged = false
    weak var delegate: TTTextParamViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        contentView.isScrollEnabled = false
        addSubview(contentView)
        
        backButton.isHidden = true
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.setImage(UIImage(named: "face_ic_reset"), for: .normal)
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(30)
            make.width.height.equalTo(50)
        }
    }
    
    func setup(count: Int) {
        contentView.contentSize = CGSize(width: contentView.frame.size.width * CGFloat(count), height: contentView.frame.size.height)
    }
    
    func update(textItem: AnimationTextController.TextItem?) {
        isChanged = (currentItem?.index != textItem?.index)
        currentItem = textItem
        if let _ = textItem {
            guard let state = currentState, !isHidden else { return }
            show(state: state, index: Int(contentView.contentOffset.x/contentView.frame.width))
        } else {
            currentItem = nil
            currentState = nil
            backAction()
        }
    }
    func show(state: TTTextSourceItem.State, index: Int) {
        guard let textItem = currentItem else { return }
        isHidden = false
        backButton.isHidden = false
        
        let width = contentView.frame.size.width
        let x = width * CGFloat(index)
        if currentState != state {
            contentView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }
        currentState = state
        
        switch state {
        case .animation:
            let isUninitialize = initializeView(animation: x)
            guard isChanged || isUninitialize else { break }
            if textItem.builder.holder.animators.count != 3 {
                let inAnimator = TUPVEAnimationTextClip_Animator()
                inAnimator.end = 0.1 
                let outAnimator = TUPVEAnimationTextClip_Animator()
                outAnimator.start = 0.9
                let overallAnimator = TUPVEAnimationTextClip_Animator()
                overallAnimator.end = 1
                textItem.builder.holder.animators.add(inAnimator)
                textItem.builder.holder.animators.add(outAnimator)
                textItem.builder.holder.animators.add(overallAnimator)
            }
            animationView?.animators = textItem.builder.holder.animators as! [TUPVEAnimationTextClip_Animator]
            animationView?.start = textItem.math.start
            animationView?.duration = textItem.math.duration
            animationView?.updateTitle()
        case .color:
            let isUninitialize = initializeView(color: x)
            guard isChanged || isUninitialize else { break }
            textColorView?.colorSlider.color = textItem.builder.holder.fillColor
        case .opacity:
            let isUninitialize = initializeView(opacity: x)
            guard isChanged || isUninitialize else { break }
            textOpacityView?.slider.value = textItem.overlayBuilder.holder.opacity
        case .stroke:
            if textItem.builder.holder.stroke == nil {
                textItem.builder.holder.stroke = TUPVEAnimationTextClip_Stroke()
            }
            let isUninitialize = initializeView(stroke: x)
            guard isChanged || isUninitialize else { break }
            strokeView?.colorView.colorSlider.color = textItem.builder.holder.stroke!.color;
            strokeView?.strengthView.slider.value = Float(textItem.builder.holder.stroke!.size)
        case .background:
            if textItem.builder.holder.background == nil {
                textItem.builder.holder.background = TUPVEAnimationTextClip_Background()
            }
            let isUninitialize = initializeView(background: x)
            guard isChanged || isUninitialize else { break }
            backgroundView?.colorView.colorSlider.color = textItem.builder.holder.background!.color;
            backgroundView?.strengthView.slider.value = Float(textItem.builder.holder.background!.opacity)
        case .shadow:
            if textItem.builder.holder.shadow == nil {
                textItem.builder.holder.shadow = TUPVEAnimationTextClip_Shadow()
            }
            let isUninitialize = initializeView(shadow: x)
            guard isChanged || isUninitialize else { break }
            shadowView?.colorView.colorSlider.color = textItem.builder.holder.shadow!.color
            shadowView?.opacityView.slider.value = Float(textItem.builder.holder.shadow!.opacity)
            shadowView?.strengthView.slider.value = Float(textItem.builder.holder.shadow!.blur)
            shadowView?.distanceView.slider.value = Float(textItem.builder.holder.shadow!.distance)
            shadowView?.degreeView.slider.value = Float(textItem.builder.holder.shadow!.degree)
        case .space:
            let isUninitialize = initializeView(space: x)
            guard isChanged || isUninitialize else { break }
            spaceView?.xView.slider.value = Float(textItem.builder.holder.textScaleX)
            spaceView?.yView.slider.value = Float(textItem.builder.holder.textScaleY)
        case .align:
            let isUninitialize = initializeView(align: x)
            guard isChanged || isUninitialize else { break }
            alignView?.update(select: textItem.builder.holder.alignment.rawValue)
        case .order:
            let isUninitialize = initializeView(order: x)
            guard isChanged || isUninitialize else { break }
            orderView?.update(select: textItem.builder.holder.order.rawValue)
        case .style:
            let isUninitialize = initializeView(style: x)
            guard isChanged || isUninitialize else { break }
            styleView?.update(select: textItem.builder.holder.underline2 > 0 ? 1 : 0)
        case .blend:
            let isUninitialize = initializeView(blend: x)
            guard isChanged || isUninitialize else { break }
            blendView?.setup(mode: textItem.math.blend, strength: textItem.overlayBuilder.holder.blendStrength)
        default:
            break
        }
    }
    
    @objc func backAction() {
        isHidden = true
        self.delegate?.didHiddenParamView(self)
    }
    
    private func initializeView(animation x: CGFloat) -> Bool {
        guard animationView == nil else { return false }
        animationView = TTTextAnimationView(frame: CGRect(x: x+50, y: 0, width: frame.width-50, height: frame.height))
        animationView?.completed = {[weak self]  in
            guard let `self` = self, let item = self.currentItem else { return }
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(animationView!)
        return true
    }
    private func initializeView(color x: CGFloat) -> Bool {
        guard textColorView == nil else { return false }
        textColorView = SliderBarView(title: "颜色", state: .color)
        textColorView?.colorSliderDownCompleted = {[weak self] color in
            guard let `self` = self, let item = self.currentItem, item.builder.holder.fillColor != color else { return }
            item.builder.holder.fillColor = color
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(textColorView!)
        textColorView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.centerY.equalTo(backButton.snp.centerY)
            make.height.equalTo(50)
        })
        return true
    }
    private func initializeView(opacity x: CGFloat) -> Bool {
        guard textOpacityView == nil else { return false }
        textOpacityView = SliderBarView(title: "不透明度", state: .native)
        textOpacityView?.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.overlayBuilder.holder.opacity = value
            self.delegate?.paramView(self, updateOverlay: item.index)
        }
        contentView.addSubview(textOpacityView!)
        textOpacityView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.centerY.equalTo(backButton.snp.centerY)
            make.height.equalTo(50)
        })
        return true
    }
    private func initializeView(stroke x: CGFloat) -> Bool {
        guard strokeView == nil else { return false }
        strokeView = TTColorStrengthView()
        strokeView?.strengthView.text = "宽度"
        strokeView?.strengthView.slider.maximumValue = 100
        strokeView?.colorView.colorSliderDownCompleted = {[weak self] color in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.stroke?.color = color
            self.delegate?.paramView(self, update: item.index)
        }
        strokeView?.strengthView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.stroke?.size = Int32(value)
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(strokeView!)
        strokeView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.top.equalToSuperview()
            make.height.equalTo(110)
        })
        return true
    }
    private func initializeView(background x: CGFloat) -> Bool {
        guard backgroundView == nil else { return false}
        backgroundView = TTColorStrengthView()
        backgroundView?.strengthView.text = "不透明度"
        backgroundView?.colorView.colorSliderDownCompleted = {[weak self] color in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.background?.color = color
            self.delegate?.paramView(self, update: item.index)
        }
        backgroundView?.strengthView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.background?.opacity = Double(value)
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(backgroundView!)
        backgroundView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.top.equalToSuperview()
            make.height.equalTo(110)
        })
        return true
    }
    private func initializeView(shadow x: CGFloat) -> Bool {
        guard shadowView == nil else { return false }
        shadowView = TTShadowView()
        shadowView?.distanceView.slider.maximumValue = 100
        shadowView?.degreeView.slider.maximumValue = 360
        shadowView?.colorView.colorSliderDownCompleted = {[weak self] color in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.shadow?.color = color
            self.delegate?.paramView(self, update: item.index)
        }
        shadowView?.opacityView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.shadow?.opacity = Double(value)
            self.delegate?.paramView(self, update: item.index)
        }
        shadowView?.strengthView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.shadow?.blur = Double(value)
            self.delegate?.paramView(self, update: item.index)
        }
        shadowView?.distanceView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.shadow?.distance = Int32(value)
            self.delegate?.paramView(self, update: item.index)
        }
        shadowView?.degreeView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.shadow?.degree = Int32(value)
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(shadowView!)
        shadowView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.top.equalToSuperview()
            make.height.equalTo(frame.height)
        })
        return true
    }
    private func initializeView(space x: CGFloat) -> Bool {
        guard spaceView == nil else { return false }
        spaceView = TTSpaceView()
        spaceView?.xView.slider.minimumValue = 0.5
        spaceView?.xView.slider.maximumValue = 2
        spaceView?.yView.slider.minimumValue = 0.5
        spaceView?.yView.slider.maximumValue = 2
        spaceView?.xView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.textScaleX = Double(value)
            self.delegate?.paramView(self, updateFrame: item.index)
        }
        spaceView?.yView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.textScaleY = Double(value)
            self.delegate?.paramView(self, updateFrame: item.index)
        }
        contentView.addSubview(spaceView!)
        spaceView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.top.equalToSuperview()
            make.height.equalTo(110)
        })
        return true
    }
    private func initializeView(align x: CGFloat) -> Bool {
        guard alignView == nil else { return false }
        alignView = TTButtonsView(items: TTTextSourceItem.alignAll(), frame: CGRect(x: x + 50, y: 0, width: 250, height: 110))
        alignView?.indexCompleted = {[weak self] index in
            guard let `self` = self, let item = self.currentItem, let aligment = TUPVEAnimationTextClip_AlignmentType(rawValue: index) else { return }
            item.builder.holder.alignment = aligment
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(alignView!)
        return true
    }
    private func initializeView(order x: CGFloat) -> Bool {
        guard orderView == nil else { return false }
        orderView = TTButtonsView(items: TTTextSourceItem.orderAll(), frame: CGRect(x: x + 50, y: 0, width: 160, height: 110))
        orderView?.indexCompleted = {[weak self] index in
            guard let `self` = self, let item = self.currentItem, let aligment = TUPVEAnimationTextClip_OrderType(rawValue: index) else { return }
            item.builder.holder.order = aligment
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(orderView!)
        return true
    }
    private func initializeView(style x: CGFloat) -> Bool {
        guard styleView == nil else { return false }
        styleView = TTButtonsView(items: TTTextSourceItem.styleAll(), frame: CGRect(x: x + 50, y: 0, width: 160, height: 110))
        styleView?.indexCompleted = {[weak self] index in
            guard let `self` = self, let item = self.currentItem else { return }
            item.builder.holder.underline2 = (index == 0) ? 0 : 1
            self.delegate?.paramView(self, update: item.index)
        }
        contentView.addSubview(styleView!)
        return true
    }
    private func initializeView(blend x: CGFloat) -> Bool {
        guard blendView == nil else { return false }
        blendView = TTBlendView()
        contentView.addSubview(blendView!)
        blendView?.blendCompletion = {[weak self] (mode,strength) in
            guard let `self` = self else { return }
            self.delegate?.paramView(self, blend: mode)
        }
        blendView?.strengthCompletion = {[weak self] (strength) in
            guard let `self` = self, let item = self.currentItem else { return }
            item.overlayBuilder.holder.blendStrength = strength
            self.delegate?.paramView(self, updateOverlay: item.index)
        }
        blendView?.snp.makeConstraints({ make in
            make.left.equalTo(x + 50)
            make.width.equalTo(frame.width - 50)
            make.top.equalToSuperview()
            make.height.equalTo(110)
        })
        return true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
