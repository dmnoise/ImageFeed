//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 19.03.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private enum HttpMethods {
        static let get = "GET"
        static let post = "POST"
        static let head = "HEAD"
    }
    
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
        request.httpMethod = HttpMethods.post
        
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
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let result = try decoder.decode(OAuthTokenResponseBody.self, from: data)
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
