//
//  DefaultPanableAlertView.swift
//  PanableWebViewDemo
//
//  Created by lichen on 2018/3/19.
//  Copyright © 2018年 lichen. All rights reserved.
//

import Foundation
import UIKit

class DefaultPanableAlertView: PanableAlertView {
    func setupAlertView(webview: PanableWebView, type: PanableAlertType, progress: Float, duration: TimeInterval) {
        if type == .back {
            let backView = self.getBackView(webview: webview)
            if duration > 0 {
                backView.setAnimationProgress(progress, duration: duration)
            } else {
                backView.setProgress(progress)
            }
        } else {
            let forwardView = self.getForwardView(webview: webview)
            if duration > 0 {
                forwardView.setAnimationProgress(progress, duration: duration)
            } else {
                forwardView.setProgress(progress)
            }
        }
    }

    private let alertHeight: CGFloat = 250
    private let maxAlertWidth: CGFloat = 25

    func getBackView(webview: PanableWebView) -> PanableAlertSideView {
        if self.backView.superview != webview {
            self.backView.removeFromSuperview()
            webview.addSubview(self.backView)
            self.backView.snp.makeConstraints({ (make) in
                make.left.centerY.equalToSuperview()
                make.width.equalTo(maxAlertWidth)
                make.height.equalTo(alertHeight)
            })
        }
        return self.backView
    }

    func getForwardView(webview: PanableWebView) -> PanableAlertSideView {
        if self.forwardView.superview != webview {
            self.forwardView.removeFromSuperview()
            webview.addSubview(self.forwardView)
            self.forwardView.snp.makeConstraints({ (make) in
                make.right.centerY.equalToSuperview()
                make.width.equalTo(maxAlertWidth)
                make.height.equalTo(alertHeight)
            })
        }
        return self.forwardView
    }

    lazy var backView: PanableAlertSideView = {
        var backView = PanableAlertSideView()
        backView.layer.masksToBounds = true
        backView.isUserInteractionEnabled = false
        backView.left = true
        return backView
    }()

    lazy var forwardView: PanableAlertSideView = {
        var forwardView = PanableAlertSideView()
        forwardView.layer.masksToBounds = true
        forwardView.isUserInteractionEnabled = false
        forwardView.left = false
        return forwardView
    }()
}

class PanableAlertSideView: UIView {

    var left: Bool = true

    private lazy var curveLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.black.withAlphaComponent(0.7).cgColor
        self.layer.addSublayer(shape)
        return shape
    }()

    private lazy var arrowLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 1.5
        shape.lineCap = kCALineCapRound
        shape.lineJoin = kCALineJoinRound
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shape)
        return shape
    }()

    func setProgress(_ progress: Float) {
        self.curveLayer.removeAllAnimations()
        self.arrowLayer.removeAllAnimations()
        self.curveLayer.path = self.curePath(progress)
        self.arrowLayer.path = self.arrowPath(progress)
    }

    func setAnimationProgress(_ progress: Float, duration: TimeInterval) {
        let curveAnimation = CABasicAnimation(keyPath: "path")
        curveAnimation.duration = duration
        curveAnimation.fromValue = self.curveLayer.path
        curveAnimation.toValue = self.curePath(progress)
        curveAnimation.fillMode = kCAFillModeForwards
        curveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        curveAnimation.isRemovedOnCompletion = false
        self.curveLayer.add(curveAnimation, forKey: nil)

        let arrowAnimation = CABasicAnimation(keyPath: "path")
        arrowAnimation.duration = duration
        arrowAnimation.fromValue = self.arrowLayer.path
        arrowAnimation.toValue = self.arrowPath(progress)
        arrowAnimation.fillMode = kCAFillModeForwards
        arrowAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        arrowAnimation.isRemovedOnCompletion = false
        self.arrowLayer.add(arrowAnimation, forKey: nil)
    }

    private func arrowPath(_ progress: Float) -> CGPath {
        let width = self.bounds.width
        let height = self.bounds.height

        if width * CGFloat(progress) < 11 {
            return UIBezierPath().cgPath
        }

        let realWith = width * CGFloat(progress)
        let startPoint: CGPoint = left ? CGPoint(x: realWith / 2 + 2.8, y: height / 2 - 5.6) : CGPoint(x: width - realWith / 2 - 2.8, y: height / 2 - 5.6)
        let toPoint: CGPoint = left ? CGPoint(x: realWith / 2 - 2.8, y: height / 2) : CGPoint(x: width - realWith / 2 + 2.8, y: height / 2)
        let endPoint: CGPoint = left ? CGPoint(x: realWith / 2 + 2.8, y: height / 2 + 5.6) : CGPoint(x: width - realWith / 2 - 2.8, y: height / 2 + 5.6)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: toPoint)
        path.addLine(to: endPoint)
        return path.cgPath
    }

    private func curePath(_ progress: Float) -> CGPath {
        let width = self.bounds.width
        let height = self.bounds.height

        let startPoint: CGPoint = left ? CGPoint(x: 0, y: 0) : CGPoint(x: width, y: 0)
        let endPoint: CGPoint = left ? CGPoint(x: 0, y: height) : CGPoint(x: width, y: height)
        let curvePoint: CGPoint = left ? CGPoint(x: width * CGFloat(progress), y: height / 2) : CGPoint(x: width * (1 - CGFloat(progress)), y: height / 2)

        let control1: CGPoint = CGPoint(x: startPoint.x, y: 1 / 3 * height)
        let control2: CGPoint = CGPoint(x: curvePoint.x, y: 1 / 3 * height)
        let control3: CGPoint = CGPoint(x: curvePoint.x, y: 2 / 3 * height)
        let control4: CGPoint = CGPoint(x: endPoint.x, y: 2 / 3 * height)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addCurve(to: curvePoint, controlPoint1: control1, controlPoint2: control2)
        path.addCurve(to: endPoint, controlPoint1: control3, controlPoint2: control4)
        path.addLine(to: startPoint)
        return path.cgPath
    }
}
