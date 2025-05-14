//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func addObserverUpdateAvatar()
    func didTapLogout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard let profile = profileService.profile else {
            LogService.error("profile is empty")
            return
        }
        
        view?.showProfileInfo(profile)
        updateAvatar()
    }
    
    func addObserverUpdateAvatar() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    func updateAvatar() {
        guard let imageUrl = profileImageService.avatarURL else {
            return
        }
        
        view?.setAvatar(with: imageUrl)
    }
    
    func didTapLogout() {
        let actions = [
            AlertAction(title: "Нет", style: .cancel, handler: nil),
            AlertAction(title: "Да", style: .default) { [weak self] in
                guard let self else { return }
                logout()
            }
        ]
        
        let alert = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            actions: actions,
            preferredStyle: .alert
        )
        
        view?.showAlert(alert)
    }
    
    // MARK: - Private methods
    private func logout() {
        ProfileLogoutService.shared.logout()
        view?.proceedToSplashScreen()
    }
    
}
