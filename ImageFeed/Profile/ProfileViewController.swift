//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 27.02.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get }
    
    func showProfileInfo(_ profile: Profile)
    func setAvatar(with imageUrl: URL)
    func proceedToSplashScreen()
    func showAlert(_ alert: AlertModel)
}

final class ProfileViewController: UIViewController {
    private(set) var presenter: ProfileViewPresenterProtocol?
    
    func configure(with presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.attachView(self)
    }
    
    // MARK: - Private properties
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .avatar))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатирина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()
    
    private var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ecatirina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .exitButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        presenter?.addObserverUpdateAvatar()
        initialUi()  
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private methods
    private func initialUi() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        setupConstraints()
        
        logoutButton.addTarget(self, action: #selector(pressLogoutButtton), for: .touchUpInside)
    }
 
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginLabel.trailingAnchor)
        ])
    }
    
    // MARK: - objc
    @objc private func pressLogoutButtton() {
        presenter?.didTapLogout()
    }
}

// MARK: - ProfileViewControllerProtocol
extension ProfileViewController: ProfileViewControllerProtocol {
    func showProfileInfo(_ profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func setAvatar(with imageUrl: URL) {
        
        let processeor = RoundCornerImageProcessor(
            cornerRadius: 35,
            targetSize: CGSize(width: 70.0, height: 70.0),
            backgroundColor: .clear
        )
        
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(resource: .avatarStub),
            options: [.processor(processeor)]
        )
    }
    
    func proceedToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        
        window.rootViewController = SplashViewController()
    }
    
    func showAlert(_ alert: AlertModel) {
        AlertPresenter(from: alert).presentAlert(from: self)
    }
}
