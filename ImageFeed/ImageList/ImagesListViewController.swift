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
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let imagesListService = ImagesListService.shared
    private let storage = OAuth2TokenKeychain.shared
    
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
            
            tableView.reloadData()
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

            let imageURL = imagesListService.photos[indexPath.row].largeImageURL
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func showNextImages() {
        
        LogService.notice("start refresh")
        
        imagesListService.fetchPhotosNextPage() { error in
            
            guard error != nil else {
                LogService.error(error?.localizedDescription ?? "Ошибка загрузки изображений")
                return
            }
            
            LogService.notice("refresh finish")
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndetifer, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let image = imagesListService.photos[indexPath.row]
        
        imageListCell.configure(
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
        let imageWidth = imagesListService.photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imagesListService.photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if imagesListService.photos.count - 1 == indexPath.row {
            showNextImages()
        }
    }
}
