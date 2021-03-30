//
//  ImagePicker.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import TZImagePickerController
class ImagePicker: NSObject {
    enum State {
        case image
        case video
        case both
    }
    var maxCount = 1
    var minCount = 0
    var state: State = .video
    typealias Completed = (SourceViewModel?) -> Void
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    private var completed: Completed?
    func showImagePicker(sender: UIViewController?, completed:Completed?) {
        self.completed = completed
        let imagePicker = TZImagePickerController()
        
        switch state {
        case .video:
            imagePicker.allowPickingVideo = true
            imagePicker.allowPickingImage = false
        case .image:
            imagePicker.allowPickingVideo = false
            imagePicker.allowPickingImage = true
        case .both:
            imagePicker.allowPickingVideo = true
            imagePicker.allowPickingImage = true
        }
    
        imagePicker.allowPickingOriginalPhoto = false
        imagePicker.allowPickingGif = false
        imagePicker.allowTakeVideo = false
        imagePicker.allowTakePicture = false
        imagePicker.maxImagesCount = maxCount
        imagePicker.minImagesCount = minCount
        imagePicker.allowPickingMultipleVideo = ((state != .image) && maxCount > 1)
        imagePicker.didFinishPickingVideoHandle = {[weak self] image, asset in
            guard let `self` = self else { return }
            self.makeCompleted(images: [image], assets: asset != nil ? [asset!] : nil)
        }
        imagePicker.didFinishPickingPhotosHandle = {[weak self] images, assets, _ in
            guard let `self` = self else { return }
            self.makeCompleted(images: images, assets: assets as? [PHAsset])
        }
        imagePicker.modalPresentationStyle = .overFullScreen
        sender?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func makeCompleted(images: [UIImage?]?, assets: [PHAsset]?) {
        let images = images ?? []
        let assets = assets ?? []
        if state == .image {
            var sources: [SourceModel] = []
            for (index, image) in images.enumerated() {
                var filename = String.currentTimestamp
                if assets.count > index, let item = assets[index].value(forKey: "filename") as? String {
                    filename = item
                }
                filename += ".png"
                if let image = image, let data = image.pngData() {
                    do {
                        let paths = TuFileManager.createURL(state: .images, name: filename)
                        try data.write(to: paths, options: .atomic)
                        let source = SourceModel(coverImage: image, path: filename, state: .picture)
                        sources.append(source)
                    } catch  {
                        printLog("save image to sandbox error: \(error.localizedDescription)")
                    }
                }
            }
            
            completedAction(SourceViewModel(sources: sources, state: state))
        } else if state == .video {
            let group = DispatchGroup()
            var sources: [SourceModel] = []
           
            for (index, asset) in assets.enumerated() {
                group.enter()
                concurrentQueue.async(group: group, qos: .default, flags: []) {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (videoAsset, audioMix, info) in
                        if let videoAsset = videoAsset as? AVURLAsset {
                            var cover: UIImage? = nil
                            if images.count > index {
                                cover = images[index]
                            }
                            let source = SourceModel(coverImage: cover, path: videoAsset.url.absoluteString, state: .video)
                            sources.append(source)
                        }
                        group.leave()
                    }
                }
                group.wait()
            }
            group.notify(queue: concurrentQueue) {
                self.completedAction(SourceViewModel(sources: sources,state: self.state))
            }
            
        } else {
            var sources: [SourceModel] = []
            let group = DispatchGroup()
            for (index, asset) in assets.enumerated() {
                if asset.mediaType == .image {
                    var filename = "\(Int(Date().timeIntervalSince1970))"
                    if assets.count > index, let item = assets[index].value(forKey: "filename") as? String {
                        filename = item
                    } else {
                        filename += ".png"
                    }
                    if let image = images[index], let data = image.pngData() {
                        do {
                            let paths = TuFileManager.createURL(state: .images, name: filename)
                            try data.write(to: paths, options: .atomic)
                            let source = SourceModel(coverImage: image, path: filename, state: .picture)
                            sources.append(source)
                        } catch  {
                            printLog("save image to sandbox error: \(error.localizedDescription)")
                        }
                    }
                }
                else {
                    group.enter()
                    concurrentQueue.async(group: group, qos: .default, flags: []) {
                        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (videoAsset, audioMix, info) in
                            if let videoAsset = videoAsset as? AVURLAsset {
                                var cover: UIImage? = nil
                                if images.count > index {
                                    cover = images[index]
                                }
                                let source = SourceModel(coverImage: cover, path: videoAsset.url.absoluteString, state: .video)
                                sources.append(source)
                            }
                            group.leave()
                        }
                    }
                    group.wait()
                }
            }
            group.notify(queue: concurrentQueue) {
                self.completedAction(SourceViewModel(sources: sources,state: self.state))
            }
        }
    }
    
    private func completedAction(_ source: SourceViewModel?) {
        DispatchQueue.main.async {
            self.completed?(source)
        }
    }
    class func saveVideo(_ url: URL?, completion:((Bool,String)->Void)?) {
        guard let url = url else {
            completion?(false, "资源地址为空")
            return }
        DispatchQueue.main.async {
            TZImageManager.default()?.saveVideo(with: url, completion: { (asset, error) in
                if let error = error {
                    completion?(false, error.localizedDescription)
                } else {
                    completion?(true, "保存成功")
                }
            })
        }
    }
    static func fetchShotImage(filePath : String)->UIImage {
        
        if filePath.hasSuffix(".png") || filePath.hasSuffix(".PNG") || filePath.hasSuffix(".jpg") || filePath.hasSuffix(".JPG") {
            let url = NSURL(string: filePath)
            let data = NSData(contentsOf: url! as URL)
            return UIImage(data: data! as Data)!
            
        }else if filePath.hasSuffix(".mp4") || filePath.hasSuffix(".MP4") || filePath.hasSuffix(".mov") || filePath.hasSuffix(".MOV"){
            let  videoUrl =  NSURL(fileURLWithPath: filePath) as URL
            let avAsset = AVAsset.init(url: videoUrl)
            let generator = AVAssetImageGenerator.init(asset: avAsset)
            generator.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600) // 取第0秒， 一秒600帧
            var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)
            let cgImage: CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
            
            return UIImage.init(cgImage: cgImage)
        }else {
            return UIImage()
        }
        
    }
    
}



