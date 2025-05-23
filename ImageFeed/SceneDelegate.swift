//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 24.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = SplashViewController()
        
        window?.makeKeyAndVisible()
    }
}

