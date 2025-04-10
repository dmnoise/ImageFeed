//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 19.03.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { [weak self] data in
            
            DispatchQueue.main.async {
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
                
                self?.lastCode = nil
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
}
