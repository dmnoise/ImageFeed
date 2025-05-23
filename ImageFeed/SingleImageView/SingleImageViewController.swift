//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 27.02.2025.
//

import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Public properties
    static let identifier = "ShowSingleImage"
    var imageURL: String? {
        didSet {
            loadFullImage()
        }
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadFullImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - IBAction
    @IBAction private func didTapBackButton() {
        ProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        
        guard let image = imageView.image else {
            LogService.notice("image is empty")
            return
        }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func loadFullImage() {
        
        guard isViewLoaded, let imageURL, let url = URL(string: imageURL) else {
            return
        }
        
        ProgressHUD.animate()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            
            guard let self else { return }
            
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let retriveImage):
                self.rescaleImageInScrollView(image: retriveImage.image)

            case .failure(let error):
                showErrorLoadImage()
                
                LogService.error(error.localizedDescription)
            }
        }
    }
    
    private func showErrorLoadImage() {
        DispatchQueue.main.async {

            let actions = [
                AlertAction(title: "Не надо", style: .cancel, handler: nil),
                AlertAction(title: "Повторить", style: .default) { [weak self] in
                    guard let self else { return }
                    
                    loadFullImage()
                }
            ]
            
            let alert = AlertModel(
                title: "Что-то пошло не так(",
                message: "Попробовать ещё раз?",
                actions: actions,
                preferredStyle: .alert
            )
            
            AlertPresenter(from: alert).presentAlertFromTopVC()
        }
    }
    
    private func rescaleImageInScrollView(image: UIImage) {
        imageView.frame.size = image.size
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard visibleRectSize.width != 0, visibleRectSize.height != 0,
              imageSize.width != 0, imageSize.height != 0 else {
            return
        }
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let vInset = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
        let hInset = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageInScrollView()
    }
}
