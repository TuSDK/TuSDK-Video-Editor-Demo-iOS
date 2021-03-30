//
//  SourceModel.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/15.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import Photos
import HandyJSON
struct SourceModel: HandyJSON {
    var coverImage: UIImage?
    var path: String = "file"
    var state: State = .video
    var asset: PHAsset?
    enum State {
        case video
        case picture
    }
}
struct ResourceModel {
    enum State: Int {
        case image = 1
        case video
    }
    let state: State
    let filename: String
    var coverImage: UIImage? = nil
    init(state: State, filename: String, coverImage: UIImage?) {
        self.state = state
        self.filename = filename
        self.coverImage = coverImage
    }
    init(sandbox path: String) {
        if path.hasSuffix(".png") || path.hasSuffix(".PNG") || path.hasSuffix(".jpg") || path.hasSuffix(".JPG") {
            self.state = .image
        } else {
            self.state = .video
        }
        self.filename = path.components(separatedBy: "/").last ?? ""
        self.coverImage = ImagePicker.fetchShotImage(filePath: path)
    }
    
    func path() -> URL {
        TuFileManager.createURL(state: .resource, name: filename)
    }
}
