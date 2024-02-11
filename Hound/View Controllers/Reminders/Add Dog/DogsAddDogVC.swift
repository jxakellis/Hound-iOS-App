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

    // MARK: - IB

    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!

    @IBOutlet private weak var dogNameTextField: GeneralUITextField!

    @IBOutlet private weak var dogIconButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }

    @IBOutlet private weak var remindersTableView: GeneralUITableView?

    @IBOutlet private weak var addDogButton: GeneralWithBackgroundUIButton!
    // When the add button is tapped, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func didTouchUpInsideAddDog(_ sender: Any) {
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

        let initialReminders = initialReminders?.reminders ?? []
        let currentReminders = dogReminders?.reminders ?? []
        let createdReminders = currentReminders.filter({ currentReminder in
            // Reminders that were just created have no reminderId and were not in the initialReminders array
            return currentReminder.reminderId == nil && initialReminders.contains(where: { initialReminder in
                return initialReminder.reminderUUID == currentReminder.reminderUUID
            })
        })

        createdReminders.forEach { reminder in
            reminder.resetForNextAlarm()
        }

        let updatedReminders = currentReminders.filter { currentReminder in
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
            // Reminders that were just deleted have needed to have a reminderId and were in the initialReminders array but not in currentReminders
            guard initialReminder.reminderId != nil else {
                return false
            }

            // Only include reminders that no longer exist in currentReminders
            return !currentReminders.contains(where: { currentReminder in
                return initialReminder.reminderUUID == currentReminder.reminderUUID
            })
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
            DogsRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, forDog: dog) { responseStatusDogUpdate, _ in
                guard responseStatusDogUpdate != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }

                // Updated dog
                self.dogManager?.addDog(forDog: dog)
                completionTracker.completedTask()

                if createdReminders.count >= 1 {
                    RemindersRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: createdReminders) { responseStatusReminderCreate, _ in
                        guard responseStatusReminderCreate != .failureResponse else {
                            completionTracker.failedTask()
                            return
                        }

                        dog.dogReminders.addReminders(forReminders: createdReminders)
                        completionTracker.completedTask()
                    }
                }

                if updatedReminders.count >= 1 {
                    RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: updatedReminders) { responseStatusReminderUpdate, _ in
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
                    RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: deletedReminders) { responseStatusReminderDelete, _ in
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
            DogsRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, forDog: dog) { responseStatusDogCreate, _ in
                guard responseStatusDogCreate != .failureResponse else {
                    self.addDogButton.endSpinning()
                    return
                }

                RemindersRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: createdReminders) { responseStatusReminderCreate, _ in
                    self.addDogButton.endSpinning()
                    
                    guard responseStatusReminderCreate != .failureResponse else {
                        // reminders were unable to be created so we delete the dog to remove everything.
                        DogsRequest.delete(errorAlert: .automaticallyAlertForNone, forDogUUID: dog.dogUUID) { _, _ in
                            // do nothing, we can't do more even if it fails.
                        }
                        return
                    }
                    
                    // dog and reminders successfully created, so we can proceed
                    dog.dogReminders.addReminders(forReminders: createdReminders)

                    self.dogManager?.addDog(forDog: dog)
                    if let dogManager = self.dogManager {
                        self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                    }

                    self.dismiss(animated: true)
                }
            }
        }
    }

    @IBOutlet private weak var removeDogButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideRemoveDog(_ sender: Any) {
        guard let dogToUpdate = dogToUpdate else {
            return
        }

        let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogNameTextField.text ?? dogToUpdate.dogName)?", message: nil, preferredStyle: .alert)

        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DogsRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogToUpdate.dogUUID) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                self.dogManager?.removeDog(forDogUUID: dogToUpdate.dogUUID)
                self.dogManager?.clearTimers()

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

    @IBOutlet private weak var dismissPageButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideDismissPage(_ sender: Any) {
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
        if initialReminders?.reminders.count != dogReminders?.reminders.count {
            return true
        }
        if let initialReminders = initialReminders?.reminders {
            let currentReminders = dogReminders?.reminders
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

        var passedReminders: DogReminderManager {
            dogToUpdate?.dogReminders.copy() as? DogReminderManager ?? DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
        }

        // dogRemoveButton.isEnabled = dogToUpdate != nil

        initialDogName = dogNameTextField.text
        initialDogIcon = dogIconButton.imageView?.image
        initialReminders = passedReminders

        DogIconManager.didSelectDogIconController.delegate = self
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        guard didSetupCustomSubviews == false else {
            return
        }

        didSetupCustomSubviews = true

        if let remindersTableView = remindersTableView {
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
            remindersTableView?.allowsSelection = !dogReminders.reminders.isEmpty
        }

        remindersTableView?.reloadData()
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let dogReminders = dogReminders else {
            return 0
        }

        return dogReminders.reminders.count
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
        // Make the background color show through
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dogReminders = dogReminders else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DogsAddDogDisplayReminderTableViewCell", for: indexPath)

        if let castedCell = cell as? DogsAddDogDisplayReminderTableViewCell {
            castedCell.delegate = self
            castedCell.setup(forReminder: dogReminders.reminders[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dogReminders = dogReminders else {
            return
        }

        dogsAddReminderViewControllerReminderToUpdate = dogReminders.reminders[indexPath.section]
        performSegueOnceInWindowHierarchy(segueIdentifier: "DogsAddReminderViewController")
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let dogReminders = dogReminders else {
            return
        }

        if editingStyle == .delete && dogReminders.reminders.isEmpty == false {
            let reminder = dogReminders.reminders[indexPath.section]

            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)

            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
                self.remindersTableView?.deleteSections([indexPath.section], with: .automatic)
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

        return dogReminders.reminders.isEmpty == false
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddReminderViewController = segue.destination as? DogsAddReminderViewController {
            /// DogsAddDogViewController takes care of all server communication when, and if, the user decides to save their changes to the dog. Therefore, we don't provide a reminderToUpdateDogUUID to dogsAddReminderViewController, as otherwise it would contact and update the server.
            dogsAddReminderViewController.setup(forDelegate: self, forReminderToUpdateDogUUID: nil, forReminderToUpdate: self.dogsAddReminderViewControllerReminderToUpdate)
            self.dogsAddReminderViewControllerReminderToUpdate = nil
        }
    }
}
