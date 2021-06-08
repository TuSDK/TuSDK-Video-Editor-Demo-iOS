//
//  TTTextInputView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/4/26.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import RSKGrowingTextView
class TTTextInputView: UIView,RSKGrowingTextViewDelegate {

    lazy var textView: RSKGrowingTextView = {
        let item = RSKGrowingTextView()
        item.maximumNumberOfLines = 3
        item.minimumNumberOfLines = 1
        item.growingTextViewDelegate = self
        item.font = .systemFont(ofSize: 17)
        item.backgroundColor = UIColor.white
        return item
    }()
    var placeholder: String? {
        didSet {
            textView.placeholder = placeholder as NSString?
        }
    }
    var textDidChange:((String)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textView.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 49)
        addSubview(textView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textDismissAction)))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
    }
    @objc private func textDismissAction() {
        self.textView.resignFirstResponder()
    }
    @objc func keyBoardWillShow(_ notification:Notification) {
        let user_info = notification.userInfo
        let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardRect.height
        UIView.animate(withDuration: 0.3) {
            self.textView.frame = CGRect(x: 0, y: self.frame.height - keyboardHeight - 49, width: UIScreen.width, height: 49)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.textView.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 49)
            self.isHidden = true
        }
    }
    func show() {
        if isHidden {
            isHidden = false
        }
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        //if let xx = textView.textInputMode?.primaryLanguage, xx == "zh-Hans" {}
        if textView.markedTextRange == nil { // 拼音全部输入完成
            textDidChange?(textView.text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
