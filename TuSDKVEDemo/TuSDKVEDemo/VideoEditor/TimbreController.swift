//
//  TimbreController.swift
//  TuSDKVEDemo
//
//  Created by 刘鹏程 on 2021/8/16.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
import Alamofire
import FCFileManager
import AudioKit
import SVProgressHUD

class TimbreController: UIViewController {

    enum RecordState {
        case waiting
        case recording
        case complete
    }
    
    private let recordButton = UIButton()
    private let completeButton = UIButton()
    private var selectButton = UIButton()
    private var audioRecorder : AVAudioRecorder?
    var recordState : RecordState = .waiting
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/voice\(Int(Date().timeIntervalSince1970)).pcm")
    let player = AVPlayer(playerItem: nil)
    var voiceType : Int = 5
    
    let engine = AudioEngine()
    private let conversionQueue = DispatchQueue(label: "conversionQueue")
    var allDataValueArray = [Float]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
//        self.title = Navigator.Scene.timbre.rawValue
        setupView()
        
        setupAudioSession()
        // Do any additional setup after loading the view.
    }
    
    
    func setupView() {
        let voiceLabel = UILabel()
        voiceLabel.textColor = .white
        voiceLabel.text = "音色类型:"
        voiceLabel.font = .systemFont(ofSize: 13)
        self.view.addSubview(voiceLabel)
        voiceLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.top.equalTo(CGFloat.naviHeight + 30)
            make.height.equalTo(20)
        }
        
        let maleVoiceLabel = UILabel()
        maleVoiceLabel.backgroundColor = .white
        maleVoiceLabel.font = .systemFont(ofSize: 15)
        maleVoiceLabel.text = "男声"
        maleVoiceLabel.textAlignment = .center
        self.view.addSubview(maleVoiceLabel)
        maleVoiceLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(voiceLabel.snp_bottom).offset(10)
            make.height.equalTo(40)
        }
        
        let margin = 15
        let btnWidth = Int((UIScreen.width() - CGFloat(margin * 2)) / 5)
        for i in 1 ... 5 {
            
            let maleButton = UIButton()
            maleButton.setTitle(String.init(i), for: .normal)
            maleButton.setTitleColor(.black, for: .normal)
            maleButton.setTitleColor(.red, for: .selected)
            maleButton.titleLabel?.font = .systemFont(ofSize: 13)
            maleButton.layer.cornerRadius = CGFloat((btnWidth - 5) / 2)
            maleButton.backgroundColor = .white
            maleButton.tag = i + 4
            if i == 1 {
                selectButton = maleButton
                selectButton.isSelected = true
            }
            maleButton.addTarget(self, action: #selector(chooseVoiceAction(_ :)), for: .touchUpInside)
            self.view.addSubview(maleButton)
            maleButton.snp.makeConstraints { (make) in
                
                make.left.equalTo(margin + btnWidth * (i - 1))
                make.width.equalTo(btnWidth - 5)
                make.top.equalTo(maleVoiceLabel.snp_bottom).offset(margin)
                make.height.equalTo(btnWidth - 5)
            }
        }
        
        let femaleVoiceLabel = UILabel()
        femaleVoiceLabel.backgroundColor = .white
        femaleVoiceLabel.font = .systemFont(ofSize: 15)
        femaleVoiceLabel.text = "女声"
        femaleVoiceLabel.textAlignment = .center
        self.view.addSubview(femaleVoiceLabel)
        femaleVoiceLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(maleVoiceLabel.snp_bottom).offset(btnWidth + margin * 2)
            make.height.equalTo(40)
        }
        
        for i in 1 ... 5 {
            
            let femaleButton = UIButton()
            femaleButton.setTitle(String.init(i), for: .normal)
            femaleButton.setTitleColor(.black, for: .normal)
            femaleButton.setTitleColor(.red, for: .selected)
            femaleButton.titleLabel?.font = .systemFont(ofSize: 13)
            femaleButton.layer.cornerRadius = CGFloat((btnWidth - 5) / 2)
            femaleButton.backgroundColor = .white
            femaleButton.tag = i - 1
            femaleButton.addTarget(self, action: #selector(chooseVoiceAction(_ :)), for: .touchUpInside)
            self.view.addSubview(femaleButton)
            femaleButton.snp.makeConstraints { (make) in
                
                make.left.equalTo(margin + btnWidth * (i - 1))
                make.width.equalTo(btnWidth - 5)
                make.top.equalTo(femaleVoiceLabel.snp_bottom).offset(margin)
                make.height.equalTo(btnWidth - 5)
            }
        }
        
        recordButton.setTitle("录音", for: .normal)
        recordButton.backgroundColor = .white
        recordButton.layer.cornerRadius = 20
        recordButton.titleLabel?.font = .systemFont(ofSize: 15)
        recordButton.setTitleColor(.black, for: .normal)
        recordButton.addTarget(self, action: #selector(recordVoice(_:)), for: .touchUpInside)
        self.view.addSubview(recordButton)
        recordButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(femaleVoiceLabel.snp_bottom).offset(btnWidth + margin * 2)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        completeButton.backgroundColor = .systemBlue
        completeButton.layer.cornerRadius = 20
        completeButton.setTitle("生成", for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 15)
        completeButton.addTarget(self, action: #selector(timbreVoiceAction(_:)), for: .touchUpInside)
        self.view.addSubview(completeButton)
        completeButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordButton.snp_bottom).offset(10)
            make.width.height.equalTo(recordButton)
        }
    }
    
    func setupAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
        } catch let error {
            print(error)
        }
    }

    //选择音色类型
    @objc func chooseVoiceAction(_ sender : UIButton) {
        
        //0 - 4 为女声 5 - 9 为男声
        selectButton.isSelected = false
        selectButton = sender
        selectButton.isSelected = true
        
        voiceType = sender.tag
        print("选择的声音类型\(voiceType)")
    }
    
    //录音操作
    @objc func recordVoice(_ sender: UIButton) {
        
        if recordState == .waiting {
            recordButton.setTitle("录音中...", for: .normal)
            startEngine()
            
        } else if recordState == .recording {
            recordButton.setTitle("录音完成", for: .normal)
            stopEngine()
        }
    }
    
    //生成
    @objc func timbreVoiceAction(_ sender: UIButton) {
        
        if recordState == .recording {
            recordButton.setTitle("录音完成", for: .normal)
            stopEngine()
            return
        }
        timbreRequestAction()
    }
    
    //音色转换请求
    func timbreRequestAction() {
        
        //base64编码
        let fileManager = FileManager.default
        let fileUrl = URL.init(string: filePath!)
        if fileManager.fileExists(atPath: fileUrl!.path) {
            let voiceData = fileManager.contents(atPath: fileUrl!.path)
            let voice64String = voiceData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            //print("编码后的base64\(voice64String)")
            
            let parameters : [String : Any] = ["sessionId" : "vc_1234abcd", "targetVoiceId" : NSNumber.init(value: voiceType), "audio" : voice64String as Any]
            let server = "http://59.111.57.55:8889/vc"
            SVProgressHUD.show()
            AF.request(server, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {[weak self] (response) in
                guard let `self` = self else {return}
                
                
                if(response.error == nil){
  
                    SVProgressHUD.showSuccess(withStatus: "转换成功")
                    let targetValue = response.value as! [String : Any]
                    
                    let targetAudioString = targetValue["targetAudio"] as! String
                    //print("解码后的base64数据\(targetAudioString)")
                    
                    //base64解码
                    let decodedAudioData = NSData.init(base64Encoded: targetAudioString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
                    let temp = FCFileManager.pathForTemporaryDirectory(withPath: "temp\(Int(Date().timeIntervalSince1970)).pcm")
                    //FCFileManager.removeItem(atPath: temp)
                    FCFileManager.writeFile(atPath: temp, content: decodedAudioData)
    //                let audioPlayer = AudioQueuePlay.init()
    //                audioPlayer.play(with: decodedAudioData! as Data)
                    
                    //AVPlayer(url: )
                    //读取 /Applications/VLC.app/Contents/MacOS/VLC  --demux=rawaud --rawaud-channels 1 --rawaud-samplerate 22050 + 文件名
                    
                    AudioQueuePlayer.shared().player(withFilePath: temp!)
                    
                }else{
                    SVProgressHUD.showError(withStatus: "转换失败")
                    print("请求失败\(String(describing: response.error))")
                }
                
            }
            
            recordState = .waiting
            recordButton.setTitle("录音", for: .normal)
        }
    }
    
    //开始录音
    func startEngine() {

        recordState = .recording

        allDataValueArray.removeAll()
        
        Settings.sampleRate = 48000
        Settings.channelCount = 2
//        try! Settings.setSession(category: .playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker.rawValue)
        try! Settings.setSession(category: .playAndRecord)
        
        let mic = engine.input!
        let micMixer = Mixer(mic)
        micMixer.volume = 0
        let mixer = Mixer(micMixer)
        mixer.volume = 0
        engine.output = mixer
        
        do {
            try engine.start()
            let inputFormat = mic.avAudioNode.outputFormat(forBus: 0)
            let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: true)!
            guard let formatConverter = AVAudioConverter(from: inputFormat, to: recordingFormat) else {
                return
            }
            mic.avAudioNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(4800), format: inputFormat) { [weak self] (buffer, time) in
                guard let strongSelf = self else { return }
                strongSelf.conversionQueue.async {
                    let pcmBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat, frameCapacity: AVAudioFrameCount(2205))

                    var error: NSError? = nil

                    let inputBlock: AVAudioConverterInputBlock = {inNumPackets, outStatus in
                        outStatus.pointee = AVAudioConverterInputStatus.haveData
                        return buffer
                    }

                    formatConverter.convert(to: pcmBuffer!, error: &error, withInputFrom: inputBlock)
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else if let channelData = pcmBuffer!.floatChannelData {

                        let channelDataValue = channelData.pointee
                        let channelDataValueArray = stride(from: 0,
                                                           to: Int(pcmBuffer!.frameLength),
                                                           by: pcmBuffer!.stride).map{ channelDataValue[$0] }
                        strongSelf.allDataValueArray += channelDataValueArray
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //结束录音
    func stopEngine() {
        engine.stop()
        recordState = .waiting
        
        //print("allDataValueArray.count:", allDataValueArray.count)
        
        let outputFormatSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey:16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 1
            ] as [String : Any]


        let outputFileUrl = URL.init(fileURLWithPath: filePath!)

        let tempformat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!
        let outputformat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 22050, channels: 1, interleaved: false)!

        let outputAudioFile = try? AVAudioFile(forWriting: outputFileUrl, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatInt16, interleaved: false)

        let tempFloatPcmBuffer = AVAudioPCMBuffer(pcmFormat: tempformat, frameCapacity: AVAudioFrameCount(allDataValueArray.count))

        let outputPcmBuffer = AVAudioPCMBuffer(pcmFormat: outputformat, frameCapacity: AVAudioFrameCount(allDataValueArray.count))

        for i in 0..<allDataValueArray.count {
            tempFloatPcmBuffer!.floatChannelData!.pointee[i] = allDataValueArray[i]
        }
        tempFloatPcmBuffer!.frameLength = AVAudioFrameCount(allDataValueArray.count)

        guard let formatConverter = AVAudioConverter(from: tempformat, to: outputformat) else {
            return
        }
        var error: NSError? = nil
        let inputBlock: AVAudioConverterInputBlock = {inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return tempFloatPcmBuffer
        }

        formatConverter.convert(to: outputPcmBuffer!, error: &error, withInputFrom: inputBlock)
        if let error = error {
            print(error.localizedDescription)
        }

        do{
            try outputAudioFile!.write(from: outputPcmBuffer!)
        } catch let error as NSError {
            print("error:", error.localizedDescription)
        }

//        // Create the Array which includes the files you want to share
//        var filesToShare = [Any]()
//
//        // Add the path of the file to the Array
//        filesToShare.append(outputFileUrl)
//
//        // Make the activityViewContoller which shows the share-view
//        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
//
//        activityViewController.isModalInPresentation = true
//        // Show the share-view
//        self.present(activityViewController, animated: true, completion: nil)
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

//extension Data {
//    init(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
//        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
//        self.init(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
//    }
//
//    func makePCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
//        let streamDesc = format.streamDescription.pointee
//        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
//        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
//
//        buffer.frameLength = buffer.frameCapacity
//        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
//
//        withUnsafeBytes { (bufferPointer) in
//            guard let addr = bufferPointer.baseAddress else { return }
//            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
//        }
//
//        return buffer
//    }
//}
