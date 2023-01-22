//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsFamilyIntroductionViewControllerDelegate {
    
    // MARK: - SettingsFamilyIntroductionViewControllerDelegate
    
    func willUpgrade() {
        SettingsSubscriptionViewController.performSegueToSettingsSubscriptionViewController(forViewController: self)
    }
    
    // MARK: - IB
    
    // MARK: General
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    @IBAction private func willRefresh(_ sender: Any) {
        self.refreshButton.isEnabled = false
        self.navigationItem.beginTitleViewActivity(forNavigationBarFrame: self.navigationController?.navigationBar.frame ?? CGRect())
        FamilyRequest.get(invokeErrorManager: true) { requestWasSuccessful, _ in
            self.refreshButton.isEnabled = true
            self.navigationItem.endTitleViewActivity(forNavigationBarFrame: self.navigationController?.navigationBar.frame ?? CGRect())
            
            guard requestWasSuccessful else {
                return
            }
            
            // update the data to reflect what was retrieved from the server
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshFamilyTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshFamilySubtitle, forStyle: .success)
            self.repeatableSetup()
            self.tableView.reloadData()
            // its possible that the familymembers table changed its constraint for height, so re layout
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func didTapShareFamily(_ sender: Any) {
        ExportManager.shareFamilyCode(forFamilyCode: familyCode)
    }
    
    // MARK: Family Code
    @IBOutlet private weak var familyCodeLabel: ScaledUILabel!
    
    // MARK: Family Lock
    @IBOutlet private weak var familyIsLockedLabel: ScaledUILabel!
    @IBOutlet private weak var familyIsLockedSwitch: UISwitch!
    @IBAction private func didToggleIsLocked(_ sender: Any) {
        
        // assume request will go through and update values
        let initalIsLocked = FamilyInformation.familyIsLocked
        FamilyInformation.familyIsLocked = familyIsLockedSwitch.isOn
        updateIsLockedLabel()
        
        let body = [KeyConstant.familyIsLocked.rawValue: familyIsLockedSwitch.isOn]
        FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // request failed so we revert
                FamilyInformation.familyIsLocked = initalIsLocked
                self.updateIsLockedLabel()
                self.familyIsLockedSwitch.setOn(initalIsLocked, animated: true)
            }
        }
    }
    
    // MARK: Family Members
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Leave Family
    
    @IBOutlet private weak var leaveFamilyButton: ScreenWidthUIButton!
    
    @IBAction private func didTapLeaveFamily(_ sender: Any) {
        // We don't want to check the status of a family's subscription locally.
        // In order for a user to cancel a subscription, they must use Apple's subscription interface
        // This inherently doesn't update Hound, only the server.
        // Therefore the Hound app will always be outdated on this information.
        
        AlertManager.enqueueAlertForPresentation(leaveFamilyAlertController)
    }
    
    // MARK: - Properties
    
    var leaveFamilyAlertController: GeneralUIAlertController!
    
    var kickFamilyMemberAlertController: GeneralUIAlertController!
    
    private var familyCode: String {
        var code = FamilyInformation.familyCode
        code.insert("-", at: code.index(code.startIndex, offsetBy: 4))
        return code
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorInset = .zero
        
        leaveFamilyButton.applyStyle(forStyle: .whiteTextBlueBackgroundNoBorder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
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
        
        tableView.allowsSelection = FamilyInformation.isUserFamilyHead
        
        // MARK: Leave Family Button
        
        leaveFamilyAlertController = GeneralUIAlertController(title: "placeholder", message: nil, preferredStyle: .alert)
        
        // user is not the head of the family, so the button is enabled for them
        if FamilyInformation.isUserFamilyHead == false {
            leaveFamilyButton.isEnabled = true
            
            leaveFamilyButton.setTitle("Leave Family", for: .normal)
            leaveFamilyButton.backgroundColor = .systemBlue
            
            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                RequestUtils.beginRequestIndictator()
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        guard requestWasSuccessful else {
                            return
                        }
                        
                        // family was successfully left, revert to server sync view controller
                        MainTabBarViewController.mainTabBarViewController?.dismissIntoServerSyncViewController()
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
            
            // TO DO NOW TEST server side verification works for active subscription and banner pops down that allows a user to tap it.
            
            leaveFamilyButton.setTitle("Delete Family", for: .normal)
            
            leaveFamilyAlertController.title = "Are you sure you want to delete your family?"
            
            // If the user has an active subscription, then let them know they will lose the rest of its duration
            if FamilyInformation.activeFamilySubscription.product != nil {
                leaveFamilyAlertController.title?.append(" The remaining duration of your active subscription will be forfitted.")
            }
            
            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                RequestUtils.beginRequestIndictator()
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        guard requestWasSuccessful else {
                            return
                        }
                        // family was successfully deleted, revert to server sync view controller
                        MainTabBarViewController.mainTabBarViewController?.dismissIntoServerSyncViewController()
                    }
                }
            }
            leaveFamilyAlertController.addAction(deleteAlertAction)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        leaveFamilyAlertController.addAction(cancelAlertAction)
        
        // MARK: Introduction Page
        
        if LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController == false {
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
        
        let familyMember = FamilyInformation.familyMembers[indexPath.row]
        // family members is sorted to have the family head as its first element
        if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyHeadTableViewCell", for: indexPath) as? SettingsFamilyHeadTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName)
            
            return cell
        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyMemberTableViewCell", for: indexPath) as? SettingsFamilyMemberTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        // the first row is the family head who should be able to be selected
        if indexPath.row != 0 {
            // construct the alert controller which will confirm if the user wants to kick the family member
            let familyMember = FamilyInformation.familyMembers[indexPath.row]
            kickFamilyMemberAlertController = GeneralUIAlertController(title: "Do you want to kick \(familyMember.displayFullName) from your family?", message: nil, preferredStyle: .alert)
            
            let kickAlertAction = UIAlertAction(title: "Kick \(familyMember.displayFullName)", style: .destructive) { _ in
                // the user wants to kick the family member so query the server
                let body = [KeyConstant.familyKickUserId.rawValue: familyMember.userId]
                RequestUtils.beginRequestIndictator()
                FamilyRequest.delete(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        guard requestWasSuccessful else {
                            return
                        }
                        // invoke the @IBAction private function to refresh this page
                        self.willRefresh(0)
                    }
                }
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            kickFamilyMemberAlertController.addAction(kickAlertAction)
            kickFamilyMemberAlertController.addAction(cancelAlertAction)
            
            AlertManager.enqueueAlertForPresentation(kickFamilyMemberAlertController)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsFamilyIntroductionViewController = segue.destination as? SettingsFamilyIntroductionViewController {
            settingsFamilyIntroductionViewController.delegate = self
        }
    }
    
}
