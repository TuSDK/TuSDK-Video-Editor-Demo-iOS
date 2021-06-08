//
//  TuFileManager.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/2.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
/**
 Temp 临时文件
 Drafts 草稿箱
 */
class TuFileManager: NSObject {
    enum State: String {
        case images = "Image"
        case drafts = "Drafts"
        case video = "Video"
        case resource = "Resource"
        case temp = "Temp"
    }
    class func documents() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    class func createFolder(name: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documentURL.appendingPathComponent(name, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                return folder
            } catch  {
                printLog("写入文件夹失败：\(error.localizedDescription)")
                return documentURL
            }
        }
        return folder
    }
    class func fileExists(path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
    class func createURL(state: TuFileManager.State, name: String) -> URL {
        createFolder(name: state.rawValue).appendingPathComponent(name)
    }
    class func path(state: TuFileManager.State, name: String) -> String {
        createFolder(name: state.rawValue).path + "/" + name
    }
    class func absolute(state: TuFileManager.State, name: String) -> String {
        createFolder(name: state.rawValue).absoluteString + name
    }
    class func remove(state: TuFileManager.State) {
        let myDirectory = createFolder(name: state.rawValue).path
        let fileArray = FileManager.default.subpaths(atPath: myDirectory)
        for fn in fileArray!{
            try? FileManager.default.removeItem(atPath: myDirectory + "/\(fn)")
        }
    }
    class func remove(state: TuFileManager.State, name: String) {
        let path = TuFileManager.createURL(state: state, name: name).path
        remove(path: path)
    }
    class func remove(path: String?) {
        guard let path = path else { return }
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}
