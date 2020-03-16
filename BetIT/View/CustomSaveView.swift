//
//  CustomSaveView.swift
//  BetIT
//
//  Created by joseph on 10/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CustomSaveViewDelegate: AnyObject {
    @objc optional func customSaveViewAnimationDidStop(_ customSaveView: CustomSaveView)
    @objc optional func customSaveViewAnimationDidStart(_ customSaveView: CustomSaveView)
}

internal final class CustomSaveView: UIView {
    weak var delegate: CustomSaveViewDelegate?
    static let defaultSize = CGSize(width: 132, height: 132)
    private let insetVal = CGFloat(16)
    private let backgroundCircleColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 0.4)
    private let foregroundCircleColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)
    private let circleBorderWidth = CGFloat(5.0)
    private var backgroundCircleView: UIView!
    
    var circleLayer: CAShapeLayer!
    var checkMarkLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        // self.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        self.backgroundColor = UIColor.clear

        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0
        self.layer.cornerRadius = 5.0
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        let circleViewFrame = self.bounds.inset(by: UIEdgeInsets(top: insetVal, left: insetVal, bottom: insetVal, right: insetVal))
        
        backgroundCircleView = UIView(frame: circleViewFrame)
        backgroundCircleView.layer.borderWidth = circleBorderWidth
        backgroundCircleView.layer.borderColor = backgroundCircleColor.cgColor
        backgroundCircleView.layer.cornerRadius = min(backgroundCircleView.frame.width, backgroundCircleView.frame.height) / 2.0
        backgroundCircleView.backgroundColor = UIColor.white
        self.addSubview(backgroundCircleView)

        
        let arcCenter = CGPoint(x: frame.size.width / 2.0,
                                y: frame.size.height / 2.0)
        let radius = frame.size.width / 2.0 - circleBorderWidth / 2.0 - insetVal
        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                      radius: radius,
                                      startAngle: CGFloat(Double.pi / 4.0),
                                      endAngle: CGFloat(Double.pi * (9.0 / 8.0)),
                                      clockwise: false)
        
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = foregroundCircleColor.cgColor
        circleLayer.lineWidth = circleBorderWidth;

        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        
        self.layer.addSublayer(circleLayer)

        
        // Check mark
        let checkMarkCenter = CGPoint(x: arcCenter.x - 10.0 , y: arcCenter.y + 20.0)
        
        // [START calculate_target_point]
        let firstCheckMarkEndAngle = CGFloat(Double.pi * (9.0 / 8.0))
        var xVal = radius * cos(firstCheckMarkEndAngle), yVal = radius * sin(firstCheckMarkEndAngle)
        var targetPoint = CGPoint(x: xVal + arcCenter.x, y: yVal + arcCenter.y)
        // polar coords: x = r * sin(theta) ; y = r * cos(theta) for clockwise, since we're going counter clockwise, swap sin & cos
        // [END calculate_target_point]
        let firstCheckMarkPath = UIBezierPath()
        firstCheckMarkPath.move(to: targetPoint)
        firstCheckMarkPath.addLine(to: checkMarkCenter)

        let secondCheckMarkEndAngle = CGFloat(Double.pi * (14.0 / 8.0))
        xVal = radius * cos(secondCheckMarkEndAngle)
        yVal = radius * sin(secondCheckMarkEndAngle)
        targetPoint = CGPoint(x: xVal + arcCenter.x, y: yVal + arcCenter.y)
        firstCheckMarkPath.addLine(to: targetPoint)

        checkMarkLayer = CAShapeLayer()
        checkMarkLayer.fillColor = UIColor.clear.cgColor
        checkMarkLayer.strokeColor = foregroundCircleColor.cgColor
        checkMarkLayer.lineWidth = circleBorderWidth
        checkMarkLayer.path = firstCheckMarkPath.cgPath
        checkMarkLayer.strokeEnd = 0.0
        checkMarkLayer.fillMode = .forwards
        self.layer.addSublayer(checkMarkLayer)
    }
    
    func startAnimation() {
        let beginTime = CACurrentMediaTime()
        addArcAnimation(beginTime: beginTime, duration: 0.2)
        addCheckmarkAnimation(beginTime: beginTime + 0.2, duration: 0.5)
        self.delegate?.customSaveViewAnimationDidStart?(self)
    }
    
    private func addArcAnimation(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.beginTime = beginTime
        strokeAnimation.duration = duration
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1.0
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        circleLayer.add(strokeAnimation, forKey: "animateCircle")
    }
    
    private func addCheckmarkAnimation(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        
        let strokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEnd.values = [0.0, 0.4, 1.0, 0.6, 0.7]
        strokeEnd.keyTimes = [0.0, 0.4, 0.7, 0.8, 1.0]
        strokeEnd.duration = duration
        strokeEnd.isAdditive = true
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let strokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStart.values = [0.0, 0.3, 0.4, 0.3]
        strokeStart.keyTimes = [0.0, 0.5, 0.6, 0.7]
        strokeStart.duration = 0.25
        strokeStart.beginTime = 0.25
        strokeStart.isAdditive = true
        strokeStart.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let group = CAAnimationGroup()
        group.delegate = self
        group.setValue("group", forKey: "animationID")
        group.animations = [strokeEnd, strokeStart]
        group.duration = duration
        group.beginTime = beginTime
        checkMarkLayer.add(group, forKey: "group")
    }
        
}

extension CustomSaveView: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let animationID = anim.value(forKey: "animationID") as? String else { return }

        if animationID == "group" {
            CATransaction.setDisableActions(true)
            checkMarkLayer.strokeEnd = 0.7
            checkMarkLayer.strokeStart = 0.3
            CATransaction.setDisableActions(false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.delegate?.customSaveViewAnimationDidStop?(self)
            }
        }
        
    }
}
