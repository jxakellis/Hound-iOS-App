//
//  DogsAddDogVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class DogsAddDogVC: HoundScrollViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DogsAddReminderVCDelegate, DogsAddTriggerVCDelegate, DogsAddDogRemindersViewDelegate, DogsAddDogTriggersViewDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forInfo: info) {
            self.dogIconButton.setTitle(nil, for: .normal)
            self.dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // attempt to read the range they are trying to change
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under dogNameCharacterLimit
        return updatedText.count <= ClassConstant.DogConstant.dogNameCharacterLimit
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - DogsAddDogRemindersViewDelegate
    
    func shouldOpenAddReminderVC(forReminder: Reminder?) {
        let vc = DogsAddReminderVC()
        /// DogsAddDogVC takes care of all server communication when, and if, the user decides to save their changes to the dog. Therefore, we don't provide a reminderToUpdateDogUUID to dogsAddReminderViewController, as otherwise it would contact and update the server.
        vc.setup(forDelegate: self, forReminderToUpdateDogUUID: nil, forReminderToUpdate: forReminder)
        PresentationManager.enqueueViewController(vc)
    }
    
    // MARK: - DogsAddDogTriggersViewDelegate
    
    func shouldOpenAddTriggerVC(forTrigger: Trigger?) {
        let vc = DogsAddTriggerVC()
        /// DogsAddDogVC takes care of all server communication when, and if, the user decides to save their changes to the dog. Therefore, we don't provide a reminderToUpdateDogUUID to dogsAddReminderViewController, as otherwise it would contact and update the server.
        vc.setupWithoutServerPersistence(forDelegate: self, forDog: dogToUpdate, forTriggerToUpdate: forTrigger)
        PresentationManager.enqueueViewController(vc)
    }
    
    // MARK: - DogsAddReminderVCDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        self.remindersView.didAddReminder(forReminder: forReminder)
    }
    
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        self.remindersView.didUpdateReminder(forReminder: forReminder)
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID) {
        self.remindersView.didRemoveReminder(forReminderUUID: forReminderUUID)
    }
    
    // MARK: - DogsAddTriggerVCDelegate
    
    func didAddTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger) {
        self.triggersView.didAddTrigger(forTrigger: forTrigger)
    }
    
    func didUpdateTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger) {
        self.triggersView.didUpdateTrigger(forTrigger: forTrigger)
    }
    
    func didRemoveTrigger(sender: Sender, forDogUUID: UUID?, forTriggerUUID: UUID) {
        self.triggersView.didRemoveTrigger(forTriggerUUID: forTriggerUUID)
    }
    
    // MARK: - Elements
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 330, compressionResistancePriority: 330)
        
        view.trailingButton.isHidden = false
        view.trailingButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveDog), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var dogNameTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 290, compressionResistancePriority: 290)
        textField.delegate = self
        
        textField.placeholder = "Enter your dog's name..."
        textField.backgroundColor = UIColor.systemBackground
        
        textField.applyStyle(.thinGrayBorder)
        
        return textField
    }()
    
    private lazy var dogIconButton: HoundButton = {
        let button = HoundButton(huggingPriority: 290, compressionResistancePriority: 290)
        
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.secondaryHeaderLabel
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.thinGrayBorder)
        
        button.addTarget(self, action: #selector(didTouchUpInsideDogIcon), for: .touchUpInside)
        
        return button
    }()
    
    private enum SegmentedControlSection: Int, CaseIterable {
        case reminders
        case triggers

        var title: String {
            switch self {
            case .reminders: return "Reminders"
            case .triggers: return "Automations"
            }
        }

        static func index(of section: SegmentedControlSection) -> Int { section.rawValue }
    }
    
    private lazy var segmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        SegmentedControlSection.allCases.enumerated().forEach { index, section in
            segmentedControl.insertSegment(withTitle: section.title, at: index, animated: false)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel,
            .foregroundColor: UIColor.systemBackground
        ]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        
        segmentedControl.selectedSegmentIndex = SegmentedControlSection.reminders.rawValue
        segmentedControl.apportionsSegmentWidthsByContent = false
        
        segmentedControl.addTarget(self, action: #selector(didUpdateSegment), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var remindersView: DogsAddDogRemindersView = {
        let view = DogsAddDogRemindersView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.reminders.rawValue
        return view
    }()
    
    private lazy var triggersView: DogsAddDogTriggersView = {
        let view = DogsAddDogTriggersView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.triggers.rawValue
        return view
    }()
    
        private lazy var tableViewsStack: HoundStackView = {
            let stack = HoundStackView(arrangedSubviews: [remindersView, triggersView])
            stack.axis = .vertical
            stack.spacing = ConstraintConstant.Spacing.contentIntraVert
            return stack
        }()
    
    private lazy var saveDogButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideSaveDog), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = UIColor.systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideDismissPage), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    @objc private func didTouchUpInsideRemoveDog(_ sender: Any) {
        guard let dogToUpdate = dogToUpdate else { return }
        
        let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogNameTextField.text ?? dogToUpdate.dogName)?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogToUpdate.dogUUID) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }
                
                self.dogManager?.removeDog(forDogUUID: dogToUpdate.dogUUID)
                
                if let dogManager = self.dogManager {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                
                self.dismiss(animated: true)
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(removeAlertAction)
        removeDogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeDogConfirmation)
    }
    
    @objc private func didUpdateSegment(_ sender: UISegmentedControl) {
        remindersView.isHidden = sender.selectedSegmentIndex != SegmentedControlSection.reminders.rawValue
        triggersView.isHidden = sender.selectedSegmentIndex != SegmentedControlSection.triggers.rawValue
        }
    
    // When the add button is tapped, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsVC.
    @objc private func didTouchUpInsideSaveDog(_ sender: Any) {
        // could be new dog or updated one
        var dog: Dog!
        do {
            // try to initialize from a passed dog, if non exists, then we make a new one
            dog = try dogToUpdate ?? Dog(forDogName: dogNameTextField.text)
            try dog.changeDogName(forDogName: dogNameTextField.text)
            // DogsRequest handles .addIcon and .removeIcon.
            dog.dogIcon = dogIconButton.imageView?.image
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown().alert()
            return
        }
        
        saveDogButton.isLoading = true
        
        let initialReminders = remindersView.initialReminders.dogReminders
        let currentReminders = remindersView.dogReminders.dogReminders
        let createdReminders = currentReminders.filter({ currentReminder in
            // Reminders that were just created have no reminderId
            // If a reminder was created in offline mode already, it would have no reminderId. Therefore, being classified as a created reminder. This is inaccurate, but doesn't matter, as the same flag for offline mode will be set to true again.
            return currentReminder.reminderId == nil
        })
        
        createdReminders.forEach { reminder in
            reminder.resetForNextAlarm()
        }
        
        let updatedReminders = currentReminders.filter { currentReminder in
            // The reminder needs to have already been created on the Hound server
            guard currentReminder.reminderId != nil else {
                return false
            }
            
            // Reminders that were updated were in the initialReminders array (maybe or maybe not have reminderId, depends if were in offline mode)
            guard let initialReminder = initialReminders.first(where: { initialReminder in
                initialReminder.reminderUUID == currentReminder.reminderUUID
            }) else {
                return false
            }
            
            // If current reminder is different that its corresponding initial reminder, then its been updated
            return currentReminder.isSame(asReminder: initialReminder) == false
        }
        
        updatedReminders.forEach { updatedReminder in
            // updated reminder could have had its timing updating, so resetForNextAlarm to clear skippedDate, snoozing, etc.
            updatedReminder.resetForNextAlarm()
        }
        
        // looks for reminders that were present in initialReminders but not in currentReminders
        let deletedReminders = initialReminders.filter({ initialReminder in
            // The reminder needs to have already been created on the Hound server
            guard initialReminder.reminderId != nil else {
                return false
            }
            
            // Only include reminders that no longer exist in currentReminders
            return currentReminders.contains(where: { currentReminder in
                return initialReminder.reminderUUID == currentReminder.reminderUUID
            }) == false
        })
        
        if dogToUpdate != nil {
            // dog + created reminders + updated reminders + deleted reminders
            let numberOfTasks = {
                // first task is dog update
                var numberOfTasks = 1
                if createdReminders.count >= 1 {
                    numberOfTasks += 1
                }
                if updatedReminders.count >= 1 {
                    numberOfTasks += 1
                }
                if deletedReminders.count >= 1 {
                    numberOfTasks += 1
                }
                return numberOfTasks
            }()
            
            let completionTracker = CompletionTracker(numberOfTasks: numberOfTasks) {
                // everytime a task completes, update the dog manager so everything else updates
                if let dogManager = self.dogManager {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
            } completedAllTasksCompletionHandler: {
                // when everything completes, close the page
                self.saveDogButton.isLoading = false
                self.dismiss(animated: true)
            } failedTaskCompletionHandler: {
                // if a problem is encountered, then just stop the indicator
                self.saveDogButton.isLoading = false
            }
            
            // first query to update the dog itself (independent of any reminders)
            DogsRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDog: dog) { responseStatusDogUpdate, _ in
                guard responseStatusDogUpdate != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }
                
                // Updated dog
                self.dogManager?.addDog(forDog: dog)
                completionTracker.completedTask()
                
                if createdReminders.count >= 1 {
                    RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: createdReminders) { responseStatusReminderCreate, _ in
                        guard responseStatusReminderCreate != .failureResponse else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        dog.dogReminders.addReminders(forReminders: createdReminders)
                        completionTracker.completedTask()
                    }
                }
                
                if updatedReminders.count >= 1 {
                    RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: updatedReminders) { responseStatusReminderUpdate, _ in
                        guard responseStatusReminderUpdate != .failureResponse else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        // add updated reminders as they already have their reminderUUID
                        dog.dogReminders.addReminders(forReminders: updatedReminders)
                        completionTracker.completedTask()
                    }
                }
                
                if deletedReminders.count >= 1 {
                    RemindersRequest.delete(
                        forErrorAlert: .automaticallyAlertOnlyForFailure,
                        forDogUUID: dog.dogUUID,
                        forReminderUUIDs: deletedReminders.map({ reminder in
                            return reminder.reminderUUID
                        })
                    ) { responseStatusReminderDelete, _ in
                        guard responseStatusReminderDelete != .failureResponse else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        for deletedReminder in deletedReminders {
                            dog.dogReminders.removeReminder(forReminderUUID: deletedReminder.reminderUUID)
                        }
                        
                        completionTracker.completedTask()
                    }
                }
                
            }
        }
        else {
            // not updating, therefore the dog is being created new and the reminders are too
            DogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDog: dog) { responseStatusDogCreate, _ in
                guard responseStatusDogCreate != .failureResponse else {
                    self.saveDogButton.isLoading = false
                    return
                }
                
                RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: createdReminders) { responseStatusReminderCreate, _ in
                    self.saveDogButton.isLoading = false
                    
                    guard responseStatusReminderCreate != .failureResponse else {
                        // reminders were unable to be created so we delete the dog to remove everything.
                        DogsRequest.delete(forErrorAlert: .automaticallyAlertForNone, forDogUUID: dog.dogUUID) { _, _ in
                            // do nothing, we can't do more even if it fails.
                        }
                        return
                    }
                    
                    self.dogManager?.addDog(forDog: dog)
                    
                    // dog and reminders successfully created, so we can proceed
                    dog.dogReminders.addReminders(forReminders: createdReminders)
                    
                    if let dogManager = self.dogManager {
                        self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                    }
                    
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func didTouchUpInsideDismissPage(_ sender: Any) {
        // If the user changed any values on the page, then ask them to confirm to discarding those changes
        guard didUpdateInitialValues == true else {
            self.dismiss(animated: true)
            return
        }
        
        let unsavedInformationConfirmation = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
        
        let exitAlertAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
            self.dismiss(animated: true)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        unsavedInformationConfirmation.addAction(exitAlertAction)
        unsavedInformationConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(unsavedInformationConfirmation)
    }
    
    // MARK: - Properties
    
    private var didSetupCustomSubviews: Bool = false
    
    private weak var delegate: DogsAddDogVCDelegate?
    
    private var dogManager: DogManager?
    private var dogToUpdate: Dog?
    
    private var initialDogName: String?
    private var initialDogIcon: UIImage?
    
    var didUpdateInitialValues: Bool {
        if dogNameTextField.text != initialDogName {
            return true
        }
        if let image = dogIconButton.imageView?.image, image != initialDogIcon {
            return true
        }
        
        if remindersView.didUpdateInitialValues {
            return true
        }
        if triggersView.didUpdateInitialValues {
            return true
        }
        
        return false
    }
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.view.dismissKeyboardOnTap(delegate: self)
        
        DogIconManager.didSelectDogIconController.delegate = self
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddDogVCDelegate, forDogManager: DogManager?, forDogToUpdate: Dog?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogToUpdate = forDogToUpdate
        
        editPageHeaderView.setTitle(dogToUpdate == nil ? "Create Dog" : "Edit Dog")
        
        dogNameTextField.text = dogToUpdate?.dogName ?? ""
        initialDogName = dogToUpdate?.dogName ?? ""
        
        if let dogIcon = dogToUpdate?.dogIcon {
            dogIconButton.setTitle(nil, for: .normal)
            dogIconButton.setImage(dogIcon, for: .normal)
        }
        initialDogIcon = dogToUpdate?.dogIcon
        
        remindersView.setup(forDelegate: self, forDogReminders: dogToUpdate?.dogReminders)
        triggersView.setup(forDelegate: self, forDogTriggers: dogToUpdate?.dogTriggers)
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveDogButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(dogIconButton)
        containerView.addSubview(dogNameTextField)
        containerView.addSubview(segmentedControl)
        containerView.addSubview(tableViewsStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // editPageHeaderView
        NSLayoutConstraint.activate([
            editPageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editPageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editPageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // dogIconButton
        NSLayoutConstraint.activate([
            dogIconButton.topAnchor.constraint(equalTo: editPageHeaderView.bottomAnchor),
            dogIconButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteCircleHoriInset),
            dogIconButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            dogIconButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight),
            dogIconButton.createSquareAspectRatio()
        ])
        
        // dogNameTextField
        NSLayoutConstraint.activate([
            dogNameTextField.leadingAnchor.constraint(equalTo: dogIconButton.trailingAnchor, constant: ConstraintConstant.Spacing.absoluteCircleHoriInset),
            dogNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            dogNameTextField.centerYAnchor.constraint(equalTo: dogIconButton.centerYAnchor),
            dogNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            dogNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        // segmentedControl
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: dogIconButton.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
                        segmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
                        segmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
                        segmentedControl.createHeightMultiplier(ConstraintConstant.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
                        segmentedControl.createMaxHeight(ConstraintConstant.Input.segmentedMaxHeight)
        ])
        
        // tableViewsStack
        NSLayoutConstraint.activate([
            tableViewsStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
                        tableViewsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
                        tableViewsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        tableViewsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        // saveLogButton
        NSLayoutConstraint.activate([
            saveDogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            saveDogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleHoriInset),
            saveDogButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            saveDogButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight),
            saveDogButton.createSquareAspectRatio()
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
    }
    
}
