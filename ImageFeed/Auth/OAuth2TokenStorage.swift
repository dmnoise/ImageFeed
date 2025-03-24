//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 20.03.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            storage.string(forKey: Keys.token.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
