//
//  SecondViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
}

final class DogsVC: HoundViewController, DogsAddDogVCDelegate, DogsTableVCDelegate, DogsAddReminderVCDelegate, DogsAddTriggerVCDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Dual Delegate Implementation
    
    func didUpdateDogManager(sender: Sender, dogManager: DogManager) {
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    // MARK: - DogsAddReminderVCDelegate
    
    func didAddReminder(sender: Sender, dogUUID: UUID?, reminder: Reminder) {
        // dogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminder(reminder: reminder)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    func didUpdateReminder(sender: Sender, dogUUID: UUID?, reminder: Reminder) {
        // dogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminder(reminder: reminder)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, dogUUID: UUID?, reminderUUID: UUID) {
        // dogUUID must be defined, as we are either adding a reminder to some existing dog or creating a reminder for an existing dog. Only DogsAddDogVC can use dogsAddReminderViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        dogManager.findDog(dogUUID: dogUUID)?.dogReminders.removeReminder(reminderUUID: reminderUUID)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    // MARK: - DogsAddTriggerVCDelegate
    
    func didAddTrigger(sender: Sender, dogUUID: UUID?, trigger: Trigger) {
        // dogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(dogUUID: dogUUID)?.dogTriggers.addTrigger(trigger: trigger)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    func didUpdateTrigger(sender: Sender, dogUUID: UUID?, trigger: Trigger) {
        // dogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        // Since our reminder was already created by the server, we don't need to worry about placeholderIds. Simply add the reminder and DogReminderManager handles it
        dogManager.findDog(dogUUID: dogUUID)?.dogTriggers.addTrigger(trigger: trigger)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    func didRemoveTrigger(sender: Sender, dogUUID: UUID?, triggerUUID: UUID) {
        // dogUUID must be defined, as we are either adding a trigger to some existing dog or creating a trigger for an existing dog. Only DogsAddDogVC can use dogsAddTriggerViewController without a dogUUID
        guard let dogUUID = dogUUID else { return }
        
        dogManager.findDog(dogUUID: dogUUID)?.dogTriggers.removeTrigger(triggerUUID: triggerUUID)
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    // MARK: - DogsTableVCDelegate
    
    /// If a dog in DogsTableVC or Add Dog were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenDogMenu(dogUUID: UUID?) {
        guard let dogUUID = dogUUID, let dog = dogManager.findDog(dogUUID: dogUUID) else {
            let vc = DogsAddDogVC()
            vc.setup(delegate: self, dogManager: dogManager, dogToUpdate: nil)
            dogsAddDogViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }
        
        PresentationManager.beginFetchingInformationIndicator()
        
        DogsRequest.get(errorAlert: .automaticallyAlertOnlyForFailure, dog: dog) { newDog, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                
                guard let newDog = newDog else {
                    // If the response was successful but no dog was returned, that means the dog was deleted. Therefore, update the dogManager to indicate as such.
                    self.dogManager.removeDog(dogUUID: dogUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    return
                }
                
                let vc = DogsAddDogVC()
                vc.setup(delegate: self, dogManager: self.dogManager, dogToUpdate: newDog)
                self.dogsAddDogViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    /// If a reminder in DogsTableVC or Add Reminder were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenReminderMenu(dogUUID: UUID, reminder: Reminder?) {
        guard let reminder = reminder else {
            // creating new
            // no need to query as nothing in server since creating
            let vc = DogsAddReminderVC()
            vc.setup(delegate: self, reminderToUpdateDogUUID: dogUUID, reminderToUpdate: nil)
            self.dogsAddReminderViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }
        
        // updating
        PresentationManager.beginFetchingInformationIndicator()
        // query for existing
        RemindersRequest.get(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminder: reminder) { responseReminder, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                guard let responseReminder = responseReminder else {
                    // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                    let dogReminders = self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders
                    dogReminders?.removeReminder(reminderUUID: reminder.reminderUUID)
                    
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    return
                }
                
                let vc = DogsAddReminderVC()
                vc.setup(delegate: self, reminderToUpdateDogUUID: dogUUID, reminderToUpdate: responseReminder)
                self.dogsAddReminderViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    /// If a trigger in DogsTableVC or Add Trigger were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenTriggerMenu(dog: Dog, trigger: Trigger?) {
        guard let trigger = trigger else {
            // creating new
            // no need to query as nothing in server since creating
            let vc = DogsAddTriggerVC()
            vc.setupWithServerPersistence(delegate: self, dog: dog, triggerToUpdate: nil)
            self.dogsAddTriggerViewController = vc
            PresentationManager.enqueueViewController(vc)
            return
        }
        
        // updating
        PresentationManager.beginFetchingInformationIndicator()
        // query for existing
        TriggersRequest.get(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dog.dogUUID, trigger: trigger) { responseTrigger, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus != .failureResponse else {
                    return
                }
                guard let responseTrigger = responseTrigger else {
                    // If the response was successful but no trigger was returned, that means the trigger was deleted. Therefore, update the dogManager to indicate as such.
                    let dogTriggers = self.dogManager.findDog(dogUUID: dog.dogUUID)?.dogTriggers
                    dogTriggers?.removeTrigger(triggerUUID: trigger.triggerUUID)
                    
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    return
                }
                
                let vc = DogsAddTriggerVC()
                vc.setupWithServerPersistence(delegate: self, dog: dog, triggerToUpdate: responseTrigger)
                self.dogsAddTriggerViewController = vc
                PresentationManager.enqueueViewController(vc)
            }
        }
    }
    
    func shouldUpdateAlphaForButtons(alpha: Double) {
        createNewMenuButton.alpha = alpha
        createNewMenuButton.isHidden = alpha == 0
    }
    
    // MARK: - Elements
    
    private lazy var dogsTableViewController: DogsTableVC = {
        let tableView = DogsTableVC(style: .grouped)
        
        tableView.setup(delegate: self)
        
        return tableView
    }()
    
    private let noDogsRecordedLabel: HoundLabel = {
        let label = HoundLabel()
        label.isHidden = true
        label.text = "No dogs created yet!\n\nTry creating one..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryHeaderLabel
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
            self.shouldOpenDogMenu(dogUUID: nil)
            return
        }
        
        createNewMenuIsOpen.toggle()
    }
    
    @objc private func didSelectCreateDog() {
        closeCreateNewMenu()
        self.shouldOpenDogMenu(dogUUID: nil)
    }
    
    @objc private func didSelectCreateReminder() {
        closeCreateNewMenu()
        presentDogSelection(action: .reminder)
    }
    
    @objc private func didSelectCreateTrigger() {
        closeCreateNewMenu()
        presentDogSelection(action: .trigger)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsVCDelegate?
    
    private(set) var dogsAddDogViewController: DogsAddDogVC?
    
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
    
    func setDogManager(sender: Sender, dogManager: DogManager) {
        self.dogManager = dogManager
        
        // possible senders
        // DogsTableVC
        // DogsAddDogVC
        // MainTabBarController
        
        if !(sender.lastLocation is DogsTableVC) {
            dogsTableViewController.setDogManager(sender: Sender(source: sender, lastLocation: self), dogManager: dogManager)
        }
        
        if (sender.lastLocation is MainTabBarController) == true {
            // main tab bar view controller could have performed a dog manager refresh, meaning the open modification page is invalid
//            dogsAddDogViewController?.dismiss(animated: false)
//            dogsAddReminderViewController?.dismiss(animated: false)
//            dogsAddTriggerViewController?.dismiss(animated: false)
        }
        if !(sender.lastLocation is MainTabBarController) {
            delegate?.didUpdateDogManager(sender: Sender(source: sender, lastLocation: self), dogManager: dogManager)
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
    
    func setup(delegate: DogsVCDelegate) {
        self.delegate = delegate
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
    
    private func presentDogSelection(action: CreateAction) {
        guard dogManager.dogs.isEmpty == false else {
            return
        }
        
        let openForDog: (Dog) -> Void = { dog in
            if action == .reminder {
                let numNonTriggerReminders = dog.dogReminders.dogReminders.count(where: { $0.reminderIsTriggerResult == false })
                
                guard numNonTriggerReminders < Constant.Class.Dog.maximumNumberOfReminders else {
                    PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.noAddMoreRemindersTitle, subtitle: Constant.Visual.BannerText.noAddMoreRemindersSubtitle, style: .warning)
                    return
                }
                
                self.shouldOpenReminderMenu(dogUUID: dog.dogUUID, reminder: nil)
            }
            else {
                let numTriggers = dog.dogTriggers.dogTriggers.count
                
                guard numTriggers < Constant.Class.Dog.maximumNumberOfTriggers else {
                    PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.noAddMoreTriggersTitle, subtitle: Constant.Visual.BannerText.noAddMoreTriggersSubtitle, style: .warning)
                    return
                }
                
                self.shouldOpenTriggerMenu(dog: dog, trigger: nil)
            }
        }
        
        if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            openForDog(dog)
            return
        }
        
        let alert = UIAlertController(title: action == .reminder ? "Add Reminder" : "Add Automation", message: nil, preferredStyle: .alert)
        for dog in dogManager.dogs {
            alert.addAction(UIAlertAction(title: dog.dogName, style: .default) { _ in
                openForDog(dog)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PresentationManager.enqueueAlert(alert)
    }
    
    private func openCreateNewMenu() {
        guard isViewLoaded else { return }
        UIView.animate(withDuration: Constant.Visual.Animation.showMultipleElements) { [weak self] in
            guard let self = self else { return }
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
        guard isViewLoaded else { return }
        UIView.animate(withDuration: Constant.Visual.Animation.hideMultipleElements) { [weak self] in
            guard let self = self else { return }
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
                button.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
                button.createMaxHeight(Constant.Constraint.Button.circleMaxHeight)
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
            createNewMenuButton.createHeightMultiplier(Constant.Constraint.Button.largeCircleHeightMultiplier, relativeToWidthOf: view),
            createNewMenuButton.createMaxHeight(Constant.Constraint.Button.largeCircleMaxHeight)
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
