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

final class DogsViewController: GeneralUIViewController, DogsAddDogViewControllerDelegate, DogsTableViewControllerDelegate, DogsAddReminderViewControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Dual Delegate Implementation

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }

    // MARK: - DogsAddReminderViewControllerDelegate

    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder reminder: Reminder) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else {
            return
        }

        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: reminder)

        setDogManager(sender: sender, forDogManager: dogManager)
    }

    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else {
            return
        }

        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: forReminder)

        setDogManager(sender: sender, forDogManager: dogManager)
    }

    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else {
            return
        }

        let dogReminders = dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders

        dogReminders?.removeReminder(forReminderUUID: forReminderUUID)

        setDogManager(sender: sender, forDogManager: dogManager)
    }

    // MARK: - DogsTableViewControllerDelegate

    /// If a dog in DogsTableViewController or Add Dog were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenDogMenu(forDogUUID: UUID?) {
        guard let forDogUUID = forDogUUID, let forDog = dogManager.findDog(forDogUUID: forDogUUID) else {
            let vc = DogsAddDogViewController()
            vc.setup(forDelegate: self, forDogManager: dogManager, forDogToUpdate: nil)
            dogsAddDogViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }

        PresentationManager.beginFetchingInformationIndicator()

        DogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDog: forDog) { newDog, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                
                guard let newDog = newDog else {
                    // If the response was successful but no dog was returned, that means the dog was deleted. Therefore, update the dogManager to indicate as such.
                    self.dogManager.removeDog(forDogUUID: forDogUUID)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    return
                }

                let vc = DogsAddDogViewController()
                vc.setup(forDelegate: self, forDogManager: self.dogManager, forDogToUpdate: newDog)
                self.dogsAddDogViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }

    /// If a reminder in DogsTableViewController or Add Reminder were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenReminderMenu(forDogUUID: UUID, forReminder: Reminder?) {
        guard let forReminder = forReminder else {
            // creating new
            // no need to query as nothing in server since creating
            let vc = DogsAddReminderViewController()
            vc.setup(forDelegate: self, forReminderToUpdateDogUUID: forDogUUID, forReminderToUpdate: forReminder)
            self.dogsAddReminderViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }

        // updating
        PresentationManager.beginFetchingInformationIndicator()
        // query for existing
        RemindersRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminder: forReminder) { reminder, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                guard let reminder = reminder else {
                    // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                    let dogReminders = self.dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders
                    dogReminders?.removeReminder(forReminderUUID: forReminder.reminderUUID)

                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    return
                }

                let vc = DogsAddReminderViewController()
                vc.setup(forDelegate: self, forReminderToUpdateDogUUID: forDogUUID, forReminderToUpdate: reminder)
                self.dogsAddReminderViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }

    func shouldUpdateAlphaForButtons(forAlpha: Double) {
        createNewDogOrReminderButton.alpha = forAlpha
        createNewDogOrReminderButton.isHidden = forAlpha == 0
    }

    // MARK: - Elements
    
    private let dogsTableViewController: DogsTableViewController = DogsTableViewController()

    private let noDogsRecordedLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.isHidden = true
        label.text = "No dogs recorded! Try creating one..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBlue
        return label
    }()

    private let createNewDogOrReminderButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .secondarySystemBackground
        
        return button
    }()

    // MARK: - Properties

    private weak var delegate: DogsViewControllerDelegate?

    private(set) var dogsAddDogViewController: DogsAddDogViewController?

    private(set) var dogsAddReminderViewController: DogsAddReminderViewController?

    private let createNewButtonPadding: CGFloat = 10.0

    private var createNewMenuIsOpen: Bool = false
    private var createNewMenuScreenDimmer: UIView!
    private var createNewButtons: [GeneralUIButton] = []
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
            dogsTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }

        if (sender.localized is MainTabBarController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
            dogsAddDogViewController?.dismiss(animated: false)
            dogsAddReminderViewController?.dismiss(animated: false)
        }
        if !(sender.localized is MainTabBarController) {
            delegate?.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }

        noDogsRecordedLabel.isHidden = !dogManager.dogs.isEmpty
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        dogsTableViewController.setup(forDelegate: self)

        // TODO UIKIT mvoe this logic to the proper place
        let createNewMenuScreenDimmer = UIView(frame: view.frame)
        createNewMenuScreenDimmer.backgroundColor = UIColor.black
        createNewMenuScreenDimmer.isUserInteractionEnabled = false
        createNewMenuScreenDimmer.alpha = 0
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
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsViewControllerDelegate) {
        self.delegate = forDelegate
    }

    // MARK: - Functions
    
    func scrollDogsTableViewControllerToTop() {
        guard let y = dogsTableViewController.referenceContentOffsetY else {
            return
        }
        dogsTableViewController.tableView?.setContentOffset(CGPoint(x: 0, y: y), animated: true)
    }
    
    @objc private func didTouchUpInsideCreateNewDogOrReminder(_ sender: Any) {
        if createNewMenuIsOpen {
            closeCreateNewDogOrReminder()
        }
        else {
            openCreateNewDogOrReminder()
        }
    }

    @objc private func willOpenMenu(sender: Any) {
        // The sender could be a UIButton or UIGestureRecognizer (which is attached to a GeneralUILabel), so we attempt to unwrap the sender as both
        let senderProperties = (sender as? GeneralUIProtocol)?.properties ?? ((sender as? UITapGestureRecognizer)?.view as? GeneralUILabel)?.properties
        let dogUUID = UUID.fromString(forUUIDString: senderProperties?[KeyConstant.dogUUID.rawValue] as? String)
        
        if let dogUUID = dogUUID {
            self.shouldOpenReminderMenu(forDogUUID: dogUUID, forReminder: nil)
        }
        else {
            self.shouldOpenDogMenu(forDogUUID: nil)
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
        let createNewDogButton = GeneralUIButton(frame: CGRect(
            x: createNewButtonXOrigin, y: createNewButtonYOrigin,
            width: createNewButtonSize, height: createNewButtonSize))
        createNewDogButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        createNewDogButton.tintColor = .systemBlue
        createNewDogButton.backgroundCircleTintColor = .systemBackground
        
        // TODO RT make these buttons "create dog, create reminder, and create trigger". if multile dogs, then display dialog to select dog

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

            let createNewReminderButton = GeneralUIButton(frame: CGRect(
                origin: CGPoint(x: lastCreateNewButton.frame.origin.x, y: lastCreateNewButton.frame.origin.y - createNewButtonPadding - createNewButtonSize),
                size: CGSize(width: createNewButtonSize, height: createNewButtonSize)))
            createNewReminderButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            createNewReminderButton.tintColor = .systemBlue
            createNewReminderButton.backgroundCircleTintColor = .systemBackground

            let createNewReminderLabel = createCreateAddLabel(relativeToFrame: createNewReminderButton.frame, text: "Create New Reminder For \(dog.dogName)")
            let createNewReminderLabelBackground = createCreateAddBackgroundLabel(forLabel: createNewReminderLabel)

            createNewReminderButton.properties[KeyConstant.dogUUID.rawValue] = dog.dogUUID.uuidString
            createNewReminderButton.addTarget(self, action: #selector(willOpenMenu(sender:)), for: .touchUpInside)
            
            createNewReminderLabel.properties[KeyConstant.dogUUID.rawValue] = dog.dogUUID.uuidString
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
        let font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
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

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .secondarySystemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        embedChild(dogsTableViewController)
        
        view.addSubview(noDogsRecordedLabel)
        view.addSubview(createNewDogOrReminderButton)
        
        createNewDogOrReminderButton.addTarget(self, action: #selector(didTouchUpInsideCreateNewDogOrReminder), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // McreateNewDogOrReminderButton constraints
        let createNewDogOrReminderBottom = createNewDogOrReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.circleAbsInset)
        let createNewDogOrReminderTrailing = createNewDogOrReminderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.circleAbsInset)
        let createNewDogOrReminderWidthMultiplier = createNewDogOrReminderButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: ConstraintConstant.Button.circleHeightMultiplier)
        createNewDogOrReminderWidthMultiplier.priority = .defaultHigh
        let createNewDogOrReminderMaxWidth = createNewDogOrReminderButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight)
        let createNewDogOrReminderSquare = createNewDogOrReminderButton.createSquareAspectRatio()

        // noDogsRecordedLabel
        let noDogsRecordedLabelTop = noDogsRecordedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let noDogsRecordedLabelBottom = noDogsRecordedLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let noDogsRecordedLabelLeading = noDogsRecordedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let noDogsRecordedLabelTrailing = noDogsRecordedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // dogsTableViewController
        let dogsTableViewControllerViewTop = dogsTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        let dogsTableViewControllerViewBottom = dogsTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let dogsTableViewControllerViewLeading = dogsTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let dogsTableViewControllerViewTrailing = dogsTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            createNewDogOrReminderBottom,
            createNewDogOrReminderTrailing,
            createNewDogOrReminderWidthMultiplier,
            createNewDogOrReminderMaxWidth,
            createNewDogOrReminderSquare,
            
            noDogsRecordedLabelTop,
            noDogsRecordedLabelBottom,
            noDogsRecordedLabelLeading,
            noDogsRecordedLabelTrailing,
            
            dogsTableViewControllerViewTop,
            dogsTableViewControllerViewBottom,
            dogsTableViewControllerViewLeading,
            dogsTableViewControllerViewTrailing
        ])
    }

}
