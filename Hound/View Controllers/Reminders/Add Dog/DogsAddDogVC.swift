//
//  DogsAddDogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class DogsAddDogViewController: GeneralUIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, DogsAddReminderViewControllerDelegate, DogsAddDogDisplayReminderTableViewCellDelegate, DogsAddDogAddReminderFooterViewDelegate {
    
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
    
    // MARK: - DogsAddReminderViewControllerDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        dogReminders?.addReminder(forReminder: forReminder)
        reloadTable()
    }
    
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder) {
        dogReminders?.addReminder(forReminder: forReminder)
        reloadTable()
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID) {
        dogReminders?.removeReminder(forReminderUUID: forReminderUUID)
        reloadTable()
    }
    
    // MARK: - DogsAddDogDisplayReminderTableViewCellDelegate
    
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool) {
        dogReminders?.findReminder(forReminderUUID: forReminderUUID)?.reminderIsEnabled = forReminderIsEnabled
    }
    
    // MARK: - DogsAddDogAddReminderFooterViewDelegate
    
    func didTouchUpInsideAddReminder() {
        performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddReminderViewController")
    }
    
    // MARK: - Elements
    
    private let pageTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Create Dog"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 35)
        label.textColor = .systemBlue
        return label
    }()
    
    private let dogNameTextField: GeneralUITextField = {
        let textField = GeneralUITextField(huggingPriority: 290, compressionResistencePriority: 790)
        
        textField.placeholder = "Enter your dog's name..."
        textField.backgroundColor = .systemBackground
       
        textField.borderWidth = 0.5
        textField.borderColor = .systemGray
        textField.shouldRoundCorners = true
        
        return textField
    }()
    
    private let dogIconButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 290)
        
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 0.5
        button.borderColor = .systemGray
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    private let remindersTableView: GeneralUITableView = {
        let tableView = GeneralUITableView()
        tableView.clipsToBounds = true
        tableView.contentMode = .scaleToFill
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.bouncesZoom = false
        tableView.separatorStyle = .none
        tableView.rowHeight = -1
        tableView.estimatedRowHeight = -1
        tableView.sectionHeaderHeight = -1
        tableView.estimatedSectionHeaderHeight = -1
        tableView.sectionFooterHeight = -1
        tableView.estimatedSectionFooterHeight = -1
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.shouldAutomaticallyAdjustHeight = true
        return tableView
    }()
    
    private let addDogButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        return button
    }()
    
    // When the add button is tapped, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @objc private func didTouchUpInsideAddDog(_ sender: Any) {
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
        
        addDogButton.beginSpinning()
        
        let initialReminders = initialReminders?.dogReminders ?? []
        let currentReminders = dogReminders?.dogReminders ?? []
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
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
            } completedAllTasksCompletionHandler: {
                // when everything completes, close the page
                self.addDogButton.endSpinning()
                self.dismiss(animated: true)
            } failedTaskCompletionHandler: {
                // if a problem is encountered, then just stop the indicator
                self.addDogButton.endSpinning()
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
                    self.addDogButton.endSpinning()
                    return
                }
                
                RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: createdReminders) { responseStatusReminderCreate, _ in
                    self.addDogButton.endSpinning()
                    
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
                        self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                    }
                    
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    private let removeDogButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
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
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                
                self.dismiss(animated: true)
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(removeAlertAction)
        removeDogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeDogConfirmation)
    }
    
    private let dismissPageButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = .systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.alwaysBounceVertical = true
        
        return scrollView
    }()
    
    private let containerInsideScrollView: GeneralUIView = GeneralUIView()
    
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
    
    private var dogsAddReminderViewControllerReminderToUpdate: Reminder?
    
    private weak var delegate: DogsAddDogViewControllerDelegate!
    
    private var dogManager: DogManager?
    private var dogToUpdate: Dog?
    /// dogReminders is either a copy of dogToUpdate's reminders or a DogReminderManager initialized to a default array of reminders. This is purposeful so that either, if you dont have a dogToUpdate, you can still create reminders, and if you do have a dogToUpdate, you don't directly update the dogToUpdate until save is pressed
    private var dogReminders: DogReminderManager?
    private var initialDogName: String?
    private var initialDogIcon: UIImage?
    private var initialReminders: DogReminderManager?
    var didUpdateInitialValues: Bool {
        if dogNameTextField.text != initialDogName {
            return true
        }
        if let image = dogIconButton.imageView?.image, image != initialDogIcon {
            return true
        }
        // need to check count, make sure the arrays are 1:1. if current reminders has more reminders than initial reminders, the loop below won't catch it, as the loop below just looks to see if each initial reminder is still present in current reminders.
        if initialReminders?.dogReminders.count != dogReminders?.dogReminders.count {
            return true
        }
        if let initialReminders = initialReminders?.dogReminders {
            let currentReminders = dogReminders?.dogReminders
            // make sure each initial reminder has a corresponding current reminder, otherwise current reminders have been updated
            for initialReminder in initialReminders {
                let currentReminder = currentReminders?.first(where: { $0.reminderUUID == initialReminder.reminderUUID })
                
                guard let currentReminder = currentReminder else {
                    // no corresponding reminder
                    return true
                }
                
                // if any of the corresponding reminders are different, then return true to indicate that a reminder has been updated
                if initialReminder.isSame(asReminder: currentReminder) == false {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // gestures
        self.view.dismissKeyboardOnTap(delegate: self)
        
        if dogToUpdate == nil {
            pageTitleLabel.text = "Create Dog"
            removeDogButton.removeFromSuperview()
        }
        else {
            pageTitleLabel.text = "Edit Dog"
        }
        
        dogNameTextField.text = dogToUpdate?.dogName ?? ""
        dogNameTextField.delegate = self
        
        if let dogIcon = dogToUpdate?.dogIcon {
            dogIconButton.setTitle(nil, for: .normal)
            dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        initialDogName = dogNameTextField.text
        initialDogIcon = dogIconButton.imageView?.image
        
        initialReminders = (dogReminders?.copy() as? DogReminderManager)
        
        DogIconManager.didSelectDogIconController.delegate = self
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        let tableFooterView = DogsAddDogAddReminderFooterView(frame:
                                                                CGRect(
                                                                    x: 0,
                                                                    y: 0,
                                                                    width: remindersTableView.frame.width,
                                                                    height: DogsAddDogAddReminderFooterView.cellHeight(forTableViewWidth: remindersTableView.frame.width)
                                                                )
        )
        tableFooterView.setup(forDelegate: self)
        remindersTableView.tableFooterView = tableFooterView
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsAddDogViewControllerDelegate, forDogManager: DogManager?, forDogToUpdate: Dog?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogToUpdate = forDogToUpdate
        dogReminders = (dogToUpdate?.dogReminders.copy() as? DogReminderManager) ?? DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
    }
    
    private func reloadTable() {
        if let dogReminders = dogReminders {
            remindersTableView.allowsSelection = !dogReminders.dogReminders.isEmpty
        }
        
        remindersTableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let dogReminders = dogReminders else {
            return 0
        }
        
        return dogReminders.dogReminders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dogReminders != nil else {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set the spacing between sections
        // I don't fully understand how this spacing works. Setting the value to 0.0 makes it behave as expected. As soon as its >0.0, then its size is increased by some mysterious constant + whatever value I specified here.
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return GeneralUIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dogReminders = dogReminders else {
            return UITableViewCell()
        }
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "DogsAddDogDisplayReminderTableViewCell", for: indexPath)
        //
        //        if let castedCell = cell as? DogsAddDogDisplayReminderTableViewCell {
        //            castedCell.delegate = self
        //            castedCell.setup(forReminder: dogReminders.dogReminders[indexPath.section])
        //            castedCell.containerView.roundCorners(setCorners: .all)
        //        }
        
        // TODO what is the new proper way to do this?
        
        let cell = DogsAddDogDisplayReminderTVC()
        cell.delegate = self
        cell.setup(forReminder: dogReminders.dogReminders[indexPath.section])
        cell.containerView.roundCorners(setCorners: .all)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dogReminders = dogReminders else {
            return
        }
        
        dogsAddReminderViewControllerReminderToUpdate = dogReminders.dogReminders[indexPath.section]
        performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddReminderViewController")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let dogReminders = dogReminders else {
            return
        }
        
        if editingStyle == .delete && dogReminders.dogReminders.isEmpty == false {
            let reminder = dogReminders.dogReminders[indexPath.section]
            
            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
                self.remindersTableView.deleteSections([indexPath.section], with: .automatic)
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeReminderConfirmation.addAction(removeAlertAction)
            removeReminderConfirmation.addAction(cancelAlertAction)
            PresentationManager.enqueueAlert(removeReminderConfirmation)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let dogReminders = dogReminders else {
            return false
        }
        
        return dogReminders.dogReminders.isEmpty == false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddReminderViewController = segue.destination as? DogsAddReminderViewController {
            /// DogsAddDogViewController takes care of all server communication when, and if, the user decides to save their changes to the dog. Therefore, we don't provide a reminderToUpdateDogUUID to dogsAddReminderViewController, as otherwise it would contact and update the server.
            dogsAddReminderViewController.setup(forDelegate: self, forReminderToUpdateDogUUID: nil, forReminderToUpdate: self.dogsAddReminderViewControllerReminderToUpdate)
            self.dogsAddReminderViewControllerReminderToUpdate = nil
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(scrollView)
        view.addSubview(addDogButton)
        addDogButton.addTarget(self, action: #selector(didTouchUpInsideAddDog), for: .touchUpInside)
        view.addSubview(dismissPageButton)
        dismissPageButton.addTarget(self, action: #selector(didTouchUpInsideDismissPage), for: .touchUpInside)
        scrollView.addSubview(containerInsideScrollView)
        containerInsideScrollView.addSubview(dogIconButton)
        dogIconButton.addTarget(self, action: #selector(didTouchUpInsideDogIcon), for: .touchUpInside)
        containerInsideScrollView.addSubview(remindersTableView)
        containerInsideScrollView.addSubview(pageTitleLabel)
        containerInsideScrollView.addSubview(removeDogButton)
        removeDogButton.addTarget(self, action: #selector(didTouchUpInsideRemoveDog), for: .touchUpInside)
        containerInsideScrollView.addSubview(dogNameTextField)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            dogIconButton.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 15),
            dogIconButton.leadingAnchor.constraint(equalTo: containerInsideScrollView.leadingAnchor, constant: 10),
            dogIconButton.widthAnchor.constraint(equalTo: dogIconButton.heightAnchor),
            dogIconButton.widthAnchor.constraint(equalTo: containerInsideScrollView.widthAnchor, multiplier: 100 / 414),
            dogIconButton.heightAnchor.constraint(equalToConstant: 50),
            dogIconButton.heightAnchor.constraint(equalToConstant: 150),
            
            pageTitleLabel.topAnchor.constraint(equalTo: containerInsideScrollView.topAnchor, constant: 10),
            pageTitleLabel.leadingAnchor.constraint(equalTo: containerInsideScrollView.leadingAnchor, constant: 10),
            pageTitleLabel.centerXAnchor.constraint(equalTo: containerInsideScrollView.centerXAnchor),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            removeDogButton.topAnchor.constraint(equalTo: containerInsideScrollView.topAnchor, constant: 5),
            removeDogButton.leadingAnchor.constraint(equalTo: pageTitleLabel.trailingAnchor, constant: 10),
            removeDogButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor),
            removeDogButton.widthAnchor.constraint(equalTo: removeDogButton.heightAnchor),
            
            dogNameTextField.leadingAnchor.constraint(equalTo: dogIconButton.trailingAnchor, constant: 10),
            dogNameTextField.trailingAnchor.constraint(equalTo: containerInsideScrollView.trailingAnchor, constant: -10),
            dogNameTextField.trailingAnchor.constraint(equalTo: removeDogButton.trailingAnchor),
            dogNameTextField.centerYAnchor.constraint(equalTo: dogIconButton.centerYAnchor),
            dogNameTextField.heightAnchor.constraint(equalToConstant: 45),
            
            remindersTableView.topAnchor.constraint(equalTo: dogIconButton.bottomAnchor, constant: 15),
            remindersTableView.bottomAnchor.constraint(equalTo: containerInsideScrollView.bottomAnchor),
            remindersTableView.leadingAnchor.constraint(equalTo: containerInsideScrollView.leadingAnchor),
            remindersTableView.trailingAnchor.constraint(equalTo: containerInsideScrollView.trailingAnchor),
            
            containerInsideScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerInsideScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerInsideScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerInsideScrollView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerInsideScrollView.trailingAnchor),
            
            addDogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addDogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            addDogButton.widthAnchor.constraint(equalTo: addDogButton.heightAnchor),
            addDogButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100 / 414),
            addDogButton.heightAnchor.constraint(equalToConstant: 150),
            addDogButton.heightAnchor.constraint(equalToConstant: 50),
            
            dismissPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            dismissPageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            dismissPageButton.widthAnchor.constraint(equalTo: dismissPageButton.heightAnchor),
            dismissPageButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100 / 414),
            dismissPageButton.heightAnchor.constraint(equalToConstant: 50),
            dismissPageButton.heightAnchor.constraint(equalToConstant: 150),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        
    }
}
