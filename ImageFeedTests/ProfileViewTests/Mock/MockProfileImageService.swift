//
//  MockProfileImageService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

@testable import ImageFeed
import Foundation

final class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: URL?
}
