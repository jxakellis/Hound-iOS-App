//
//  RemindersIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RemindersIntroductionViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager dogManager: DogManager)
}

final class RemindersIntroductionViewController: GeneralUIViewController {
    
    // MARK: - IB

    @IBOutlet private weak var whiteBackgroundView: UIView!

    @IBOutlet private weak var setUpRemindersButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideSetUpReminders(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false

        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            // Verify that the user is still eligible for default reminders
            guard self.dogManager.hasCreatedReminder == false, let dog = self.dogManager.dogs.first else {
                self.dismiss(animated: true, completion: nil)
                return
            }

            // We are able to add the user's default reminders
            let reminders = ClassConstant.ReminderConstant.defaultReminders
            PresentationManager.beginFetchingInformationIndictator()
            RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: reminders) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndictator {
                    guard responseStatus != .failureResponse else {
                        // Something failed, re-enable the buttons so they can try again
                        self.setUpRemindersButton.isEnabled = true
                        self.maybeLaterButton.isEnabled = true
                        return
                    }

                    dog.dogReminders.addReminders(forReminders: reminders)
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)

                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBOutlet private weak var maybeLaterButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideMaybeLater(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false

        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Properties

    private weak var delegate: RemindersIntroductionViewControllerDelegate!

    // MARK: - Dog Manager

    private var dogManager = DogManager()

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: RemindersIntroductionViewControllerDelegate, forDogManager: DogManager) {
        self.delegate = forDelegate
        self.dogManager = forDogManager
    }

}
