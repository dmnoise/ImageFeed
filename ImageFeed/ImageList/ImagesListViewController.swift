//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 24.02.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet private var tableView: UITableView!
    
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
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        showNextImages()
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let self else { return }
            
            updateTableViewAnimated()
        }

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SingleImageViewController.identifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let imageURL = photos[indexPath.row].largeImageURL
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func updateTableViewAnimated() {
        
        let oldCount = photos.count
        photos = imagesListService.photos
        
        if oldCount != photos.count {
            
            let indexPaths = (oldCount ..< photos.count).map { i in
                IndexPath(row: i, section: 0)
            }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        } else {
            photos = imagesListService.photos
        }
    }
    
    private func showNextImages() {
        
        UIBlockingProgressHUD.show()
        
        imagesListService.fetchPhotosNextPage() { error in
            
            UIBlockingProgressHUD.dismiss()
            
            if let error {
                LogService.error("Ошибка загрузки изображений: \(error.localizedDescription)")
            }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                cell.changeLikeStatus(isLiked: !photo.isLiked)
                
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
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndetifer, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        let image = photos[indexPath.row]
        
        imageListCell.configure(
            id: image.id,
            imageURL: image.thumbImageURL,
            date: dateFormatter.string(from: image.createdAt ?? Date()),
            isLiked: image.isLiked
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SingleImageViewController.identifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if photos.count - 1 == indexPath.row {
            showNextImages()
        }
    }
}
