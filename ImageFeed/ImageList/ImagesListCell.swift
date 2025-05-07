//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 25.02.2025.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet private var placeholderView: UIView!
    @IBOutlet private var imageCell: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!

    // MARK: - Public propetrties
    static let reuseIndetifer = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Private properties
    private let imageListService = ImagesListService.shared

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPlaceholder()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        placeholderView.isHidden = false
        imageCell.kf.cancelDownloadTask()
    }
    
    // MARK: - IBAction
    @IBAction func pressLikeButton() {
        
        delegate?.imagesListCellDidTapLike(self)
    }
    
    // MARK: - Public methods
    func configure(id: String, imageURL: String, date: String, isLiked: Bool) {
        
        guard let url = URL(string: imageURL) else {
            return
        }
        
        imageCell.kf.setImage(with: url) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.placeholderView.isHidden = true
            case .failure:
                self.placeholderView.isHidden = false
                LogService.error("Ошибка загрузки изображения")
            }
        }
        dateLabel.text = date
        
        changeLikeStatus(isLiked: isLiked)
    }
    
    func changeLikeStatus(isLiked: Bool) {
        
        let likeImageName = isLiked ? "Active" : "No Active"

        if let likeImage = UIImage(named: likeImageName) {
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    // MARK: - Private methods  
    private func setupPlaceholder() {
        placeholderView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        placeholderView.isHidden = false
        
        let imageView = UIImageView(image: UIImage(resource: .stub))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 83, height: 75)
        
        placeholderView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 83),
            imageView.heightAnchor.constraint(equalToConstant: 75),
        ])
        
    }
}
