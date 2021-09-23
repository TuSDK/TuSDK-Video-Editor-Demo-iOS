//
//  TTMatteView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/13.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

protocol TTMatteViewDelegate: AnyObject {
    func matteView(_ matteView: TTMatteView, posX: Float, posY: Float)
    func matteView(_ matteView: TTMatteView, rotate: Float)
    func matteView(_ matteView: TTMatteView, scaleX: Float, scaleY: Float)
}
class TTMatteView: UIView, UIGestureRecognizerDelegate {
    private(set) var interactionRatio: Float = 1
    weak var delegate: TTMatteViewDelegate?
    private var code: String = ""
    private let interactionView = UIView()
    private var itemView: UIView?
    private var rotate: CGFloat = 0
    private var itemPanGesture: UIPanGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    var currentScale = CGPoint(x: 1, y: 1) 
    private var startScale = CGPoint(x: 1, y: 1)
    private var rectangleScale = CGPoint(x: 1, y: 1)
    private var loc_in: CGPoint = .zero
    private var isPanVertical = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(interactionView)
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(superPanAction(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateinteraction(rect: CGRect) {
        interactionView.frame = rect
        interactionRatio = Float(rect.width/rect.height)
    }
    // transform init property
    func addItem(code:String, model: TTMatteModel) {
        self.code = code
        reload()
        let posX = model.nativePosX()
        let posY = model.nativePosY()
        switch code {
        case TUPVEMatteEffect_CONFIG_TYPE_LINEAR:
            pinchGesture.isEnabled = false
            panGesture.isEnabled = false
            // 线延长
            let itemWidth = frame.width * 3
            itemView = UIView(frame: CGRect(x: (interactionView.frame.width * posX - itemWidth/2) + interactionView.frame.origin.x, y: ((interactionView.frame.height - 1) * posY) + interactionView.frame.origin.y, width: itemWidth, height: 1))
            itemView?.backgroundColor = .white
            itemView?.setEnlargeEdgeWithTop(10, left: 0, bottom: 10, right: 0)
            addSubview(itemView!)
            break
        case TUPVEMatteEffect_CONFIG_TYPE_MIRROR:
            panGesture.isEnabled = false
            startScale = CGPoint(x: CGFloat(model.scale), y: CGFloat(model.scale))
            let itemWidth = frame.width * 3
            let itemHeight = CGFloat(model.scale) * interactionView.frame.height
            itemView = UIView(frame: CGRect(x: interactionView.frame.width * posX - itemWidth/2 + interactionView.frame.origin.x, y: interactionView.frame.height * posY - itemHeight/2 + interactionView.frame.origin.y, width: itemWidth, height: itemHeight))
            //itemView?.setEnlargeEdgeWithTop(10, left: 0, bottom: 10, right: 0)
            addSubview(itemView!)
            
            let topLine = UIView()
            topLine.backgroundColor = .white
            itemView?.addSubview(topLine)
            topLine.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(1)
            }
            let bottomLine = UIView()
            bottomLine.backgroundColor = .white
            itemView?.addSubview(bottomLine)
            bottomLine.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            break
        case TUPVEMatteEffect_CONFIG_TYPE_CIRCLE, TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE:
            startScale = CGPoint(x: CGFloat(model.scaleX), y: CGFloat(model.scaleY))
            let itemWidth: CGFloat = CGFloat(kDefaultMatteScale) * interactionView.frame.width
            itemView = UIView(frame: CGRect(x: interactionView.frame.width * posX - itemWidth/2 + interactionView.frame.origin.x, y: interactionView.frame.height * posY - itemWidth/2 + interactionView.frame.origin.y, width: itemWidth, height: itemWidth))
            
            if code == TUPVEMatteEffect_CONFIG_TYPE_CIRCLE {
                itemView?.layer.cornerRadius = itemWidth/2
            }
            itemView?.layer.borderWidth = 1
            itemView?.layer.borderColor = UIColor.white.cgColor
            addSubview(itemView!)
            //itemView?.transform = itemView!.transform.scaledBy(x: CGFloat(model.scaleX/kDefaultMatteScale), y: CGFloat(model.scaleY/(kDefaultMatteScale * interactionRatio)))
                
            let topIcon = UIImageView(image: UIImage(named: "mask_scale_top"))
            itemView?.addSubview(topIcon)
            topIcon.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(-10)
                make.width.height.equalTo(10)
            }
            let bottomIcon = UIImageView(image: UIImage(named: "mask_scale_bottom"))
            itemView?.addSubview(bottomIcon)
            bottomIcon.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(10)
                make.width.height.equalTo(10)
            }
            let leftIcon = UIImageView(image: UIImage(named: "mask_scale_hor"))
            itemView?.addSubview(leftIcon)
            leftIcon.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(-10)
                make.width.height.equalTo(10)
            }
            let rightIcon = UIImageView(image: UIImage(named: "mask_scale_hor"))
            itemView?.addSubview(rightIcon)
            rightIcon.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(10)
                make.width.height.equalTo(10)
            }
            
            break
        case TUPVEMatteEffect_CONFIG_TYPE_LOVE, TUPVEMatteEffect_CONFIG_TYPE_STAR:
            panGesture.isEnabled = false
            startScale = CGPoint(x: CGFloat(model.scaleX), y: CGFloat(model.scaleX))
            let itemWidth: CGFloat = CGFloat(kDefaultMatteScale) * min(interactionView.frame.width, interactionView.frame.height)
            let itemView = UIImageView(frame: CGRect(x: interactionView.frame.width * posX - itemWidth/2 + interactionView.frame.origin.x, y: interactionView.frame.height * posY - itemWidth/2 + interactionView.frame.origin.y, width: itemWidth, height: itemWidth))
            itemView.isUserInteractionEnabled = true
            itemView.image = UIImage(named: (code == TUPVEMatteEffect_CONFIG_TYPE_LOVE) ? "mask_item_heart" : "mask_item_star")
            self.itemView = itemView
            addSubview(itemView)
            
            itemView.transform = itemView.transform.scaledBy(x: CGFloat(model.scaleX/kDefaultMatteScale), y: CGFloat(model.scaleX/kDefaultMatteScale))
            break
        default:
            break
        }
        guard let itemView = itemView else { return }
        let pointView = UIImageView()
        pointView.image = UIImage(named: "mask_center")
        itemView.addSubview(pointView)
        pointView.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.center.equalToSuperview()
        }
        itemPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        itemPanGesture.maximumNumberOfTouches = 1
        itemView.addGestureRecognizer(itemPanGesture)
        
        rotate = CGFloat(model.rotate)
        if code == TUPVEMatteEffect_CONFIG_TYPE_CIRCLE || code == TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE {
            rectangleScale = CGPoint(x: CGFloat(model.scaleX/kDefaultMatteScale), y: CGFloat(model.scaleY/(kDefaultMatteScale*interactionRatio)))
            itemView.transform = CGAffineTransform.init(rotationAngle: rotate).scaledBy(x: rectangleScale.x, y: rectangleScale.y)
        }  else {
            itemView.transform = itemView.transform.rotated(by: rotate)
        }
        itemSubviewDisableTransform()
        currentScale = CGPoint(x: 1, y: 1)
    }
    func reload() {
        self.itemView?.removeFromSuperview()
        panGesture.isEnabled = true
        pinchGesture.isEnabled = true
    }
    
    private func itemSubviewDisableTransform() {
        guard let itemView = itemView else { return }
        for subView in itemView.subviews {
            subView.transform = itemView.transform.inverted().rotated(by: rotate)
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func panAction(_ gesture: UIPanGestureRecognizer) {
        guard let itemView = itemView else { return }
        let translation = gesture.translation(in: self)
        let newCenter = CGPoint(x: itemView.center.x + translation.x, y: itemView.center.y + translation.y)
        let position = CGPoint(x: newCenter.x-interactionView.frame.origin.x, y: newCenter.y-interactionView.frame.origin.y)
        if position.x > 0,
           position.x < interactionView.frame.width,
           position.y > 0,
           position.y < interactionView.frame.height {
            itemView.center = newCenter
            self.delegate?.matteView(self, posX: Float(position.x/interactionView.frame.width), posY: Float(position.y/interactionView.frame.height))
            // print("mattexx", position, posX, posY)
        }
        gesture.setTranslation(.zero, in: self)
    }
    @objc func rotationAction(_ gesture: UIRotationGestureRecognizer) {
        guard let itemView = itemView else { return }
        rotate += gesture.rotation
        if code == TUPVEMatteEffect_CONFIG_TYPE_CIRCLE || code == TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE {
            itemView.transform = CGAffineTransform.init(rotationAngle: rotate).scaledBy(x: currentScale.x * rectangleScale.x, y: currentScale.y * rectangleScale.y)
        }  else {
            itemView.transform = itemView.transform.rotated(by: gesture.rotation)
        }
        self.delegate?.matteView(self, rotate: Float(rotate))
        gesture.rotation = 0;
    }
    @objc func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        guard let itemView = itemView else { return }
        currentScale.x *= gesture.scale
        currentScale.y *= gesture.scale
        itemView.transform = itemView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        itemSubviewDisableTransform()
        gesture.scale = 1;
        self.delegate?.matteView(self, scaleX: Float(currentScale.x * startScale.x), scaleY: Float(currentScale.y * startScale.y))
    }
    
    @objc func superPanAction(_ gesture: UIPanGestureRecognizer) {
        guard let itemView = itemView else { return }
        //let translation = gesture.translation(in: self)
        let location = gesture.location(in: self)
        
        if gesture.state == .began {
            loc_in = location
//            isPanVertical = abs(translation.y) > abs(translation.x)
            let angle = angle(radius: rotate)
            isPanVertical = !(location.x > itemView.frame.maxX || location.x < itemView.frame.minX)
            if (angle > 45 && angle < 135) || (angle > 225 && angle < 315) {
                isPanVertical = !isPanVertical
            }
            //print("matte 上下：", isPanVertical, angle, !(location.x > itemView.frame.maxX || location.x < itemView.frame.minX))
        } else if gesture.state == .changed {
            let scale = getScale(current: location, began: loc_in)
            var scaleX = scale
            var scaleY = scale
            
            if isPanVertical { // 上下
                currentScale.y *= scale
                scaleX = 1
            } else { // 左右
                currentScale.x *= scale
                scaleY = 1
            }
            itemView.transform = itemView.transform.scaledBy(x: scaleX, y: scaleY)
            itemSubviewDisableTransform()
            //print("scale-- y:", isPanVertical, scale)
            self.delegate?.matteView(self, scaleX: Float(currentScale.x * startScale.x), scaleY: Float(currentScale.y * startScale.y))
            loc_in = location
        }
        gesture.setTranslation(.zero, in: self)
    }
    
    private func getScale(current: CGPoint, began: CGPoint) -> CGFloat {
        let x = current.x - center.x
        let y = current.y - center.y
        let curDistance = sqrt(x*x + y*y)
        let x1 = began.x - center.x
        let y1 = began.y - center.y
        let preDistance = sqrt(x1*x1 + y1*y1)
        return curDistance/preDistance
    }
    /// 弧度转换为角度
    private func angle(radius: CGFloat) -> Int {
        let angle = Int(radius * 180 / CGFloat(Double.pi))
        return abs(angle) % 360
    }
    
}
