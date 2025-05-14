//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 05.05.2025.
//

import Foundation
import WebKit

protocol ProfileLogoutServiceProtocol {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    
    static let shared = ProfileLogoutService()
    
    private let stotage = OAuth2TokenKeychain.shared
    private let profile = ProfileService.shared
    private let images = ImagesListService.shared
    
    private init() { }
    
    func logout() {
        
        stotage.token = nil
        profile.logout()
        images.logout()
        
        cleanCookies()
    }
    
    private func cleanCookies() {
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

