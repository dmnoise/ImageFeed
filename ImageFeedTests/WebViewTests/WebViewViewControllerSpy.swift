//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 13.05.2025.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    
    var loadCodeCalled = false
    
    func load(request: URLRequest) {
        loadCodeCalled = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    func setProgressHidden(_ isHidden: Bool) { }
    
    
}
