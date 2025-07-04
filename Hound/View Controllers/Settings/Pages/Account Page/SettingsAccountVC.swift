//
//  SettingsAccountVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsAccountVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
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
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let userNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let userEmailHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Email"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let userEmailLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserEmailButton: HoundButton = {
        let button = HoundButton(huggingPriority: 330, compressionResistancePriority: 330)
        
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
    
    private let userIdHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Support ID"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let userIdLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let copyUserIdButton: HoundButton = {
        let button = HoundButton(huggingPriority: 300, compressionResistancePriority: 300)
        
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    private let redownloadDataButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)
       
        button.setTitle("Redownload Data", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.applyStyle(.labelBorder)
        
        return button
    }()
    
    private let redownloadDataDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "Deletes local storage of all dogs, reminders, logs, and triggers to fully redownload them from the Hound server, ensuring that the data displayed locally reflects the data stored server-side."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let deleteAccountButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)
        
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
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
        
        userEmailLabel.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userIdLabel.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownUserId
        copyUserIdButton.isEnabled = UserInformation.userId != nil
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsAccountVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
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
        containerView.addSubview(deleteAccountButton)
        containerView.addSubview(pageHeader)
        
        redownloadDataButton.addTarget(self, action: #selector(didTapRedownloadData), for: .touchUpInside)
        copyUserIdButton.addTarget(self, action: #selector(didTapCopyUserId), for: .touchUpInside)
        copyUserEmailButton.addTarget(self, action: #selector(didTapCopyUserEmail), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // userNameHeaderLabel constraints
        NSLayoutConstraint.activate([
            userNameHeaderLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            userNameHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userNameHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            userNameHeaderLabel.createMaxHeight( ConstraintConstant.Text.sectionLabelMaxHeight),
            userNameHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // userNameLabel constraints
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: userNameHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // userEmailHeaderLabel constraints
        NSLayoutConstraint.activate([
            userEmailHeaderLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            userEmailHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userEmailHeaderLabel.createMaxHeight( ConstraintConstant.Text.sectionLabelMaxHeight),
            userEmailHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // copyUserEmailButton
        NSLayoutConstraint.activate([
            copyUserEmailButton.centerYAnchor.constraint(equalTo: userEmailHeaderLabel.centerYAnchor),
            copyUserEmailButton.leadingAnchor.constraint(equalTo: userEmailHeaderLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            copyUserEmailButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * ConstraintConstant.Spacing.absoluteHoriInset),
            copyUserEmailButton.heightAnchor.constraint(equalTo: userEmailHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserEmailButton.createSquareAspectRatio()
        ])
        
        // userEmailLabel constraints
        NSLayoutConstraint.activate([
            userEmailLabel.topAnchor.constraint(equalTo: userEmailHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            userEmailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userEmailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // userIdHeaderLabel constraints
        NSLayoutConstraint.activate([
            userIdHeaderLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            userIdHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userIdHeaderLabel.createMaxHeight( ConstraintConstant.Text.sectionLabelMaxHeight),
            userIdHeaderLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Text.sectionLabelHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // copyUserIdButton constraints
        NSLayoutConstraint.activate([
            copyUserIdButton.centerYAnchor.constraint(equalTo: userIdHeaderLabel.centerYAnchor),
            copyUserIdButton.leadingAnchor.constraint(equalTo: userIdHeaderLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            copyUserIdButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0 * ConstraintConstant.Spacing.absoluteHoriInset),
            copyUserIdButton.heightAnchor.constraint(equalTo: userIdHeaderLabel.heightAnchor, multiplier: 1.5),
            copyUserIdButton.createSquareAspectRatio()
        ])
        
        // userIdLabel constraints
        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: userIdHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            userIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            userIdLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // redownloadDataButton constraints
        NSLayoutConstraint.activate([
            redownloadDataButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            redownloadDataButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            redownloadDataButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            redownloadDataButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            redownloadDataButton.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert)
        ])
        
        // redownloadDataDescriptionLabel constraints
        NSLayoutConstraint.activate([
            redownloadDataDescriptionLabel.topAnchor.constraint(equalTo: redownloadDataButton.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            redownloadDataDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            redownloadDataDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // deleteAccountButton constraints
        NSLayoutConstraint.activate([
            deleteAccountButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            deleteAccountButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            deleteAccountButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            deleteAccountButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            deleteAccountButton.topAnchor.constraint(equalTo: redownloadDataDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            deleteAccountButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset)
        ])
        
    }

}
