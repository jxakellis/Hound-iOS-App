//
//  DogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsTableViewControllerDelegate: AnyObject {
    func shouldOpenDogMenu(forDogId: Int?)
    func shouldOpenReminderMenu(forDogId: Int, forReminder: Reminder?)
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func didUpdateAlphaForButtons(forAlpha: Double)
}

final class DogsTableViewController: UITableViewController {
    
    // TO DO NOW when a user taps at the top of the table, scroll back to top
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Sometimes the default contentOffset.y isn't 0.0, in testing it was -47.0, so we want to adjust that value to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - (defaultContentOffsetY ?? 0.0)
        // When scrollView.contentOffset.y reaches the value of alphaConstant, the UI element's alpha is set to 0 and is hidden.
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate.didUpdateAlphaForButtons(forAlpha: alpha)
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsTableViewControllerDelegate!
    
    private var loopTimer: Timer?
    
    private var defaultContentOffsetY: Double?
    
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
            self.reloadVisibleCellsNextAlarmLabels()
        }
        
        // start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to reminder added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.reloadVisibleCellsNextAlarmLabels), userInfo: nil, repeats: true)
            
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
        
        self.tableView.allowsSelection = !dogManager.dogs.isEmpty
        self.tableView.separatorStyle = .none
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    private var viewIsBeingViewed: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsBeingViewed = true
        
        self.tableView.reloadData()
        
        loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.reloadVisibleCellsNextAlarmLabels), userInfo: nil, repeats: true)
        
        if let loopTimer = loopTimer {
            RunLoop.main.add(loopTimer, forMode: .common)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dummyTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        
        if defaultContentOffsetY == nil {
            // Our dummyTableHeaderViewHeight conflicts with
            defaultContentOffsetY = tableView.contentOffset.y - tableView.contentInset.top
            // scrollViewDidScroll can be called at a point in which defaultContentOffsetY is ni, providing faulty alpha. This corrects for that
            delegate.didUpdateAlphaForButtons(forAlpha: 1.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsBeingViewed = false
        
        loopTimer?.invalidate()
        loopTimer = nil
    }
    
    // MARK: - Functions
    
    @objc private func reloadVisibleCellsNextAlarmLabels() {
        guard tableView.visibleCells.isEmpty == false else {
            loopTimer?.invalidate()
            loopTimer = nil
            return
        }
        
        for cell in tableView.visibleCells {
            (cell as? DogsReminderDisplayTableViewCell)?.reloadNextAlarmLabel()
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
            
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.refreshRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshRemindersSubtitle, forStyle: .success)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            // manually reload table as the self sernder doesn't do that
            self.tableView.reloadData()
        }
    }
    
    private func willShowDogActionSheet(forCell cell: DogsDogDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        guard let dogName = cell.dog?.dogName, let dogId = cell.dog?.dogId, let section = self.dogManager.dogs.firstIndex(where: { dog in
            return dog.dogId == dogId
        }) else {
            return
        }
        
        let alertController = UIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAlertAction = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            self.delegate.shouldOpenReminderMenu(forDogId: dogId, forReminder: nil)
        }
        
        let editAlertAction = UIAlertAction(
            title: "Edit Dog",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                self.delegate.shouldOpenDogMenu(forDogId: dogId)
            })
        
        let removeAlertAction = UIAlertAction(title: "Delete Dog", style: .destructive) { (alert) in
            
            // REMOVE CONFIRMATION
            let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)
            
            let confirmRemoveDogAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
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
            
            let confirmCancelRemoveDogAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeDogConfirmation.addAction(confirmRemoveDogAlertAction)
            removeDogConfirmation.addAction(confirmCancelRemoveDogAlertAction)
            
            PresentationManager.enqueueAlert(removeDogConfirmation)
        }
        
        alertController.addAction(addAlertAction)
        
        alertController.addAction(editAlertAction)
        
        alertController.addAction(removeAlertAction)
        
        alertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueActionSheet(alertController, sourceView: cell)
    }
    
    /// Called when a reminder is tapped by the user, display an action sheet of possible modifcations to the alarm/reminder.
    private func willShowReminderActionSheet(forCell cell: DogsReminderDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        guard let dog = dogManager.findDog(forDogId: cell.forDogId) else {
            return
        }
        
        let reminder: Reminder = cell.reminder
        
        let selectedReminderAlertController = UIAlertController(title: "You Selected: \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)) for \(dog.dogName)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate.shouldOpenReminderMenu(forDogId: cell.forDogId, forReminder: reminder)
        }
        
        // REMOVE BUTTON
        let removeAlertAction = UIAlertAction(title: "Delete Reminder", style: .destructive) { (_) in
            
            // REMOVE CONFIRMATION
            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
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
            
            PresentationManager.enqueueAlert(removeReminderConfirmation)
            
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
            let logAlertAction = UIAlertAction(
                title: "Undo Log for \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // logAction not needed as unskipping alarm does not require that component
                    AlarmManager.willUnskipReminder(
                        forDog: dog, forReminder: reminder)
                    PresentationManager.enqueueBanner(forTitle: "Undid \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))", forSubtitle: nil, forStyle: .success)
                    
                })
            alertActionsForLog.append(logAlertAction)
        }
        else {
            // Cant convert a reminderAction of potty directly to logAction, as it has serveral possible outcomes. Otherwise, logAction and reminderAction 1:1
            let logActions: [LogAction] = reminder.reminderAction == .potty ? [.pee, .poo, .both, .neither, .accident] : [LogAction(rawValue: reminder.reminderAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction]
            
            for logAction in logActions {
                let displayActionName = logAction.displayActionName(logCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
                let logAlertAction = UIAlertAction(
                    title: "Log \(displayActionName)",
                    style: .default,
                    handler: { (_)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willSkipReminder(forDogId: dog.dogId, forReminder: reminder, forLogAction: logAction)
                        PresentationManager.enqueueBanner(forTitle: "Logged \(displayActionName)", forSubtitle: nil, forStyle: .success)
                    })
                alertActionsForLog.append(logAlertAction)
            }
        }
        
        for logAlertAction in alertActionsForLog {
            selectedReminderAlertController.addAction(logAlertAction)
        }
        
        selectedReminderAlertController.addAction(editAlertAction)
        
        selectedReminderAlertController.addAction(removeAlertAction)
        
        selectedReminderAlertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueActionSheet(selectedReminderAlertController, sourceView: cell)
        
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dogManager.dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dogManager.dogs.isEmpty == false else {
            return 0
        }
        
        return dogManager.dogs[section].dogReminders.reminders.count + 1
    }
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // I don't fully understand how this spacing works. Setting the value to 0.0 makes it behave as expected. As soon as its >0.0, then its size is increased by some mysterious constant + whatever value I specified here.
        return 0.1
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard dogManager.dogs.isEmpty == false else {
            return UITableViewCell()
        }
        
        let cell = indexPath.row == 0
        ? tableView.dequeueReusableCell(withIdentifier: "DogsDogDisplayTableViewCell", for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: "DogsReminderDisplayTableViewCell", for: indexPath)
        
        if let castedCell = cell as? DogsDogDisplayTableViewCell {
            castedCell.setup(forDog: dogManager.dogs[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }
        else if let castedCell = cell as? DogsReminderDisplayTableViewCell {
            castedCell.setup(forForDogId: dogManager.dogs[indexPath.section].dogId, forReminder: dogManager.dogs[indexPath.section].dogReminders.reminders[indexPath.row - 1])
            
            // This cell is a bottom cell
            if indexPath.row == dogManager.dogs[indexPath.section].dogReminders.reminders.count {
                castedCell.containerView.roundCorners(setCorners: .bottom)
            }
            else {
                castedCell.containerView.roundCorners(setCorners: .none)
            }
        }
        
        return cell
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
        var removeConfirmation: UIAlertController?
        
        // delete dog
        if indexPath.row == 0, let dogCell = tableView.cellForRow(at: indexPath) as?  DogsDogDisplayTableViewCell, let dog = dogCell.dog {
            // cell in question
            
            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(dog.dogName)?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(invokeErrorManager: true, forDogId: dog.dogId) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    self.dogManager.removeDog(forDogId: dog.dogId)
                    self.dogManager.clearTimers()
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)
                    
                }
                
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(removeAlertAction)
            removeConfirmation?.addAction(cancelAlertAction)
        }
        // delete reminder
        if indexPath.row > 0, let reminderCell = tableView.cellForRow(at: indexPath) as? DogsReminderDisplayTableViewCell, let dog: Dog = dogManager.findDog(forDogId: reminderCell.forDogId) {
            let reminder: Reminder = reminderCell.reminder
            
            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(invokeErrorManager: true, forDogId: reminderCell.forDogId, forReminder: reminder) { requestWasSuccessful, _ in
                    guard requestWasSuccessful else {
                        return
                    }
                    dog.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }
                
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(removeAlertAction)
            removeConfirmation?.addAction(cancelAlertAction)
        }
        
        if let removeConfirmation = removeConfirmation {
            PresentationManager.enqueueAlert(removeConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dogManager.dogs.count >= 1
    }
    
}
