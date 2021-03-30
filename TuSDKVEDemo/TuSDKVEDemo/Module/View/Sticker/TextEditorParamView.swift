//
//  TextEditorParamView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/9.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import ColorSlider
class TextEditorParamView: UIView {
    enum State: Int {
        case color = 1
        case alpha
        case stroke
        case background
        case space
        case alignment
        case order
        case style
        case blend
    }
    var builder: TUPVEText2DClip_PropertyBuilder?
    var textItem : TextEditorViewController.TextViewModel?
    private let backButton = UIButton()
    lazy var colorBar: SliderBarView = {
        return SliderBarView(title: "颜色", state: .color)
    }()
    lazy var valueBar: SliderBarView = {
        return SliderBarView(title: "不透明度", state: .native)
    }()
    lazy var blendBar: SliderBarView = {
        return SliderBarView(title: "混合强度", state: .native)
    }()
    lazy var spaceBar: SliderBarView = {
        let item = SliderBarView(title: "字间距", state: .native)
        item.startValue = 1
        item.slider.minimumValue = 0.5
        item.slider.maximumValue = 2
        return item
    }()
    lazy var btn1: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.isHidden = true
        btn.tag = 1
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var btn2: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.isHidden = true
        btn.tag = 2
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var btn3: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.isHidden = true
        btn.tag = 3
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var btns: [UIButton] = {
        return [btn1,btn2,btn3]
    }()
    lazy var alignments: [TUPVEText2DClip_AlignmentType] = {
        return [.alignmentType_LEFT, .alignmentType_CENTER, .alignmentType_RIGHT]
    }()
    
    let items:[(String, String, Bool)] = [(TUPVEditorLayerBlendMode_None,"无",false),
                                          (TUPVEditorLayerBlendMode_Normal,"正常",false),
                                          (TUPVEditorLayerBlendMode_Add, "相加", false),
                                          (TUPVEditorLayerBlendMode_Substract, "减去", false),
                                          (TUPVEditorLayerBlendMode_Negation, "反色", false),
                                          (TUPVEditorLayerBlendMode_Average, "均值", false),
                                          (TUPVEditorLayerBlendMode_Multiply,"正片叠底", false),
                                          (TUPVEditorLayerBlendMode_Difference, "差值", false),
                                          (TUPVEditorLayerBlendMode_Screen, "滤色", false),
                                          (TUPVEditorLayerBlendMode_Softlight, "柔光", false),
                                          (TUPVEditorLayerBlendMode_Hardlight, "强光", false),
                                          (TUPVEditorLayerBlendMode_Lighten, "变亮",false),
                                          (TUPVEditorLayerBlendMode_Darken,"变暗", false),
                                          (TUPVEditorLayerBlendMode_Reflect, "反射", false),
                                          (TUPVEditorLayerBlendMode_Exclusion, "排除", false)]
    var blendBtns : [UIButton] = []
    //var blendString : String = TUPVEditorLayerBlendMode_None
    
