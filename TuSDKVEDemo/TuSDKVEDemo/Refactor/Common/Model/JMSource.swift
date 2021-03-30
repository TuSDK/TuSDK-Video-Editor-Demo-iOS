//
//  JMSource.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import Photos
class JMSource {
    enum State {
        case video
        case image
    }
    /// 文件名
    var filename: String = ""
    /// 文件路径
    var url: URL!
    var asset: PHAsset?
    var coverImage: UIImage?
    var state: State = .video
    /// 草稿箱沙盒初始化
    var editorState: EditorState = .resource
    /// 是否替换成沙盒地址
    var isReplaced = false
    init(state: State, filename: String, url: URL, coverImage: UIImage?, asset: PHAsset) {
        self.state = state
        self.filename = filename
        self.url = url
        self.coverImage = coverImage
        self.asset = asset
    }
    init(sandbox path: String) {
        if path.hasSuffix(".png") || path.hasSuffix(".PNG") || path.hasSuffix(".jpg") || path.hasSuffix(".JPG") {
            self.state = .image
        } else {
            self.state = .video
        }
        self.filename = path.components(separatedBy: "/").last ?? ""
        self.url = TuFileManager.createURL(state: .drafts, name: filename)
        self.editorState = .draft
        self.isReplaced = true
        fetchShotImage()
    }
    func update(url: URL) {
        printTu("source repleace: \(self.url) -> \(url)")
        self.url = url
        isReplaced = true
    }
    /// 获取封面
    private func fetchShotImage() {
        if state == .image, let data = try? Data(contentsOf: url) {
            coverImage = UIImage(data: data)
        }
    }

}
