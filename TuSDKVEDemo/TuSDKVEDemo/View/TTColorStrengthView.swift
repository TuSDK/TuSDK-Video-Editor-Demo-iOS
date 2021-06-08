//
//  TTColorStrengthView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/20.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TTColorStrengthView: UIView {

    let colorView = SliderBarView(title: "颜色", state: .color)
    let strengthView = SliderBarView(title: "强度", state: .native)
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        addSubview(strengthView)
        strengthView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
