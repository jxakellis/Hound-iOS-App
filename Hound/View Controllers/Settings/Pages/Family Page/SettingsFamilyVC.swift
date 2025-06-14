//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Elements

    @objc private func didTouchUpInsideShareFamily(_ sender: Any) {
        guard let familyCode = familyCode else {
            return
        }
        
        ExportActivityViewManager.shareFamilyCode(forFamilyCode: familyCode)
    }

    private let familyCodeLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    private let familyCodeDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "The family code is the key your family. Have a prospective family member input the code above to join your family (case-insensitive)."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()

    private let familyMembersTableView: GeneralUITableView = {
        // TODO standardize GeneralUITableView
        let tableView = GeneralUITableView(huggingPriority: 240, compressionResistancePriority: 240)
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.bouncesZoom = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.borderWidth = 1
        tableView.borderColor = .label
        tableView.shouldRoundCorners = true
        return tableView
    }()

    private let leaveFamilyButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 230, compressionResistancePriority: 230)
       
        button.setTitle("Leave Family", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
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
        
        return view
    }()
    
    private let leaveFamilyDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 220, compressionResistancePriority: 220)
        label.text = "Family members can freely join or leave families. The head can only leave by deleting the family, which requires all other members to leave first (or be kicked)."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
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
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 380, compressionResistancePriority: 380)
        label.text = "Family"
        label.font = .systemFont(ofSize: 35)
        return label
    }()
    
    private let shareFamilyButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Invite to Family", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let membersHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Members"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    @objc private func didTouchUpInsideLeaveFamily(_ sender: Any) {
        // We don't want to check the status of a family's subscription locally.
        // In order for a user to cancel a subscription, they must use Apple's subscription interface
        // This inherently doesn't update Hound, only the server.
        // Therefore the Hound app will always be outdated on this information.
        guard let leaveFamilyAlertController = leaveFamilyAlertController else {
            return
        }

        PresentationManager.enqueueAlert(leaveFamilyAlertController)
    }

    // MARK: - Properties

    private var leaveFamilyAlertController: UIAlertController?

    private var familyCode: String? {
        var familyCode = FamilyInformation.familyCode
        if let code = familyCode {
            familyCode?.insert("-", at: code.index(code.startIndex, offsetBy: 4))
        }
        return familyCode
    }

    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        modalPresentationStyle = .pageSheet
        
        self.familyMembersTableView.register(SettingsFamilyHeadTableViewCell.self, forCellReuseIdentifier: "SettingsFamilyHeadTableViewCell")
        
        
        let activeSubscriptionNumberOfFamilyMembers = FamilyInformation.familyActiveSubscription.numberOfFamilyMembers
        let precalculatedDynamicTextColor = familyCodeDescriptionLabel.textColor

        familyCodeDescriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "The family code is the key your family. Have a prospective family member input the code above to join your family (case-insensitive).",
                attributes: [.font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
            
            // Add a disclaimer for the user that they
            if activeSubscriptionNumberOfFamilyMembers <= 1 {
                message.append(
                    NSAttributedString(
                    string: " Currently, your Hound plan is for individual use only. To add family members, try out a free trial of Hound+!",
                    attributes: [.font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
                    )
                )
            }
            
            return message
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        repeatableSetup()
    }

    // MARK: - Functions

    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {

        // MARK: Family Code
        familyCodeLabel.text = "Code: \(familyCode ?? "NO CODE⚠️")"

        // MARK: Family Members

        familyMembersTableView.allowsSelection = UserInformation.isUserFamilyHead

        // MARK: Leave Family Button

        let leaveFamilyAlertController = UIAlertController(title: "placeholder", message: nil, preferredStyle: .alert)

        // user is not the head of the family, so the button is enabled for them
        if UserInformation.isUserFamilyHead == false {
            leaveFamilyButton.isEnabled = true

            leaveFamilyButton.setTitle("Leave Family", for: .normal)

            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                PresentationManager.beginFetchingInformationIndicator()
                FamilyRequest.delete(forErrorAlert: .automaticallyAlertForAll) { responseStatus, _ in
                    PresentationManager.endFetchingInformationIndicator {
                        guard responseStatus == .successResponse else {
                            return
                        }

                        // family was successfully left, revert to server sync view controller
                        self.dismissToViewController(ofClass: ServerSyncViewController.self, completionHandler: nil)
                    }
                }
            }
            leaveFamilyAlertController.addAction(leaveAlertAction)
        }
        // user is the head of the family, further checks needed
        else {
            // user must kicked other members before they can destroy their family
            leaveFamilyButton.isEnabled = FamilyInformation.familyMembers.count == 1
            leaveFamilyButton.setTitle("Delete Family", for: .normal)

            leaveFamilyAlertController.title = "Are you sure you want to delete your family?"

            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                PresentationManager.beginFetchingInformationIndicator()
                FamilyRequest.delete(forErrorAlert: .automaticallyAlertForAll) { responseStatus, _ in
                    PresentationManager.endFetchingInformationIndicator {
                        guard responseStatus == .successResponse else {
                            return
                        }
                        // family was successfully deleted, revert to server sync view controller
                        self.dismissToViewController(ofClass: ServerSyncViewController.self, completionHandler: nil)
                    }
                }
            }
            leaveFamilyAlertController.addAction(deleteAlertAction)
        }

        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        leaveFamilyAlertController.addAction(cancelAlertAction)
        self.leaveFamilyAlertController = leaveFamilyAlertController
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FamilyInformation.familyMembers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let familyMember = FamilyInformation.familyMembers.safeIndex(indexPath.row) else {
            return UITableViewCell()
        }

        let cell = indexPath.row == 0
        ? tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyHeadTableViewCell", for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyMemberTableViewCell", for: indexPath)

        if let cell = cell as? SettingsFamilyHeadTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)
            cell.containerView.roundCorners(setCorners: .all)
        }

        if let cell = cell as? SettingsFamilyMemberTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)
            cell.containerView.roundCorners(setCorners: .none)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.familyMembersTableView.deselectRow(at: indexPath, animated: true)
        // the first row is the family head who should be able to be selected
        guard indexPath.row != 0 else {
            return
        }
        
            // construct the alert controller which will confirm if the user wants to kick the family member
            let familyMember = FamilyInformation.familyMembers[indexPath.row]
            let kickFamilyMemberAlertController = UIAlertController(title: "Do you want to kick \(familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName) from your family?", message: nil, preferredStyle: .alert)

            let kickAlertAction = UIAlertAction(title: "Kick \(familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)", style: .destructive) { _ in
                // the user wants to kick the family member so query the server
                let body = [KeyConstant.familyKickUserId.rawValue: familyMember.userId]
                PresentationManager.beginFetchingInformationIndicator()
                FamilyRequest.delete(forErrorAlert: .automaticallyAlertForAll, forBody: body) { responseStatusFamilyDelete, _ in
                    PresentationManager.endFetchingInformationIndicator {
                        guard responseStatusFamilyDelete == .successResponse else {
                            return
                        }

                        // Refresh this page
                        FamilyRequest.get(forErrorAlert: .automaticallyAlertForAll) { responseStatusFamilyGet, _ in
                            guard responseStatusFamilyGet == .successResponse else {
                                return
                            }

                            self.repeatableSetup()
                            self.familyMembersTableView.reloadData()
                            // its possible that the familymembers table changed its constraint for height, so re-layout
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)

            kickFamilyMemberAlertController.addAction(kickAlertAction)
            kickFamilyMemberAlertController.addAction(cancelAlertAction)

            PresentationManager.enqueueAlert(kickFamilyMemberAlertController)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(familyMembersTableView)
        containerView.addSubview(familyCodeLabel)
        containerView.addSubview(familyCodeDescriptionLabel)
        containerView.addSubview(leaveFamilyButton)
        containerView.addSubview(leaveFamilyDescriptionLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(headerLabel)
        containerView.addSubview(shareFamilyButton)
        containerView.addSubview(membersHeaderLabel)
        
        shareFamilyButton.addTarget(self, action: #selector(didTouchUpInsideShareFamily), for: .touchUpInside)
        leaveFamilyButton.addTarget(self, action: #selector(didTouchUpInsideLeaveFamily), for: .touchUpInside)
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            leaveFamilyButton.topAnchor.constraint(equalTo: familyMembersTableView.bottomAnchor, constant: 45),
            leaveFamilyButton.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
            leaveFamilyButton.widthAnchor.constraint(equalTo: leaveFamilyButton.heightAnchor, multiplier: 1 / 0.16),
        
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1 / 1),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50 / 414),
            // TODO look for repetition like this. there are conflicting
            backButton.heightAnchor.constraint(equalToConstant: 25),
            backButton.heightAnchor.constraint(equalToConstant: 75),
        
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 40),
        
            shareFamilyButton.topAnchor.constraint(equalTo: familyCodeDescriptionLabel.bottomAnchor, constant: 25),
            shareFamilyButton.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
            shareFamilyButton.widthAnchor.constraint(equalTo: shareFamilyButton.heightAnchor, multiplier: 1 / 0.16),
        
            familyCodeLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            familyCodeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            familyCodeLabel.trailingAnchor.constraint(equalTo: familyCodeDescriptionLabel.trailingAnchor),
            familyCodeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            familyCodeLabel.trailingAnchor.constraint(equalTo: shareFamilyButton.trailingAnchor),
            familyCodeLabel.trailingAnchor.constraint(equalTo: membersHeaderLabel.trailingAnchor),
            familyCodeLabel.trailingAnchor.constraint(equalTo: leaveFamilyDescriptionLabel.trailingAnchor),
            familyCodeLabel.trailingAnchor.constraint(equalTo: leaveFamilyButton.trailingAnchor),
        
            membersHeaderLabel.topAnchor.constraint(equalTo: shareFamilyButton.bottomAnchor, constant: 45),
            membersHeaderLabel.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
        
            familyMembersTableView.topAnchor.constraint(equalTo: membersHeaderLabel.bottomAnchor, constant: 10),
            familyMembersTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            familyMembersTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        
            leaveFamilyDescriptionLabel.topAnchor.constraint(equalTo: leaveFamilyButton.bottomAnchor, constant: 7.5),
            leaveFamilyDescriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            leaveFamilyDescriptionLabel.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
        
            familyCodeDescriptionLabel.topAnchor.constraint(equalTo: familyCodeLabel.bottomAnchor, constant: 7.5),
            familyCodeDescriptionLabel.leadingAnchor.constraint(equalTo: familyCodeLabel.leadingAnchor),
        
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        
        ])
        
    }
}
