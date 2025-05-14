//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.05.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func attachView(_ view: ImagesListViewControllerProtocol)
    func numberOfRows() -> Int
    func photo(at index: Int) -> Photo
    func imageURL(at index: Int) -> String
    func formatDate(at index: Int) -> String
    func loadNextImages()
    func didTapLike(at index: Int)
}

final class ImageListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private properties
    private let imagesListService = ImagesListService.shared
    private let storage = OAuth2TokenKeychain.shared
    
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Public Methods
    func viewDidLoad() {
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let self else { return }
            
            self.handlePhotosDidChange()
        }
        
        loadNextImages()
    }
    
    func attachView(_ view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func numberOfRows() -> Int {
        photos.count
    }
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func imageURL(at index: Int) -> String {
        photo(at: index).largeImageURL
    }
    
    func formatDate(at index: Int) -> String {
        let photo = photo(at: index)
        let createdAt = photo.createdAt
        let formatedDate = dateFormatter.string(from: createdAt ?? Date())
        
        return formatedDate
    }
    
    func loadNextImages() {

        UIBlockingProgressHUD.show()
        
        imagesListService.fetchPhotosNextPage() { [weak self] error in
            
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            if let error {
                LogService.error("Ошибка загрузки изображений: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.handlePhotosDidChange()
                }
            }
        }
    }
    
    func didTapLike(at index: Int) {
        
        let photo = photos[index]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.view?.updateLikeStatus(at: index, isLiked: !photo.isLiked)
                }
 
            case .failure(let error):
                DispatchQueue.main.async {

                    let actions = [
                        AlertAction(title: "Ok", style: .cancel, handler: nil)
                    ]
                    
                    let alert = AlertModel(
                        title: "Что-то пошло не так(",
                        message: !photo.isLiked ? "Не удалось поставить лайк" : "Не удалось убрать лайк",
                        actions: actions,
                        preferredStyle: .alert
                    )
                    
                    AlertPresenter(from: alert).presentAlertFromTopVC()
                }
                
                LogService.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private methods
    private func handlePhotosDidChange() {
        let oldCount = photos.count
        photos = imagesListService.photos
        
        guard oldCount != photos.count else {
            return
        }
     
        let indexPaths = (oldCount ..< photos.count).map { i in
            IndexPath(row: i, section: 0)
        }
        
        view?.insertRows(at: indexPaths)
    }
}
