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

final class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate, DogsTableViewControllerDelegate, DogsAddReminderViewControllerDelegate, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: - Dual Delegate Implementation

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }

    // MARK: - DogsAddReminderViewControllerDelegate

    func didAddReminder(sender: Sender, forDogId: Int?, forReminder reminder: Reminder) {
        // forDogId must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogId
        guard let forDogId = forDogId else {
            return
        }

        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and ReminderManager handles it
        dogManager.findDog(forDogId: forDogId)?.dogReminders.addReminder(forReminder: reminder)

        setDogManager(sender: sender, forDogManager: dogManager)

        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }

    func didUpdateReminder(sender: Sender, forDogId: Int?, forReminder: Reminder) {
        // forDogId must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogId
        guard let forDogId = forDogId else {
            return
        }

        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and ReminderManager handles it
        dogManager.findDog(forDogId: forDogId)?.dogReminders.addReminder(forReminder: forReminder)

        setDogManager(sender: sender, forDogManager: dogManager)

        CheckManager.checkForReview()
        CheckManager.checkForShareHound()
    }

    func didRemoveReminder(sender: Sender, forDogId: Int?, forReminderId: Int) {
        // forDogId must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogId
        guard let forDogId = forDogId else {
            return
        }

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

        DogsRequest.get(invokeErrorManager: true, dog: currentDog) { newDog, responseStatus, _ in
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

                self.dogsAddDogViewControllerDogToUpdate = newDog
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddDogViewController")
            }
        }
    }

    /// If a reminder in DogsTableViewController or Add Reminder were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenReminderMenu(forDogId: Int, forReminder: Reminder?) {
        guard let forReminder = forReminder else {
            // creating new
            // no need to query as nothing in server since creating
            dogsAddReminderViewControllerParentDogId = forDogId
            dogsAddReminderViewControllerReminderToUpdate = forReminder
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddReminderViewController")
            return
        }

        // updating
        PresentationManager.beginFetchingInformationIndictator()
        // query for existing
        RemindersRequest.get(invokeErrorManager: true, forDogId: forDogId, forReminder: forReminder) { reminder, responseStatus, _ in
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

                self.dogsAddReminderViewControllerParentDogId = forDogId
                self.dogsAddReminderViewControllerReminderToUpdate = reminder
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddReminderViewController")
            }
        }
    }

    func didUpdateAlphaForButtons(forAlpha: Double) {
        createNewDogOrReminderButton.alpha = forAlpha
        createNewDogOrReminderButton.isHidden = forAlpha == 0
    }

    // MARK: - IB

    @IBOutlet private weak var noDogsRecordedLabel: GeneralUILabel!

    @IBOutlet private weak var createNewDogOrReminderButton: GeneralWithBackgroundUIButton!
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

    private(set) var dogsTableViewController: DogsTableViewController?

    private var dogsAddDogViewControllerDogToUpdate: Dog?
    private(set) var dogsAddDogViewController: DogsAddDogViewController?

    private var dogsAddReminderViewControllerParentDogId: Int?
    private var dogsAddReminderViewControllerReminderToUpdate: Reminder?
    private(set) var dogsAddReminderViewController: DogsAddReminderViewController?

    private let createNewButtonPadding: CGFloat = 10.0

    private var createNewMenuIsOpen: Bool = false
    private var createNewMenuScreenDimmer: UIView!
    private var createNewButtons: [GeneralWithBackgroundUIButton] = []
    private var createNewLabels: [GeneralUILabel] = []
    private var createNewBackgroundLabels: [GeneralUILabel] = []

    // MARK: - Dog Manager

    private(set) var dogManager = DogManager()

    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager

        // possible senders
        // DogsTableViewController
        // DogsAddDogViewController
        // MainTabBarController

        if !(sender.localized is DogsTableViewController) {
            dogsTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }

        if (sender.localized is MainTabBarController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
            dogsAddDogViewController?.dismiss(animated: false)
            dogsAddReminderViewController?.dismiss(animated: false)
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
        let createNewDogButton = GeneralWithBackgroundUIButton(frame: CGRect(
            x: createNewButtonXOrigin, y: createNewButtonYOrigin,
            width: createNewButtonSize, height: createNewButtonSize))
        createNewDogButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        createNewDogButton.tintColor = .systemBlue
        createNewDogButton.shouldScaleImagePointSize = true
        createNewDogButton.backgroundUIButtonTintColor = .systemBackground

        let createNewDogLabel = createCreateAddLabel(relativeToFrame: createNewDogButton.frame, text: "Create New Dog")
        let createNewDogLabelBackground = createCreateAddBackgroundLabel(forLabel: createNewDogLabel)

        createNewDogButton.addTarget(self, action: #selector(willOpenMenu(sender:)), for: .touchUpInside)
        createNewDogLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willOpenMenu(sender:))))

        view.insertSubview(createNewDogLabelBackground, belowSubview: createNewDogOrReminderButton)
        view.insertSubview(createNewDogLabel, belowSubview: createNewDogOrReminderButton)
        view.insertSubview(createNewDogButton, belowSubview: createNewDogOrReminderButton)
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

            let createNewReminderButton = GeneralWithBackgroundUIButton(frame: CGRect(
                origin: CGPoint(x: lastCreateNewButton.frame.origin.x, y: lastCreateNewButton.frame.origin.y - createNewButtonPadding - createNewButtonSize),
                size: CGSize(width: createNewButtonSize, height: createNewButtonSize)))
            createNewReminderButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            createNewReminderButton.tintColor = .systemBlue
            createNewReminderButton.shouldScaleImagePointSize = true
            createNewReminderButton.backgroundUIButtonTintColor = .systemBackground

            let createNewReminderLabel = createCreateAddLabel(relativeToFrame: createNewReminderButton.frame, text: "Create New Reminder For \(dog.dogName)")
            let createNewReminderLabelBackground = createCreateAddBackgroundLabel(forLabel: createNewReminderLabel)

            createNewReminderButton.tag = dog.dogId
            createNewReminderButton.addTarget(self, action: #selector(willOpenMenu(sender:)), for: .touchUpInside)
            createNewReminderLabel.tag = dog.dogId
            createNewReminderLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willOpenMenu(sender:))))

            view.insertSubview(createNewReminderLabelBackground, belowSubview: createNewDogOrReminderButton)
            view.insertSubview(createNewReminderLabel, belowSubview: createNewDogOrReminderButton)
            view.insertSubview(createNewReminderButton, belowSubview: createNewDogOrReminderButton)

            createNewBackgroundLabels.append(createNewReminderLabelBackground)
            createNewLabels.append(createNewReminderLabel)
            createNewButtons.append(createNewReminderButton)
        }

        // Animate dimming the screen for when the menu opens and rotate createNewDogOrReminderButton slightly
        UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
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

            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
                createNewButton.frame.origin = originalCreateNewButtonOrigin
            }
        }

        // Conceal createNewLabel by shifting it directly right off screen, then animate them back into their original positons
        createNewLabels.forEach { createNewLabel in
            let originalCreateNewLabelOrigin = createNewLabel.frame.origin

            // move createNewLabel horizontally so that it sits out of view to the right
            createNewLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX

            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
                createNewLabel.frame.origin = originalCreateNewLabelOrigin
            }
        }

        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            let originalCreateNewBackgroundLabelOrigin = createNewBackgroundLabel.frame.origin

            // move createNewLabel horizontally so that it sits out of view to the right
            createNewBackgroundLabel.frame.origin.x = view.safeAreaLayoutGuide.layoutFrame.maxX

            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
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

        UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
            self.createNewDogOrReminderButton.transform = .identity
            self.createNewDogOrReminderButton.tintColor = .systemBlue
            self.createNewMenuScreenDimmer.alpha = 0

            self.tabBarController?.tabBar.alpha = 1
        }

        // animate the labels back into origina, opening positions then remove after delay
        createNewButtons.forEach { createNewButton in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
                // move createNewButton vertically so that it sits vertically aligned inside of createNewDogOrReminderButton. This will conceal createNewButton below createNewDogOrReminderButton
                createNewButton.frame.origin.y = self.createNewDogOrReminderButton.frame.midY - (createNewButton.frame.height / 2)
                // the buttons' right edges slightly stick out under createNewDogOrReminderButton. Therefore, we must shift them ever so slightly in
                createNewButton.frame.origin.x -= (self.createNewDogOrReminderButton.frame.width * 0.025)

            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeFromViewCreateNewDogOrReminderDelay) {
                    createNewButton.removeFromSuperview()
                }
            }
        }

        // animate the labels back into original, opening position then remove after delay
        createNewLabels.forEach { createNewLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX

            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeFromViewCreateNewDogOrReminderDelay) {
                    createNewLabel.removeFromSuperview()
                }
            }
        }

        // same as above
        createNewBackgroundLabels.forEach { createNewBackgroundLabel in
            UIView.animate(withDuration: VisualConstant.AnimationConstant.openOrCloseCreateNewDogOrReminder) {
                // move createNewLabel horizontally so that it sits out of view to the right
                createNewBackgroundLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX

            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + VisualConstant.AnimationConstant.removeFromViewCreateNewDogOrReminderDelay) {
                    createNewBackgroundLabel.removeFromSuperview()
                }
            }
        }

        createNewButtons = []
        createNewLabels = []
        createNewBackgroundLabels = []
    }

    private func createCreateAddLabel(relativeToFrame frame: CGRect, text: String) -> GeneralUILabel {
        let font = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        let createNewLabelSize = text.bounding(font: font)

        let createNewLabel = GeneralUILabel(frame: CGRect(
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

    private func createCreateAddBackgroundLabel(forLabel label: GeneralUILabel) -> GeneralUILabel {
        let createNewBackgroundLabel = GeneralUILabel(frame: label.frame)
        // we can't afford to shrink the label here, already small
        createNewBackgroundLabel.minimumScaleFactor = 1.0

        let precalculatedDynamicText = label.text ?? ""
        let precalculatedDynamicFont = label.font
        createNewBackgroundLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            return NSAttributedString(string: precalculatedDynamicText, attributes: [
                .strokeColor: UIColor.systemBlue,
                .foregroundColor: UIColor.systemBlue,
                .strokeWidth: 15.0,
                .font: precalculatedDynamicFont as Any
            ])
        }

        createNewBackgroundLabel.isUserInteractionEnabled = false

        return createNewBackgroundLabel
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddDogViewController = segue.destination as? DogsAddDogViewController {
            self.dogsAddDogViewController = dogsAddDogViewController
            dogsAddDogViewController.setup(forDelegate: self, forDogManager: dogManager, forDogToUpdate: dogsAddDogViewControllerDogToUpdate)

            dogsAddDogViewControllerDogToUpdate = nil
        }
        else if let dogsTableViewController = segue.destination as? DogsTableViewController {
            self.dogsTableViewController = dogsTableViewController
            dogsTableViewController.delegate = self

            dogsTableViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let dogsAddReminderViewController = segue.destination as? DogsAddReminderViewController {
            self.dogsAddReminderViewController = dogsAddReminderViewController
            // dogsAddReminderViewControllerParentDogId must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a parentDogId
            if let dogsAddReminderViewControllerParentDogId = dogsAddReminderViewControllerParentDogId {
                dogsAddReminderViewController.setup(forDelegate: self, forParentDogId: dogsAddReminderViewControllerParentDogId, forReminderToUpdate: dogsAddReminderViewControllerReminderToUpdate)

                self.dogsAddReminderViewControllerParentDogId = nil
                self.dogsAddReminderViewControllerReminderToUpdate = nil
            }

        }
    }

}
