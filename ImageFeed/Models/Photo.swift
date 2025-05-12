//
//  Photo.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 12.05.2025.
//
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
}
