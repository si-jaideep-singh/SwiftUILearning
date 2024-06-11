//
//  ReCAPTCHAViewController.swift
//  Rajasthan Royals
//
//  Created by Manann Sseth on 20/12/22.
//

import UIKit
import WebKit

final class ReCaptchaVC: UIViewController {
    
    var webView: WKWebView!
    private let viewModel: ReCaptchaVM
    
    init(viewModel: ReCaptchaVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(viewModel, name: "recaptcha")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isHidden = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadHTMLString(viewModel.html, baseURL: viewModel.url)
    }
}
