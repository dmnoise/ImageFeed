//
//  ProfileViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//
@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func attachView(_ view: any ImageFeed.ProfileViewControllerProtocol) { }    
    func addObserverUpdateAvatar() { }
    func didTapLogout() { }
    
    
}
