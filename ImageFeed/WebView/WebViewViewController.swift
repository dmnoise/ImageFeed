//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 15.03.2025.
//

import UIKit
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - IBOutlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateProgress()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        loadRequest()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] _, _ in
            guard let self else { return }
            self.updateProgress()
        }
    }
    
    // MARK: - IBAction
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadRequest() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            LogService.error("Не удалось сформировать urlComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            LogService.error("Не удалось сформировать url")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            LogService.error("Не удалось получить значение")
            return nil
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
