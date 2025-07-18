//
//  SettingsFamilyVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyVC: HoundScrollViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Elements
    
    private let pageHeader: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 380, compressionResistancePriority: 380)
        view.pageHeaderLabel.text = "Family"
        return view
    }()
    
    private let familyCodeHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let familyCodeDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        
        let activeSubscriptionNumberOfFamilyMembers = FamilyInformation.familyActiveSubscription.numberOfFamilyMembers
        let precalculatedDynamicTextColor = label.textColor
        
        label.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "The family code is the key your family. Have a prospective family member input the code above to join your family (case-insensitive).",
                attributes: [.font: VisualConstant.FontConstant.secondaryColorDescLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
            
            // Add a disclaimer for the user that they
            if activeSubscriptionNumberOfFamilyMembers <= 1 {
                message.append(
                    NSAttributedString(
                        string: " Currently, your Hound plan is for individual use only. To add family members, try out a free trial of Hound+!",
                        attributes: [.font: VisualConstant.FontConstant.emphasizedSecondaryColorDescLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
                    )
                )
            }
            
            return message
        }
        
        return label
    }()
    
    private let shareFamilyButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Invite to Family", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        return button
    }()
    
    @objc private func didTouchUpInsideShareFamily(_ sender: Any) {
        guard let familyCode = familyCode else { return }
        
        ExportActivityViewManager.shareFamilyCode(forFamilyCode: familyCode)
    }
    
    private let membersHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Members"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let familyMembersTableView: HoundTableView = {
        let tableView = HoundTableView(huggingPriority: 240, compressionResistancePriority: 240)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.systemBackground
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.applyStyle(.thinLabelBorder)
        return tableView
    }()
    
    private let leaveFamilyButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Leave Family", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        return button
    }()
    
    private let leaveFamilyDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 220, compressionResistancePriority: 220)
        label.text = "Family members can freely join or leave families. The head can only leave by deleting the family, which requires all other members to leave first (or be kicked)."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    @objc private func didTouchUpInsideLeaveFamily(_ sender: Any) {
        // We don't want to check the status of a family's subscription locally.
        // In order for a user to cancel a subscription, they must use Apple's subscription interface
        // This inherently doesn't update Hound, only the server.
        // Therefore the Hound app will always be outdated on this information.
        guard let leaveFamilyAlertController = leaveFamilyAlertController else { return }
        
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
        
        self.familyMembersTableView.register(SettingsFamilyHeadTVC.self, forCellReuseIdentifier: SettingsFamilyHeadTVC.reuseIdentifier)
        self.familyMembersTableView.register(SettingsFamilyMemberTVC.self, forCellReuseIdentifier: SettingsFamilyMemberTVC.reuseIdentifier)
        self.familyMembersTableView.delegate = self
        self.familyMembersTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    // MARK: - Functions
    
    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {
        
        // MARK: Family Code
        familyCodeHeaderLabel.text = "Code: \(familyCode ?? "NO CODE⚠️")"
        
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
                        self.dismissToViewController(ofClass: ServerSyncVC.self, completionHandler: nil)
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
                        self.dismissToViewController(ofClass: ServerSyncVC.self, completionHandler: nil)
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
        
        guard let familyMember = FamilyInformation.familyMembers[safe: indexPath.row] else {
            return HoundTableViewCell()
        }
        
        let cell = indexPath.row == 0
        ? tableView.dequeueReusableCell(withIdentifier: SettingsFamilyHeadTVC.reuseIdentifier, for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: SettingsFamilyMemberTVC.reuseIdentifier, for: indexPath)
        
        if let cell = cell as? SettingsFamilyHeadTVC {
            cell.setup(forDisplayFullName: familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)
            cell.containerView.roundCorners(setCorners: .all)
        }
        
        if let cell = cell as? SettingsFamilyMemberTVC {
            cell.setup(forDisplayFullName: familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)
            cell.containerView.roundCorners(setCorners: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.familyMembersTableView.deselectRow(at: indexPath, animated: true)
        // the first row is the family head who should be able to be selected
        guard indexPath.row != 0 else { return }
        
        // construct the alert controller which will confirm if the user wants to kick the family member
        let familyMember = FamilyInformation.familyMembers[indexPath.row]
        let kickFamilyMemberAlertController = UIAlertController(title: "Do you want to kick \(familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName) from your family?", message: nil, preferredStyle: .alert)
        
        let kickAlertAction = UIAlertAction(title: "Kick \(familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName)", style: .destructive) { _ in
            // the user wants to kick the family member so query the server
            let body: JSONRequestBody = [KeyConstant.familyKickUserId.rawValue: .string(familyMember.userId)]
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
                        self.familyMembersTableView.deleteRows(at: [indexPath], with: .automatic)
                        UIView.animate(withDuration: VisualConstant.AnimationConstant.moveMultipleElements) {
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                        }
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
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(familyMembersTableView)
        containerView.addSubview(familyCodeHeaderLabel)
        containerView.addSubview(familyCodeDescriptionLabel)
        containerView.addSubview(leaveFamilyButton)
        containerView.addSubview(leaveFamilyDescriptionLabel)
        containerView.addSubview(pageHeader)
        containerView.addSubview(shareFamilyButton)
        containerView.addSubview(membersHeaderLabel)
        
        shareFamilyButton.addTarget(self, action: #selector(didTouchUpInsideShareFamily), for: .touchUpInside)
        leaveFamilyButton.addTarget(self, action: #selector(didTouchUpInsideLeaveFamily), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // familyCodeHeaderLabel
        NSLayoutConstraint.activate([
            familyCodeHeaderLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            familyCodeHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            familyCodeHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            familyCodeHeaderLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            familyCodeHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // familyCodeDescriptionLabel
        NSLayoutConstraint.activate([
            familyCodeDescriptionLabel.topAnchor.constraint(equalTo: familyCodeHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            familyCodeDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            familyCodeDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // shareFamilyButton
        NSLayoutConstraint.activate([
            shareFamilyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            shareFamilyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            shareFamilyButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            shareFamilyButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            shareFamilyButton.topAnchor.constraint(equalTo: familyCodeDescriptionLabel.bottomAnchor, constant: 25.0)
        ])
        
        // membersHeaderLabel
        NSLayoutConstraint.activate([
            membersHeaderLabel.topAnchor.constraint(equalTo: shareFamilyButton.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            membersHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            membersHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            membersHeaderLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            membersHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // familyMembersTableView
        NSLayoutConstraint.activate([
            familyMembersTableView.topAnchor.constraint(equalTo: membersHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            familyMembersTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            familyMembersTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // leaveFamilyButton
        NSLayoutConstraint.activate([
            leaveFamilyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            leaveFamilyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            leaveFamilyButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            leaveFamilyButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            leaveFamilyButton.topAnchor.constraint(equalTo: familyMembersTableView.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert)
        ])
        
        NSLayoutConstraint.activate([
            leaveFamilyDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            leaveFamilyDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            leaveFamilyDescriptionLabel.topAnchor.constraint(equalTo: leaveFamilyButton.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            leaveFamilyDescriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset)
        ])
    }
    
}
