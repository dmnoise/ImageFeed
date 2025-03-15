//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 15.03.2025.
//

import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showWebViewSegueIdentifier:
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.delegate = self
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        // TODO: hmm
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
