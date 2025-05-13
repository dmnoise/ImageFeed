//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 13.05.2025.
//

import Foundation

enum Constants {
    static let accessKey = "8dhda6N8XPUSGyahXcdhUJ7b7U8XQjzMr_XWFr4UJyQ"
    static let secretKey = "CqggnlW3Jk-DQcHWiOYyO1zvdmX32qlphIeJ-8EWEHY"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string:"https://api.unsplash.com/")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

enum HttpMethods {
    static let get = "GET"
    static let post = "POST"
    static let head = "HEAD"
    static let delete = "DELETE"
}


struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let unsplashAuthorizeURLString: String
    
    init(accessKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         defaultBaseURL: URL,
         unsplashAuthorizeURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
    
    static var standart: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString)
    }
}
