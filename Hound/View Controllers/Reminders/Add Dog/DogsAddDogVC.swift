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

final class DogsAddDogVC: HoundScrollViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, DogsAddReminderVCDelegate, DogsAddDogReminderTVCDelegate {
    
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
    
    // MARK: - DogsAddReminderVCDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder)
        remindersTableView.reloadSections(IndexSet(integersIn: 0 ..< dogReminders.dogReminders.count), with: .fade)
    }
    
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder)
        remindersTableView.reloadSections(IndexSet(integersIn: 0 ..< dogReminders.dogReminders.count), with: .fade)
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID) {
        dogReminders.removeReminder(forReminderUUID: forReminderUUID)
        remindersTableView.reloadSections(IndexSet(integersIn: 0 ..< dogReminders.dogReminders.count), with: .fade)
    }
    
    // MARK: - DogsAddDogReminderTVCDelegate
    
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool) {
        dogReminders.findReminder(forReminderUUID: forReminderUUID)?.reminderIsEnabled = forReminderIsEnabled
    }
    
    // MARK: - Elements
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 330, compressionResistancePriority: 330)
        
        view.trailingButton.isHidden = false
        view.trailingButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveDog), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var dogNameTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 290, compressionResistencePriority: 290)
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
    
    private lazy var remindersTableView: HoundTableView = {
        let tableView = HoundTableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(DogsAddDogReminderTVC.self, forCellReuseIdentifier: DogsAddDogReminderTVC.reuseIdentifier)
        
        tableView.onlyScrollIfBigger()
        
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.emptyStateEnabled = true
        tableView.emptyStateMessage = "No reminders yet"
        
        return tableView
    }()
    
    private lazy var addReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Add Reminder", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.thinLabelBorder)
        
        button.addTarget(self, action: #selector(didTouchUpInsideAddReminder), for: .touchUpInside)
        
        return button
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
        guard let dogToUpdate = dogToUpdate else {
            return
        }
        
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
        
        let initialReminders = initialReminders.dogReminders
        let currentReminders = dogReminders.dogReminders
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
    
    @objc private func didTouchUpInsideAddReminder(_ sender: Any) {
        let numNonTriggerReminders = dogReminders.dogReminders.count(where: { $0.reminderIsTriggerResult == false })
        
        guard numNonTriggerReminders < ClassConstant.DogConstant.maximumNumberOfReminders else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.noAddMoreRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.noAddMoreRemindersSubtitle, forStyle: .warning)
            return
        }
        let vc = DogsAddReminderVC()
        vc.setup(forDelegate: self, forReminderToUpdateDogUUID: nil, forReminderToUpdate: nil)
        PresentationManager.enqueueViewController(vc)
    }
    
    // MARK: - Properties
    
    private var didSetupCustomSubviews: Bool = false
    
    private weak var delegate: DogsAddDogVCDelegate?
    
    private var dogManager: DogManager?
    private var dogToUpdate: Dog?
    /// dogReminders is either a copy of dogToUpdate's reminders or a DogReminderManager initialized to a default array of reminders. This is purposeful so that either, if you dont have a dogToUpdate, you can still create reminders, and if you do have a dogToUpdate, you don't directly update the dogToUpdate until save is pressed
    private var dogReminders: DogReminderManager = DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
    private var initialDogName: String?
    private var initialDogIcon: UIImage?
    private var initialReminders: DogReminderManager = DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
    var didUpdateInitialValues: Bool {
        if dogNameTextField.text != initialDogName {
            return true
        }
        if let image = dogIconButton.imageView?.image, image != initialDogIcon {
            return true
        }
        // need to check count, make sure the arrays are 1:1. if current reminders has more reminders than initial reminders, the loop below won't catch it, as the loop below just looks to see if each initial reminder is still present in current reminders.
        if initialReminders.dogReminders.count != dogReminders.dogReminders.count {
            return true
        }
        // make sure each initial reminder has a corresponding current reminder, otherwise current reminders have been updated
        for initialReminder in initialReminders.dogReminders {
            let currentReminder = dogReminders.dogReminders.first(where: { $0.reminderUUID == initialReminder.reminderUUID })
            
            guard let currentReminder = currentReminder else {
                // no corresponding reminder
                return true
            }
            
            // if any of the corresponding reminders are different, then return true to indicate that a reminder has been updated
            if initialReminder.isSame(asReminder: currentReminder) == false {
                return true
            }
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
        
        dogReminders = (dogToUpdate?.dogReminders.copy() as? DogReminderManager) ?? dogReminders
        initialReminders = (dogToUpdate?.dogReminders.copy() as? DogReminderManager) ?? initialReminders
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dogReminders.dogReminders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Only add spacing if NOT the last section
        let lastSection = dogReminders.dogReminders.count - 1
        return section == lastSection ? 0 : ConstraintConstant.Spacing.contentTallIntraVert
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Only return a view if not the last section
        let lastSection = InAppPurchaseManager.subscriptionProducts.count - 1
        if section == lastSection {
            return nil
        }
        
        let footer = HoundHeaderFooterView()
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DogsAddDogReminderTVC.reuseIdentifier, for: indexPath)
        
        if let castedCell = cell as? DogsAddDogReminderTVC {
            castedCell.setup(forDelegate: self, forReminder: dogReminders.dogReminders[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = dogReminders.dogReminders[indexPath.section]
        
        guard reminder.reminderIsTriggerResult == false else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.noEditTriggerResultRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.noEditTriggerResultRemindersSubtitle, forStyle: .warning)
            return
        }
        
        let vc = DogsAddReminderVC()
        /// DogsAddDogVC takes care of all server communication when, and if, the user decides to save their changes to the dog. Therefore, we don't provide a reminderToUpdateDogUUID to dogsAddReminderViewController, as otherwise it would contact and update the server.
        vc.setup(forDelegate: self, forReminderToUpdateDogUUID: nil, forReminderToUpdate: reminder)
        PresentationManager.enqueueViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete && dogReminders.dogReminders.isEmpty == false else {
            return
        }
        
        let reminder = dogReminders.dogReminders[indexPath.section]
        
        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
            self.remindersTableView.deleteSections([indexPath.section], with: .automatic)
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        removeReminderConfirmation.addAction(removeAlertAction)
        removeReminderConfirmation.addAction(cancelAlertAction)
        PresentationManager.enqueueAlert(removeReminderConfirmation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dogReminders.dogReminders.isEmpty == false
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveDogButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(dogIconButton)
        containerView.addSubview(dogNameTextField)
        containerView.addSubview(remindersTableView)
        containerView.addSubview(addReminderButton)
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
            dogIconButton.topAnchor.constraint(equalTo: editPageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.absoluteCircleHoriInset),
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
        
        // remindersTableView
        NSLayoutConstraint.activate([
            remindersTableView.topAnchor.constraint(equalTo: dogIconButton.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            remindersTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            remindersTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // addReminderButton
        NSLayoutConstraint.activate([
            addReminderButton.topAnchor.constraint(equalTo: remindersTableView.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            addReminderButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            addReminderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            addReminderButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
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
