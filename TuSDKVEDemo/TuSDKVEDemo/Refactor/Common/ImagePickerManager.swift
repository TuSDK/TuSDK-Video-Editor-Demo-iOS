//
//  ImagePickerManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/23.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import TZImagePickerController
class ImagePickerManager: NSObject {
    enum State {
        case image
        case video
        case both
    }
    
    var state: State = .video
    var completion: SourceListCompletion?
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    typealias SourceCompletion = (JMSource?)->Void
    typealias SourceListCompletion = ([JMSource])->Void

    public func show(segue: Router.Scene, sender: UIViewController?, completion: SourceListCompletion?) {
        self.completion = completion
        let imagePicker = TZImagePickerController()
        imagePicker.allowPickingGif = false
        imagePicker.allowTakeVideo = false
        imagePicker.allowTakePicture = false
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.minImagesCount = 1
        switch segue {
        case .videoStitch:
            imagePicker.maxImagesCount = 9
            state = .video
        case .videoImageStitch :
            imagePicker.maxImagesCount = 9
            state = .both
        case .imageStitch:
            imagePicker.maxImagesCount = 9
            state = .image
        case .transitions:
            imagePicker.maxImagesCount = 9
            imagePicker.minImagesCount = 2
            state = .both
        case .movieCut, .segmentation, .reverse, .slow, .repeat, .cover, .speed, .audioPitch:
            imagePicker.maxImagesCount = 1
            state = .video
        default:
            imagePicker.maxImagesCount = 1
            state = .both
            break
        }
        imagePicker.pickerDelegate = self
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
        imagePicker.allowPickingMultipleVideo = ((state != .image) && imagePicker.maxImagesCount > 1)
        DispatchQueue.main.async {
            sender?.present(imagePicker, animated: true, completion: nil)
        }
    }
    public class func saveVideo(_ url: URL, completion:((Bool,String)->Void)?) {
        TZImageManager.default()?.saveVideo(with: url, completion: { (asset, error) in
            if let error = error {
                completion?(false, error.localizedDescription)
            } else {
                completion?(true, "保存成功")
            }
        })        
    }
}
extension ImagePickerManager: TZImagePickerControllerDelegate {
    // 单个视频
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        requestVideo(asset: asset, coverImage: coverImage) {[weak self] (source) in
            guard let `self` = self, let source = source else { return }
            DispatchQueue.main.async {
                self.completion?([source])
            }
        }
    }
    // 多图 多视频
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        guard let assets = assets as? [PHAsset] else { return }
        let group = DispatchGroup()
        var items: [JMSource] = []
        for (index,asset) in assets.enumerated() {
            let coverImage: UIImage? = photos.count > index ? photos[index] : nil
            group.enter()
            concurrentQueue.async(group: group, qos: .default, flags: []) {
                self.request(asset: asset, coverImage: coverImage) { (source) in
                    guard let source = source else {return}
                    items.append(source)
                    group.leave()
                }
            }
            group.wait()
        }
        group.notify(queue: .main) {
            self.completion?(items)
        }
    }
    /// 相册素材写入沙盒
    func writeData(clipItems: [JMClipItem], completion:((Bool)->Void)?) {
        let group = DispatchGroup()
        var isReplaced = false
        for item in clipItems {
            guard !item.source.isReplaced else {continue}
            let sandboxURL = TuFileManager.createURL(state: .drafts, name: item.source.filename)
            if TuFileManager.fileExists(path: sandboxURL.path) {
                isReplaced = true
                item.source.update(url: sandboxURL)
                continue
            }
            guard let asset = item.source.asset, asset.mediaType == .video, let assetRescource = PHAssetResource.assetResources(for: asset).first else { continue }
            group.enter()
            concurrentQueue.async(group: group, qos: .default, flags: []) {
                PHAssetResourceManager.default().writeData(for: assetRescource, toFile: sandboxURL, options: nil) { (error) in
                    if error == nil {
                        item.source.update(url: sandboxURL)
                        isReplaced = true
                    }
                    group.leave()
                }
            }
            group.wait()
        }
        group.notify(queue: .main) {
            completion?(isReplaced)
        }
    }
}

extension ImagePickerManager {
    private func request(asset: PHAsset, coverImage: UIImage?, completion:SourceCompletion?) {
        if asset.mediaType == .image {
            requestImage(asset: asset, coverImage: coverImage, completion: completion)
        } else {
            requestVideo(asset: asset, coverImage: coverImage, completion: completion)
        }
    }
    /// 获取视频路径
    private func requestVideo(asset: PHAsset, coverImage: UIImage?, completion:SourceCompletion?) {
        let filename = sourceFilename(asset: asset)
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (videoAsset, audioMix, info) in
            guard let videoAsset = videoAsset as? AVURLAsset else {
                completion?(nil)
                return }
            let source = JMSource(state: .video, filename: filename, url: videoAsset.url, coverImage: coverImage, asset: asset)
            completion?(source)
        }
        
    }
    // 只有通过Photos框架使用PHImageFileURLKey 才能访问相册照片，通过路径访问无效。
    // 使用 UIImage -> Data write Sandbox 占用内存
    /// 获取图片路径
    private func requestImage(asset: PHAsset, coverImage: UIImage?, completion:SourceCompletion?) {
        guard let assetRescource = PHAssetResource.assetResources(for: asset).first else { return }
        let filename = sourceFilename(asset: asset)
        let sandboxURL = TuFileManager.createURL(state: .drafts, name: filename)
        let source = JMSource(state: .image, filename: filename, url: sandboxURL, coverImage: coverImage,asset: asset)
        if TuFileManager.fileExists(path: sandboxURL.path) {
            completion?(source)
        } else {
            PHAssetResourceManager.default().writeData(for: assetRescource, toFile: sandboxURL, options: nil) { (error) in
                guard error == nil else {
                    completion?(nil)
                    return }
                completion?(source)
            }
        }
    }
    /// 文件名
    private func sourceFilename(asset: PHAsset) -> String {
        if let item = asset.value(forKey: "filename") as? String {
            return item
        }
        return String.currentTimestamp + (asset.mediaType == .image ? ".png" : ".mov")
    }
}
