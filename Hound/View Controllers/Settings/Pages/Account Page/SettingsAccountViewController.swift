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
    
    private let pageHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 355, compressionResistancePriority: 355)
        label.text = "Account"
        label.font = VisualConstant.FontConstant.pageHeaderLabel
        return label
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
    
    private let userNameHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.text = "Name"
        label.font = VisualConstant.FontConstant.sectionHeaderLabel
        return label
    }()
    
    private let userNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userEmailHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Email"
        label.font = VisualConstant.FontConstant.sectionHeaderLabel
        return label
    }()
    
    private let userEmailLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
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
    
    private let userIdHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Support ID"
        label.font = VisualConstant.FontConstant.sectionHeaderLabel
        return label
    }()
    
    private let userIdLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserIdButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 300, compressionResistancePriority: 300)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    private let redownloadDataButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)
       
        button.setTitle("Redownload Data", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let redownloadDataDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "Deletes local storage of all dogs, reminders, logs, and triggers to fully redownload them from the Hound server, ensuring that the data displayed locally reflects the data stored server-side."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let deleteAccountButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)
        
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        
        button.backgroundColor = .systemRed
        
        button.shouldRoundCorners = true
        
        return button
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
                self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
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
    
    private weak var delegate: SettingsAccountViewControllerDelegate?
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
       
        userNameLabel.text = UserInformation.displayFullName
        
        userEmailLabel.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userIdLabel.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownUserId
        copyUserIdButton.isEnabled = UserInformation.userId != nil
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsAccountViewControllerDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(userNameHeaderLabel)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(userEmailHeaderLabel)
        containerView.addSubview(redownloadDataButton)
        containerView.addSubview(redownloadDataDescriptionLabel)
        containerView.addSubview(userEmailLabel)
        containerView.addSubview(userIdHeaderLabel)
        containerView.addSubview(userIdLabel)
        containerView.addSubview(copyUserIdButton)
        containerView.addSubview(copyUserEmailButton)
        containerView.addSubview(deleteAccountButton)
        containerView.addSubview(backButton)
        containerView.addSubview(pageHeaderLabel)
        
        redownloadDataButton.addTarget(self, action: #selector(didTapRedownloadData), for: .touchUpInside)
        copyUserIdButton.addTarget(self, action: #selector(didTapCopyUserId), for: .touchUpInside)
        copyUserEmailButton.addTarget(self, action: #selector(didTapCopyUserEmail), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // pageHeaderLabel
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Global.contentVertInset),
            pageHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            pageHeaderLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.PageHeader.labelMaxHeight),
            pageHeaderLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.PageHeader.labelHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Button.miniCircleInset),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Button.miniCircleInset),
            backButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier).withPriority(.defaultHigh),
            backButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareConstraint()
        ])
        
        // userNameHeaderLabel constraints
        NSLayoutConstraint.activate([
            userNameHeaderLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: ConstraintConstant.PageHeader.vertSpacingToSection),
            userNameHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userNameHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset),
            userNameHeaderLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Section.sectionTitleMaxHeight),
            userNameHeaderLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Section.sectionTitleHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // userNameLabel constraints
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: userNameHeaderLabel.bottomAnchor, constant: ConstraintConstant.Section.intraSectionVertSpacing),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        ])
        
        // userEmailHeaderLabel constraints
        NSLayoutConstraint.activate([
            userEmailHeaderLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: ConstraintConstant.Section.interSectionVertSpacing),
            userEmailHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userEmailHeaderLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Section.sectionTitleMaxHeight),
            userEmailHeaderLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Section.sectionTitleHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // copyUserEmailButton
        NSLayoutConstraint.activate([
            copyUserEmailButton.centerYAnchor.constraint(equalTo: userEmailHeaderLabel.centerYAnchor),
            copyUserEmailButton.leadingAnchor.constraint(equalTo: userEmailHeaderLabel.trailingAnchor, constant: ConstraintConstant.Global.intraContentHoriInset),
            copyUserEmailButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * ConstraintConstant.Global.contentHoriInset),
            copyUserEmailButton.heightAnchor.constraint(equalTo: userEmailHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserEmailButton.createSquareConstraint()
        ])
        
        // userEmailLabel constraints
        NSLayoutConstraint.activate([
            userEmailLabel.topAnchor.constraint(equalTo: userEmailHeaderLabel.bottomAnchor, constant: ConstraintConstant.Section.intraSectionVertSpacing),
            userEmailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userEmailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        ])
        
        // userIdHeaderLabel constraints
        NSLayoutConstraint.activate([
            userIdHeaderLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: ConstraintConstant.Section.interSectionVertSpacing),
            userIdHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userIdHeaderLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Section.sectionTitleMaxHeight),
            userIdHeaderLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Section.sectionTitleHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // copyUserIdButton constraints
        NSLayoutConstraint.activate([
            copyUserIdButton.centerYAnchor.constraint(equalTo: userIdHeaderLabel.centerYAnchor),
            copyUserIdButton.leadingAnchor.constraint(equalTo: userIdHeaderLabel.trailingAnchor, constant: ConstraintConstant.Global.intraContentHoriInset),
            copyUserIdButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * ConstraintConstant.Global.contentHoriInset),
            copyUserIdButton.heightAnchor.constraint(equalTo: userIdHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserIdButton.createSquareConstraint()
        ])
        
        // userIdLabel constraints
        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: userIdHeaderLabel.bottomAnchor, constant: ConstraintConstant.Section.intraSectionVertSpacing),
            userIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            userIdLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        ])
        
        // redownloadDataButton constraints
        NSLayoutConstraint.activate([
            redownloadDataButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            redownloadDataButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset),
            redownloadDataButton.heightAnchor.constraint(equalTo: redownloadDataButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            redownloadDataButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.screenWideMaxHeight),
            redownloadDataButton.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: ConstraintConstant.Section.interSectionVertSpacing)
        ])
        
        // redownloadDataDescriptionLabel constraints
        NSLayoutConstraint.activate([
            redownloadDataDescriptionLabel.topAnchor.constraint(equalTo: redownloadDataButton.bottomAnchor, constant: ConstraintConstant.Section.intraSectionVertSpacing),
            redownloadDataDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            redownloadDataDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        ])
        
        // deleteAccountButton constraints
        NSLayoutConstraint.activate([
            deleteAccountButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            deleteAccountButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset),
            deleteAccountButton.heightAnchor.constraint(equalTo: deleteAccountButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            deleteAccountButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.screenWideMaxHeight),
            deleteAccountButton.topAnchor.constraint(equalTo: redownloadDataDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Section.interSectionVertSpacing),
            deleteAccountButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Global.contentVertInset)
        ])
        
    }

}
