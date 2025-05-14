//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Dmitriy Noise on 15.05.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("email")
        
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        coordinate.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("passwd")
        passwordTextField.typeText("\n")
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["likeButton"].tap()
        cellToLike.buttons["likeButton"].tap()
        
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 2))
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        let imageExists = image.waitForExistence(timeout: 5)
        XCTAssertTrue(imageExists, "Изображение не появилось вовремя")

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navBackButtonWhite"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let nameLabel = app.staticTexts["Dmitriy Noise"]
        let usernameLabel = app.staticTexts["@dmnoise"]
        
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Имя пользователя не появилось")
        XCTAssertTrue(usernameLabel.exists, "Юзернейм не найден")
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
