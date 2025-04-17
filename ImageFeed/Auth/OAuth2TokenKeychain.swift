//
//  OAuth2TokenKeychain.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 20.03.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenKeychain {
    
    static let shared = OAuth2TokenKeychain()
    
    private init() { }
    
    private enum Keys: String {
        case token = "AuthToken"
    }
    
    private let keychain: KeychainWrapper = .standard
    
    var token: String? {
        get {
            keychain.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else {
                keychain.removeObject(forKey: Keys.token.rawValue)
                return
            }
            
            let isSuccess = keychain.set(newValue, forKey: Keys.token.rawValue)
            guard isSuccess else {
                LogService.error("Не удалось сохранить токен")
                return
            }
        }
    }
}
