//
//  Router.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class Router: NSObject {
    static var shared = Router()
    enum Scene: String {
        case movieCut = "视频时间裁剪"
        case segmentation = "视频分割"
        case videoStitch = "多视频拼接"
        case videoImageStitch = "视频图片拼接"
        case imageStitch = "图片合成视频"
        case videoAudioMix = "音视频混合"
        case reverse = "视频倒放"
        case slow = "视频慢动作"
        case `repeat` = "视频段反复"
        case ratio = "比例裁剪"
        case cover = "封面提取"
        case speed = "视频线性变速"
        case pictureInPicture = "画中画"
        case crop = "视频画面裁剪"
        case colorAdjust = "视频颜色调整"
        case audioMix = "多音轨混合"
        case transform = "视频变换"
        case canvasBackground = "视频背景"
        case filter = "滤镜特效"
        case mv = "MV特效"
        case audioPitch = "音频变声"
        case transitions = "转场特效"
        case scenario = "场景特效"
        case particle = "魔法效果"
        case text = "文字特效"
        case drafts = "草稿箱"
        static var all: [Scene] = [.movieCut, .segmentation, .videoStitch, .videoImageStitch, .imageStitch, .videoAudioMix, .reverse, .slow, .repeat, .ratio, .cover, .pictureInPicture, .crop, .colorAdjust, .audioMix, .transform, .canvasBackground, .filter, .mv, .audioPitch, .transitions, .scenario, .particle, .text, .drafts]
    }
    public func show(segue: Scene, sender: UIViewController?) {
        if segue == .drafts {
            sender?.navigationController?.pushViewController(DraftsViewController(), animated: true)
            return
        }
        ResourceManager.shared.showImagePicker(segue: segue, sender: sender) { (adapter) in
            let target = self.get(adapter: adapter)
            sender?.navigationController?.pushViewController(target, animated: true)
        }
    }
    public func show(segue: Scene, sender: UIViewController?, draft path: String) {
        let adapter = EditorManager(drafts: path, segue: segue)
        let target = self.get(adapter: adapter)
        sender?.navigationController?.pushViewController(target, animated: true)
    }
    public func get(adapter: EditorManager) -> UIViewController {
        switch adapter.scene {
        case .movieCut:
            return MovieCutEditorController(adapter: adapter)
        case .videoStitch:
            return VideoStitchEditorController(adapter: adapter)
        default:
            return EditorVideoController(adapter: adapter)
        }
    }
}
