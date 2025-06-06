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
    
    private let userName: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(340), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(340), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(840), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(840), for: .vertical)
        label.text = "Bob Smith"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userEmail: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(310), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(310), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(810), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(810), for: .vertical)
        label.text = "bobsmith@gmail.com"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserEmailButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 330, compressionResistancePriority: 830)
        
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
    
    private let userId: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "51c791e9b80baba4af786e2dea29068651b95aec3dc3bba9f0657cbd7ac77fae"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserIdButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 300, compressionResistancePriority: 800)
        
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
    
    private let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let nameHeader: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(350), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(350), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(850), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(850), for: .vertical)
        label.text = "Name"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let emailHeader: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(320), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(320), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .vertical)
        label.text = "Email"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let redownloadDataButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 770)
       
        button.setTitle("Redownload Data", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let label__Rou_GI_ddQ: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userIdHeader: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        label.text = "Support ID"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let deleteAccountButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 770)
        
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemRed
        
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let backButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        button.setContentHuggingPriority(UILayoutPriority(360), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(360), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(860), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(860), for: .vertical)
        
        button.isPointerInteractionEnabled = true
        
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundUIButtonTintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(355), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(355), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(855), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(855), for: .vertical)
        label.text = "Account"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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
        
        userName.text = UserInformation.displayFullName
        
        userEmail.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userId.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownUserId
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
        containerView.addSubview(nameHeader)
        containerView.addSubview(userName)
        containerView.addSubview(emailHeader)
        containerView.addSubview(redownloadDataButton)
        containerView.addSubview(label__Rou_GI_ddQ)
        containerView.addSubview(userEmail)
        containerView.addSubview(userIdHeader)
        containerView.addSubview(userId)
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
            redownloadDataButton.topAnchor.constraint(equalTo: userId.bottomAnchor, constant: 45),
            redownloadDataButton.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            redownloadDataButton.widthAnchor.constraint(equalTo: redownloadDataButton.heightAnchor, multiplier: 1 / 0.16),
            
            copyUserIdButton.leadingAnchor.constraint(equalTo: userIdHeader.trailingAnchor, constant: 5),
            copyUserIdButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            copyUserIdButton.centerYAnchor.constraint(equalTo: userIdHeader.centerYAnchor),
            copyUserIdButton.widthAnchor.constraint(equalTo: copyUserIdButton.heightAnchor, multiplier: 1 / 1),
            copyUserIdButton.widthAnchor.constraint(equalToConstant: 35),
            copyUserIdButton.heightAnchor.constraint(equalTo: userIdHeader.heightAnchor, multiplier: 1.5),
            
            copyUserEmailButton.leadingAnchor.constraint(equalTo: emailHeader.trailingAnchor, constant: 5),
            copyUserEmailButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            copyUserEmailButton.centerYAnchor.constraint(equalTo: emailHeader.centerYAnchor),
            copyUserEmailButton.widthAnchor.constraint(equalToConstant: 35),
            copyUserEmailButton.widthAnchor.constraint(equalTo: copyUserEmailButton.heightAnchor, multiplier: 1 / 1),
            copyUserEmailButton.heightAnchor.constraint(equalTo: emailHeader.heightAnchor, multiplier: 1.5),
            
            deleteAccountButton.topAnchor.constraint(equalTo: label__Rou_GI_ddQ.bottomAnchor, constant: 45),
            deleteAccountButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            deleteAccountButton.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
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
            
            emailHeader.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 45),
            emailHeader.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
            nameHeader.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            nameHeader.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            nameHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameHeader.trailingAnchor.constraint(equalTo: redownloadDataButton.trailingAnchor),
            nameHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameHeader.trailingAnchor.constraint(equalTo: userName.trailingAnchor),
            nameHeader.trailingAnchor.constraint(equalTo: label__Rou_GI_ddQ.trailingAnchor),
            nameHeader.trailingAnchor.constraint(equalTo: userEmail.trailingAnchor),
            nameHeader.trailingAnchor.constraint(equalTo: deleteAccountButton.trailingAnchor),
            nameHeader.trailingAnchor.constraint(equalTo: userId.trailingAnchor),
            
            userId.topAnchor.constraint(equalTo: copyUserIdButton.bottomAnchor, constant: 7.5),
            userId.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
            userIdHeader.topAnchor.constraint(equalTo: userEmail.bottomAnchor, constant: 45),
            userIdHeader.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
            userName.topAnchor.constraint(equalTo: nameHeader.bottomAnchor, constant: 7.5),
            userName.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
            label__Rou_GI_ddQ.topAnchor.constraint(equalTo: redownloadDataButton.bottomAnchor, constant: 7.5),
            label__Rou_GI_ddQ.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
            userEmail.topAnchor.constraint(equalTo: copyUserEmailButton.bottomAnchor, constant: 7.5),
            userEmail.leadingAnchor.constraint(equalTo: nameHeader.leadingAnchor),
            
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
