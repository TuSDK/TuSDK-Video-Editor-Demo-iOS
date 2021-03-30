//
//  ControlPlayerView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/11/25.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

import UIKit

class ControlPlayerView: UIView {

    private let playButton = UIButton()
    private let progressSlider = UISlider()
    let durationLabel = UILabel()
    
    public var playCompleted:(() -> Void)?
    public var pauseCompleted:(() -> Void)?
    public var seekCompleted:((Float) -> Void)?
    public var valueChangedCompleted: ((Float) -> Void)?

    public var isPlaying = false {
        didSet {
            playButton.isSelected = isPlaying
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.4).cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientLayer)
        
        playButton.setImage(UIImage(named: "edit_ic_play"), for: .normal)
        playButton.setImage(UIImage(named: "edit_ic_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(playAction(_:)), for: .touchUpInside)
        addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(10)
            make.width.equalTo(35)
        }
        
        durationLabel.text = "00:00/00:00"
        durationLabel.textAlignment = .center
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 12)
        addSubview(durationLabel)
        durationLabel.snp.makeConstraints { (make) in
            make.centerY.right.equalToSuperview()
            make.width.equalTo(100)
        }
        progressSlider.addTarget(self, action: #selector(sliderTouchAction(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderMoveAction(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        progressSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)

        progressSlider.setThumbImage(UIImage(named: "slider_thum_icon"), for: .normal)
        addSubview(progressSlider)
        progressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(10)
            make.right.equalTo(durationLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    @objc private func playAction(_ sender: UIButton) {
        playCompleted?()
    }
    public func updateProgress(current time: Int, duration: Int) {
        self.progress(current: time, duration: Float(duration))
    }
    public func progress(current pts: Int, duration: Float) {
        DispatchQueue.main.async {
            self.progressSlider.value = Float(pts) / duration
            self.durationLabel.text = "\(pts.formatTime())/\(Int(duration).formatTime())"
        }
    }
    @objc private func sliderTouchAction(_ sender: UISlider) {
        pauseCompleted?()
    }
    @objc private func sliderMoveAction(_ sender: UISlider) {
        seekCompleted?(sender.value)
    }
    @objc private func sliderChanged(_ slider: UISlider) {
        valueChangedCompleted?(slider.value)
    }
    public func updateProgress(current time: Float) {
        DispatchQueue.main.async {
            self.progressSlider.value = time
        }
    }
    
    public func currentProg() -> Float {
        return self.progressSlider.value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
