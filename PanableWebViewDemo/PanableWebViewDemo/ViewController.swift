//
//  ViewController.swift
//  PanableWebViewDemo
//
//  Created by lichen on 2018/3/19.
//  Copyright © 2018年 lichen. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let webview = PanableWebView()
        view.addSubview(webview)
        webview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let request = URLRequest(url: URL(string: "https://www.baidu.com")!)
        webview.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

