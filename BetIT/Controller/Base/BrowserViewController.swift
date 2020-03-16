//
//  BrowserViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import WebKit

enum BrowseMode: Int {
    case url = 0
    case file = 1
    case html = 2
}

class BrowserViewController: BaseViewController {
    var webView: WKWebView!
    var url: URL?
    var file: String?
    var html: String?
    var mode: BrowseMode = .url
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        ProgressHUD.dismiss()
    }
    
    func configure() {
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.view.addChild(view: webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func load() {
        switch self.mode {
        case .url:
            guard let url = self.url else {
                return
            }
            
            ProgressHUD.show()
            let request = URLRequest(url: url)
            webView.load(request)
            
        case .file:
            guard let file = self.file else {
                return
            }
            
            let url = URL(fileURLWithPath: file)
            let request = URLRequest(url: url)
            webView.load(request)
        case .html:
            guard let html = self.html else {
                return
            }
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}

extension BrowserViewController {
    convenience init(url: URL?, title: String = "") {
        self.init()
        self.title = title
        self.url = url
        self.mode = .url
    }
    
    convenience init(filepath: String?, title: String = "") {
        self.init()
        self.title = title
        self.file = filepath
        self.mode = .file
    }
    
    convenience init(html: String?, title: String = "") {
        self.init()
        self.title = title
        self.html = html
        self.mode = .html
    }
}

extension BrowserViewController: WKUIDelegate {
    
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ProgressHUD.dismiss()
    }
}
