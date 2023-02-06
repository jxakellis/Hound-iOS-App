//
//  DogsNestedReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// Delegate to pass setup reminder back to table view
protocol DogsNestedReminderViewControllerDelegate: AnyObject {
    func willAddReminder(sender: Sender, forReminder: Reminder)
    func willUpdateReminder(sender: Sender, forReminder: Reminder)
    func willRemoveReminder(sender: Sender, forReminder: Reminder)
}

final class DogsNestedReminderViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var pageNavigationBar: UINavigationItem!
    
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    // Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder back to table view.
    @IBAction private func willSave(_ sender: Any) {
        // Since this is the nested reminders view controller, meaning its nested in the larger Add Dog VC, we only perform the server queries when the user decides to create / update the greater dog.
        
        let reminder = dogsReminderManagerViewController.reminderWithSettingsApplied()
        // updatedReminder will be nil if a setting was invalid. If this is the case, dogsReminderManagerViewController will send a message to the user about it.
        guard let reminder = reminder else {
            return
        }
        
        // we were able to add the reminder successfully, so persist the possible reminderCustomActionName to the local storage. Technically, we should wait until the server query to complete to add this to memory but that will add significantly more complexity as this VC is nested.
        let reminderCustomActionName = reminder.reminderCustomActionName
        if reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            LocalConfiguration.addReminderCustomAction(forName: reminderCustomActionName)
        }
        
        if isUpdating == false {
            delegate.willAddReminder(sender: Sender(origin: self, localized: self), forReminder: reminder)
        }
        else {
            delegate.willUpdateReminder(sender: Sender(origin: self, localized: self), forReminder: reminder)
        }
       
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet private weak var reminderRemoveButton: UIBarButtonItem!
    @IBAction private func willRemoveReminder(_ sender: Any) {
        
        guard let targetReminder = targetReminder else {
            reminderRemoveButton.isEnabled = false
            return
        }
        
        // Since this is the nested reminders view controller, meaning its nested in the larger Add Dog VC, we only perform the server queries when the user decides to create / update the greater dog.
        
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.selectedReminderAction?.displayActionName(reminderCustomActionName: targetReminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) ?? targetReminder.reminderAction.displayActionName(reminderCustomActionName: targetReminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate.willRemoveReminder(sender: Sender(origin: self, localized: self), forReminder: targetReminder)
            navigationController?.popViewController(animated: true)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeReminderConfirmation.addAction(removeAlertAction)
        removeReminderConfirmation.addAction(cancelAlertAction)
        
        AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsNestedReminderViewControllerDelegate! = nil
    
    var dogsReminderManagerViewController = DogsReminderManagerViewController()
    
    var targetReminder: Reminder?
    
    var isUpdating: Bool {
        if targetReminder == nil {
            return false
        }
        else {
            return true
        }}
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUpdating == true {
            reminderRemoveButton.isEnabled = true
            saveButton.title = "Save"
            pageNavigationBar.title = "Edit Reminder"
        }
        else {
            reminderRemoveButton.isEnabled = false
            saveButton.title = "Add"
            pageNavigationBar.title = "Create Reminder"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsReminderManagerViewController = segue.destination as? DogsReminderManagerViewController {
            self.dogsReminderManagerViewController = dogsReminderManagerViewController
            dogsReminderManagerViewController.targetReminder = targetReminder
        }
    }
    
}
