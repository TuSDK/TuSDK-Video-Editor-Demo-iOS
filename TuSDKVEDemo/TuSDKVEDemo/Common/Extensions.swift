//
//  Extensions.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import TuSDKPulseCore

func printLog<T>(_ message: T,
                    file: String = #file,
                  method: String = #function,
                    line: Int = #line) {
    print("🐢🐢🐢TuPrint:","\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
}

func printResult<T>(_ message: T,
                    result: Bool?,
                    file: String = #file,
                  method: String = #function,
                    line: Int = #line) {
    guard !(result ?? false) else { return }
    print("tutu print failure:","\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
}
func printTu(_ items: Any..., file: String = #file, method: String = #function, line: Int = #line) {
    print("tutu print:","\((file as NSString).lastPathComponent)[\(line)], \(method): ",items)

}
extension Int {
    /// e.g. 180 -> "03:00"
    /// - Parameter seconds: 时间(毫秒)
    func formatTime() -> String {
        let seconds = self / 1000
        let hour = seconds / 3600
        let minut = (seconds % 3600)/60
        let second = seconds % 60
        if hour == 0 {
            return String(format: "%02zd:%02zd", minut,second)
        }else{
            return String(format: "%zd:%02zd:%02zd",hour,minut,second)
        }
    }
}
extension Int64 {
    /// e.g. 180 -> "03:00"
    /// - Parameter seconds: 时间(毫秒)
    func formatTime() -> String {
        let seconds = self / 1000
        let hour = seconds / 3600
        let minut = (seconds % 3600)/60
        let second = seconds % 60
        if hour == 0 {
            return String(format: "%02zd:%02zd", minut,second)
        }else{
            return String(format: "%zd:%02zd:%02zd",hour,minut,second)
        }
    }
}
extension UIDevice {
    //通过获取屏幕的宽高来判断
    @objc class func isX() -> Bool {
        let maxB = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        if maxB == 812 || maxB == 896 || maxB == 844 || maxB == 926 {
            return true
        }
        return false
    }
}
extension CGFloat {
    static var scale: CGFloat {
        return UIScreen.main.bounds.height / 812
    }
    static var safeBottom: CGFloat {
        return UIDevice.lsqIsDeviceiPhoneX() ? 34 : 0
    }
    static var naviHeight: CGFloat {
        return UIDevice.lsqIsDeviceiPhoneX() ? 88 : 64
    }
}

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.intrinsicContentSize else {
            return
        }
                
        self.imageEdgeInsets = UIEdgeInsets(
            top: -titleLabelSize.height - padding/2,
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -imageViewSize.height - padding/2,
            right: 0.0
        )
        
    }
    
}
extension UIView {
    
    /// SwifterSwift: Get view's parent view controller
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Float {
    func titleFormat() -> String {
        return String(format: "%.2f", self)
    }
}

extension UIScreen {
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
}


extension SVProgressHUD {
    class func showSuccess(_ success: Bool, text: String?) {
        success ? SVProgressHUD.showSuccess(withStatus: text) : SVProgressHUD.showError(withStatus: text)
    }
    class func showSuccess(_ success: Bool, texts: [String]) {
        success ? SVProgressHUD.showSuccess(withStatus: texts.first) : SVProgressHUD.showError(withStatus: texts.last)
    }
}

extension String {
    static var currentTimestamp: String {
        "\(Int(Date().timeIntervalSince1970))"
    }
}

extension Bool {
     var intValue: Int {
        self ? 1 : 0
    }
}

protocol Convertable: Codable {

}

extension Convertable {

    /// 直接将Struct或Class转成Dictionary
    func convertToDict() -> Dictionary<String, Any>? {
        var dict: Dictionary<String, Any>? = nil
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        } catch {
            print(error)
        }
        return dict
    }
}
