//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 21.03.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private enum SegueKeys {
        static let showTabBar = "showTabBar"
        static let showNavigationController = "showNavigationController"
    }
    
    // MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenKeychain.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if let token = storage.token {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: SegueKeys.showNavigationController, sender: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case SegueKeys.showNavigationController:
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for showAuthScreen")
                return
            }
            
            viewController.delegate = self
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func switchToTabBar() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    // MARK: - Public Methods
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }

            self.fetchOAuthToken(code)
        }
    }
    
    // MARK: - Private methods
    private func fetchOAuthToken(_ code: String) {
           
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let token):
                storage.token = token
                self.fetchProfile(token)

            case .failure:
                let actions = [
                    AlertAction(title: "Ok", style: .cancel, handler: nil)
                ]
                
                let alert = AlertModel(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    actions: actions,
                    preferredStyle: .alert
                )
                
                AlertPresenter(from: alert).presentAlert(from: self)
                
                LogService.error("Токен не был получен")
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
                     
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImage(username: profile.username) { _ in }
                
                self.switchToTabBar()
            case .failure(let error):
                LogService.error(error.localizedDescription)
            }
        }
    }
}
