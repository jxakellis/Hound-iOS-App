//
//  SecondViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate, DogsTableViewControllerDelegate, DogsIndependentReminderViewControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Dual Delegate Implementation
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }
    
    // MARK: - DogsIndependentReminderViewControllerDelegate
    
    func didAddReminder(sender: Sender, forDogId: Int, forReminder reminder: Reminder) {
        
        dogManager.findDog(forDogId: forDogId)?.dogReminders.addReminder(forReminder: reminder)
        
        setDogManager(sender: sender, forDogManager: dogManager)
        
        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }
    
    func didRemoveReminder(sender: Sender, forDogId: Int, forReminderId: Int) {
        
        let dogReminders = dogManager.findDog(forDogId: forDogId)?.dogReminders
        
        dogReminders?.findReminder(forReminderId: forReminderId)?.clearTimers()
        dogReminders?.removeReminder(forReminderId: forReminderId)
        
        setDogManager(sender: sender, forDogManager: dogManager)
        
        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }
    
    // MARK: - DogsTableViewControllerDelegate
    
    /// If a dog in DogsTableViewController or Add Dog were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenDogMenu(forDogId dogId: Int?) {
        
        guard let dogId = dogId, let currentDog = dogManager.findDog(forDogId: dogId) else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddDogViewController")
            return
        }
        
        PresentationManager.beginFetchingInformationIndictator()
        
        DogsRequest.get(invokeErrorManager: true, dog: currentDog) { newDog, responseStatus in
            PresentationManager.endFetchingInformationIndictator {
                guard let newDog = newDog else {
                    if responseStatus == .successResponse {
                        // If the response was successful but no dog was returned, that means the dog was deleted. Therefore, update the dogManager to indicate as such.
                        self.dogManager.removeDog(forDogId: currentDog.dogId)
                        self.dogManager.clearTimers()
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    }
                    return
                }
                
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddDogViewController")
                self.dogsAddDogViewController.dogToUpdate = newDog
            }
        }
    }
    
    /// If a reminder in DogsTableViewController or Add Reminder were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenReminderMenu(forDogId: Int, forReminder: Reminder?) {
        
        guard let forReminder = forReminder else {
            // creating new
            // no need to query as nothing in server since creating
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsIndependentReminderViewController")
            dogsIndependentReminderViewController.forDogId = forDogId
            return
        }
        
        // updating
        PresentationManager.beginFetchingInformationIndictator()
        // query for existing
        RemindersRequest.get(invokeErrorManager: true, forDogId: forDogId, forReminder: forReminder) { reminder, responseStatus in
            PresentationManager.endFetchingInformationIndictator {
                guard let reminder = reminder else {
                    if responseStatus == .successResponse {
                        // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                        let dogReminders = self.dogManager.findDog(forDogId: forDogId)?.dogReminders
                        dogReminders?.findReminder(forReminderId: forReminder.reminderId)?.clearTimers()
                        dogReminders?.removeReminder(forReminderId: forReminder.reminderId)
                        
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    }
                    return
                }
                
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsIndependentReminderViewController")
                self.dogsIndependentReminderViewController.forDogId = forDogId
                self.dogsIndependentReminderViewController.targetReminder = reminder
            }
        }
    }
    
    func didUpdateAlphaForButtons(forAlpha: Double) {
        createNewDogOrReminderButton.alpha = forAlpha
        createNewDogOrReminderButton.isHidden = forAlpha == 0
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var noDogsRecordedLabel: ScaledUILabel!
    
    @IBOutlet private weak var createNewDogOrReminderButton: ScaledImageWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideCreateNewDogOrReminder(_ sender: Any) {
        if createNewMenuIsOpen {
            closeCreateNewDogOrReminder()
        }
        else {
            openCreateNewDogOrReminder()
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsViewControllerDelegate!
    
    var dogsTableViewController = DogsTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogsIndependentReminderViewController = DogsIndependentReminderViewController()
    
    private let createNewButtonPadding: CGFloat = 10.0
    
    private var createNewMenuIsOpen: Bool = false
    private var createNewMenuScreenDimmer: UIView!
    private var createNewButtons: [ScaledImageWithBackgroundUIButton] = []
    private var createNewLabels: [ScaledUILabel] = []
    private var createNewBackgroundLabels: [ScaledUILabel] = []
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // possible senders
        // DogsTableViewController
        // DogsAddDogViewController
        // MainTabBarController
        
        if !(sender.localized is DogsTableViewController) {
            dogsTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        if (sender.localized is MainTabBarController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
            dogsAddDogViewController.navigationController?.popViewController(animated: false)
            dogsIndependentReminderViewController.navigationController?.popViewController(animated: false)
        }
        if !(sender.localized is MainTabBarController) {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        noDogsRecordedLabel?.isHidden = !dogManager.dogs.isEmpty
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let createNewMenuScreenDimmer = UIView(frame: view.frame)
        createNewMenuScreenDimmer.alpha = 0
        createNewMenuScreenDimmer.backgroundColor = UIColor.black
        createNewMenuScreenDimmer.isUserInteractionEnabled = false
        self.createNewMenuScreenDimmer = createNewMenuScreenDimmer
        
        let closeCreateNewDogOrReminderTap = UITapGestureRecognizer(target: self, action: #selector(closeCreateNewDogOrReminder))
        closeCreateNewDogOrReminderTap.delegate = self
        createNewMenuScreenDimmer.addGestureRecognizer(closeCreateNewDogOrReminderTap)
        
        self.view.addSubview(createNewMenuScreenDimmer)
        self.view.bringSubviewToFront(createNewDogOrReminderButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeCreateNewDogOrReminder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    @objc private func willOpenMenu(sender: Any) {
        // The sender could be a UIButton or UIGestureRecognizer (which is attached to a UILabel), so we attempt to unwrap the sender as both
        let tag = (sender as? UIView)?.tag ?? (sender as? UIGestureRecognizer)?.view?.tag ?? 0
        if tag == 0 {
            self.shouldOpenDogMenu(forDogId: nil)
        }
        else {
            self.shouldOpenReminderMenu(forDogId: tag, forReminder: nil)
        }
    }
    
    private func openCreateNewDogOrReminder() {
        guard createNewMenuIsOpen == false else {
            return
        }
        createNewMenuIsOpen = true
        
        createNewMenuScreenDimmer.isUserInteractionEnabled = true
        
        let createNewDogOrReminderButtonSmallestDimension: CGFloat = createNewDogOrReminderButton.frame.width < createNewDogOrReminderButton.frame.height ? createNewDogOrReminderButton.frame.width : createNewDogOrReminderButton.frame.height
        
        let createNewButtonSize: CGFloat = createNewDogOrReminderButtonSmallestDimension * 0.65
        let totalAvailableYSpaceForCreateNewButtons: CGFloat = createNewDogOrReminderButton.frame.origin.y - view.safeAreaLayoutGuide.layoutFrame.origin.y
        let maximumNumberOfCreateNewButtons: Int = Int(totalAvailableYSpaceForCreateNewButtons / ( createNewButtonSize + createNewButtonPadding))
        
        let createNewButtonXOrigin = createNewDogOrReminderButton.frame.maxX - createNewButtonSize
        let createNewButtonYOrigin = createNewDogOrReminderButton.frame.origin.y - createNewButtonPadding - createNewButtonSize
        
        // Creates the "add new dog" button to tap
        let createNewDogButton = ScaledImageWithBackgroundUIButton(frame: CGRect(
            x: createNewButtonXOrigin, y: createNewButtonYOrigin,
            width: createNewButtonSize, height: createNewButtonSize))
        createNewDogButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        createNewDogButton.tintColor = .systemBlue
        createNewDogButton.backgroundUIButtonTintColor = .systemBackground
        
        let createNewDogLabel = createCreateAddLabel(relativeToFrame: createNewDogButton.frame, text: "Create New Dog")
        let createNewDogLabelBackground = createCreateAddBackgroundLabel(forLabel: createNewDogLabel)
        
        createNewDogButton.addTarget(self, action: #selector(willOpenMenu(sender:)), for: .touchUpInside)
        createNewDogLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willOpenMenu(sender:))))
        
        view.addSubview(createNewDogLabelBackground)
        view.addSubview(createNewDogLabel)
        view.addSubview(createNewDogButton)
        createNewBackgroundLabels.append(createNewDogLabelBackground)
        createNewLabels.append(createNewDogLabel)
        createNewButtons.append(createNewDogButton)
        
        // Iterate through each dog to create corresponding "Create New Reminder for dogName" button and label.
        for dog in dogManager.dogs {
            guard createNewButtons.count < maximumNumberOfCreateNewButtons else {
                break
            }
            
            // Use the last createNewButton in createNewButtons as a position reference for the next button.
            // createNewButtons shouldn't be empty at this point. It should have the button for 'Create New Dog' or for one of the 'Create New Reminder for dogName'
            guard let lastCreateNewButton = createNewButtons.last else {
                break
            }
            
            let createNewReminderButton = ScaledImageWithBackgroundUIButton(frame: CGRect(
                origin: CGPoint(x: lastCreateNewButton.frame.origin.x, y: lastCreateNewButton.frame.origin.y - createNewButtonPadding - createNewButtonSize),
                size: CGSize(width: createNewButtonSize, height: createNewButtonSize)))
            createNewReminderButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            createNewReminderButton.tintColor = .systemBlue
            createNewReminderButton.backgroundUIButtonTintColor = .systemBackground
            
            let createNewReminderLabel = createCreateAddLabel(relativeToFrame: createNewReminderButton.frame, text: "Create New Reminder For \(dog.dogName)")
            let createNewDogLabelBackground = createCreateAddBackgroundLabel(forLabel: createNewReminderLabel)
            
            createNewReminderButton.tag = dog.dogId
            createNewReminderButton.addTarget(self, action: #selector(willOpenMenu(sender:)), for: .touchUpInside)
            createNewReminderLabel.tag = dog.dogId
            createNewReminderLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willOpenMenu(sender:))))
            
            view.addSubview(createNewDogLabelBackground)
            view.addSubview(createNewReminderLabel)
            view.addSubview(createNewReminderButton)
            
            createNewBackgroundLabels.append(createNewDogLabelBackground)
            createNewLabels.append(createNewReminderLabel)
            createNewButtons.append(createNewReminderButton)
        }
        
        view.bringSubviewToFront(createNewDogOrReminderButton)
        // Animate dimming the screen for when the menu opens and rotate createNewDogOrReminderButton slightly
        UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewDogOrReminderDuration) {
            self.createNewDogOrReminderButton.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            self.createNewDogOrReminderButton.tintColor = .systemRed
            
            self.createNewMenuScreenDimmer.alpha = 0.5
            self.tabBarController?.tabBar.alpha = 0.05
        }
        
        // Conceal createNewButton inside of createNewDogOrReminderButton, then animate them back to their original positions
        createNewButtons.forEach { createNewButton in
            let originalCreateNewButtonOrigin = createNewButton.frame.origin
            
            // move createNewButton vertically so that it sits vertically aligned inside of createNewDogOrReminderButton. This will conceal createNewButton below createNewDogOrReminderButton
            createNewButton.frame.origin.y = createNewDogOrReminderButton.frame.midY - (createNewButton.frame.height / 2)
            // the buttons' right edges slightly stick out under createNewDogOrReminderButton. Therefore, we must shift them ever so slightly in
            createNewButton.frame.origin.x -= (createNewDogOrReminderButton.frame.width * 0.025)
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewDogOrReminderDuration) {
                createNewButton.frame.origin = originalCreateNewButtonOrigin
            }
        }
        
        // Conceal createNewLabel by shifting it directly right off screen, then animate them back into their original positons
        createNewLabels.forEach { createNewLabel in
            let originalCreateNewLabelOrigin = createNewLabel.frame.origin
            
            // move createNewLabel horizontally so that it sits out of view to the right
            createNewLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewDogOrReminderDuration) {
                createNewLabel.frame.origin = originalCreateNewLabelOrigin
            }
        }
        
        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            let originalCreateNewBackgroundLabelOrigin = createNewBackgroundLabel.frame.origin
            
            // move createNewLabel horizontally so that it sits out of view to the right
            createNewBackgroundLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewDogOrReminderDuration) {
                createNewBackgroundLabel.frame.origin = originalCreateNewBackgroundLabelOrigin
            }
        }
    }
    
    @objc private func closeCreateNewDogOrReminder() {
        guard createNewMenuIsOpen == true else {
            return
        }
        createNewMenuIsOpen = false
        
        createNewMenuScreenDimmer.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewDogOrReminderDuration) {
            self.createNewDogOrReminderButton.transform = .identity
            self.createNewDogOrReminderButton.tintColor = .systemBlue
            self.createNewMenuScreenDimmer.alpha = 0
            
            self.tabBarController?.tabBar.alpha = 1
        }
        
        // animate the labels back into origina, opening positions then remove after delay
        createNewButtons.forEach { createNewButton in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDuration) {
                // move createNewButton vertically so that it sits vertically aligned inside of createNewDogOrReminderButton. This will conceal createNewButton below createNewDogOrReminderButton
                createNewButton.frame.origin.y = self.createNewDogOrReminderButton.frame.midY - (createNewButton.frame.height / 2)
                // the buttons' right edges slightly stick out under createNewDogOrReminderButton. Therefore, we must shift them ever so slightly in
                createNewButton.frame.origin.x -= (self.createNewDogOrReminderButton.frame.width * 0.025)
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDelay) {
                    createNewButton.removeFromSuperview()
                }
            }
        }
        
        // animate the labels back into original, opening position then remove after delay
        createNewLabels.forEach { createNewLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDuration) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDelay) {
                    createNewLabel.removeFromSuperview()
                }
            }
        }
        
        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDuration) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewBackgroundLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.closeCreateNewDogOrReminderDelay) {
                    createNewBackgroundLabel.removeFromSuperview()
                }
            }
        }
        
        createNewButtons = []
        createNewLabels = []
        createNewBackgroundLabels = []
    }
    
    private func createCreateAddLabel(relativeToFrame frame: CGRect, text: String) -> ScaledUILabel {
        let font = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        let createNewLabelSize = text.bounding(font: font)
        
        let createNewLabel = ScaledUILabel(frame: CGRect(
            x: frame.origin.x - createNewLabelSize.width,
            y: frame.midY - (createNewLabelSize.height / 2),
            width: createNewLabelSize.width,
            height: createNewLabelSize.height))
        // we can't afford to shrink the label here, already small
        createNewLabel.minimumScaleFactor = 1.0
        createNewLabel.font = font
        createNewLabel.text = text
        createNewLabel.textColor = .systemBackground
        createNewLabel.isUserInteractionEnabled = true
        createNewLabel.adjustsFontSizeToFitWidth = true
        
        let overshootDistance: CGFloat = createNewButtonPadding - createNewLabel.frame.origin.x
        // Check to make sure the label didn't overshoot the allowed bounds
        if overshootDistance > 0 {
            createNewLabel.frame = CGRect(
                x: createNewButtonPadding,
                y: createNewLabel.frame.origin.y,
                width: createNewLabel.frame.width - overshootDistance,
                height: createNewLabel.frame.height
            )
        }
        
        return createNewLabel
    }
    
    private func createCreateAddBackgroundLabel(forLabel label: ScaledUILabel) -> ScaledUILabel {
        let createNewBackgroundLabel = ScaledUILabel(frame: label.frame)
        // we can't afford to shrink the label here, already small
        createNewBackgroundLabel.minimumScaleFactor = 1.0
        createNewBackgroundLabel.font = label.font
        createNewBackgroundLabel.text = label.text
        createNewBackgroundLabel.outline(outlineColor: .systemBlue, insideColor: .systemBlue, outlineWidth: 15)
        createNewBackgroundLabel.isUserInteractionEnabled = false
        createNewBackgroundLabel.adjustsFontSizeToFitWidth = true
        
        return createNewBackgroundLabel
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddDogViewController = segue.destination as? DogsAddDogViewController {
            self.dogsAddDogViewController = dogsAddDogViewController
            dogsAddDogViewController.delegate = self
            
            dogsAddDogViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let dogsTableViewController = segue.destination as? DogsTableViewController {
            self.dogsTableViewController = dogsTableViewController
            dogsTableViewController.delegate = self
            
            dogsTableViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let dogsIndependentReminderViewController = segue.destination as? DogsIndependentReminderViewController {
            self.dogsIndependentReminderViewController = dogsIndependentReminderViewController
            dogsIndependentReminderViewController.delegate = self
        }
    }
    
}