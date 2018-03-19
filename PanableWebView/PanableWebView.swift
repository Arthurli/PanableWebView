//
//  PanableWebView.swift
//  PanableWebViewDemo
//
//  Created by lichen on 2018/3/19.
//  Copyright © 2018年 lichen. All rights reserved.
//

import Foundation
import SnapKit

enum PanableAlertType {
    case back
    case forward
}

protocol PanableAlertView {
    func setupAlertView(webview: PanableWebView, type: PanableAlertType, progress: Float, duration: TimeInterval)
}

class PanableWebView: UIWebView {

    private lazy var popGesture: UIGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        self.addGestureRecognizer(gesture)
        return gesture
    }()
    private var panStartX: CGFloat = 0

    var alertView: PanableAlertView = DefaultPanableAlertView()

    var enableToPanBack: Bool = true
    var enableToPanForward: Bool = true

    var goBackInSameUrl: ((String) -> Void)?
    lazy var maxSwipeDistance = self.bounds.width / 4
    var enablePanGesture: Bool {
        set {
            self.popGesture.isEnabled = enablePanGesture
        }
        get {
            return self.popGesture.isEnabled
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.enablePanGesture = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
    }

    override func goBack() {
        if let url = self.request?.url {
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                // 检测同页面 goback
                if let oldUrl = self.request?.url {
                    let nonFragmentURL = { (url: URL) -> String in
                        var nonFragmentURL = url.absoluteString
                        if let fragment = url.fragment {
                            nonFragmentURL = url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "")
                        }
                        return nonFragmentURL
                    }
                    if nonFragmentURL(oldUrl) == nonFragmentURL(url) {
                        self.goBackInSameUrl?(oldUrl.absoluteString)
                    }
                }
            }
        }
        super.goBack()
    }

    func setupAlertView(duration: TimeInterval = 0) {
        self.alertView.setupAlertView(webview: self, type: .back, progress: 0, duration: duration)
        self.alertView.setupAlertView(webview: self, type: .forward, progress: 0, duration: duration)
    }

    @objc private
    func panGesture(sender: UIPanGestureRecognizer) {

        let point = sender.translation(in: self)
        if sender.state == .began {
            self.panStartX = point.x
        } else if sender.state == .changed {
            let deltaX = point.x - self.panStartX
            if deltaX > 0 && self.canGoBack && self.enableToPanBack {
                let progress = min(abs(deltaX), self.maxSwipeDistance) / self.maxSwipeDistance
                self.alertView.setupAlertView(webview: self, type: .back, progress: Float(progress), duration: 0)
                self.alertView.setupAlertView(webview: self, type: .forward, progress: 0, duration: 0)
            } else if deltaX < 0 && self.canGoForward && self.enableToPanForward {
                let progress = min(abs(deltaX), self.maxSwipeDistance) / self.maxSwipeDistance
                self.alertView.setupAlertView(webview: self, type: .back, progress: 0, duration: 0)
                self.alertView.setupAlertView(webview: self, type: .forward, progress: Float(progress), duration: 0)
            } else {
                self.setupAlertView()
            }
        } else if sender.state == .ended ||
            sender.state == .cancelled ||
            sender.state == .failed {
            let deltaX = point.x - self.panStartX

            if deltaX > self.maxSwipeDistance && self.canGoBack && self.enableToPanBack {
                self.goBack()
                self.setupAlertView()
            } else if deltaX < -self.maxSwipeDistance && self.canGoForward && self.enableToPanForward {
                self.goForward()
                self.setupAlertView()
            } else {
                let duration = 0.25 * min(abs(deltaX), self.maxSwipeDistance) / self.maxSwipeDistance
                self.setupAlertView(duration: TimeInterval(duration))
            }
        }
    }
}
