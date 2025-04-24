//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 25.02.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageCell: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!

    // MARK: - Public propetrties
    static let reuseIndetifer = "ImagesListCell"

    // MARK: - Public methods
    func configure(imageURL: String, date: String, isLiked: Bool) {
        
        guard let url = URL(string: imageURL) else {
            return
        }
        
        imageCell.kf.setImage(with: url)
        dateLabel.text = date
        
        let likeImageName = isLiked ? "Active" : "No Active"

        if let likeImage = UIImage(named: likeImageName) {
            likeButton.setImage(likeImage, for: .normal)
        }
    }
}
