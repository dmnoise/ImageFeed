//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 09.04.2025.
//

import Foundation

private enum ImageServiceError: Error {
    case FailConvertUrl
}

protocol ProfileImageServiceProtocol {
    var avatarURL: URL? { get }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Private properties
    private var storage = OAuth2TokenKeychain.shared
    private(set) var avatarURL: URL?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    func fetchProfileImage(username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard
            let request = makeProfileImageServiceRequest(username: username)
        else {
            LogService.error("не удалось создать запрос")
            return
        }
        
        task?.cancel()
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let responce):
                guard
                    let imageUrl = responce.profileImage["medium"],
                    let url = URL(string: imageUrl)
                else {
                    completion(.failure(ImageServiceError.FailConvertUrl))
                    return
                }
                
                self.avatarURL = url
                
                completion(.success(()))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": url]
                )

            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private func makeProfileImageServiceRequest(username: String) -> URLRequest? {
        
        guard let token = storage.token else {
            LogService.error("token is empty")
            return nil
        }
        
        let baseURL = Constants.defaultBaseURL?
            .appendingPathComponent("users")
            .appendingPathComponent(username)
        
        guard let url = baseURL else {
            LogService.error("Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = HttpMethods.get
        
        return request
    }
}
