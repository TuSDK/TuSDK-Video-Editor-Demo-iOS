//
//  PlayerControlView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/24.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit
protocol PlayerControlDelegate {
    /// 播放事件
    /// - Parameters:
    ///   - controlView: 当前
    ///   - play: 播放/暂停
    func controlView(_ controlView: PlayerControlView, isPlay: Bool)
    //func controlView(_ controlView: PlayerControlView, seek progress: Float)
    func controlView(_ controlView: PlayerControlView, valueChanged progress: Float)
}
class PlayerControlView: UIView {

    private let playButton = UIButton()
    private let progressSlider = UISlider()
    private let durationLabel = UILabel()
    var delegate: PlayerControlDelegate?
    public var isPlaying = false {
        didSet {
            DispatchQueue.main.async {
                self.playButton.isSelected = self.isPlaying
            }
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
        let isPlay = !sender.isSelected
        delegate?.controlView(self, isPlay: isPlay)
    }
    
    @objc private func sliderTouchAction(_ sender: UISlider) {
        delegate?.controlView(self, isPlay: false)
    }
    @objc private func sliderMoveAction(_ sender: UISlider) {
        //delegate?.controlView(self, seek: sender.value)
    }
    @objc private func sliderChanged(_ slider: UISlider) {
        delegate?.controlView(self, valueChanged: slider.value)
    }
    public func progress(current pts: Int, duration: Int) {
        DispatchQueue.main.async {
            self.progressSlider.value = Float(pts) / Float(duration)
            self.durationLabel.text = "\(pts.formatTime())/\(duration.formatTime())"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
