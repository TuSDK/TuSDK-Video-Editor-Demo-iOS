//
//  SliderBarView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/27.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import MultiSlider
import ColorSlider
class SliderBarView: UIView {

    enum State {
        case native
        case multi
        case color
    }
    private let titleLabel = UILabel()
    private let state: State
    public var multiValueChangedCompleted: ((Float,Float) -> Void)?
    public var multiDragEndedCompleted: ((Float,Float) -> Void)?
    public var sliderValueChangedCompleted: ((Float) -> Void)?
    public var sliderDragEndedCompleted: ((Float) -> Void)?
    public var sliderDownCompleted: ((Float) -> Void)?
    public var colorSliderDownCompleted: ((UIColor) -> Void)?
    
    public var startValue: Float = 0 {
        didSet {
            slider.value = startValue
        }
    }
    public var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    /// 是否取整
    public var isRounded = false
    lazy var multiSlider: MultiSlider = {
        let slider = MultiSlider()
        slider.orientation = .horizontal
        slider.value = [0, 1]
        slider.thumbImage = UIImage(named: "edit_checkbox_sel")
        slider.outerTrackColor = .lightGray
        slider.trackWidth = 3
        slider.distanceBetweenThumbs = 3.13
        slider.addTarget(self, action: #selector(multiSliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(multiSliderDragEnded(_:)), for: . touchUpInside)
        return slider
    }()
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(named: "edit_checkbox_sel"), for: .normal)
        slider.maximumTrackTintColor = .lightGray
        slider.minimumTrackTintColor = actualTintColor
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        slider.addTarget(self, action: #selector(sliderDown(_:)), for: .touchDown)
        return slider
    }()
    
    lazy var colorSlider: ColorSlider = {
        let previewView = DefaultPreviewView()
        previewView.offsetAmount = 10
        previewView.side = .top		
        let item = ColorSlider(orientation: .horizontal, previewView: previewView)
        item.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        return item
    }()
    
    init(title: String, state: SliderBarView.State = .native, titleWidth: CGFloat = 70) {
        self.state = state
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 50))
        titleLabel.frame = CGRect(x: 10, y: 0, width: titleWidth, height: 50)
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        addSubview(titleLabel)
        switch state {
        case .native:
            addSubview(slider)
            slider.snp.makeConstraints { (make) in
                make.left.equalTo(titleWidth + 20)
                make.right.equalTo(-30)
                make.top.bottom.equalToSuperview()
            }
        case .multi:
            addSubview(multiSlider)
            multiSlider.snp.makeConstraints { (make) in
                make.left.equalTo(titleWidth + 20)
                make.right.equalTo(-30)
                make.top.bottom.equalToSuperview()
            }
        case .color:
            addSubview(colorSlider)
            colorSlider.snp.makeConstraints { (make) in
                make.left.equalTo(titleWidth + 20)
                make.right.equalTo(-30)
                make.centerY.equalToSuperview()
                make.height.equalTo(10)
            }
        }
        
    }
    public func multiBetweenThumbs(distance: Float) {
        guard state == .multi else { return }
        multiSlider.keepsDistanceBetweenThumbs = true
        multiSlider.distanceBetweenThumbs = CGFloat(distance)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func multiSliderChanged(_ slider: MultiSlider) {
//        print("thumb \(slider.draggedThumbIndex) moved")
//        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
        guard slider.value.count > 1 else { return }
        multiValueChangedCompleted?(Float(slider.value[0]), Float(slider.value[1]))
    }
    @objc private func multiSliderDragEnded(_ slider: MultiSlider) {
        guard slider.value.count > 1 else { return }
        multiDragEndedCompleted?(Float(slider.value[0]), Float(slider.value[1]))
    }
    
    @objc private func sliderChanged(_ slider: UISlider) {
        if isRounded {
            slider.setValue(slider.value.rounded(), animated: true)
        }
        sliderValueChangedCompleted?(slider.value)
        
    }
    @objc private func sliderDragEnded(_ slider: UISlider) {
        sliderDragEndedCompleted?(slider.value)
    }
    @objc private func sliderDown(_ slider: UISlider) {
        sliderDownCompleted?(slider.value)
    }
    @objc func changedColor(_ slider: ColorSlider) {
        colorSliderDownCompleted?(slider.color)
    }
}
