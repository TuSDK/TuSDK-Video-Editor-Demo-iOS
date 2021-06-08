//
//  TTButtonsView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/21.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class TTButtonsView: UIView {
    var indexCompleted:((Int)->Void)?
    private var btns: [UIButton] = []
    init(items:[EditorSourceItem], frame: CGRect, hasImage: Bool = true) {
        super.init(frame: frame)
        for (index,item) in items.enumerated() {
            let height: CGFloat = hasImage ? 75:45
            let width: CGFloat = frame.width/CGFloat(items.count)
            let btn = UIButton(frame: CGRect(x: width * CGFloat(index), y: (frame.height - height)/2, width: width, height: height))
            btn.setTitleColor(.white, for: .normal)
            btn.setTitleColor(UIColor(red: 0.36, green: 0.45, blue: 0.85, alpha: 1), for: .selected)
            btn.titleLabel?.font = .systemFont(ofSize: 13)
            btn.setTitle(item.name, for: .normal)
            btn.isSelected = item.isSelected
            btn.tag = index
            if hasImage {
                btn.setImage(UIImage(named: item.code), for: .normal)
                btn.centerVertically()
            }
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            addSubview(btn)
            btns.append(btn)
        }
    }
    public func update(select index: Int) {
        guard index < btns.count, !btns[index].isSelected else { return }
        for (i,btn) in btns.enumerated() {
            btn.isSelected = (i == index)
        }
    }
    @objc private func btnAction(_ sender: UIButton) {
        let index = sender.tag
        update(select: index)
        indexCompleted?(index)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
