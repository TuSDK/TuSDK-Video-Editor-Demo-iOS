//
//  LayerView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/22.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class LayerView: UIView {

    private let borderLimit: Float = 0
    var currentTransform: CGAffineTransform? = nil
    var beginCenter: CGPoint = .zero
    var lastScale:CGFloat!
    let maxScale: CGFloat = 5.0
    let minScale: CGFloat = 0.5
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("图层：初始位置:\(center),frame:(\(frame)")
        currentTransform = transform
        beginCenter = center
        addGestures()
    }
    func addGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(pan)
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
            //pinchGetsture.delegate = self
        addGestureRecognizer(pinchGetsture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension LayerView {
    // MARK: - 移动
    @objc func panAction(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            break
        case .changed:
            if location.y < 0 || location.y > bounds.height {
                return
            }
            // Store current transfrom
            let currentTransform = transform
            // Initialize transform
            transform = CGAffineTransform.identity
            
            // Move
            let translation: CGPoint = gesture.translation(in: self)
            let movedPoint = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            center = movedPoint
            
            // Revert transform
            transform = currentTransform
            
            // Reset translation
            gesture.setTranslation(.zero, in: self)
            print("图层：当前位置:\(center)----平移位置:\(translation)")
            break
        case .ended, .cancelled:
            break
        default:
            break
        }
    }
    // MARK: - 缩放
    @objc func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began { // Begin pinch
            currentTransform = transform
            beginCenter = center
            let touchPoint1 = gesture.location(ofTouch: 0, in: self)
            let touchPoint2 = gesture.location(ofTouch: 1, in: self)
            lastScale = gesture.scale
        } else if gesture.state == .changed {
            let pinchCenter = CGPoint(x: gesture.location(in: self).x - bounds.midX,
                                      y: gesture.location(in: self).y - bounds.midY)
            transform = transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: gesture.scale, y: gesture.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            gesture.scale = 1
        } else if gesture.state == .ended {
            let currentScale = sqrt(abs(transform.a * transform.d - transform.b * transform.c))
            if currentScale <= minScale {
                center = CGPoint(x: frame.width / 2, y: frame.height / 2)
                transform = CGAffineTransform(scaleX: minScale, y: minScale)
            } else if maxScale <= currentScale {
                center = CGPoint(x: frame.width / 2, y: frame.height / 2)
                transform = CGAffineTransform(scaleX: minScale, y: minScale)
            }
        }
    }
}
