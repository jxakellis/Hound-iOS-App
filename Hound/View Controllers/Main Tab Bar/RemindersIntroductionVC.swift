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

final class RemindersIntroductionViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var remindersTitle: ScaledUILabel!
    
    @IBOutlet private weak var remindersTitleDescription: ScaledUILabel!
    
    @IBOutlet private weak var remindersHeader: ScaledUILabel!
    
    @IBOutlet private weak var remindersBody: ScaledUILabel!
    
    @IBOutlet private weak var remindersToggleSwitch: UISwitch!
    
    @IBOutlet private weak var continueButton: ScreenWidthUIButton!
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        
        // If the user has notifications authorized and turned on, then there is no need to pop a request to the user
        if LocalConfiguration.localIsNotificationAuthorized == true && UserConfiguration.isNotificationEnabled == true {
            completeRemindersIntroductionPage()
        }
        else {
            NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
                completeRemindersIntroductionPage()
            }
        }
        
        func completeRemindersIntroductionPage() {
            // wait the user to select an grant or deny notification permission (and for the server to response if situation requires the use of it) before continuing
            
            // Recheck to verify that the user is still eligible for default reminders, then check if reminders toggle switch could have been programically removed and deleted
            guard self.dogManager.dogs.count >= 1, self.dogManager.hasCreatedReminder == false, let remindersToggleSwitch = self.remindersToggleSwitch, remindersToggleSwitch.isOn == true else {
                // the user has chosen to not add default reminders (or was blocked because their family already created reminders for some dog)
                self.continueButton.isEnabled = true
                LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // the user has a dog to add the default reminders too
            RemindersRequest.create(invokeErrorManager: true, forDogId: self.dogManager.dogs[0].dogId, forReminders: ClassConstant.ReminderConstant.defaultReminders) { reminders, _ in
                
                self.continueButton.isEnabled = true
                
                guard let reminders = reminders else {
                    return
                }
                
                // if we were able to add the reminders, then append to the dogManager
                self.dogManager.dogs[0].dogReminders.addReminders(forReminders: reminders)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Properties
    
    weak var delegate: RemindersIntroductionViewControllerDelegate! = nil
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        if !(sender.localized is MainTabBarViewController) {
            self.delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the user's family has at least one dog and has no reminders, then they are in need of default reminders. If the user's family doesn't have a dog there is no place to put the default reminders, and if the user's family already created a reminder then its excessive to add the default reminders
        let isEligibleForDefaultReminders = dogManager.dogs.count >= 1 && dogManager.hasCreatedReminder == false
        remindersHeader.text = isEligibleForDefaultReminders ?
        "Setup Reminders" : "Setup Reminders"
        remindersBody.text = isEligibleForDefaultReminders
        ? "We'll create reminders that are useful for most dogs. Do you want to use them? You can always create more or edit reminders later."
        : "It appears that your family has already created a few reminders for your dog\(dogManager.dogs.count > 1 ? "s" : ""). Hopefully they cover everything you need. If not, you can always create more or edit reminders. Enjoy!"
        remindersToggleSwitch.isEnabled = isEligibleForDefaultReminders
        remindersToggleSwitch.isOn = isEligibleForDefaultReminders
        
        if isEligibleForDefaultReminders == false {
            // no use for the remindersToggleSwitch if the user can't have default reminders
            remindersToggleSwitch.removeFromSuperview()
            remindersBody.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0).isActive = true
        }
        
        continueButton.applyStyle(forStyle: .whiteTextBlueBackgroundNoBorder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
}
