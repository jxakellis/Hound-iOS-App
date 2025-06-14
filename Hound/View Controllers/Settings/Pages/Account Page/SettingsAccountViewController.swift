//
//  SettingsAccountViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsAccountViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsAccountViewController: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let userNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userEmailLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserEmailButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 330, compressionResistancePriority: 330)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    @objc private func didTapCopyUserEmail(_ sender: Any) {
        guard let userEmail = UserInformation.userEmail else {
            return
        }
        
        UIPasteboard.general.setPasteboard(forString: userEmail)
    }
    
    private let userIdLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserIdButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 300, compressionResistancePriority: 300)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let nameHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.text = "Name"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let emailHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Email"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let redownloadDataButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)
       
        button.setTitle("Redownload Data", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let redownloadDataDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userIdHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Support ID"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let deleteAccountButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)
        
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemRed
        
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 360, compressionResistancePriority: 360)
        
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 355, compressionResistancePriority: 355)
        label.text = "Account"
        label.font = .systemFont(ofSize: 35)
        return label
    }()
    @objc private func didTapCopyUserId(_ sender: Any) {
        guard let userId = UserInformation.userId else {
            return
        }
        
        UIPasteboard.general.setPasteboard(forString: userId)
    }
    
    @objc private func didTapRedownloadData(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndicator()
        
        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentUserConfigurationPreviousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization
        // manually set previousDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.previousDogManagerSynchronization = nil
        
        DogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogManager: DogManager()) { dogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse, let dogManager = dogManager else {
                    // Revert previousDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.previousDogManagerSynchronization = currentUserConfigurationPreviousDogManagerSynchronization
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.successRedownloadDataTitle, forSubtitle: VisualConstant.BannerTextConstant.successRedownloadDataSubtitle, forStyle: .success)
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // If OfflineModeManager has displayed its banner that indicates its turning on, then we are safe to display this banner. Otherwise, we would run the risk of both of these banners displaying if its the first time enterin offline mode.
                        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.infoRedownloadOnHoldTitle, forSubtitle: VisualConstant.BannerTextConstant.infoRedownloadOnHoldSubtitle, forStyle: .info)
                    }
                }
                
                // successful query to fully redownload the dogManager, no need to mess with previousDogManagerSynchronization as that is automatically handled
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
            }
        }
    }
    
    @objc private func didTapDeleteAccount(_ sender: Any) {
        
        let deleteAccountAlertController = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .alert)
        
        let deleteAlertAction = UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            PresentationManager.beginFetchingInformationIndicator()
            
            UserRequest.delete(forErrorAlert: .automaticallyAlertForAll) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndicator {
                    guard responseStatus == .successResponse else {
                        return
                    }
                    
                    // family was successfully deleted, revert to server sync view controller
                    self.dismissToViewController(ofClass: ServerSyncViewController.self, completionHandler: nil)
                }
            }
        }
        deleteAccountAlertController.addAction(deleteAlertAction)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        deleteAccountAlertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(deleteAccountAlertController)
    }
    
    // MARK: - Properties
    
    private weak var delegate: SettingsAccountViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        modalPresentationStyle = .pageSheet
        
        userNameLabel.text = UserInformation.displayFullName
        
        userEmailLabel.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userIdLabel.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownUserId
        copyUserIdButton.isEnabled = UserInformation.userId != nil
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: SettingsAccountViewControllerDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(nameHeaderLabel)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(emailHeaderLabel)
        containerView.addSubview(redownloadDataButton)
        containerView.addSubview(redownloadDataDescriptionLabel)
        containerView.addSubview(userEmailLabel)
        containerView.addSubview(userIdHeaderLabel)
        containerView.addSubview(userIdLabel)
        containerView.addSubview(copyUserIdButton)
        containerView.addSubview(copyUserEmailButton)
        containerView.addSubview(deleteAccountButton)
        containerView.addSubview(backButton)
        containerView.addSubview(headerLabel)
        
        redownloadDataButton.addTarget(self, action: #selector(didTapRedownloadData), for: .touchUpInside)
        copyUserIdButton.addTarget(self, action: #selector(didTapCopyUserId), for: .touchUpInside)
        copyUserEmailButton.addTarget(self, action: #selector(didTapCopyUserEmail), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            redownloadDataButton.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 45),
            redownloadDataButton.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            redownloadDataButton.widthAnchor.constraint(equalTo: redownloadDataButton.heightAnchor, multiplier: 1 / 0.16),
            
            copyUserIdButton.leadingAnchor.constraint(equalTo: userIdHeaderLabel.trailingAnchor, constant: 5),
            copyUserIdButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            copyUserIdButton.centerYAnchor.constraint(equalTo: userIdHeaderLabel.centerYAnchor),
            copyUserIdButton.widthAnchor.constraint(equalTo: copyUserIdButton.heightAnchor, multiplier: 1 / 1),
            copyUserIdButton.widthAnchor.constraint(equalToConstant: 35),
            copyUserIdButton.heightAnchor.constraint(equalTo: userIdHeaderLabel.heightAnchor, multiplier: 1.5),
            
            copyUserEmailButton.leadingAnchor.constraint(equalTo: emailHeaderLabel.trailingAnchor, constant: 5),
            copyUserEmailButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            copyUserEmailButton.centerYAnchor.constraint(equalTo: emailHeaderLabel.centerYAnchor),
            copyUserEmailButton.widthAnchor.constraint(equalToConstant: 35),
            copyUserEmailButton.widthAnchor.constraint(equalTo: copyUserEmailButton.heightAnchor, multiplier: 1 / 1),
            copyUserEmailButton.heightAnchor.constraint(equalTo: emailHeaderLabel.heightAnchor, multiplier: 1.5),
            
            deleteAccountButton.topAnchor.constraint(equalTo: redownloadDataDescriptionLabel.bottomAnchor, constant: 45),
            deleteAccountButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            deleteAccountButton.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            deleteAccountButton.widthAnchor.constraint(equalTo: deleteAccountButton.heightAnchor, multiplier: 1 / 0.16),
            
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1 / 1),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50 / 414),
            backButton.heightAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 25),
            
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerLabel.heightAnchor.constraint(equalToConstant: 40),
            
            emailHeaderLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 45),
            emailHeaderLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            nameHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            nameHeaderLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            nameHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: redownloadDataButton.trailingAnchor),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: redownloadDataDescriptionLabel.trailingAnchor),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: userEmailLabel.trailingAnchor),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: deleteAccountButton.trailingAnchor),
            nameHeaderLabel.trailingAnchor.constraint(equalTo: userIdLabel.trailingAnchor),
            
            userIdLabel.topAnchor.constraint(equalTo: copyUserIdButton.bottomAnchor, constant: 7.5),
            userIdLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            userIdHeaderLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: 45),
            userIdHeaderLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            userNameLabel.topAnchor.constraint(equalTo: nameHeaderLabel.bottomAnchor, constant: 7.5),
            userNameLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            redownloadDataDescriptionLabel.topAnchor.constraint(equalTo: redownloadDataButton.bottomAnchor, constant: 7.5),
            redownloadDataDescriptionLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            userEmailLabel.topAnchor.constraint(equalTo: copyUserEmailButton.bottomAnchor, constant: 7.5),
            userEmailLabel.leadingAnchor.constraint(equalTo: nameHeaderLabel.leadingAnchor),
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ])
        
    }
}
