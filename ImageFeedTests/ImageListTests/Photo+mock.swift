//
//  Photo+mock.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 15.05.2025.
//

@testable import ImageFeed
import Foundation

extension Photo {
    static func mock(
        id: String = "test",
        size: CGSize = CGSize(width: 100, height: 100),
        createdAt: Date? = Date(),
        welcomeDescription: String? = nil,
        isLiked: Bool = false,
        thumbImageURL: String = "thumb",
        largeImageURL: String = "large"
    ) -> Photo {
        return Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
