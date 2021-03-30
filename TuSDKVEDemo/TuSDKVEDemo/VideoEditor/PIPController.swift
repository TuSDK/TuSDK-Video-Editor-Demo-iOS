//
//  PIPController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SnapKit
class PIPController: EditorBaseController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainLayerView = LayerView(frame: displayView.bounds)
        mainLayerView.backgroundColor = .red
        displayView.addSubview(mainLayerView)
        
        let bottomView = UIView()
        bottomView.backgroundColor = .green
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
