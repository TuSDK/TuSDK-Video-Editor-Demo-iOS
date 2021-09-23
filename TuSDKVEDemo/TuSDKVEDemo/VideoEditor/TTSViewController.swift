//
//  TTSViewController.swift
//  TuSDKVEDemo
//
//  Created by 刘鹏程 on 2021/8/16.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import FCFileManager
import Alamofire

class TTSViewController: UIViewController {

    
    let textView = UITextView()
    
    private var selectButton = UIButton()
    private var playerButton = UIButton()
    var voiceID : Int = 0
    
    var filePath : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        // Do any additional setup after loading the view.
    }
    
    
    func setupView() {
        
        self.view.backgroundColor = .black
        self.title = Navigator.Scene.tts.rawValue
        
        let margin = 15
        
        let contentLabel = UILabel()
        contentLabel.textColor = .white
        contentLabel.text = "文字内容:"
        contentLabel.font = .systemFont(ofSize: 13)
        self.view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(margin)
            make.top.equalTo(CGFloat.naviHeight + 30)
            make.height.equalTo(20)
        }
        
        
        self.view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            
            make.left.equalTo(margin)
            make.top.equalTo(contentLabel.snp_bottom).offset(10)
            make.width.equalTo(UIScreen.width - CGFloat(2 * margin))
            make.height.equalTo(100)
        }
        
        let voiceLabel = UILabel()
        voiceLabel.textColor = .white
        voiceLabel.text = "音色类型:"
        voiceLabel.font = .systemFont(ofSize: 13)
        self.view.addSubview(voiceLabel)
        voiceLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.top.equalTo(textView.snp_bottom).offset(30)
            make.height.equalTo(20)
        }
        
        let dataSet = ["男神", "女神", "男童", "女童", "小新", "可达鸭", "Siri"]
        
        let itemWidth = (UIScreen.width - CGFloat(margin)) / 4
        let btnWidth = itemWidth - 10
        let btnHeight = 40
        
        for (index, voiceStr) in dataSet.enumerated() {
            let ttsButton = UIButton()
            ttsButton.setTitle(voiceStr, for: .normal)
            ttsButton.setTitleColor(.black, for: .normal)
            ttsButton.setTitleColor(.red, for: .selected)
            ttsButton.titleLabel?.font = .systemFont(ofSize: 13)
            ttsButton.backgroundColor = .white
            ttsButton.tag = index
            ttsButton.addTarget(self, action: #selector(chooseVoiceAction(_ :)), for: .touchUpInside)
            self.view.addSubview(ttsButton)
            if index == 0 {
                selectButton = ttsButton
                selectButton.isSelected = true
            }
            ttsButton.snp.makeConstraints { (make) in
                
                make.left.equalTo(margin + Int(itemWidth) * (index))
                make.width.equalTo(btnWidth)
                if index / 4 == 0 {
                    make.top.equalTo(voiceLabel.snp_bottom).offset(margin)
                } else {
                    make.top.equalTo(voiceLabel.snp_bottom).offset(2 * margin + btnHeight)
                    make.left.equalTo(margin + Int(itemWidth) * (index % 4))
                }
                make.height.equalTo(btnHeight)
            }
        }
        
        let completeButton = UIButton()
        completeButton.backgroundColor = .systemBlue
        completeButton.layer.cornerRadius = 20
        completeButton.setTitle("生成", for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 15)
        completeButton.addTarget(self, action: #selector(ttsAction(_:)), for: .touchUpInside)
        self.view.addSubview(completeButton)
        completeButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(voiceLabel.snp_bottom).offset((btnHeight + margin) * 2 + 30)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        playerButton.backgroundColor = .white
        playerButton.layer.cornerRadius = 20
        playerButton.setTitle("播放", for: .normal)
        playerButton.setTitleColor(.black, for: .normal)
        playerButton.titleLabel?.font = .systemFont(ofSize: 15)
        playerButton.isHidden = true
        playerButton.addTarget(self, action: #selector(playerAction(_:)), for: .touchUpInside)
        self.view.addSubview(playerButton)
        playerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(completeButton.snp_bottom).offset(20)
            make.width.height.equalTo(completeButton)
        }
        
    }
 
    //选择声音类型
    @objc func chooseVoiceAction(_ sender : UIButton) {
        
        selectButton.isSelected = false
        selectButton = sender
        selectButton.isSelected = true
        
        voiceID = sender.tag
    }
    
    //生成
    @objc func ttsAction(_ sender: UIButton) {
        
        if textView.text.count == 0 {
            
            SVProgressHUD.showInfo(withStatus: "请输入文字")
            return
        }
        textView.resignFirstResponder()
        ttsRequestAction()
    }
    
    //播放
    @objc func playerAction(_ sender: UIButton) {
        
        print("音频路径\(filePath!)")
        
        AudioQueuePlayer.shared().player(withFilePath: filePath!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    //文字语音转换请求
    func ttsRequestAction() {
        
        struct TTSBody : Codable {
            let sessionId : String
            let voiceName : Int
            let text : String
        }
        
        let parameters = TTSBody(sessionId: "abcd1234", voiceName: voiceID, text: textView.text)
        
        print("请求参数\(parameters)")
        let server = "http://59.111.57.55:8888/tts"
        SVProgressHUD.show()
        AF.request(server, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseData { (response) in
            if response.data != nil {
                
                let temp = FCFileManager.pathForTemporaryDirectory(withPath: "tts\(Int(Date().timeIntervalSince1970)).pcm")
                self.filePath = temp
                FCFileManager.writeFile(atPath: temp, content: response.data as NSObject?)
                print(response.data as Any)
                
                DispatchQueue.main.async {
                    self.playerButton.isHidden = false
                    SVProgressHUD.showSuccess(withStatus: "合成成功")
                }
                
                
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "合成失败")
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Data {
    
    func makePCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
        
        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        
        withUnsafeBytes {(bufferPointer) in
            guard let addr = bufferPointer.baseAddress else { return }
            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
        }
        return buffer
    }
}
