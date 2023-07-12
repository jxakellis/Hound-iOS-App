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
    func willOpenDogMenu(forDogId dogId: Int?) {
        
        guard let dogId = dogId, let currentDog = dogManager.findDog(forDogId: dogId) else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddDogViewController")
            return
        }
        
        AlertManager.beginFetchingInformationIndictator()
        
        DogsRequest.get(invokeErrorManager: true, dog: currentDog) { newDog, responseStatus in
            AlertManager.endFetchingInformationIndictator {
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
    func willOpenReminderMenu(forDogId: Int, forReminder: Reminder?) {
        
        guard let forReminder = forReminder else {
            // creating new
            // no need to query as nothing in server since creating
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsIndependentReminderViewController")
            dogsIndependentReminderViewController.forDogId = forDogId
            return
        }
        
        // updating
        AlertManager.beginFetchingInformationIndictator()
        // query for existing
        RemindersRequest.get(invokeErrorManager: true, forDogId: forDogId, forReminder: forReminder) { reminder, responseStatus in
            AlertManager.endFetchingInformationIndictator {
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
    
    // MARK: - IB
    
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet private weak var noDogsRecordedLabel: ScaledUILabel!
    
    @IBAction private func willRefresh(_ sender: Any) {
        self.refreshButton.isEnabled = false
        self.navigationItem.beginTitleViewActivity(forNavigationBarFrame: navigationController?.navigationBar.frame ?? CGRect())
        DogsRequest.get(invokeErrorManager: true, dogManager: dogManager) { newDogManager, _ in
            self.refreshButton.isEnabled = true
            self.navigationItem.endTitleViewActivity(forNavigationBarFrame: self.navigationController?.navigationBar.frame ?? CGRect())
            
            guard let newDogManager = newDogManager else {
                return
            }
            
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshRemindersSubtitle, forStyle: .success)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
        }
        
    }
    
    @IBOutlet private weak var toggleCreateNewMenuButton: ScaledImageWIthBackgroundUIButton!
    
    @IBAction private func toggleCreateNewMenu(_ sender: Any) {
        if createNewMenuIsOpen {
            closeCreateNewMenu()
        }
        else {
            openCreateNewMenu()
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsViewControllerDelegate! = nil
    
    var dogsTableViewController = DogsTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogsIndependentReminderViewController = DogsIndependentReminderViewController()
    
    private let createNewButtonPadding: CGFloat = 10.0
    
    private var createNewMenuIsOpen: Bool = false
    private var createNewMenuScreenDimmer: UIView!
    private var createNewButtons: [ScaledImageWIthBackgroundUIButton] = []
    private var createNewLabels: [ScaledUILabel] = []
    private var createNewBackgroundLabels: [ScaledUILabel] = []
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // possible senders
        // DogsTableViewController
        // DogsAddDogViewController
        // MainTabBarViewController
        
        if !(sender.localized is DogsTableViewController) {
            dogsTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        if (sender.localized is MainTabBarViewController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
            dogsAddDogViewController.navigationController?.popViewController(animated: false)
            dogsIndependentReminderViewController.navigationController?.popViewController(animated: false)
        }
        if !(sender.localized is MainTabBarViewController) {
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
        
        let closeCreateNewMenuTap = UITapGestureRecognizer(target: self, action: #selector(closeCreateNewMenu))
        closeCreateNewMenuTap.delegate = self
        createNewMenuScreenDimmer.addGestureRecognizer(closeCreateNewMenuTap)
        
        self.view.addSubview(createNewMenuScreenDimmer)
        self.view.bringSubviewToFront(toggleCreateNewMenuButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeCreateNewMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    @objc private func willOpenMenu(sender: Any) {
        // The sender could be a UIButton or UIGestureRecognizer (which is attached to a UILabel), so we attempt to unwrap the sender as both
        let tag = (sender as? UIView)?.tag ?? (sender as? UIGestureRecognizer)?.view?.tag ?? 0
        if tag == 0 {
            self.willOpenDogMenu(forDogId: nil)
        }
        else {
            self.willOpenReminderMenu(forDogId: tag, forReminder: nil)
        }
    }
    
    private func openCreateNewMenu() {
        guard createNewMenuIsOpen == false else {
            return
        }
        createNewMenuIsOpen = true
        
        createNewMenuScreenDimmer.isUserInteractionEnabled = true
        refreshButton.isEnabled = false
        
        let toggleCreateNewMenuButtonSmallestDimension: CGFloat = toggleCreateNewMenuButton.frame.width < toggleCreateNewMenuButton.frame.height ? toggleCreateNewMenuButton.frame.width : toggleCreateNewMenuButton.frame.height
        
        let createNewButtonSize: CGFloat = toggleCreateNewMenuButtonSmallestDimension * 0.65
        let totalAvailableYSpaceForCreateNewButtons: CGFloat = toggleCreateNewMenuButton.frame.origin.y - view.safeAreaLayoutGuide.layoutFrame.origin.y
        let maximumNumberOfCreateNewButtons: Int = Int(totalAvailableYSpaceForCreateNewButtons / ( createNewButtonSize + createNewButtonPadding))
        
        let createNewButtonXOrigin = toggleCreateNewMenuButton.frame.maxX - createNewButtonSize
        let createNewButtonYOrigin = toggleCreateNewMenuButton.frame.origin.y - createNewButtonPadding - createNewButtonSize
        
        // Creates the "add new dog" button to tap
        let createNewDogButton = ScaledImageWIthBackgroundUIButton(frame: CGRect(
            x: createNewButtonXOrigin, y: createNewButtonYOrigin,
            width: createNewButtonSize, height: createNewButtonSize))
        createNewDogButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        createNewDogButton.tintColor = .systemBlue
        
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
            
            let createNewReminderButton = ScaledImageWIthBackgroundUIButton(frame: CGRect(
                origin: CGPoint(x: lastCreateNewButton.frame.origin.x, y: lastCreateNewButton.frame.origin.y - createNewButtonPadding - createNewButtonSize),
                size: CGSize(width: createNewButtonSize, height: createNewButtonSize)))
            createNewReminderButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            createNewReminderButton.tintColor = .systemBlue
            
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
        
        view.bringSubviewToFront(toggleCreateNewMenuButton)
        // Animate dimming the screen for when the menu opens and rotate toggleCreateNewMenuButton slightly
        UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewMenuDuration) {
            self.toggleCreateNewMenuButton.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            self.toggleCreateNewMenuButton.tintColor = .systemRed
            
            self.createNewMenuScreenDimmer.alpha = 0.5
            MainTabBarViewController.mainTabBarViewController?.tabBar.alpha = 0.05
            MainTabBarViewController.mainTabBarViewController?.dogsViewController?.navigationController?.navigationBar.alpha = 0.05
        }
        
        // Conceal createNewButton inside of toggleCreateNewMenuButton, then animate them back to their original positions
        createNewButtons.forEach { createNewButton in
            let originalCreateNewButtonOrigin = createNewButton.frame.origin
            
            // move createNewButton vertically so that it sits vertically aligned inside of toggleCreateNewMenuButton. This will conceal createNewButton below toggleCreateNewMenuButton
            createNewButton.frame.origin.y = toggleCreateNewMenuButton.frame.midY - (createNewButton.frame.height / 2)
            // the buttons' right edges slightly stick out under toggleCreateNewMenuButton. Therefore, we must shift them ever so slightly in
            createNewButton.frame.origin.x -= (toggleCreateNewMenuButton.frame.width * 0.025)
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewMenuDuration) {
                createNewButton.frame.origin = originalCreateNewButtonOrigin
            }
        }
        
        // Conceal createNewLabel by shifting it directly right off screen, then animate them back into their original positons
        createNewLabels.forEach { createNewLabel in
            let originalCreateNewLabelOrigin = createNewLabel.frame.origin
            
            // move createNewLabel horizontally so that it sits out of view to the right
            createNewLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewMenuDuration) {
                createNewLabel.frame.origin = originalCreateNewLabelOrigin
            }
        }
        
        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            let originalCreateNewBackgroundLabelOrigin = createNewBackgroundLabel.frame.origin
            
            // move createNewLabel horizontally so that it sits out of view to the right
            createNewBackgroundLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewMenuDuration) {
                createNewBackgroundLabel.frame.origin = originalCreateNewBackgroundLabelOrigin
            }
        }
    }
    
    @objc private func closeCreateNewMenu() {
        guard createNewMenuIsOpen == true else {
            return
        }
        createNewMenuIsOpen = false
        
        createNewMenuScreenDimmer.isUserInteractionEnabled = false
        refreshButton.isEnabled = true
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.openCreateNewMenuDuration) {
            self.toggleCreateNewMenuButton.transform = .identity
            self.toggleCreateNewMenuButton.tintColor = .systemBlue
            self.createNewMenuScreenDimmer.alpha = 0
            MainTabBarViewController.mainTabBarViewController?.tabBar.alpha = 1
            MainTabBarViewController.mainTabBarViewController?.dogsViewController?.navigationController?.navigationBar.alpha = 1
        }
        
        // animate the labels back into origina, opening positions then remove after delay
        createNewButtons.forEach { createNewButton in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewMenuDuration) {
                // move createNewButton vertically so that it sits vertically aligned inside of toggleCreateNewMenuButton. This will conceal createNewButton below toggleCreateNewMenuButton
                createNewButton.frame.origin.y = self.toggleCreateNewMenuButton.frame.midY - (createNewButton.frame.height / 2)
                // the buttons' right edges slightly stick out under toggleCreateNewMenuButton. Therefore, we must shift them ever so slightly in
                createNewButton.frame.origin.x -= (self.toggleCreateNewMenuButton.frame.width * 0.025)
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeCreateNewMenuDelay) {
                    createNewButton.removeFromSuperview()
                }
            }
        }
        
        // animate the labels back into original, opening position then remove after delay
        createNewLabels.forEach { createNewLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewMenuDuration) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeCreateNewMenuDelay) {
                    createNewLabel.removeFromSuperview()
                }
            }
        }
        
        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.closeCreateNewMenuDuration) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewBackgroundLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeCreateNewMenuDelay) {
                    createNewBackgroundLabel.removeFromSuperview()
                }
            }
        }
        
        createNewButtons = []
        createNewLabels = []
        createNewBackgroundLabels = []
    }
    
    private func createCreateAddLabel(relativeToFrame frame: CGRect, text: String) -> ScaledUILabel {
        let createNewLabelSize = text.bounding(font: VisualConstant.FontConstant.semiboldAddDogAddReminderUILabel)
        
        let createNewLabel = ScaledUILabel(frame: CGRect(
            x: frame.origin.x - createNewLabelSize.width,
            y: frame.midY - (createNewLabelSize.height / 2),
            width: createNewLabelSize.width,
            height: createNewLabelSize.height))
        // we can't afford to shrink the label here, already small
        createNewLabel.minimumScaleFactor = 1.0
        createNewLabel.font = VisualConstant.FontConstant.semiboldAddDogAddReminderUILabel
        createNewLabel.text = text
        createNewLabel.textColor = .white
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
