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

final class DogsAddDogViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // TODO NOW add page title to page and little trash can next to it
    
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
    
    // MARK: - IB
    
    @IBOutlet private weak var dogNameTextField: GeneralUITextField!
    
    @IBOutlet private weak var dogIconButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    @IBOutlet private weak var addDogButton: GeneralWithBackgroundUIButton!
    // When the add button is tapped, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func didTouchUpInsideAddDog(_ sender: Any) {
        // could be new dog or updated one
        var dog: Dog!
        do {
            // try to initialize from a passed dog, if non exists, then we make a new one
            dog = try dogToUpdate ?? Dog(dogName: dogNameTextField.text)
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
        let currentReminders = dogsReminderTableViewController?.dogReminders.reminders ?? []
        // create reminders have placeholder ids
        let createdReminders = currentReminders.filter({ currentReminder in
            return currentReminder.reminderId <= -1
        })
        
        createdReminders.forEach { reminder in
            reminder.resetForNextAlarm()
        }
        
        let updatedReminders = currentReminders.filter { currentReminder in
            // current remoinders have to have a real reminderId as we are contacting the server
            guard currentReminder.reminderId >= 1 else {
                return false
            }
            
            // updated reminders have to have a corresponding initial reminder
            guard let initialReminder = initialReminders.first(where: { initialReminder in
                return initialReminder.reminderId == currentReminder.reminderId
            }) else {
                return false
            }
            
            // if current reminder is different that its corresponding initial reminder, then its been updated
            return currentReminder.isSame(asReminder: initialReminder) == false
        }
        
        updatedReminders.forEach { updatedReminder in
            // updated reminder could have had its timing updating, so resetForNextAlarm to clear skippedDate, snoozing, etc.
            updatedReminder.resetForNextAlarm()
        }
        
        // looks for reminders that were present in initialReminders but not in currentReminders
        let deletedReminders = initialReminders.filter({ initialReminder in
            // deleted reminders have to have a real reminderId as we are contacting the server
            guard initialReminder.reminderId >= 1 else {
                return false
            }
            
            let currentRemindersContainsInitialReminder = currentReminders.contains(where: { currentReminder in
                return initialReminder.reminderId == currentReminder.reminderId
            })
            // if current reminders contains the target initial reminder, then that initial reminder wasn't deleted and shouldnt be included
            return !currentRemindersContainsInitialReminder
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
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
            } completedAllTasksCompletionHandler: {
                // when everything completes, close the page
                self.addDogButton.endSpinning()
                self.dismiss(animated: true)
            } failedTaskCompletionHandler: {
                // if a problem is encountered, then just stop the indicator
                self.addDogButton.endSpinning()
            }
            
            // first query to update the dog itself (independent of any reminders)
            DogsRequest.update(invokeErrorManager: true, forDog: dog) { requestWasSuccessful1, _ in
                guard requestWasSuccessful1 else {
                    completionTracker.failedTask()
                    return
                }
                
                // Updated dog
                self.dogManager.addDog(forDog: dog)
                completionTracker.completedTask()
                
                if createdReminders.count >= 1 {
                    RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: createdReminders) { reminders, _ in
                        guard let reminders = reminders else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        dog.dogReminders.addReminders(forReminders: reminders)
                        completionTracker.completedTask()
                    }
                }
                
                if updatedReminders.count >= 1 {
                    RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: updatedReminders) { reminderUpdateWasSuccessful, _ in
                        guard reminderUpdateWasSuccessful else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        // add updated reminders as they already have their reminderId
                        dog.dogReminders.addReminders(forReminders: updatedReminders)
                        completionTracker.completedTask()
                    }
                }
                
                if deletedReminders.count >= 1 {
                    RemindersRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forReminders: deletedReminders) { reminderDeleteWasSuccessful, _ in
                        guard reminderDeleteWasSuccessful else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        for deletedReminder in deletedReminders {
                            dog.dogReminders.removeReminder(forReminderId: deletedReminder.reminderId)
                        }
                        completionTracker.completedTask()
                    }
                }
                
            }
        }
        else {
            // not updating, therefore the dog is being created new and the reminders are too
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    self.addDogButton.endSpinning()
                    return
                }
                
                RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: createdReminders) { reminders, _ in
                    self.addDogButton.endSpinning()
                    guard let reminders = reminders else {
                        // reminders were unable to be created so we delete the dog to remove everything.
                        DogsRequest.delete(invokeErrorManager: false, forDogId: dog.dogId) { _, _ in
                            // do nothing, we can't do more even if it fails.
                        }
                        return
                    }
                    // dog and reminders successfully created, so we can proceed
                    dog.dogReminders.addReminders(forReminders: reminders)
                    
                    self.dogManager.addDog(forDog: dog)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    /*
     Removed the delete dog button from this page after removal of top tab bar
    @IBOutlet private weak var removeDogButton: UIBarButtonItem!
    @IBAction private func didTouchUpInsideRemoveDog(_ sender: Any) {
        guard let dogToUpdate = dogToUpdate else {
            return
        }
        
        let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogNameTextField.text ?? dogToUpdate.dogName)?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DogsRequest.delete(invokeErrorManager: true, forDogId: dogToUpdate.dogId) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                
                self.dogManager.removeDog(forDogId: dogToUpdate.dogId)
                self.dogManager.clearTimers()
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                
                self.dismiss(animated: true)
                
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(removeAlertAction)
        removeDogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeDogConfirmation)
    }
     */
    
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
    
    private(set) var dogsReminderTableViewController: DogsReminderTableViewController?
    
    weak var delegate: DogsAddDogViewControllerDelegate!
    
    /// VC uses this to initialize its values, its absense or presense indicates whether or not we are editing or creating a dog
    var dogToUpdate: Dog?
    
    var initialDogName: String?
    var initialDogIcon: UIImage?
    var initialReminders: ReminderManager?
    
    var didUpdateInitialValues: Bool {
        if dogNameTextField.text != initialDogName {
            return true
        }
        if let image = dogIconButton.imageView?.image, image != initialDogIcon {
            return true
        }
        // need to check count, make sure the arrays are 1:1. if current reminders has more reminders than initial reminders, the loop below won't catch it, as the loop below just looks to see if each initial reminder is still present in current reminders.
        if initialReminders?.reminders.count != dogsReminderTableViewController?.dogReminders.reminders.count {
            return true
        }
        if let initialReminders = initialReminders?.reminders {
            let currentReminders = dogsReminderTableViewController?.dogReminders.reminders
            // make sure each initial reminder has a corresponding current reminder, otherwise current reminders have been updated
            for initialReminder in initialReminders {
                let currentReminder = currentReminders?.first(where: { $0.reminderId == initialReminder.reminderId })
                
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
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        if !(sender.localized is DogsViewController) {
            delegate.didUpdateDogManager(sender: sender, forDogManager: dogManager)
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gestures
        self.view.setupDismissKeyboardOnTap()
        
        dogNameTextField.text = dogToUpdate?.dogName ?? ""
        dogNameTextField.delegate = self
        
        if let dogIcon = dogToUpdate?.dogIcon {
            dogIconButton.setTitle(nil, for: .normal)
            dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        var passedReminders: ReminderManager {
            return dogToUpdate?.dogReminders.copy() as? ReminderManager ?? ReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
        }
        
        // dogRemoveButton.isEnabled = dogToUpdate != nil
        
        initialDogName = dogNameTextField.text
        initialDogIcon = dogIconButton.imageView?.image
        initialReminders = passedReminders
        
        DogIconManager.didSelectDogIconController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    /// If the user is editting a reminder, we don't them to be able to Hides the big gray back button and big blue checkmark, don't want access to them while editting a reminder.
    func shouldHideButtons(forIsHidden: Bool) {
        addDogButton.isHidden = forIsHidden
        dismissPageButton.isHidden = forIsHidden
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            
            if let dogsReminderTableViewController = navigationController.viewControllers.first as? DogsReminderTableViewController {
                self.dogsReminderTableViewController = dogsReminderTableViewController
                dogsReminderTableViewController.dogReminders = (dogToUpdate?.dogReminders.copy() as? ReminderManager) ?? ReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
            }
            
        }
        
    }
}
