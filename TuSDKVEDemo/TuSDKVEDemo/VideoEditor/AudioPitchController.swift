//
//  AudioPitchController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/19.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SnapKit
class AudioPitchController: EditorBaseController {

    var items:[EditorSourceItem] = EditorSourceItem.audioPitchAll()
    var buttons: [UIButton] = []
    var selectedIndex: Int = 2
    lazy var effect: TUPVEditorEffect = {
        return TUPVEditorEffect(viewModel.ctx, withType: TUPVEPitchEffect_AUDIO_TYPE_NAME)
    }()
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        if viewModel.state == .draft {
            if let item = viewModel.clipItems[0].audioClip.effects().getEffect(effectIndex) {
                effect = item
                let code = effect.getConfig().getString(TUPVEPitchEffect_CONFIG_TYPE, or: TUPVEPitchEffect_TYPE_Normal)
                for (index, item) in items.enumerated() {
                    if item.code == code {
                        selectedIndex = index
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        for (index, item) in items.enumerated() {
            if index == selectedIndex {
                item.isSelected = true
            }
        }
        setupView()
    }

}

extension AudioPitchController {
    func setupView() {
        let w = UIScreen.width/CGFloat(items.count)
        for (index, item) in items.enumerated() {
            let button = UIButton()
            button.tag = index
            button.setTitle(item.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 0.0, alpha: 1.0), for: .selected)
            button.titleLabel?.font = .systemFont(ofSize: 13)
            button.backgroundColor = UIColor.lightGray
            if index == selectedIndex {
                button.backgroundColor = UIColor.darkGray
            }
            button.addTarget(self, action: #selector(voiceAction(_ :)), for: .touchUpInside)
            buttons.append(button)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(100)
                make.left.equalTo(w * CGFloat(index))
                make.height.equalTo(40)
                make.width.equalTo(w)
            }
        }
    }
    @objc private func voiceAction(_ sender : UIButton) {
        if sender.isSelected {
            return
        }
        selectedIndex = sender.tag
        updateSelected()
        let item = items[selectedIndex]
        fetchLock()
        defer {
            fetchUnlockOriginal()
        }
                
        let config = TUPConfig()
        config.setString(item.code, forKey: TUPVEPitchEffect_CONFIG_TYPE)
        effect.setConfig(config)
        if viewModel.clipItems[0].audioClip.effects().getEffect(effectIndex) == nil {
            viewModel.clipItems[0].audioClip.effects().add(effect, at: effectIndex)
        }
        viewModel.build()
    }
    func updateSelected() {
        for (i,button) in buttons.enumerated() {
            if selectedIndex == i {
                button.backgroundColor = UIColor.darkGray
            } else {
                button.backgroundColor = UIColor.lightGray
            }
        }
    }
    
}
