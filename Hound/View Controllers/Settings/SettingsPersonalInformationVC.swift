//
//  SettingsPersonalInformationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsPersonalInformationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsPersonalInformationViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var userName: ScaledUILabel!
    
    @IBOutlet private weak var userEmail: ScaledUILabel!
    @IBOutlet private weak var copyUserEmailButton: ScaledImageUIButton!
    @IBAction private func didTapCopyUserEmail(_ sender: Any) {
        guard let userEmail = UserInformation.userEmail else {
            return
        }
        
        UIPasteboard.general.setPasteboard(forString: userEmail)
    }
    
    @IBOutlet private weak var userId: ScaledUILabel!
    @IBOutlet private weak var copyUserIdButton: ScaledImageUIButton!
    @IBAction private func didTapCopyUserId(_ sender: Any) {
        guard let userId = UserInformation.userId else {
            return
        }
        
        UIPasteboard.general.setPasteboard(forString: userId)
    }
    
    @IBOutlet private weak var redownloadDataButton: ScreenWidthUIButton!
    @IBAction private func didTapRedownloadData(_ sender: Any) {
        AlertManager.beginFetchingInformationIndictator()
        
        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentUserConfigurationPreviousDogManagerSynchronization = LocalConfiguration.userConfigurationPreviousDogManagerSynchronization
        // manually set userConfigurationPreviousDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        
        DogsRequest.get(invokeErrorManager: true, dogManager: DogManager()) { newDogManager, _ in
            AlertManager.endFetchingInformationIndictator {
                
                guard let newDogManager = newDogManager else {
                    // failed query to fully redownload the dogManager
                    // revert userConfigurationPreviousDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = currentUserConfigurationPreviousDogManagerSynchronization
                    return
                }
                
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.redownloadDataTitle, forSubtitle: VisualConstant.BannerTextConstant.redownloadDataSubtitle, forStyle: .success)
                
                // successful query to fully redownload the dogManager, no need to mess with userConfigurationPreviousDogManagerSynchronization as that is automatically handled
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }
    
    @IBOutlet private weak var deleteAccountButton: ScreenWidthUIButton!
    @IBAction private func didTapDeleteAccount(_ sender: Any) {
        
        let deleteAccountAlertController = GeneralUIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .alert)
        
        let deleteAlertAction = UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            AlertManager.beginFetchingInformationIndictator()
            
            UserRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                AlertManager.endFetchingInformationIndictator {
                    guard requestWasSuccessful else {
                        return
                    }
                    // family was successfully deleted, revert to server sync view controller
                    AlertManager.globalPresenter?.dismissIntoServerSyncViewController()
                }
            }
        }
        deleteAccountAlertController.addAction(deleteAlertAction)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        deleteAccountAlertController.addAction(cancelAlertAction)
        
        AlertManager.enqueueAlertForPresentation(deleteAccountAlertController)
    }
    
    // MARK: - Properties
    
    weak var delegate: SettingsPersonalInformationViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = UserInformation.displayFullName
        
        userEmail.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownEmail
        copyUserEmailButton.isEnabled = UserInformation.userEmail != nil
        
        userId.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownUserId
        copyUserIdButton.isEnabled = UserInformation.userId != nil
        
        redownloadDataButton.applyStyle(forStyle: .whiteTextBlueBackgroundNoBorder)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
}
