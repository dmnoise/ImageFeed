//
//  MockImageListService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

@testable import ImageFeed
import Foundation

final class MockImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var shouldLikeSucceed = true
    
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldLikeSucceed {
            completion(.success(()))
        } else {
            completion(.failure(MockError()))
        }
    }
}

struct MockError: Error {}
