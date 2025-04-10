//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 08.04.2025.
//

/*
 {
   "id": "pXhwzz1JtQU",
   "updated_at": "2016-07-10T11:00:01-05:00",
   "username": "jimmyexample",
   "first_name": "James",
   "last_name": "Example",
   "twitter_username": "jimmy",
   "portfolio_url": null,
   "bio": "The user's bio",
   "location": "Montreal, Qc",
   "total_likes": 20,
   "total_photos": 10,
   "total_collections": 5,
   "downloads": 4321,
   "uploads_remaining": 4,
   "instagram_username": "james-example",
   "location": null,
   "email": "jim@example.com",
   "links": {
     "self": "https://api.unsplash.com/users/jimmyexample",
     "html": "https://unsplash.com/jimmyexample",
     "photos": "https://api.unsplash.com/users/jimmyexample/photos",
     "likes": "https://api.unsplash.com/users/jimmyexample/likes",
     "portfolio": "https://api.unsplash.com/users/jimmyexample/portfolio"
   }
 }
 */

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func makeProfileServiceRequest(authToken: String) -> URLRequest? {
        
        let baseURL = Constants.defaultBaseURL?.appendingPathComponent("me")
        
        guard let url = baseURL else {
            print("makeProfileServiceRequest: Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = HttpMethods.get
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        guard let request = makeProfileServiceRequest(authToken: token) else {
            print("fetchProfile: ошибка - не удалось создать request")
            return
        }
        
        task?.cancel()
        
        let task = URLSession.shared.data(for: request) { [weak self] data in
                        
            switch data {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let result = try decoder.decode(ProfileResult.self, from: data)
                    
                    let profile = Profile(
                        username: result.username,
                        name: "\(result.firstName ?? "") \(result.lastName ?? "")",
                        loginName: "@\(result.username)",
                        bio: result.bio ?? ""
                    )
                    
                    self?.profile = profile
                    
                    completion(.success(profile))
                }
                catch {
                    print("fetchProfile: Ошибка декодирования - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("fetchProfile: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self?.task = nil
            
        }
        
        self.task = task
        task.resume()
    }
}
