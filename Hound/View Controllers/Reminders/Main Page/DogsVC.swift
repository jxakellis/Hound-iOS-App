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

final class DogsVC: HoundViewController, DogsAddDogVCDelegate, DogsTableVCDelegate, DogsAddReminderVCDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Dual Delegate Implementation
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - DogsAddReminderVCDelegate
    
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
    
    // MARK: - DogsTableVCDelegate
    
    /// If a dog in DogsTableVC or Add Dog were tapped, invokes this function. Opens up the same page but changes between creating new and editing existing mode.
    func shouldOpenDogMenu(forDogUUID: UUID?) {
        guard let forDogUUID = forDogUUID, let forDog = dogManager.findDog(forDogUUID: forDogUUID) else {
            let vc = DogsAddDogVC()
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
                
                let vc = DogsAddDogVC()
                vc.setup(forDelegate: self, forDogManager: self.dogManager, forDogToUpdate: newDog)
                self.dogsAddDogViewController = vc
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
        
        // TODO RT if a user clicks on a trigger result reminder, tell them they can't edit it
        
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
    
    func shouldUpdateAlphaForButtons(forAlpha: Double) {
        createNewMenuButton.alpha = forAlpha
        createNewMenuButton.isHidden = forAlpha == 0
    }
    
    // MARK: - Elements
    
    private lazy var dogsTableViewController: DogsTableVC = {
        let tableView = DogsTableVC()
        
        tableView.setup(forDelegate: self)
        
        return tableView
    }()
    
    private let noDogsRecordedLabel: HoundLabel = {
        let label = HoundLabel()
        label.isHidden = true
        label.text = "No dogs recorded! Try creating one..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBlue
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
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .secondarySystemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateNew), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createNewDogLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Dog"
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = .systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateDog))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private lazy var createNewDogButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundCircleTintColor = .systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateDog), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createNewReminderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Reminder"
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = .systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateReminder))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private lazy var createNewReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundCircleTintColor = .systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateReminder), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createNewTriggerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Create New Trigger"
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .systemBackground
        label.isUserInteractionEnabled = true
        
        label.backgroundLabelColor = .systemBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCreateTrigger))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private lazy var createNewTriggerButton: HoundButton = {
        let button = HoundButton()
        
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundCircleTintColor = .systemBackground
        
        button.addTarget(self, action: #selector(didSelectCreateTrigger), for: .touchUpInside)
        
        return button
    }()
    
    private var createNewLabelsAndButtons: [(HoundLabel, HoundButton)] {
        return [(createNewDogLabel, createNewDogButton), (createNewReminderLabel, createNewReminderButton), (createNewTriggerLabel, createNewTriggerButton)].reversed()
    }
    
    private var createNewStackVisibleConstraint: NSLayoutConstraint!
    private var createNewStackOffScreenConstraint: NSLayoutConstraint!
    private lazy var createNewLabelsAndButtonsStackView: HoundStackView = {
        let substacks = createNewLabelsAndButtons.map { label, button in
            let substack = HoundStackView(arrangedSubviews: [label, button])
            substack.axis = .horizontal
            substack.distribution = .fill
            substack.alignment = .center
            substack.spacing = ConstraintConstant.Spacing.contentIntraHori
            return substack
        }
        let stack = HoundStackView(arrangedSubviews: substacks)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .trailing
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
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
    
    private(set) var dogsAddDogViewController: DogsAddDogVC?
    
    private(set) var dogsAddReminderViewController: DogsAddReminderVC?
    
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
        guard let y = dogsTableViewController.referenceContentOffsetY else {
            return
        }
        dogsTableViewController.tableView?.setContentOffset(CGPoint(x: 0, y: y), animated: true)
    }
    
    private enum CreateAction {
        case reminder
        case trigger
    }
    
    private func presentDogSelection(forAction: CreateAction) {
        guard dogManager.dogs.isEmpty == false else {
            let bannerTitle = "No Dogs Found"
            PresentationManager.enqueueBanner(forTitle: bannerTitle, forSubtitle: "Create a dog first", forStyle: .info)
            return
        }
        
        let openForDog: (UUID) -> Void = { uuid in
            if forAction == .reminder {
                self.shouldOpenReminderMenu(forDogUUID: uuid, forReminder: nil)
            }
            else {
                // TODO RT implement this
                let alert = UIAlertController(title: "Create Trigger", message: "This feature is not implemented yet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                PresentationManager.enqueueAlert(alert)
            }
        }
        
        if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            openForDog(dog.dogUUID)
            return
        }
        
        let alert = UIAlertController(title: "Select Dog", message: nil, preferredStyle: .alert)
        for dog in dogManager.dogs {
            alert.addAction(UIAlertAction(title: dog.dogName, style: .default) { _ in
                openForDog(dog.dogUUID)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PresentationManager.enqueueAlert(alert)
    }
    
    private func openCreateNewMenu() {
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showMultipleElements) {
            self.createNewMenuButton.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            self.createNewMenuButton.tintColor = .systemRed
            
            self.screenDimmer.alpha = 0.5
            self.tabBarController?.tabBar.alpha = 0.05
            
            self.createNewStackOffScreenConstraint.isActive = false
            self.createNewStackVisibleConstraint.isActive = true
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func closeCreateNewMenu() {
        UIView.animate(withDuration: VisualConstant.AnimationConstant.hideMultipleElements) {
            self.createNewMenuButton.transform = .identity
            self.createNewMenuButton.tintColor = .systemBlue
            
            self.screenDimmer.alpha = 0
            self.tabBarController?.tabBar.alpha = 1
            
            self.createNewStackVisibleConstraint.isActive = false
            self.createNewStackOffScreenConstraint.isActive = true
            
            self.view.layoutIfNeeded()
        }
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
        view.addSubview(screenDimmer)
        
        // need to be after screenDimmer so they arent obscured.
        view.addSubview(createNewLabelsAndButtonsStackView)
        view.addSubview(createNewMenuButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // createNewButtons
        for (_, button) in createNewLabelsAndButtons {
            NSLayoutConstraint.activate([
                button.createSquareAspectRatio(),
                button.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
                button.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight)
            ])
        }
        
        // createNewLabelsAndButtonsStackView
        createNewStackVisibleConstraint = createNewLabelsAndButtonsStackView.trailingAnchor.constraint(equalTo: createNewMenuButton.trailingAnchor)
        createNewStackOffScreenConstraint = createNewLabelsAndButtonsStackView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        createNewStackVisibleConstraint.isActive = false
        createNewStackOffScreenConstraint.isActive = true
        NSLayoutConstraint.activate([
            createNewLabelsAndButtonsStackView.bottomAnchor.constraint(equalTo: createNewMenuButton.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert)
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
            createNewMenuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            createNewMenuButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleHoriInset),
            createNewMenuButton.createSquareAspectRatio(),
            createNewMenuButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            createNewMenuButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight)
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
            noDogsRecordedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            noDogsRecordedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            noDogsRecordedLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
}
