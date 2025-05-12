//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 12.05.2025.
//

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}
