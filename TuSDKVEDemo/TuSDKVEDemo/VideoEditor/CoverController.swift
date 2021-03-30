//
//  CoverController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/22.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class CoverController: EditorBaseController {

    private let coverImageView = UIImageView()
    lazy var maker: TUPThumbnailMaker = {
        let item = TUPThumbnailMaker(path: viewModel.clipItems[0].source.path().absoluteString, andSize: 800)
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //coverImageView.clipsToBounds = true
        
        navigationItem.rightBarButtonItem = nil
        
        let countBarView = SliderBarView(title: "封面位置",state: .native)
        contentView.addSubview(countBarView)
        countBarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(15)
            make.width.equalTo(UIScreen.width())
            make.height.equalTo(50)
        }
        
        countBarView.sliderDragEndedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            let image = self.maker.readImage(Int64(Int(value * self.viewModel.originalDuration)))
            DispatchQueue.main.async {
                self.coverImageView.image = image
            }
        }
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.isUserInteractionEnabled = true
        view.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.top.equalTo(countBarView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-CGFloat.safeBottom - 20)
        }
        
    }

}
