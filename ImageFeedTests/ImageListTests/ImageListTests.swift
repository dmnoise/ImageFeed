//
//  ImageListTests.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

import XCTest
@testable import ImageFeed
import Foundation

final class ImageListViewPresenterTests: XCTestCase {
    
    var presenter: ImageListViewPresenter!
    var view: MockImagesListView!
    var service: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        service = MockImagesListService()
        view = MockImagesListView()
        
        presenter = ImageListViewPresenter(imagesListService: service)
        presenter.attachView(view)
    }
    
    func testNumberOfRows() {
        service.photos = [Photo.mock(id: "1"), Photo.mock(id: "2")]
        presenter.handlePhotosDidChange() // обновляем presenter.photos
        
        XCTAssertEqual(presenter.numberOfRows(), 2)
    }
    
    func testPhotoAtIndex() {
        service.photos = [Photo.mock(id: "1"), Photo.mock(id: "2")]
        presenter.handlePhotosDidChange()
        
        let photo = presenter.photo(at: 1)
        XCTAssertEqual(photo.id, "2")
    }
    
    func testFormatDate() {
        service.photos = [Photo.mock(createdAt: Date())]
        presenter.handlePhotosDidChange()
        
        let dateString = presenter.formatDate(at: 0)
        XCTAssertFalse(dateString.isEmpty)
    }
    
    func testDidTapLikeFailure() {
        let photo = Photo.mock(id: "1", isLiked: true)
        service.photos = [photo]
        service.shouldLikeSucceed = false
        presenter.handlePhotosDidChange()
        
        presenter.didTapLike(at: 0)
        
        XCTAssertNil(view.updatedLikeIndex)
    }
}
