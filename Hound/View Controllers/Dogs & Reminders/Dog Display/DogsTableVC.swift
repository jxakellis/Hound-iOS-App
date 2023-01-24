//
//  DogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsTableViewControllerDelegate: AnyObject {
    func willOpenDogMenu(forDogId: Int?)
    func willOpenReminderMenu(forDogId: Int, forReminder: Reminder?)
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class DogsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var delegate: DogsTableViewControllerDelegate! = nil
    
    private var loopTimer: Timer?
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // possible senders
        // DogsReminderTableViewCell
        // DogsDogDisplayTableViewCell
        // DogsViewController
        if !(sender.localized is DogsViewController) {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if !(sender.localized is DogsReminderDisplayTableViewCell) && !(sender.origin is DogsTableViewController) {
            self.tableView.reloadData()
        }
        if sender.localized is DogsReminderDisplayTableViewCell {
            self.reloadVisibleCellsTimeLeftLabel()
        }
        
        // start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to reminder added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)
            
            if let loopTimer = loopTimer {
                RunLoop.main.add(loopTimer, forMode: .common)
            }
        }
        
        tableView.allowsSelection = !dogManager.dogs.isEmpty
        tableView.rowHeight = dogManager.dogs.isEmpty ? 65.5 : -1.0
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dogManager.dogs.isEmpty {
            tableView.allowsSelection = false
        }
        
        tableView.separatorInset = .zero
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    private var viewIsBeingViewed: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsBeingViewed = true
        
        self.tableView.reloadData()
        
        loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)
        
        if let loopTimer = loopTimer {
            RunLoop.main.add(loopTimer, forMode: .common)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsBeingViewed = false
        
        loopTimer?.invalidate()
        loopTimer = nil
    }
    
    // MARK: - Functions
    
    @objc private func loopReload() {
        if tableView.visibleCells.isEmpty {
            loopTimer?.invalidate()
            loopTimer = nil
        }
        else {
            reloadVisibleCellsTimeLeftLabel()
        }
    }
    
    private func reloadVisibleCellsTimeLeftLabel() {
        for cell in tableView.visibleCells {
            if let sudoCell = cell as? DogsReminderDisplayTableViewCell {
                sudoCell.reloadNextAlarmText()
            }
        }
    }
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        DogsRequest.get(invokeErrorManager: true, dogManager: dogManager) { newDogManager, _ in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            
            guard let newDogManager = newDogManager else {
                return
            }
            
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshRemindersSubtitle, forStyle: .success)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            // manually reload table as the self sernder doesn't do that
            self.tableView.reloadData()
        }
    }
    
    /// Shows action sheet of possible optiosn to do to dog
    private func willShowDogActionSheet(forCell cell: DogsDogDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        // properties
        let dog: Dog = cell.dog
        let dogName = dog.dogName
        let dogId = dog.dogId
        guard let section = self.dogManager.dogs.firstIndex(where: { dog in
            return dog.dogId == dogId
        }) else {
            return
        }
        
        let alertController = GeneralUIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertActionAdd = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            self.delegate.willOpenReminderMenu(forDogId: dogId, forReminder: nil)
        }
        
        let alertActionEdit = UIAlertAction(
            title: "Edit Dog",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                self.delegate.willOpenDogMenu(forDogId: dogId)
            })
        
        let alertActionRemove = UIAlertAction(title: "Delete Dog", style: .destructive) { (alert) in
            
            // REMOVE CONFIRMATION
            let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)
            
            let removeDogConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(invokeErrorManager: true, forDogId: dogId) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    self.dogManager.removeDog(forDogId: dogId)
                    self.dogManager.clearTimers()
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteSections([section], with: .automatic)
                    
                }
            }
            
            let removeDogConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeDogConfirmation.addAction(removeDogConfirmationRemove)
            removeDogConfirmation.addAction(removeDogConfirmationCancel)
            
            AlertManager.enqueueAlertForPresentation(removeDogConfirmation)
        }
        
        alertController.addAction(alertActionAdd)
        
        alertController.addAction(alertActionEdit)
        
        alertController.addAction(alertActionRemove)
        
        alertController.addAction(alertActionCancel)
        
        AlertManager.enqueueActionSheetForPresentation(alertController, sourceView: cell, permittedArrowDirections: [.up, .down])
    }
    
    /// Called when a reminder is tapped by the user, display an action sheet of possible modifcations to the alarm/reminder.
    private func willShowReminderActionSheet(forCell cell: DogsReminderDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        guard let dog = dogManager.findDog(forDogId: cell.forDogId) else {
            return
        }
        
        let reminder: Reminder = cell.reminder
        
        let selectedReminderAlertController = GeneralUIAlertController(title: "You Selected: \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)) for \(dog.dogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertActionEdit = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate.willOpenReminderMenu(forDogId: cell.forDogId, forReminder: reminder)
        }
        
        // REMOVE BUTTON
        let alertActionRemove = UIAlertAction(title: "Delete Reminder", style: .destructive) { (_) in
            
            // REMOVE CONFIRMATION
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let removeReminderConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forReminder: reminder) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    dog.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                    
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }
                
            }
            
            let removeReminderConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeReminderConfirmation.addAction(removeReminderConfirmationRemove)
            removeReminderConfirmation.addAction(removeReminderConfirmationCancel)
            
            AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
            
        }
        
        // DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        let shouldUndoLog: Bool = {
            guard reminder.reminderIsEnabled == true && reminder.snoozeComponents.executionInterval == nil else {
                return false
            }
            
            return (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping)
        }()
        
        // STORES LOG BUTTON(S)
        var alertActionsForLog: [UIAlertAction] = []
        
        // ADD LOG BUTTONS (MULTIPLE IF POTTY OR OTHER SPECIAL CASE)
        if shouldUndoLog == true {
            let alertActionLog = UIAlertAction(
                title: "Undo Log for \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // logAction not needed as unskipping alarm does not require that component
                    AlarmManager.willUnskipReminder(
                        forDog: dog, forReminder: reminder)
                    AlertManager.enqueueBannerForPresentation(forTitle: "Undid \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))", forSubtitle: nil, forStyle: .success)
                    
                })
            alertActionsForLog.append(alertActionLog)
        }
        else {
            // Cant convert a reminderAction of potty directly to logAction, as it has serveral possible outcomes. Otherwise, logAction and reminderAction 1:1
            let logActions: [LogAction] = reminder.reminderAction == .potty ? [.pee, .poo, .both, .neither, .accident] : [LogAction(rawValue: reminder.reminderAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction]
            
            for logAction in logActions {
                let displayActionName = logAction.displayActionName(logCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
                let alertActionLog = UIAlertAction(
                    title: "Log \(displayActionName)",
                    style: .default,
                    handler: { (_)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willSkipReminder(forDogId: dog.dogId, forReminder: reminder, forLogAction: logAction)
                        AlertManager.enqueueBannerForPresentation(forTitle: "Logged \(displayActionName)", forSubtitle: nil, forStyle: .success)
                    })
                alertActionsForLog.append(alertActionLog)
            }
        }
        
        for alertActionLog in alertActionsForLog {
            selectedReminderAlertController.addAction(alertActionLog)
        }
        
        selectedReminderAlertController.addAction(alertActionEdit)
        
        selectedReminderAlertController.addAction(alertActionRemove)
        
        selectedReminderAlertController.addAction(alertActionCancel)
        
        AlertManager.enqueueActionSheetForPresentation(selectedReminderAlertController, sourceView: cell, permittedArrowDirections: [.up, .down])
        
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard dogManager.dogs.isEmpty == false else {
            return 0
        }
        
        return dogManager.dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dogManager.dogs.isEmpty == false else {
            return 0
        }
        
        return dogManager.dogs[section].dogReminders.reminders.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard dogManager.dogs.isEmpty == false else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DogsDogDisplayTableViewCell", for: indexPath)
            
            if let customCell = cell as? DogsDogDisplayTableViewCell {
                customCell.setup(forDog: dogManager.dogs[indexPath.section])
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DogsReminderDisplayTableViewCell", for: indexPath)
            
            if let customCell = cell as? DogsReminderDisplayTableViewCell {
                customCell.setup(forForDogId: dogManager.dogs[indexPath.section].dogId, forReminder: dogManager.dogs[indexPath.section].dogReminders.reminders[indexPath.row - 1])
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard dogManager.dogs.isEmpty == false else {
            return
        }
        
        if indexPath.row == 0, let dogsDogDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogsDogDisplayTableViewCell {
            willShowDogActionSheet(forCell: dogsDogDisplayTableViewCell, forIndexPath: indexPath)
        }
        else if indexPath.row > 0, let dogsReminderDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogsReminderDisplayTableViewCell {
            willShowReminderActionSheet(forCell: dogsReminderDisplayTableViewCell, forIndexPath: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete && dogManager.dogs.isEmpty == false else {
            return
        }
        var removeConfirmation: GeneralUIAlertController?
        
        // delete dog
        if indexPath.row == 0, let dogCell = tableView.cellForRow(at: indexPath) as?  DogsDogDisplayTableViewCell {
            // cell in question
            
            let dogId: Int = dogCell.dog.dogId
            
            removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogCell.dog.dogName)?", message: nil, preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(invokeErrorManager: true, forDogId: dogId) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    self.dogManager.removeDog(forDogId: dogId)
                    self.dogManager.clearTimers()
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)
                    
                }
                
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(alertActionRemove)
            removeConfirmation?.addAction(alertActionCancel)
        }
        // delete reminder
        if indexPath.row > 0, let reminderCell = tableView.cellForRow(at: indexPath) as? DogsReminderDisplayTableViewCell, let dog: Dog = dogManager.findDog(forDogId: reminderCell.forDogId) {
            let reminder: Reminder = reminderCell.reminder
            
            removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(invokeErrorManager: true, forDogId: reminderCell.forDogId, forReminder: reminder) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    dog.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }
                
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(alertActionRemove)
            removeConfirmation?.addAction(alertActionCancel)
        }
        
        if let removeConfirmation = removeConfirmation {
            AlertManager.enqueueAlertForPresentation(removeConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dogManager.dogs.count >= 1
    }
    
}
