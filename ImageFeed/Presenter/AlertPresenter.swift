//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 14.04.2025.
//

import UIKit

public struct AlertModel {
    let title: String
    let message: String?
    let actions: [AlertAction]
    let preferredStyle: UIAlertController.Style
}

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?
}

final class AlertPresenter {
    private let model: AlertModel
    
    init(from alertModel: AlertModel) {
        self.model = alertModel
    }
    
    func presentAlert(from viewController: UIViewController) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: model.preferredStyle)
        
        model.actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.handler?()
            }
            
            alert.addAction(alertAction)
        }
        
        alert.view.accessibilityIdentifier = "AlertPresent"
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertFromTopVC() {
        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            
            var topController = rootController
            while let presentedController = topController.presentedViewController {
                topController = presentedController
            }
            
           presentAlert(from: topController)
        }
    }
}
