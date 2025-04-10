//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 09.04.2025.
//

/*
 {
   "id": "pXhwzz1JtQU",
   "updated_at": "2016-07-10T11:00:01-05:00",
   "username": "jimmyexample",
   "name": "James Example",
   "first_name": "James",
   "last_name": "Example",
   "instagram_username": "instantgrammer",
   "twitter_username": "jimmy",
   "portfolio_url": null,
   "bio": "The user's bio",
   "location": "Montreal, Qc",
   "total_likes": 20,
   "total_photos": 10,
   "total_collections": 5,
   "downloads": 225974,
   "social": {
     "instagram_username": "instantgrammer",
     "portfolio_url": "",
     "twitter_username": "jimmy"
   },
   "profile_image": {
     "small": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=32&w=32",
     "medium": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=64&w=64",
     "large": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=128&w=128"
   },
   "badge": {
     "title": "Book contributor",
     "primary": true,
     "slug": "book-contributor",
     "link": "https://book.unsplash.com"
   },
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

private enum ImageServiceError: Error {
    case FailConvertUrl
}

struct UserResult: Codable {
    let profileImage: [String:String]
}

final class ProfileImageService {
    
    private init() {}
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var storage = OAuth2TokenStorage.shared
    private(set) var avatarURL: URL?
    private var task: URLSessionTask?
        
    private func makeProfileImageServiceRequest(username: String) -> URLRequest? {
        
        guard let token = storage.token else {
            print("makeProfileImageServiceRequest: token == nil")
            return nil
        }
        
        let baseURL = Constants.defaultBaseURL?
            .appendingPathComponent("users")
            .appendingPathComponent(username)
        
        guard let url = baseURL else {
            print("makeProfileServiceRequest: Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = HttpMethods.get
        
        return request
    }
    
    func fetchProfileImage(username: String, completion: @escaping (Result<UserResult, Error>) -> Void) {
        
        guard
            let request = makeProfileImageServiceRequest(username: username)
        else {
            print("fetchProfiileImage: не удалось создать запрос")
            return
        }
        
        task?.cancel()
        
        let task = URLSession.shared.data(for: request) { [weak self] data in
            
            guard let self else { return }
            
            switch data {
            case .success(let result):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let responce = try decoder.decode(UserResult.self, from: result)
                    
                    guard
                        let imageUrl = responce.profileImage["small"],
                        let url = URL(string: imageUrl)
                    else {
                        completion(.failure(ImageServiceError.FailConvertUrl))
                        return
                    }
                    
                    self.avatarURL = url
                    
                    completion(.success(responce))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": url]
                    )
                    
                    print("ok")
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