    private var state = State.color
    private var reverseState : Bool = false
    private var underlineState : Bool = false
    private var defualtDict:[Int: String] = [:]
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.setImage(UIImage(named: "face_ic_reset"), for: .normal)
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(75)
        }
        addSubview(spaceBar)
        spaceBar.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        addSubview(colorBar)
        colorBar.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(25)
        }
        
        addSubview(valueBar)
        valueBar.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(25)
        }
        addSubview(btn1)
        btn1.snp.makeConstraints { (make) in
            make.left.equalTo(60)
            make.top.equalTo(10)
            make.height.width.equalTo(75)
        }
        addSubview(btn2)
        btn2.snp.makeConstraints { (make) in
            make.left.equalTo(btn1.snp.right).offset(10)
            make.top.equalTo(10)
            make.height.width.equalTo(75)
        }
        addSubview(btn3)
        btn3.snp.makeConstraints { (make) in
            make.left.equalTo(btn2.snp.right).offset(10)
            make.top.equalTo(10)
            make.height.width.equalTo(75)
        }
        addSubview(blendBar)
        blendBar.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(UIScreen.width())
            make.top.equalTo(80)
            make.height.equalTo(50)
        }
        
        valueBar.isHidden = true
        colorBar.isHidden = true
        spaceBar.isHidden = true
        blendBar.isHidden = true
        colorBar.colorSliderDownCompleted = {[weak self] (color) in
            guard let `self` = self else { return }
            if self.state == .color {
                self.builder?.holder.fillColor = color
                self.textItem?.textColor = color
            } else if self.state == .stroke {
                self.builder?.holder.strokeColor = color
            } else if self.state == .background {
                self.builder?.holder.bgColor = UIColor(red: color.rgba.red, green: color.rgba.green, blue: color.rgba.blue, alpha: (self.builder?.holder.bgColor.rgba.alpha)!)
            }
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
        }
        valueBar.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            if self.state == .alpha {
                self.textItem?.opacity = value
                NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorAlphaChangeNotification"), object: self.textItem)
                return
            } else if self.state == .stroke {
                self.builder?.holder.strokeWidth = Double(value)
            } else if self.state == .background {
                if let bgColor = self.builder?.holder.bgColor {
                    self.builder?.holder.bgColor = bgColor.withAlphaComponent(CGFloat(value))
                }
            } else if self.state == .space {
                self.builder?.holder.textScaleY = Double(0.5 + value * (2 - 0.5))
            }
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
        }
        spaceBar.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.builder?.holder.textScaleX = Double(value)
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
        }
        blendBar.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.textItem?.blendValue = value
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamVlaueChangeNotification"), object: self.textItem)
        }
        
    }
    func show(index: Int) {
        guard let state = State(rawValue: index) else { return }

        self.state = state
        subviews.forEach { (subview) in
            subview.isHidden = true
        }
        backButton.isHidden = false
        var colorTop = 25
        var valueTop = 25
        switch state {
        case .color:
            colorBar.text = "颜色"
            colorBar.colorSlider.color = self.textItem!.textColor
            colorBar.isHidden = false
        case .alpha:
            valueBar.text = "不透明度"
            valueBar.isHidden = false
            valueBar.startValue = self.textItem!.opacity
        case .stroke:
            colorTop = 0
            valueTop = 50
            colorBar.isHidden = false
            valueBar.isHidden = false
            valueBar.startValue = Float(builder!.holder.strokeWidth)
            colorBar.colorSlider.color = (builder?.holder.strokeColor)!
            colorBar.text = "颜色"
            valueBar.text = "宽度"
        case .background:
            colorTop = 0
            valueTop = 50
            colorBar.isHidden = false
            valueBar.isHidden = false
            
            colorBar.colorSlider.color = (builder?.holder.bgColor)!
            valueBar.startValue = Float((builder?.holder.bgColor)!.rgba.alpha)
            colorBar.text = "颜色"
            valueBar.text = "不透明度"
            
        case .space:
            valueTop = 50
            valueBar.isHidden = false
            spaceBar.isHidden = false
            valueBar.text = "行距"
        case .blend:
            
            let scrollView = UIScrollView()
            scrollView.isUserInteractionEnabled = true
            addSubview(scrollView)
            scrollView.snp.makeConstraints { (make) in
                make.left.equalTo(60)
                make.top.equalTo(0)
                make.height.equalTo(75)
                make.right.equalTo(-10)
            }
            scrollView.contentSize = CGSize(width: 75 * items.count, height: 75)
            
            for (index, item) in items.enumerated() {
                let btn = UIButton()
                btn.setTitleColor(.white, for: .normal)
                btn.setTitleColor(.red, for: .selected)
                btn.titleLabel?.font = .systemFont(ofSize: 13)
                btn.setTitle(item.1, for: .normal)
                btn.tag = index
                btn.addTarget(self, action: #selector(blendBtnAction(_:)), for: .touchUpInside)
                let selectBlend = items[index].0
                
                if selectBlend == self.textItem?.blendMode {
                    btn.isSelected = true
                }
                scrollView.addSubview(btn)
                btn.snp.makeConstraints { (make) in
                    make.left.equalTo(0 + 75 * index)
                    make.top.equalTo(0)
                    make.height.width.equalTo(75)
                }
                blendBtns.append(btn)
            }
            blendBar.isHidden = false
            blendBar.startValue = self.textItem!.blendValue

        case .alignment, .order, .style :
            var resources = [("左对齐","edit_text_ic_left"), ("居中对齐","edit_text_ic_center"),("右对齐","edit_text_ic_right")]
            if state == .order {
                resources = [("正常","edit_text_ic_smooth"),("倒转","edit_text_ic_inverse")]
            } else if state == .style {
                resources = [("正常","t_ic_nor_nor"),("下划线","t_ic_underline_nor")]
            }
            for (index,item) in resources.enumerated() {
                let btn = btns[index]
                btn.isHidden = false
                btn.isSelected = false
                btn.setTitle(item.0, for: .normal)
                btn.setImage(UIImage(named: item.1), for: .normal)
                btn.centerVertically()
                if state == .alignment {
                    if builder?.holder.alignment == alignments[index]{
                        btn.isSelected = true
                    }
                } else if state == .order {
                    if index == 0 && self.reverseState == false {
                        btn.isSelected = true
                    }
                    if index == 1 && self.reverseState == true {
                        btn.isSelected = true
                    }
                } else if state == .style {
                    if index == 0 && self.underlineState == false {
                        btn.isSelected = true
                    }
                    if index == 1 && self.underlineState == true {
                        btn.isSelected = true
                    }
                }
            }
        }
        
        colorBar.snp.remakeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(colorTop)
        }
        valueBar.snp.remakeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(valueTop)
        }
    }
    @objc func backAction() {
        self.isHidden = true
    }
    @objc func btnAction(_ sender: UIButton) {
        btns.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
        if state == .alignment {
            builder?.holder.alignment = alignments[sender.tag - 1]
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
        } else if state == .style {
            builder?.holder.underline = sender.tag == 2 ? 1 : 0
            self.underlineState = builder?.holder.underline == 1 ? true : false
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamChangeNotification"), object: self.builder)
        } else if state == .order {
            if reverseState == false {
                reverseState = true
            } else {
                reverseState = false
            }
            NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamOrderNotification"), object: self.builder)
            return
        }
    }
    
    @objc func blendBtnAction(_ sender: UIButton) {
        blendBtns.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: NSNotification.Name.init("TextEditorParamBlendChangeNotification"), object: items[sender.tag].0)
        self.textItem?.blendMode = items[sender.tag].0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
