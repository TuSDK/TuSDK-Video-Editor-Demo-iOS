//
//  Navigator.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit

class Navigator: NSObject {
    static var shared = Navigator()
    enum Scene: String {
        case cut = "视频时间裁剪"
        case segment = "视频分割"
        case video = "多视频拼接"
        case pictureVideo = "视频图片拼接"
        case pictures = "图片合成视频"
        case media = "音视频混合"
        case reverse = "视频倒放"
        case slow = "视频慢动作"
        case `repeat` = "视频段反复"
        case ratio = "比例裁剪"
        case cover = "封面提取"
        case speed = "视频线性变速"
        case pip = "画中画"
        case crop = "视频画面裁剪"
        case color = "视频颜色调整"
        case audioMix = "多音轨混合"
        case transform = "视频变换"
        case background = "视频背景"
        case filter = "滤镜特效"
        case mv = "MV特效"
        case audioPitch = "音频变声"
        case transition = "转场特效"
        case scenario = "场景特效"
        case particle = "魔法特效"
        case text = "文字特效"
        case bubbleText = "气泡文字"
        case graffiti = "涂鸦"
        case freeze = "视频定格"
        case mosaic = "马赛克"
        case draft = "草稿箱"
        
        static var all: [Scene] = [ .cut, .segment, .video, .pictureVideo,.pictures, .media, .reverse, .slow, .repeat, .ratio, .cover, .speed, .pip, .crop , .color, .audioMix, .transform, .background, .filter, .mv, .audioPitch, .transition, .scenario, .particle, .text, .bubbleText, .graffiti, .freeze, .mosaic, .draft]
    }
    let imagePicker = ImagePicker()
    public func show(segue: Scene, sender: UIViewController?) {
        
        imagePicker.minCount = 1
        imagePicker.maxCount = 1
        imagePicker.state = .both
        imagePicker.showImagePicker(sender: sender) { (viewModel) in
            guard let viewModel = viewModel else { return }
            let target = self.get(segue: segue, viewModel: viewModel)
            sender?.navigationController?.pushViewController(target, animated: true)
        }
    }
    // new
    public func show(segue: Scene, draft: String?, sender: UIViewController?) {
        if segue == .draft {
            sender?.navigationController?.pushViewController(DraftViewController(), animated: true)
            return
        }
        if let draft = draft {
            let viewModel = EditorViewModel(scene: segue, draft: draft)
            let target = get(viewModel: viewModel)
            sender?.navigationController?.pushViewController(target, animated: true)
        } else {
            imagePicker.minCount = 1
            switch segue {
            case .video:
                imagePicker.maxCount = 9
                imagePicker.state = .video
            case .pictureVideo :
                imagePicker.maxCount = 9
                imagePicker.state = .both
            case .pictures:
                imagePicker.maxCount = 9
                imagePicker.state = .image
            case .transition:
                imagePicker.maxCount = 9
                imagePicker.minCount = 2
                imagePicker.state = .both
            case .cut, .segment, .reverse, .slow, .repeat, .cover, .speed, .audioPitch, .freeze:
                imagePicker.maxCount = 1
                imagePicker.state = .video
            default:
                imagePicker.maxCount = 1
                imagePicker.state = .both
                break
            }
            imagePicker.show(sender: sender) { (sources) in
                guard sources.count > 0 else { return }
                let viewModel = EditorViewModel(scene: segue, sources: sources)
                let target = self.get(viewModel: viewModel)
                sender?.navigationController?.pushViewController(target, animated: true)
            }
        }
    }
    // new
    public func get(viewModel: EditorViewModel) -> UIViewController {
        switch viewModel.scene {
        case .cut:
            return MovieCutController(viewModel: viewModel)
        case .segment:
            return VideoSegmentationController(viewModel: viewModel)
        case .video, .pictures, .pictureVideo:
            return StitchingController(viewModel: viewModel)
        case .media:
            return VideoAudioMixController(viewModel: viewModel)
        case .ratio:
            return RatioController(viewModel: viewModel)
        case .cover:
            return CoverController(viewModel: viewModel)
        case .speed:
            return SpeedController(viewModel: viewModel)
        case .pip:
            return PIPController(viewModel: viewModel)
        case .crop:
            return CropController(viewModel: viewModel)
        case .color:
            return ColorAdjustController(viewModel: viewModel)
        case .audioMix:
            return AudioMixController(viewModel: viewModel)
        case .reverse:
            return ReverseController(viewModel: viewModel)
        case .slow:
            return SlowController(viewModel: viewModel)
        case .repeat:
            return RepeatController(viewModel: viewModel)
        case .transform:
            return TransformController(viewModel: viewModel)
        case .background:
            return CanvasBackgroundController(viewModel: viewModel)
        case .filter:
            return FilterController(viewModel: viewModel)
        case .mv:
            return MVController(viewModel: viewModel)
        case .audioPitch:
            return AudioPitchController(viewModel: viewModel)
        case .transition:
            return TransitionsController(viewModel: viewModel)
        case .scenario:
            return SceneController(viewModel: viewModel)
        case .particle:
            return ParticleController(viewModel: viewModel)
        case .text:
            return AnimationTextController(viewModel: viewModel)
        case .bubbleText:
            return BubbleTextController(viewModel: viewModel)
        case .graffiti:
            return GraffitiController(viewModel: viewModel)
        case .freeze:
            return FreezeController(viewModel: viewModel)
        case .mosaic:
            return MosaicController(viewModel: viewModel)
        default:
            return EditorBaseController(viewModel: viewModel)
        }
    }
    public func get(segue: Scene, viewModel: SourceViewModel) -> UIViewController {
        switch segue {
        case .pip:
            return ImageStickerEditorViewController(scene: segue, viewModel: viewModel)
        default:
            return EditorViewController(scene: segue, viewModel: viewModel)
        }
    }
}

