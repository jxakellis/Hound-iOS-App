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
    
    @IBOutlet private weak var whiteBackgroundView: UIView!
    
    @IBOutlet private weak var setUpRemindersButton: SemiboldUIButton!
    @IBAction private func didTouchUpInsideSetUpReminders(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false
        
        NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            // Verify that the user is still eligible for default reminders
            guard self.dogManager.hasCreatedReminder == false, let dog = self.dogManager.dogs.first else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // We are able to add the user's default reminders
            PresentationManager.beginFetchingInformationIndictator()
            RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: ClassConstant.ReminderConstant.defaultReminders) { reminders, _ in
                PresentationManager.endFetchingInformationIndictator {
                    guard let reminders = reminders else {
                        // Something failed, re-enable the buttons so that
                        self.setUpRemindersButton.isEnabled = true
                        self.maybeLaterButton.isEnabled = true
                        return
                    }
                    
                    dog.dogReminders.addReminders(forReminders: reminders)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBOutlet private weak var maybeLaterButton: SemiboldUIButton!
    @IBAction private func didTouchUpInsideMaybeLater(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false
        
        NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: RemindersIntroductionViewControllerDelegate!
    
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
        
        whiteBackgroundView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous
        
        // Use this page to configure and manage reminders to care for your dog.
        setUpRemindersButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
        maybeLaterButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This page should be light. Elements do not transfer well to dark mode
        self.overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
    }
    
}
