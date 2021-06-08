//
//  EditorStickerController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/28.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class EditorStickerController: EditorBaseController {
    let stickerDisplayView = TTStickerDisplayView()
    var stickerLayerIndex: Int = 10000
    lazy var textInputView: TTTextInputView = {
        let textInputView = TTTextInputView(frame: CGRect(x: 0, y: CGFloat.naviHeight, width: UIScreen.width, height: UIScreen.height - CGFloat.naviHeight))
        textInputView.placeholder = defaultText
        textInputView.isHidden = true
        view.addSubview(textInputView)
        return textInputView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerDisplayView.frame = CGRect(x: 0, y: 0, width: displayView.frame.width, height: displayView.frame.height)
        displayView.addSubview(stickerDisplayView)
    }
    
    /// 计算 stickerItem 坐标
    /// - Parameter info: 绘制返回
    /// - Returns: 坐标
    func stickerFrame(posX: CGFloat, posY: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        let width = width * naturalRatio
        let height = height * naturalRatio
        let x = interactionRect.width * posX + interactionRect.origin.x - width / 2
        let y = interactionRect.height * posY + interactionRect.origin.y - height / 2
        let rect = CGRect(x: x, y: y, width: width, height: height)
        printTu(rect)
        return rect
    }
    func removeStickerItem(_ index: Int) {
        fetchLock()
        viewModel.editor.videoComposition().deleteLayer(at: index)
        viewModel.build()
        fetchUnlock()
        player.previewFrame(currentTs)
    }
    
    /// 计算 贴纸时间
    func stickerDuration(start: CGFloat, end: CGFloat) -> (Int, Int){
        let start = Int(CGFloat(viewModel.originalDuration) * start)
        let end = Int(CGFloat(viewModel.originalDuration) * end)
        return (start, (end - start))
    }
    /// 进度转毫秒
    func convertPts(begin: Float, end: Float) -> (Int, Int) {
        let start = Int(begin * viewModel.originalDuration)
        let duration = Int((end - begin) * viewModel.originalDuration)
        return (start, duration)
    }
    /// 毫秒转进度
    func convertProgress(start: Int, duration: Int) -> (CGFloat, CGFloat) {
        let begin = CGFloat(start)/CGFloat(viewModel.originalDuration)
        let duration = CGFloat(duration)/CGFloat(viewModel.originalDuration)
        return (begin, begin + duration)
    }
}