extension ImagePicker {
    public func show(sender: UIViewController?, completion:(([ResourceModel])->Void)?) {
        let imagePicker = TZImagePickerController()
        switch state {
        case .video:
            imagePicker.allowPickingVideo = true
            imagePicker.allowPickingImage = false
        case .image:
            imagePicker.allowPickingVideo = false
            imagePicker.allowPickingImage = true
        case .both:
            imagePicker.allowPickingVideo = true
            imagePicker.allowPickingImage = true
        }
    
        imagePicker.allowPickingOriginalPhoto = false
        imagePicker.allowPickingGif = false
        imagePicker.allowTakeVideo = false
        imagePicker.allowTakePicture = false
        imagePicker.maxImagesCount = maxCount
        imagePicker.minImagesCount = minCount
        imagePicker.allowPickingMultipleVideo = ((state != .image) && maxCount > 1)
        imagePicker.didFinishPickingVideoHandle = {[weak self] image, asset in
            guard let `self` = self else { return }
            self.sandbox(images: [image], assets: asset != nil ? [asset!] : nil, completion: completion)
        }
        imagePicker.didFinishPickingPhotosHandle = {[weak self] images, assets, _ in
            guard let `self` = self else { return }
            self.sandbox(images: images, assets: assets as? [PHAsset], completion: completion)
        }
        imagePicker.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            sender?.present(imagePicker, animated: true, completion: nil)
        }
    }
    private func sandbox(images: [UIImage?]?, assets: [PHAsset]?, completion:(([ResourceModel])->Void)?) {
        let images = images ?? []
        let assets = assets ?? []
        var sources: [ResourceModel] = []
        let group = DispatchGroup()
        for (index,asset) in assets.enumerated() {
            guard let assetRescource = PHAssetResource.assetResources(for: asset).first else { continue }
            let state = ResourceModel.State(rawValue: asset.mediaType.rawValue)!
            let coverImage: UIImage? = images.count > index ? images[index] : nil
            group.enter()
            concurrentQueue.async(group: group, qos: .default, flags: []) {
                var filename = asset.value(forKey: "filename") as? String
                if filename == nil {
                    filename = String.currentTimestamp + (asset.mediaType == .image ? ".png" : ".mov")
                }
                let model = ResourceModel(state: state,
                                          filename: filename!,
                                          coverImage: coverImage)
                let sandboxURL = model.path()
                if TuFileManager.fileExists(path: sandboxURL.path) {
                    sources.append(model)
                    group.leave()
                } else {
                    PHAssetResourceManager.default().writeData(for: assetRescource, toFile: sandboxURL, options: nil) { (error) in
                        if error == nil {
                            sources.append(model)
                        }
                        group.leave()
                    }
                }
            }
            group.wait()
        }
        group.notify(queue: concurrentQueue) {
            DispatchQueue.main.async {
                completion?(sources)
            }
        }
    }
}
