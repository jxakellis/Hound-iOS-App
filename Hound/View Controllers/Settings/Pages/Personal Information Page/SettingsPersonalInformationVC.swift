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

    // MARK: - IB

    @IBOutlet private weak var userName: GeneralUILabel!

    @IBOutlet private weak var userEmail: GeneralUILabel!
    @IBOutlet private weak var copyUserEmailButton: GeneralUIButton!
    @IBAction private func didTapCopyUserEmail(_ sender: Any) {
        guard let userEmail = UserInformation.userEmail else {
            return
        }

        UIPasteboard.general.setPasteboard(forString: userEmail)
    }

    @IBOutlet private weak var userId: GeneralUILabel!
    @IBOutlet private weak var copyUserIdButton: GeneralUIButton!
    @IBAction private func didTapCopyUserId(_ sender: Any) {
        guard let userId = UserInformation.userId else {
            return
        }

        UIPasteboard.general.setPasteboard(forString: userId)
    }

    @IBAction private func didTapRedownloadData(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndictator()

        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentUserConfigurationPreviousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization
        // manually set previousDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.previousDogManagerSynchronization = nil

        DogsRequest.get(invokeErrorManager: true, dogManager: DogManager()) { newDogManager, _, _ in
            PresentationManager.endFetchingInformationIndictator {

                guard let newDogManager = newDogManager else {
                    // failed query to fully redownload the dogManager
                    // revert previousDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.previousDogManagerSynchronization = currentUserConfigurationPreviousDogManagerSynchronization
                    return
                }

                PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.redownloadDataTitle, forSubtitle: VisualConstant.BannerTextConstant.redownloadDataSubtitle, forStyle: .success)

                // successful query to fully redownload the dogManager, no need to mess with previousDogManagerSynchronization as that is automatically handled
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }

    @IBAction private func didTapDeleteAccount(_ sender: Any) {

        let deleteAccountAlertController = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .alert)

        let deleteAlertAction = UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            PresentationManager.beginFetchingInformationIndictator()

            UserRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _, _ in
                PresentationManager.endFetchingInformationIndictator {
                    guard requestWasSuccessful else {
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

    weak var delegate: SettingsAccountViewControllerDelegate!

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .didDismissForSettingsPagesTableViewController, object: self)
    }
}
