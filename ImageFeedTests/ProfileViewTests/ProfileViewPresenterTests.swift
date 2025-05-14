//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileViewPresenterTests: XCTestCase {
    
    // MARK: - Tests
    func testViewControllerCallsViewDidLoad() {
        
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(with: presenter)
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewDidLoadWhenProfileExistsShouldShowProfileInfoAndAvatar() {

        let profile = Profile(
            username: "asdasd",
            name: "Asd Asd",
            loginName: "@asdasd",
            bio: "hello!"
        )
        let profileService = MockProfileService()
        profileService.profile = profile
        
        let imageService = MockProfileImageService()
        imageService.avatarURL = URL(string: "https://clck.ru/3M5RkY")
        
        let logoutService = MockLogoutService()
        let view = MockProfileViewController()
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileLogoutService: logoutService,
            profileImageService: imageService
        )
        presenter.attachView(view)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(view.didShowProfileInfo)
        XCTAssertTrue(view.didSetAvatar)
    }
    
    func testViewDidLoadWhenProfileMissingShouldNotShowProfile() {
        
        let profileService = MockProfileService() // profile = nil
        let imageService = MockProfileImageService()
        imageService.avatarURL = URL(string: "https://clck.ru/3M5RkY")
        
        let logoutService = MockLogoutService()
        let view = MockProfileViewController()
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileLogoutService: logoutService,
            profileImageService: imageService
        )
        presenter.attachView(view)
        
        presenter.viewDidLoad()
        
        XCTAssertFalse(view.didShowProfileInfo)
    }
    
    func testUpdateAvatarWhenAvatarURLExistsShouldCallSetAvatar() {
        
        let profileService = MockProfileService()
        let imageService = MockProfileImageService()
        imageService.avatarURL = URL(string: "https://clck.ru/3M5RkY")
        
        let logoutService = MockLogoutService()
        let view = MockProfileViewController()
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileLogoutService: logoutService,
            profileImageService: imageService
        )
        presenter.attachView(view)
        
        presenter.updateAvatar()
        
        XCTAssertTrue(view.didSetAvatar)
    }
    
    func testUpdateAvatarWhenNoAvatarURLShouldNotCallSetAvatar() {
        
        let profileService = MockProfileService()
        let imageService = MockProfileImageService() // avatarURL = nil
        
        let logoutService = MockLogoutService()
        let view = MockProfileViewController()
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileLogoutService: logoutService,
            profileImageService: imageService
        )
        presenter.attachView(view)
        
        presenter.updateAvatar()
        
        XCTAssertFalse(view.didSetAvatar)
    }
    
    func testDidTapLogoutShouldPresentAlertWithTwoActions() {
        
        let profileService = MockProfileService()
        let imageService = MockProfileImageService()
        let logoutService = MockLogoutService()
        let view = MockProfileViewController()
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileLogoutService: logoutService,
            profileImageService: imageService
        )
        presenter.attachView(view)
        
        presenter.didTapLogout()
        
        guard let alert = view.presentedAlert else {
            XCTFail("Alert was not presented")
            return
        }
        
        XCTAssertEqual(alert.title, "Пока, пока!")
        XCTAssertEqual(alert.message, "Уверены что хотите выйти?")
        XCTAssertEqual(alert.actions.count, 2)
        
        let yesAction = alert.actions[1]
        XCTAssertEqual(yesAction.title, "Да")
        XCTAssertEqual(yesAction.style, .default)
        
        yesAction.handler?()
        
        XCTAssertTrue(logoutService.didCallLogout)
        XCTAssertTrue(view.didProceedToSplash)
    }
}
