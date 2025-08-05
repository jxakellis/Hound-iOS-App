//
//  SettingsAccountVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsAccountVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
}

final class SettingsAccountVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private let pageHeader: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 360, compressionResistancePriority: 360)
        view.pageHeaderLabel.text = "Account"
        return view
    }()
    
    private let userNameHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.text = "Name"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let userNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private let userEmailHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Email"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let userEmailLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private lazy var copyUserEmailButton: HoundButton = {
        let button = HoundButton(huggingPriority: 330, compressionResistancePriority: 330)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        
        button.addTarget(self, action: #selector(didTapCopyUserEmail), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didTapCopyUserEmail(_ sender: Any) {
        guard let userEmail = UserInformation.userEmail else { return }
        
        UIPasteboard.general.setPasteboard(string: userEmail)
    }
    
    private let userIdHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Support ID"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let userIdLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private lazy var copyUserIdButton: HoundButton = {
        let button = HoundButton(huggingPriority: 300, compressionResistancePriority: 300)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        
        button.addTarget(self, action: #selector(didTapCopyUserId), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var redownloadDataButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)
       
        button.setTitle("Redownload Data", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.addTarget(self, action: #selector(didTapRedownloadData), for: .touchUpInside)
        
        return button
    }()
    
    private let redownloadDataDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "Deletes local storage of all dogs, reminders, logs, and automations to fully redownload them from the Hound server, ensuring that the data displayed locally reflects the data stored server-side."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        
        return label
    }()
    
    private lazy var signOutButton: HoundButton = {
        let button = HoundButton(huggingPriority: 265, compressionResistancePriority: 265)
        
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var deleteAccountButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)
        
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemRed
        
        button.shouldRoundCorners = true
        
        button.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didTapCopyUserId(_ sender: Any) {
        guard let userId = UserInformation.userId else { return }
        
        UIPasteboard.general.setPasteboard(string: userId)
    }
    
    @objc private func didTapRedownloadData(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndicator()
        
        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentUserConfigurationPreviousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization
        // manually set previousDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.previousDogManagerSynchronization = nil
        redownloadDataButton.isLoading = true
        
        DogsRequest.get(errorAlert: .automaticallyAlertOnlyForFailure, dogManager: DogManager()) { dogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                self.redownloadDataButton.isLoading = false
                guard responseStatus != .failureResponse, let dogManager = dogManager else {
                    // Revert previousDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.previousDogManagerSynchronization = currentUserConfigurationPreviousDogManagerSynchronization
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.successRedownloadDataTitle, subtitle: Constant.Visual.BannerText.successRedownloadDataSubtitle, style: .success)
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // If OfflineModeManager has displayed its banner that indicates its turning on, then we are safe to display this banner. Otherwise, we would run the risk of both of these banners displaying if its the first time enterin offline mode.
                        PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.infoRedownloadOnHoldTitle, subtitle: Constant.Visual.BannerText.infoRedownloadOnHoldSubtitle, style: .info)
                    }
                }
                
                // successful query to fully redownload the dogManager, no need to mess with previousDogManagerSynchronization as that is automatically handled
                self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: dogManager)
            }
        }
    }
    
    @objc private func didTapSignOut(_ sender: Any) {
        
        let signOutAlertController = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .alert)
        
        let signOutAlertAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
            PersistenceManager.clearStorageToReloginToAccount()
            self.dismissToViewController(ofClass: ServerSyncVC.self, completionHandler: nil)
        }
        signOutAlertController.addAction(signOutAlertAction)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        signOutAlertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(signOutAlertController)
    }
    
    @objc private func didTapDeleteAccount(_ sender: Any) {
        
        let deleteAccountAlertController = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .alert)
        
        let deleteAlertAction = UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            PresentationManager.beginFetchingInformationIndicator()
            self.deleteAccountButton.isLoading = true
            
            UserRequest.delete(errorAlert: .automaticallyAlertForAll) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndicator {
                    self.deleteAccountButton.isLoading = false
                    guard responseStatus == .successResponse else {
                        return
                    }
                    
                    // family was successfully deleted, revert to server sync view controller
                    self.dismissToViewController(ofClass: ServerSyncVC.self, completionHandler: nil)
                }
            }
        }
        deleteAccountAlertController.addAction(deleteAlertAction)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        deleteAccountAlertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(deleteAccountAlertController)
    }
    
    // MARK: - Properties
    
    private weak var delegate: SettingsAccountVCDelegate?
    
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
        
        userEmailLabel.text = UserInformation.userEmail ?? Constant.Visual.Text.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userIdLabel.text = UserInformation.userId ?? Constant.Visual.Text.unknownUserId
        copyUserIdButton.isEnabled = UserInformation.userId != nil
    }
    
    // MARK: - Setup
    
    func setup(delegate: SettingsAccountVCDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
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
        containerView.addSubview(signOutButton)
        containerView.addSubview(deleteAccountButton)
        containerView.addSubview(pageHeader)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // userNameHeaderLabel
        NSLayoutConstraint.activate([
            userNameHeaderLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            userNameHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userNameHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            userNameHeaderLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            userNameHeaderLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // userNameLabel
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: userNameHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // userEmailHeaderLabel
        NSLayoutConstraint.activate([
            userEmailHeaderLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            userEmailHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userEmailHeaderLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            userEmailHeaderLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // copyUserEmailButton
        NSLayoutConstraint.activate([
            copyUserEmailButton.centerYAnchor.constraint(equalTo: userEmailHeaderLabel.centerYAnchor),
            copyUserEmailButton.leadingAnchor.constraint(equalTo: userEmailHeaderLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            copyUserEmailButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * Constant.Constraint.Spacing.absoluteHoriInset),
            copyUserEmailButton.heightAnchor.constraint(equalTo: userEmailHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserEmailButton.createSquareAspectRatio()
        ])
        
        // userEmailLabel
        NSLayoutConstraint.activate([
            userEmailLabel.topAnchor.constraint(equalTo: userEmailHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            userEmailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userEmailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // userIdHeaderLabel
        NSLayoutConstraint.activate([
            userIdHeaderLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            userIdHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userIdHeaderLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            userIdHeaderLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // copyUserIdButton
        NSLayoutConstraint.activate([
            copyUserIdButton.centerYAnchor.constraint(equalTo: userIdHeaderLabel.centerYAnchor),
            copyUserIdButton.leadingAnchor.constraint(equalTo: userIdHeaderLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            copyUserIdButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * Constant.Constraint.Spacing.absoluteHoriInset),
            copyUserIdButton.heightAnchor.constraint(equalTo: userIdHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserIdButton.createSquareAspectRatio()
        ])
        
        // userIdLabel
        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: userIdHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            userIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            userIdLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // redownloadDataButton
        NSLayoutConstraint.activate([
            redownloadDataButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            redownloadDataButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            redownloadDataButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            redownloadDataButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight),
            redownloadDataButton.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert)
        ])
        
        // redownloadDataDescriptionLabel
        NSLayoutConstraint.activate([
            redownloadDataDescriptionLabel.topAnchor.constraint(equalTo: redownloadDataButton.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            redownloadDataDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            redownloadDataDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // signOutButton
        NSLayoutConstraint.activate([
            signOutButton.topAnchor.constraint(equalTo: redownloadDataDescriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            signOutButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            signOutButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            signOutButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            signOutButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
        
        // deleteAccountButton
        NSLayoutConstraint.activate([
            deleteAccountButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            deleteAccountButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            deleteAccountButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            deleteAccountButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            deleteAccountButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            deleteAccountButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
        
    }

}
