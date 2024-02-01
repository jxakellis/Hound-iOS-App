//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsFamilyIntroductionViewControllerDelegate {

    // MARK: - SettingsFamilyIntroductionViewControllerDelegate

    func didTouchUpInsideUpgrade() {
        StoryboardViewControllerManager.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
            guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                // Error message automatically handled
                return
            }
            
            PresentationManager.enqueueViewController(settingsSubscriptionViewController)
        }
    }

    // MARK: - IB

    @IBAction private func didTouchUpInsideShareFamily(_ sender: Any) {
        ExportManager.shareFamilyCode(forFamilyCode: familyCode)
    }

    @IBOutlet private weak var familyCodeLabel: GeneralUILabel!
    @IBOutlet private weak var familyCodeDescriptionLabel: GeneralUILabel!
    
    @IBOutlet private weak var familyIsLockedLabel: GeneralUILabel!
    @IBOutlet private weak var familyIsLockedSwitch: UISwitch!
    @IBAction private func didToggleIsLocked(_ sender: Any) {

        // assume request will go through and update values
        let initialIsLocked = FamilyInformation.familyIsLocked
        FamilyInformation.familyIsLocked = familyIsLockedSwitch.isOn
        updateIsLockedLabel()

        let body = [KeyConstant.familyIsLocked.rawValue: familyIsLockedSwitch.isOn]
        FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // request failed so we revert
                FamilyInformation.familyIsLocked = initialIsLocked
                self.updateIsLockedLabel()
                self.familyIsLockedSwitch.setOn(initialIsLocked, animated: true)
            }
        }
    }

    @IBOutlet private weak var familyMembersTableView: UITableView!

    @IBOutlet private weak var leaveFamilyButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideLeaveFamily(_ sender: Any) {
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

    private var familyCode: String {
        var code = FamilyInformation.familyCode
        code.insert("-", at: code.index(code.startIndex, offsetBy: 4))
        return code
    }

    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        let activeSubscriptionNumberOfFamilyMembers = FamilyInformation.activeFamilySubscription.numberOfFamilyMembers
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
        familyCodeLabel.text = "Code: \(familyCode)"

        // MARK: Family Lock

        familyIsLockedSwitch.isOn = FamilyInformation.familyIsLocked
        updateIsLockedLabel()

        // MARK: Family Members

        familyMembersTableView.allowsSelection = UserInformation.isUserFamilyHead

        // MARK: Leave Family Button

        let leaveFamilyAlertController = UIAlertController(title: "placeholder", message: nil, preferredStyle: .alert)

        // user is not the head of the family, so the button is enabled for them
        if UserInformation.isUserFamilyHead == false {
            leaveFamilyButton.isEnabled = true

            leaveFamilyButton.setTitle("Leave Family", for: .normal)
            leaveFamilyButton.backgroundColor = .systemBlue

            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                PresentationManager.beginFetchingInformationIndictator()
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _, _ in
                    PresentationManager.endFetchingInformationIndictator {
                        guard requestWasSuccessful else {
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
            if FamilyInformation.familyMembers.count == 1 {
                leaveFamilyButton.isEnabled = true
                leaveFamilyButton.backgroundColor = .systemBlue
            }
            // user is only family member so can destroy their family
            else {
                leaveFamilyButton.isEnabled = false
                leaveFamilyButton.backgroundColor = .systemGray4
            }

            leaveFamilyButton.setTitle("Delete Family", for: .normal)

            leaveFamilyAlertController.title = "Are you sure you want to delete your family?"

            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                PresentationManager.beginFetchingInformationIndictator()
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _, _ in
                    PresentationManager.endFetchingInformationIndictator {
                        guard requestWasSuccessful else {
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

        // MARK: Introduction Page

        if LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController == false && FamilyInformation.activeFamilySubscription.productId == ClassConstant.SubscriptionConstant.defaultSubscription.productId {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "SettingsFamilyIntroductionViewController")
        }
    }

    private func updateIsLockedLabel() {
        familyIsLockedLabel.text = "Lock: "
        if FamilyInformation.familyIsLocked == true {
            // locked emoji
            familyIsLockedLabel.text?.append("🔐")
        }
        else {
            // unlocked emoji
            familyIsLockedLabel.text?.append("🔓")
        }
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
                PresentationManager.beginFetchingInformationIndictator()
                FamilyRequest.delete(invokeErrorManager: true, forBody: body) { requestWasSuccessful, _, _ in
                    PresentationManager.endFetchingInformationIndictator {
                        guard requestWasSuccessful else {
                            return
                        }

                        // Refresh this page
                        FamilyRequest.get(invokeErrorManager: true) { requestWasSuccessful, _, _ in
                            guard requestWasSuccessful else {
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsFamilyIntroductionViewController = segue.destination as? SettingsFamilyIntroductionViewController {
            settingsFamilyIntroductionViewController.delegate = self
        }
    }

}
