//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 15.03.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
