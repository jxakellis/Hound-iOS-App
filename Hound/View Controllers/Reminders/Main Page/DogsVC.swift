//
//  SecondViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class DogsVC: HoundViewController, DogsAddDogVCDelegate, DogsTableVCDelegate, DogsAddReminderVCDelegate, DogsAddTriggerVCDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Dual Delegate Implementation
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - DogsAddReminderVCDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: forReminder)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: forReminder)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID) {
        // forDogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.removeReminder(forReminderUUID: forReminderUUID)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - DogsAddTriggerVCDelegate
    
    func didAddTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger) {
        // forDogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogTriggers.addTrigger(forTrigger: forTrigger)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didUpdateTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger) {
        // forDogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(forDogUUID: forDogUUID)?.dogTriggers.addTrigger(forTrigger: forTrigger)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveTrigger(sender: Sender, forDogUUID: UUID?, forTriggerUUID: UUID) {
        // forDogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a forDogUUID
        guard let forDogUUID = forDogUUID else { return }
        
        dogManager.findDog(forDogUUID: forDogUUID)?.dogTriggers.removeTrigger(forTriggerUUID: forTriggerUUID)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - DogsTableVCDelegate
    
    /// If a dog in DogsTableVC or Add Dog were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenDogMenu(forDogUUID: UUID?) {
        guard let forDogUUID = forDogUUID, let forDog = dogManager.findDog(forDogUUID: forDogUUID) else {
            let vc = DogsAddDogVC()
            vc.setup(forDelegate: self, forDogManager: dogManager, forDogToUpdate: nil)
            dogsDogsAddDogViewController = vc
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
                
                let vc = DogsAddDogVC()
                vc.setup(forDelegate: self, forDogManager: self.dogManager, forDogToUpdate: newDog)
                self.dogsDogsAddDogViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    /// If a reminder in DogsTableVC or Add Reminder were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenReminderMenu(forDogUUID: UUID, forReminder: Reminder?) {
        guard let forReminder = forReminder else {
            // creating new
            // no need to query as nothing in server since creating
            let vc = DogsAddReminderVC()
            vc.setup(forDelegate: self, forReminderToUpdateDogUUID: forDogUUID, forReminderToUpdate: nil)
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
                
                let vc = DogsAddReminderVC()
                vc.setup(forDelegate: self, forReminderToUpdateDogUUID: forDogUUID, forReminderToUpdate: reminder)
                self.dogsAddReminderViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    /// If a trigger in DogsTableVC or Add Trigger were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenTriggerMenu(forDog: Dog, forTrigger: Trigger?) {
        guard let forTrigger = forTrigger else {
            // creating new
            // no need to query as nothing in server since creating
            let vc = DogsAddTriggerVC()
            vc.setupWithServerPersistence(forDelegate: self, forDog: forDog, forTriggerToUpdate: nil)
            self.dogsAddTriggerViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }
        
        // updating
        PresentationManager.beginFetchingInformationIndicator()
        // query for existing
        TriggersRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDog.dogUUID, forTrigger: forTrigger) { trigger, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                guard let trigger = trigger else {
                    // If the response was successful but no trigger was returned, that means the trigger was deleted. Therefore, update the dogManager to indicate as such.
                    let dogTriggers = self.dogManager.findDog(forDogUUID: forDog.dogUUID)?.dogTriggers
                    dogTriggers?.removeTrigger(forTriggerUUID: forTrigger.triggerUUID)
                    
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    return
                }
                
                let vc = DogsAddTriggerVC()
                vc.setupWithServerPersistence(forDelegate: self, forDog: forDog, forTriggerToUpdate: trigger)
                self.dogsAddTriggerViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    func shouldUpdateAlphaForButtons(forAlpha: Double) {
        createNewMenuButton.alpha = forAlpha
        createNewMenuButton.isHidden = forAlpha == 0
    }
    
    // MARK: - Elements
    
    private lazy var dogsTableViewController: DogsTableVC = {
        let tableView = DogsTableVC(style: .grouped)
        
        tableView.setup(forDelegate: self)
        
        return tableView
    }()
    
    private let noDogsRecordedLabel: HoundLabel = {
        let label = HoundLabel()
        label.isHidden = true
        label.text = "No dogs recorded! Try creating one..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.primaryHeaderLabel
        label.textColor = UIColor.systemBlue
        return label
    }()
    
    private lazy var screenDimmer: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.black
        view.isUserInteractionEnabled = false
        view.alpha = 0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeCreateNewMenu))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        
        return view
    }()
    
    private lazy var createNewMenuButton: HoundButton = {
        let button = HoundButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateNew), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createNewDogLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Dog"
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        label.textColor = UIColor.systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = UIColor.systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateDog))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    private lazy var createNewDogButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateDog), for: .touchUpInside)
        
        return button
    }()
    private lazy var createNewDogStack: HoundStackView = {
        let substack = HoundStackView(arrangedSubviews: [createNewDogLabel, createNewDogButton])
        substack.axis = .horizontal
        substack.distribution = .fill
        substack.alignment = .center
        substack.spacing = Constant.Constraint.Spacing.contentIntraHori
        return substack
    }()
    
    private lazy var createNewReminderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Reminder"
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        label.textColor = UIColor.systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = UIColor.systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateReminder))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    private lazy var createNewReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateReminder), for: .touchUpInside)
        
        return button
    }()
    private lazy var createNewReminderStack: HoundStackView = {
        let substack = HoundStackView(arrangedSubviews: [createNewReminderLabel, createNewReminderButton])
        substack.axis = .horizontal
        substack.distribution = .fill
        substack.alignment = .center
        substack.spacing = Constant.Constraint.Spacing.contentIntraHori
        return substack
    }()
    
    private lazy var createNewTriggerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Automation"
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        label.textColor = UIColor.systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = UIColor.systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateTrigger))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    private lazy var createNewTriggerButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateTrigger), for: .touchUpInside)
        
        return button
    }()
    private lazy var createNewTriggerStack: HoundStackView = {
        let substack = HoundStackView(arrangedSubviews: [createNewTriggerLabel, createNewTriggerButton])
        substack.axis = .horizontal
        substack.distribution = .fill
        substack.alignment = .center
        substack.spacing = Constant.Constraint.Spacing.contentIntraHori
        return substack
    }()
    
    private var createNewStackVisibleConstraint: NSLayoutConstraint!
    private var createNewStackOffScreenConstraint: NSLayoutConstraint!
    private lazy var createNewLabelsAndButtonsStackView: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [createNewDogStack, createNewReminderStack, createNewTriggerStack])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .trailing
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didSelectCreateNew() {
        guard !dogManager.dogs.isEmpty else {
            self.shouldOpenDogMenu(forDogUUID: nil)
            return
        }
        
        createNewMenuIsOpen.toggle()
    }
    
    @objc private func didSelectCreateDog() {
        closeCreateNewMenu()
        self.shouldOpenDogMenu(forDogUUID: nil)
    }
    
    @objc private func didSelectCreateReminder() {
        closeCreateNewMenu()
        presentDogSelection(forAction: .reminder)
    }
    
    @objc private func didSelectCreateTrigger() {
        closeCreateNewMenu()
        presentDogSelection(forAction: .trigger)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsVCDelegate?
    
    private(set) var dogsDogsAddDogViewController: DogsAddDogVC?
    
    private(set) var dogsAddReminderViewController: DogsAddReminderVC?
    private(set) var dogsAddTriggerViewController: DogsAddTriggerVC?
    
    private var createNewMenuIsOpen: Bool = false {
        didSet {
            if createNewMenuIsOpen {
                screenDimmer.isUserInteractionEnabled = true
                openCreateNewMenu()
            }
            else {
                screenDimmer.isUserInteractionEnabled = false
                closeCreateNewMenu()
            }
        }
    }
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // possible senders
        // DogsTableVC
        // DogsAddDogVC
        // MainTabBarController
        
        if !(sender.localized is DogsTableVC) {
            dogsTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        if (sender.localized is MainTabBarController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
            dogsDogsAddDogViewController?.dismiss(animated: false)
            dogsAddReminderViewController?.dismiss(animated: false)
            dogsAddTriggerViewController?.dismiss(animated: false)
        }
        if !(sender.localized is MainTabBarController) {
            delegate?.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        noDogsRecordedLabel.isHidden = !dogManager.dogs.isEmpty
        createNewReminderStack.isHidden = dogManager.dogs.isEmpty
        createNewTriggerStack.isHidden = dogManager.dogs.isEmpty
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeCreateNewMenu()
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Functions
    
    func scrollDogsTableViewControllerToTop() {
        guard let y = dogsTableViewController.referenceContentOffsetY else { return }
        dogsTableViewController.tableView?.setContentOffset(CGPoint(x: 0, y: y), animated: true)
    }
    
    private enum CreateAction {
        case reminder
        case trigger
    }
    
    private func presentDogSelection(forAction: CreateAction) {
        guard dogManager.dogs.isEmpty == false else {
            return
        }
        
        let openForDog: (Dog) -> Void = { dog in
            if forAction == .reminder {
                let numNonTriggerReminders = dog.dogReminders.dogReminders.count(where: { $0.reminderIsTriggerResult == false })
                
                guard numNonTriggerReminders < Constant.Class.Dog.maximumNumberOfReminders else {
                    PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.noAddMoreRemindersTitle, forSubtitle: Constant.Visual.BannerText.noAddMoreRemindersSubtitle, forStyle: .warning)
                    return
                }
                
                self.shouldOpenReminderMenu(forDogUUID: dog.dogUUID, forReminder: nil)
            }
            else {
                let numTriggers = dog.dogTriggers.dogTriggers.count
                
                guard numTriggers < Constant.Class.Dog.maximumNumberOfTriggers else {
                    PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.noAddMoreTriggersTitle, forSubtitle: Constant.Visual.BannerText.noAddMoreTriggersSubtitle, forStyle: .warning)
                    return
                }
                
                self.shouldOpenTriggerMenu(forDog: dog, forTrigger: nil)
            }
        }
        
        if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            openForDog(dog)
            return
        }
        
        let alert = UIAlertController(title: forAction == .reminder ? "Add Reminder to Dog" : "Add Automation to Dog", message: nil, preferredStyle: .alert)
        for dog in dogManager.dogs {
            alert.addAction(UIAlertAction(title: dog.dogName, style: .default) { _ in
                openForDog(dog)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PresentationManager.enqueueAlert(alert)
    }
    
    private func openCreateNewMenu() {
        UIView.animate(withDuration: Constant.Visual.Animation.showMultipleElements) {
            self.createNewMenuButton.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            self.createNewMenuButton.tintColor = UIColor.systemRed
            
            self.screenDimmer.alpha = 0.5
            self.tabBarController?.tabBar.alpha = 0.25
            
            self.createNewStackOffScreenConstraint.isActive = false
            self.createNewStackVisibleConstraint.isActive = true
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func closeCreateNewMenu() {
        UIView.animate(withDuration: Constant.Visual.Animation.hideMultipleElements) {
            self.createNewMenuButton.transform = .identity
            self.createNewMenuButton.tintColor = UIColor.systemBlue
            
            self.screenDimmer.alpha = 0
            self.tabBarController?.tabBar.alpha = 1
            
            self.createNewStackVisibleConstraint.isActive = false
            self.createNewStackOffScreenConstraint.isActive = true
            
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        embedChild(dogsTableViewController)
        
        view.addSubview(noDogsRecordedLabel)
        view.addSubview(screenDimmer)
        
        // need to be after screenDimmer so they arent obscured.
        view.addSubview(createNewLabelsAndButtonsStackView)
        view.addSubview(createNewMenuButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // createNewButtons
        for button in [createNewDogButton, createNewReminderButton, createNewTriggerButton] {
            NSLayoutConstraint.activate([
                button.createSquareAspectRatio(),
                button.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
                button.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight)
            ])
        }
        
        // createNewLabelsAndButtonsStackView
        createNewStackVisibleConstraint = createNewLabelsAndButtonsStackView.trailingAnchor.constraint(equalTo: createNewMenuButton.trailingAnchor)
        createNewStackOffScreenConstraint = createNewLabelsAndButtonsStackView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        createNewStackVisibleConstraint.isActive = false
        createNewStackOffScreenConstraint.isActive = true
        NSLayoutConstraint.activate([
            createNewLabelsAndButtonsStackView.bottomAnchor.constraint(equalTo: createNewMenuButton.topAnchor, constant: -Constant.Constraint.Spacing.contentIntraVert)
        ])
        
        // logsTableViewController.view
        NSLayoutConstraint.activate([
            dogsTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            dogsTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dogsTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dogsTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // createNewMenuButton
        NSLayoutConstraint.activate([
            createNewMenuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            createNewMenuButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            createNewMenuButton.createSquareAspectRatio(),
            createNewMenuButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            createNewMenuButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight)
        ])
        
        // screenDimmer
        NSLayoutConstraint.activate([
            screenDimmer.topAnchor.constraint(equalTo: view.topAnchor),
            screenDimmer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            screenDimmer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            screenDimmer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // noLogsRecordedLabel
        NSLayoutConstraint.activate([
            noDogsRecordedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            noDogsRecordedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            noDogsRecordedLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
}
