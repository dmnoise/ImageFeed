//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 22.04.2025.
//

import Foundation

private enum ImageListServiceError: Error {
    case invalidRequest
    case tokenIsEmpty
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
}

private struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}

private struct UrlsResult: Decodable {
    let full: String
    let small: String
    let thumb: String
}


final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    // MARK: - Private properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 1
    private var task: URLSessionTask?
    private var taskLike: URLSessionTask?
    
    private let storage = OAuth2TokenKeychain.shared
    private let dateFormatter = ISO8601DateFormatter()

    // MARK: - Public Methods
    func logout() {
        photos = []
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard taskLike == nil else {
            LogService.notice("Запрос уже выполняется")
            return
        }
        
        guard let request = makeLikePhotoRequest(id: photoId, isLike: isLike) else {
            completion(.failure(ImageListServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] (result: Result<Data, Error>) in
            
            guard let self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.updateLikeStatus(for: photoId, isLike: isLike)
                }
                
                completion(.success(Void()))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
            taskLike = nil
        }
        
        task.resume()
        taskLike = task
    }

    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        
        guard let token = storage.token else {
            LogService.error("Отсутствует токен")
            completion(ImageListServiceError.tokenIsEmpty)
            return
        }
        
        guard task == nil else {
            LogService.notice("Запрос уже выполняется")
            return
        }
        
        guard let request = makePhotosRequest(token: token) else {
            completion(ImageListServiceError.invalidRequest)
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            guard let self else { return }
            
            switch result {
            case .success(let photosRes):
           
                // TODO: По какой-то причине приходят изображения последняя в первом запросе и первая в следующем - одинаковые
                // TODO: Вероятно так быть не должно, поэтому этот фильтр здесь
                let uniquePhotos = photosRes.filter { new in
                    !self.photos.contains(where: { $0.id == new.id })
                }
                
                photos.append(
                    contentsOf: uniquePhotos.map { element in
                            .init(
                                id: element.id,
                                size: CGSize(width: element.width, height: element.height),
                                createdAt: self.dateFormatter.date(from: element.createdAt),
                                welcomeDescription: element.description,
                                thumbImageURL: element.urls.small,
                                largeImageURL: element.urls.full,
                                isLiked: element.likedByUser
                            )
                    }
                )
                
                lastLoadedPage += 1
                
                updatePhotos()
                
                completion(nil)
                
            case .failure(let error):
                completion(error)
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private func updateLikeStatus(for id: String, isLike: Bool) {
        
        if let index = photos.firstIndex(where: { $0.id == id }) {
            
            var photo = photos[index]
            photo.isLiked = isLike
            photos[index] = photo
            
            updatePhotos()
        } else {
            LogService.error("Фото ID:\(id) - не найдено")
        }
    }
    
    private func makeLikePhotoRequest(id: String, isLike: Bool) -> URLRequest? {
        guard let stringUrl = Constants.defaultBaseURL?.absoluteString else {
            LogService.error("Не удалось получить url из constants")
            return nil
        }
        
        guard let token = storage.token else {
            LogService.error("Отсутствует токен")
            return nil
        }
        
        let urlComponents = URLComponents(string: stringUrl)
        
        guard var urlComponents else {
            LogService.error("Ошибка создания URLComponents")
            return nil
        }
        
        urlComponents.path = "/photos/\(id)/like"
        
        guard let url = urlComponents.url else {
            LogService.error("Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? HttpMethods.post : HttpMethods.delete
        
        return request
    }
    
    private func makePhotosRequest(token: String) -> URLRequest? {
        
        guard let stringUrl = Constants.defaultBaseURL?.absoluteString else {
            LogService.error("Не удалось получить url из constants")
            return nil
        }
        
        let urlComponents = URLComponents(string: stringUrl)
        
        guard var urlComponents else {
            LogService.error("Ошибка создания URLComponents")
            return nil
        }
        
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(lastLoadedPage)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            LogService.error("Ошибка создания url")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HttpMethods.get
        
        return request
        
    }
    
    private func updatePhotos() {
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
        )
    }
}
