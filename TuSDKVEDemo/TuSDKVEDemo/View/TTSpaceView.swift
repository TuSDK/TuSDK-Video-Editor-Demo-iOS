//
//  TTSpaceView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/21.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TTSpaceView: UIView {

    let xView = SliderBarView(title: "字间距", state: .native)
    let yView = SliderBarView(title: "行间距", state: .native)
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(xView)
        xView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        addSubview(yView)
        yView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
class TTShadowView: UIView {
    let colorView = SliderBarView(title: "颜色", state: .color)
    let opacityView = SliderBarView(title: "不透明度", state: .native, titleWidth: 30)
    let strengthView = SliderBarView(title: "模糊强度", state: .native, titleWidth: 30)
    let distanceView = SliderBarView(title: "模糊距离", state: .native, titleWidth: 30)
    let degreeView = SliderBarView(title: "旋转角度", state: .native, titleWidth: 30)
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        addSubview(opacityView)
        opacityView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
            make.height.equalTo(50)
            make.top.equalTo(colorView.snp.bottom)
        }
        addSubview(strengthView)
        strengthView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(self.snp.centerX)
            make.height.equalTo(50)
            make.top.equalTo(colorView.snp.bottom)
        }
        addSubview(distanceView)
        distanceView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
            make.height.equalTo(50)
            make.top.equalTo(opacityView.snp.bottom)
        }
        addSubview(degreeView)
        degreeView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(self.snp.centerX)
            make.height.equalTo(50)
            make.top.equalTo(opacityView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
