//
//  DogsReminderTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderTableViewController: UITableViewController, DogsReminderTableViewCellDelegate, DogsNestedReminderViewControllerDelegate {
    
    // MARK: DogsNestedReminderViewControllerDelegate
    
    func willAddReminder(sender: Sender, forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder, shouldOverrideReminderWithSamePlaceholderId: false)
        reloadTable()
    }
    
    func willUpdateReminder(sender: Sender, forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder, shouldOverrideReminderWithSamePlaceholderId: true)
        reloadTable()
    }
    
    func willRemoveReminder(sender: Sender, forReminder: Reminder) {
        dogReminders.removeReminder(forReminderId: forReminder.reminderId)
        reloadTable()
    }
    
    // MARK: - DogsReminderTableViewCell
    
    func didUpdateReminderIsEnabled(sender: Sender, forReminderId: Int, forReminderIsEnabled: Bool) {
        dogReminders.findReminder(forReminderId: forReminderId)?.reminderIsEnabled = forReminderIsEnabled
    }
    
    // MARK: - Properties
    
    /// Used for when a reminder is selected (aka tapped) on the table view in order to pass information to open the editing page for the reminder
    private var selectedReminder: Reminder?
    
    // MARK: - Reminder Manager
    
    /// Use a reminders array instead of a ReminderManager. We will be performing changes on the reminderManager that can potentially be discarded by hitting the cancel button, therefore we can't use ReminderManager as it can invalidate timers
    var dogReminders: ReminderManager = ReminderManager()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTable()
        
        MainTabBarViewController.mainTabBarViewController?.dogsViewController?.dogsAddDogViewController.willHideButtons(isHidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MainTabBarViewController.mainTabBarViewController?.dogsViewController?.dogsAddDogViewController.willHideButtons(isHidden: true)
    }
    
    // MARK: - Functions
    
    /// Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    private func reloadTable() {
        
        tableView.rowHeight = dogReminders.reminders.isEmpty ? 65.5 : -1
        
        if dogReminders.reminders.isEmpty {
            tableView.allowsSelection = false
        }
        else {
            tableView.allowsSelection = true
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    /// Returns the number of cells present in section (currently only 1 section)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogReminders.reminders.count
    }
    
    /// Configures cells at the given index path, pulls from reminder manager reminders to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of reminder manager reminder e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogsReminderTableViewCell", for: indexPath)
        
        if let castCell = cell as? DogsReminderTableViewCell {
            castCell.delegate = self
            castCell.setup(forReminder: dogReminders.reminders[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReminder = dogReminders.reminders[indexPath.row]
        
        performSegueOnceInWindowHierarchy(segueIdentifier: "DogsNestedReminderViewController")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && dogReminders.reminders.isEmpty == false {
            let reminder = dogReminders.reminders[indexPath.row]
            
            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeReminderConfirmation.addAction(removeAlertAction)
            removeReminderConfirmation.addAction(cancelAlertAction)
            PresentationManager.enqueueAlert(removeReminderConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if dogReminders.reminders.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Links delegate to NestedReminder
        if let dogsNestedReminderViewController = segue.destination as? DogsNestedReminderViewController {
            dogsNestedReminderViewController.delegate = self
            
            dogsNestedReminderViewController.targetReminder = selectedReminder
            selectedReminder = nil
        }
    }
    
}
