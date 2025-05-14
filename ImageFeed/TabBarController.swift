//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 17.04.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard
            let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController
        else { return }
        
        let imageListViewPresenter = ImageListViewPresenter()
        imagesListViewController.configure(with: imageListViewPresenter)
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.configure(with: profileViewPresenter)
        
        let tabBatItem = UITabBarItem(
            title: nil,
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        profileViewController.tabBarItem = tabBatItem
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
