//
//  UIViewExtension.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import SnapKit
import QuartzCore

extension UIView {
    @IBInspectable
    var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
    }
}

@IBDesignable extension UIView{
    @IBInspectable
    public var cornerRadius: CGFloat{
        set{
            self.layer.roundCorners(radius: newValue)
        }get{
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var shadowRadius: CGFloat {
        set{
            self.layer.addShadow(radius: newValue)
        }get{
            return self.layer.shadowRadius
        }
    }
}

extension CALayer {
    func addShadow(radius: CGFloat) {
        self.shadowOffset = .zero
        self.shadowOpacity = 0.2
        self.shadowRadius = radius
        self.shadowColor = UIColor.black.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        self.masksToBounds = true
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "shadow_layer" {
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "shadow_layer"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}

//Flip, Rotate
extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        self.layer.transform = CATransform3DMakeRotation(toValue, 0, 0, 1);
    }
    
    func flip(flipped: Bool = true) {
        self.layer.transform = CATransform3DMakeRotation(flipped ? .pi : 0, 0, 0, 1);
//        let radian = atan2(self.transform.b, self.transform.a)
//        if radian == 0 {
//            self.layer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1);
//        }
//        else {
//            self.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
//        }
    }
}

//Tap Action
extension UIView {
    func addTapAction(target: Any?, action: Selector?) {
        self.gestureRecognizers?.removeAll()
        
        let gesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(gesture)
    }
}

extension UIStackView {
    
    func safelyRemoveArrangedSubviews() {
        
        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }
        
        // Deactive all constraints at once
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

