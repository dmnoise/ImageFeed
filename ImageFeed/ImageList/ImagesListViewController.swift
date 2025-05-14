//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 24.02.2025.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get }
    
    func updateLikeStatus(at index: Int, isLiked: Bool)
    func insertRows(at indexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController {
    
    private(set) var presenter: ImagesListViewPresenterProtocol?
    
    //MARK: - IBOutlet
    @IBOutlet private var tableView: UITableView!
    
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
        
        presenter?.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SingleImageViewController.identifier:
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let imageURL = presenter?.imageURL(at: indexPath.row)
            viewController.imageURL = imageURL
            
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func configure(with presenter: ImagesListViewPresenterProtocol) {
        self.presenter = presenter
        presenter.attachView(self)
    }
}

// MARK: - ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
 
    func updateLikeStatus(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            return
        }
        
        cell.changeLikeStatus(isLiked: isLiked)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter?.didTapLike(at: indexPath.row)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndetifer, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        guard let presenter else { return UITableViewCell() }
        
        let image = presenter.photo(at: indexPath.row)
        
        imageListCell.configure(
            id: image.id,
            imageURL: image.thumbImageURL,
            date: presenter.formatDate(at: indexPath.row),
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
        
        guard let photo = presenter?.photo(at: indexPath.row) else {
            LogService.error("presenter is empty")
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if ProcessInfo.processInfo.arguments.contains("testMode") {
            return
        }
        
        let numberOfRows = presenter?.numberOfRows() ?? 0
        
        if numberOfRows - 1 == indexPath.row {
            presenter?.loadNextImages()
        }
    }
}
