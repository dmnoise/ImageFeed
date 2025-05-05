//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 08.04.2025.
//

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
    
    // MARK: - Private properties
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    func logout() {
        profile = nil
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        guard let request = makeProfileServiceRequest(authToken: token) else {
            LogService.error("Hе удалось создать request")
            return
        }
        
        task?.cancel()
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            guard let self else { return }
            
            switch result {
            case .success(let result):
                let profile = Profile(
                    username: result.username,
                    name: "\(result.firstName ?? "") \(result.lastName ?? "")",
                    loginName: "@\(result.username)",
                    bio: result.bio ?? ""
                )
                
                self.profile = profile
                
                completion(.success(profile))
            case .failure(let error):
                LogService.error(error.localizedDescription)
                completion(.failure(error))
            }
            
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private func makeProfileServiceRequest(authToken: String) -> URLRequest? {
        
        let baseURL = Constants.defaultBaseURL?.appendingPathComponent("me")
        
        guard let url = baseURL else {
            LogService.error("Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = HttpMethods.get
        
        return request
    } 
}
