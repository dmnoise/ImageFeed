//
//  Untitled.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 16.05.2025.
//

import Foundation

enum Constants {
    static let accessKey = "8dhda6N8XPUSGyahXcdhUJ7b7U8XQjzMr_XWFr4UJyQ"
    static let secretKey = "CqggnlW3Jk-DQcHWiOYyO1zvdmX32qlphIeJ-8EWEHY"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string:"https://api.unsplash.com/")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
