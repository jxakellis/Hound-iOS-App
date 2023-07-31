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
    
    @IBOutlet private weak var saveReminderButton: UIBarButtonItem!
    // Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder back to table view.
    @IBAction private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsReminderManagerViewController?.currentReminder else {
            return
        }
        
        if reminder.reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            LocalConfiguration.addReminderCustomAction(forName: reminder.reminderCustomActionName)
        }
        
        if reminderToUpdate == nil {
            delegate.willAddReminder(sender: Sender(origin: self, localized: self), forReminder: reminder)
        }
        else {
            delegate.willUpdateReminder(sender: Sender(origin: self, localized: self), forReminder: reminder)
        }
       
        // We are in a navigation controller currently, the last one in Hound. We use popViewController NOT dismiss
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func backButton(_ sender: Any) {
        // We are in a navigation controller currently, the last one in Hound. We use popViewController NOT dismiss
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet private weak var reminderRemoveButton: UIBarButtonItem!
    @IBAction private func willRemoveReminder(_ sender: Any) {
        
        guard let reminderToUpdate = reminderToUpdate else {
            reminderRemoveButton.isEnabled = false
            return
        }
        
        // Since this is the nested reminders view controller, meaning its nested in the larger Add Dog VC, we only perform the server queries when the user decides to create / update the greater dog.
        
        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController?.currentReminderAction?.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) ?? reminderToUpdate.reminderAction.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate.willRemoveReminder(sender: Sender(origin: self, localized: self), forReminder: reminderToUpdate)
            // We are in a navigation controller currently, the last one in Hound. We use popViewController NOT dismiss
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeReminderConfirmation.addAction(removeAlertAction)
        removeReminderConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeReminderConfirmation)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsNestedReminderViewControllerDelegate!
    
    private var dogsReminderManagerViewController: DogsReminderManagerViewController?
    
    private var reminderToUpdate: Reminder?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reminderRemoveButton.isEnabled = reminderToUpdate != nil
        saveReminderButton.title = reminderToUpdate != nil ? "Save" : "Add"
        pageNavigationBar.title = reminderToUpdate != nil ? "Edit Reminder" : "Create Reminder"
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsNestedReminderViewControllerDelegate, forReminderToUpdate: Reminder?) {
        delegate = forDelegate
        reminderToUpdate = forReminderToUpdate
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsReminderManagerViewController = segue.destination as? DogsReminderManagerViewController {
            self.dogsReminderManagerViewController = dogsReminderManagerViewController
            dogsReminderManagerViewController.setup(forReminderToUpdate: reminderToUpdate)
        }
    }
    
}
