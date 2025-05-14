//
//  MockProfileViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

@testable import ImageFeed
import Foundation

final class MockProfileViewController: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol? = nil
    
    var didShowProfileInfo = false
    var didSetAvatar = false
    var didProceedToSplash = false
    var presentedAlert: AlertModel?
    
    func showProfileInfo(_ profile: Profile) {
        didShowProfileInfo = true
    }
    
    func setAvatar(with imageUrl: URL) {
        didSetAvatar = true
    }
    
    func proceedToSplashScreen() {
        didProceedToSplash = true
    }
    
    func showAlert(_ alert: AlertModel) {
        presentedAlert = alert
    }
}
