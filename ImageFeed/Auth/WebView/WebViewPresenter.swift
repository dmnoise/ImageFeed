//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 13.05.2025.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    // MARK: - Private properties
    private var authConfiguration = AuthConfiguration.standart
    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard var urlComponents = URLComponents(string: authConfiguration.unsplashAuthorizeURLString) else {
            LogService.error("Не удалось сформировать urlComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: authConfiguration.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            LogService.error("Не удалось сформировать url")
            return
        }
        
        let request = URLRequest(url: url)
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            LogService.notice("Не удалось получить значение")
            return nil
        }
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgress = Float(newValue)
        
        view?.setProgressValue(newProgress)
        view?.setProgressHidden(shouldHideProgress(for: newProgress))
    }
    
    // MARK: - Private methods
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
