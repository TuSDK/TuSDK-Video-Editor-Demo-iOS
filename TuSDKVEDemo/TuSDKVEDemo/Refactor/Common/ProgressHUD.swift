//
//  ProgressHUD.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
class ProgressHUD: NSObject {
    class func showProgress(_ value: Float) {
        DispatchQueue.main.async {
            SVProgressHUD.showProgress(value)
        }
    }
    class func showProgress(success: Bool, message: String) {
        DispatchQueue.main.async {
            success ? SVProgressHUD.showSuccess(withStatus: message) : SVProgressHUD.showError(withStatus: message)
        }
    }
    class func showError(message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: message)
        }
    }
    class func showSuccess(message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.showSuccess(withStatus: message)
        }
    }
    class func dismiss() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
