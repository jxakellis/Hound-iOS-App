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
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forDogIconButton: dogIcon, forInfo: info) {
            self.dogIcon.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
    
    @IBOutlet private weak var dogName: BorderedUITextField!
    
    @IBOutlet private weak var dogIcon: ScaledImageUIButton!
    
    @IBAction private func didTapIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    @IBOutlet private weak var addDogButton: ScaledImageWIthBackgroundUIButton!
    // When the add button is tapped, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        // could be new dog or updated one
        var dog: Dog!
        do {
            // try to initalize from a passed dog, if non exists, then we make a new one
            dog = try dogToUpdate ?? Dog(dogName: dogName.text)
            try dog.changeDogName(forDogName: dogName.text)
            if let image = self.dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseDogIcon {
                // DogsRequest handles .addIcon and .removeIcon. It will remove the dogIcon saved under the placeholder id (if creating an dog) and it will save the new dogIcon under the offical dogId
                dog.dogIcon = image
            }
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown().alert()
            return
        }
        
        addDogButton.beginSpinning()
        
        let initalReminders = initalReminders?.reminders ?? []
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
            
            // updated reminders have to have a corresponding inital reminder
            guard let initalReminder = initalReminders.first(where: { initalReminder in
                return initalReminder.reminderId == currentReminder.reminderId
            }) else {
                return false
            }
            
            // if current reminder is different that its corresponding inital reminder, then its been updated
            return currentReminder.isSame(asReminder: initalReminder) == false
        }
        
        updatedReminders.forEach { updatedReminder in
            // updated reminder could have had its timing updating, so resetForNextAlarm to clear skippedDate, snoozing, etc.
            updatedReminder.resetForNextAlarm()
        }
        
        // looks for reminders that were present in initalReminders but not in currentReminders
        let deletedReminders = initalReminders.filter({ initalReminder in
            // deleted reminders have to have a real reminderId as we are contacting the server
            guard initalReminder.reminderId >= 1 else {
                return false
            }
            
            let currentRemindersContainsInitalReminder = currentReminders.contains(where: { currentReminder in
                return initalReminder.reminderId == currentReminder.reminderId
            })
            // if current reminders contains the target inital reminder, then that inital reminder wasn't deleted and shouldnt be included
            return !currentRemindersContainsInitalReminder
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
                self.navigationController?.popViewController(animated: true)
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
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBOutlet private weak var dogRemoveButton: UIBarButtonItem!
    
    @IBAction private func willRemoveDog(_ sender: Any) {
        guard let dogToUpdate = dogToUpdate else {
            return
        }
        
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName.text ?? dogToUpdate.dogName)?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DogsRequest.delete(invokeErrorManager: true, forDogId: dogToUpdate.dogId) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                
                self.dogManager.removeDog(forDogId: dogToUpdate.dogId)
                self.dogManager.clearTimers()
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                
                self.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(removeAlertAction)
        removeDogConfirmation.addAction(cancelAlertAction)
        
        AlertManager.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBOutlet private weak var cancelAddDogButton: ScaledImageWIthBackgroundUIButton!
    
    @IBAction private func cancelAddDogButton(_ sender: Any) {
        // If the user changed any values on the page, then ask them to confirm to discarding those changes
        guard initalValuesChanged == true else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
        
        let exitAlertAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        unsavedInformationConfirmation.addAction(exitAlertAction)
        unsavedInformationConfirmation.addAction(cancelAlertAction)
        
        AlertManager.enqueueAlertForPresentation(unsavedInformationConfirmation)
    }
    
    // MARK: - Properties
    
    var dogsReminderTableViewController: DogsReminderTableViewController?
    
    weak var delegate: DogsAddDogViewControllerDelegate! = nil
    
    /// VC uses this to initalize its values, its absense or presense indicates whether or not we are editing or creating a dog
    var dogToUpdate: Dog?
    
    var initalDogName: String?
    var initalDogIcon: UIImage?
    var initalReminders: ReminderManager?
    
    var initalValuesChanged: Bool {
        if dogName.text != initalDogName {
            return true
        }
        else if let image = dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseDogIcon && image != initalDogIcon {
            return true
        }
        // need to check count, make sure the arrays are 1:1. if current reminders has more reminders than inital reminders, the loop below won't catch it, as the loop below just looks to see if each inital reminder is still present in current reminders.
        else if initalReminders?.reminders.count != dogsReminderTableViewController?.dogReminders.reminders.count {
            return true
        }
        
        if let initalReminders = initalReminders?.reminders {
            let currentReminders = dogsReminderTableViewController?.dogReminders.reminders
            // make sure each inital reminder has a corresponding current reminder, otherwise current reminders have been updated
            for initalReminder in initalReminders {
                let currentReminder = currentReminders?.first(where: { $0.reminderId == initalReminder.reminderId })
                
                guard let currentReminder = currentReminder else {
                    // no corresponding reminder
                    return true
                }
                
                // if any of the corresponding reminders are different, then return true to indicate that a reminder has been updated
                if initalReminder.isSame(asReminder: currentReminder) == false {
                    return true
                }
            }
        }
        
        return false
    }
    
    var imagePickMethodAlertController: GeneralUIAlertController!
    
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
        self.setupToHideKeyboardOnTapOnView()
        
        // views
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButton)
        
        // values
        navigationItem.title = dogToUpdate == nil ? "Create Dog" : "Edit Dog"
        
        dogName.text = dogToUpdate?.dogName ?? ""
        dogName.delegate = self
        
        dogIcon.setImage(dogToUpdate?.dogIcon ?? ClassConstant.DogConstant.chooseDogIcon, for: .normal)
        
        var passedReminders: ReminderManager {
            return dogToUpdate?.dogReminders.copy() as? ReminderManager ?? ReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
        }
        
        // buttons
        dogIcon.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        dogIcon.layer.cornerRadius = dogIcon.frame.width / 2
        
        dogRemoveButton.isEnabled = dogToUpdate != nil
        
        initalDogName = dogName.text
        initalDogIcon = dogIcon.imageView?.image
        initalReminders = passedReminders
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = DogIconManager.setupDogIconImagePicker(forViewController: self)
        picker.delegate = self
        imagePickMethodAlertController = viewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    /// Hides the big gray back button and big blue checkmark, don't want access to them while editting a reminder.
    func willHideButtons(isHidden: Bool) {
        addDogButton.isHidden = isHidden
        cancelAddDogButton.isHidden = isHidden
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
