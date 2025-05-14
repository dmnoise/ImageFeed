//
//  MockImageListView.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

@testable import ImageFeed
import Foundation

final class MockImagesListView: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    
    var insertedIndexPaths: [IndexPath] = []
    var updatedLikeIndex: Int?
    var updatedLikeValue: Bool?
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertedIndexPaths = indexPaths
    }
    
    func updateLikeStatus(at index: Int, isLiked: Bool) {
        updatedLikeIndex = index
        updatedLikeValue = isLiked
    }
}
