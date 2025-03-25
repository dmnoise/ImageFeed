//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 19.03.2025.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
        
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        let baseUrl = "https://unsplash.com/oauth/token"
        let urlComponents = URLComponents(string: baseUrl)
        
        guard var urlComponents else {
            print("makeOAuthTokenRequest: Ошибка создания URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            print("makeOAuthTokenRequest: Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }
        
        let task = URLSession.shared.data(for: request) { data in
            
            switch data {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(result.accessToken))
                }
                catch {
                    print("fetchOAuthToken: Ошибка декодирования - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("fetchOAuthToken: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
