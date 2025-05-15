//
//  DogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsTableViewControllerDelegate: AnyObject {
    func shouldOpenDogMenu(forDogUUID: UUID?)
    func shouldOpenReminderMenu(forDogUUID: UUID, forReminder: Reminder?)
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func shouldUpdateAlphaForButtons(forAlpha: Double)
}

final class DogsTableViewController: GeneralUITableViewController {

    // MARK: - UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let referenceContentOffsetY = referenceContentOffsetY else {
            return
        }
        
        // Sometimes the default contentOffset.y isn't 0.0, in testing it was -47.0, so we want to adjust that value to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - referenceContentOffsetY
        // When scrollView.contentOffset.y reaches the value of alphaConstant, the UI element's alpha is set to 0 and is hidden.
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate.shouldUpdateAlphaForButtons(forAlpha: alpha)
    }

    // MARK: - Properties

    weak var delegate: DogsTableViewControllerDelegate!

    private var loopTimer: Timer?

    /// dummyTableTableHeaderViewHeight conflicts with our tableView. By adding it, we set our content inset to -dummyTableTableHeaderViewHeight. This change, when scrollViewDidScroll is invoked, makes it appear that we are scrolled dummyTableTableHeaderViewHeight down further than we are. Additionally, there is always some constant contentOffset, normally about -47.0, that is applied because of our tableView being constrainted to the superview and not safe area. Therefore, we have to track and correct for these.
    private(set) var referenceContentOffsetY: Double?

    // MARK: - Dog Manager

    private(set) var dogManager: DogManager = DogManager()

    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager

        // possible senders
        // DogsAddDogDisplayReminderTableViewCell
        // DogsDogTableViewCell
        // DogsViewController
        if !(sender.localized is DogsViewController) {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if !(sender.localized is DogsReminderTableViewCell) && !(sender.origin is DogsTableViewController) {
            self.tableView.reloadData()
        }
        if sender.localized is DogsReminderTableViewCell {
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
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
        
        // By default the tableView pads a header, even of height 0.0, by about 20.0 points
        self.tableView.sectionHeaderTopPadding = 0.0
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

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        let dummyTableTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)

        if referenceContentOffsetY == nil {
            referenceContentOffsetY = tableView.contentOffset.y
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
            (cell as? DogsReminderTableViewCell)?.reloadReminderNextAlarmLabel()
        }
    }

    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        PresentationManager.beginFetchingInformationIndictator()
        DogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogManager: dogManager) { newDogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndictator {
                // end refresh first otherwise there will be a weird visual issue
                self.tableView.refreshControl?.endRefreshing()

                guard responseStatus != .failureResponse, let newDogManager = newDogManager else {
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.successRefreshRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.successRefreshRemindersSubtitle, forStyle: .success)
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // If OfflineModeManager has displayed its banner that indicates its turning on, then we are safe to display this banner. Otherwise, we would run the risk of both of these banners displaying if its the first time enterin offline mode.
                        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldTitle, forSubtitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldSubtitle, forStyle: .info)
                    }
                }
                
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
                // manually reload table as the self sender doesn't do that
                self.tableView.reloadData()
            }
        }
    }

    private func willShowDogActionSheet(forCell cell: DogsDogTableViewCell, forIndexPath indexPath: IndexPath) {
        guard let dogName = cell.dog?.dogName, let dogUUID = cell.dog?.dogUUID, let section = self.dogManager.dogs.firstIndex(where: { dog in
            dog.dogUUID == dogUUID
        }) else {
            return
        }

        let alertController = UIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)

        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let addAlertAction = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            self.delegate.shouldOpenReminderMenu(forDogUUID: dogUUID, forReminder: nil)
        }

        let editAlertAction = UIAlertAction(
            title: "Edit Dog",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                self.delegate.shouldOpenDogMenu(forDogUUID: dogUUID)
            })

        let removeAlertAction = UIAlertAction(title: "Delete Dog", style: .destructive) { _ in

            // REMOVE CONFIRMATION
            let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)

            let confirmRemoveDogAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUID) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    self.dogManager.removeDog(forDogUUID: dogUUID)
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
    private func willShowReminderActionSheet(forCell cell: DogsReminderTableViewCell, forIndexPath indexPath: IndexPath) {
        guard let dogUUID = cell.dogUUID, let dog = dogManager.findDog(forDogUUID: dogUUID) else {
            return
        }
        
        guard let reminder = cell.reminder else {
            return
        }

        let selectedReminderAlertController = UIAlertController(title: "You Selected: \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName)) for \(dog.dogName)", message: nil, preferredStyle: .actionSheet)

        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let editAlertAction = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate.shouldOpenReminderMenu(forDogUUID: dogUUID, forReminder: reminder)
        }

        // REMOVE BUTTON
        let removeAlertAction = UIAlertAction(title: "Delete Reminder", style: .destructive) { _ in

            // REMOVE CONFIRMATION
            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)

            let removeReminderConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    dog.dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }

            }

            let removeReminderConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            removeReminderConfirmation.addAction(removeReminderConfirmationRemove)
            removeReminderConfirmation.addAction(removeReminderConfirmationCancel)

            PresentationManager.enqueueAlert(removeReminderConfirmation)

        }
        
        let skipOnceAlertAction = UIAlertAction(
            title: "Skip Once",
            style: .default,
            handler: { _ in
                self.userSkippedReminderOnce(forDogUUID: dog.dogUUID, forReminder: reminder)
                PresentationManager.enqueueBanner(forTitle: "Skipped \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName)) Once", forSubtitle: nil, forStyle: .success)
            })

        // DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        let shouldUndoLogOrUnskip: Bool = {
            guard reminder.reminderIsEnabled == true && reminder.snoozeComponents.executionInterval == nil else {
                return false
            }

            return (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping)
        }()
        
        let shouldShowSkipOnceAction: Bool = {
            guard shouldUndoLogOrUnskip == false else {
                return false
            }
            
            guard reminder.reminderType != .oneTime else {
                return false
            }

            return true
        }()

        // STORES LOG BUTTON(S)
        var alertActionsForLog: [UIAlertAction] = []

        // ADD LOG BUTTONS (MULTIPLE IF POTTY OR OTHER SPECIAL CASE)
        if shouldUndoLogOrUnskip == true {
            let logToUndo = findLogFromSkippedReminder(forDog: dog, forReminder: reminder)
            
            let logAlertAction = UIAlertAction(
                title:
                    (logToUndo != nil
                     ? "Undo Log "
                     : "Undo Skip ")
                    + "for \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName))",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    self.userSelectedUnskipReminder(forDog: dog, forReminder: reminder)
                    
                    let bannerTitle = (logToUndo != nil
                                       ? "Undid "
                                       : "Unskipped ")
                                      + reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName)
                    PresentationManager.enqueueBanner(forTitle: bannerTitle, forSubtitle: nil, forStyle: .success)

                })
            alertActionsForLog.append(logAlertAction)
        }
        else {
            // Cant convert a reminderAction of potty directly to logAction, as it has serveral possible outcomes. Otherwise, logAction and reminderAction 1:1
            let logActions: [LogAction] = reminder.reminderAction == .potty ? [.pee, .poo, .both, .neither, .accident] : [LogAction(internalValue: reminder.reminderAction.internalValue) ?? ClassConstant.LogConstant.defaultLogAction]

            for logAction in logActions {
                let fullReadableName = logAction.fullReadableName(logCustomActionName: reminder.reminderCustomActionName)
                let logAlertAction = UIAlertAction(
                    title: "Log \(fullReadableName)",
                    style: .default,
                    handler: { _ in
                        self.userPreemptivelyLoggedReminder(forDogUUID: dog.dogUUID, forReminder: reminder, forLogAction: logAction)
                        PresentationManager.enqueueBanner(forTitle: "Logged \(fullReadableName)", forSubtitle: nil, forStyle: .success)
                    })
                alertActionsForLog.append(logAlertAction)
            }
        }

        for logAlertAction in alertActionsForLog {
            selectedReminderAlertController.addAction(logAlertAction)
        }
        
        if shouldShowSkipOnceAction == true {
            selectedReminderAlertController.addAction(skipOnceAlertAction)
        }

        selectedReminderAlertController.addAction(editAlertAction)

        selectedReminderAlertController.addAction(removeAlertAction)

        selectedReminderAlertController.addAction(cancelAlertAction)

        PresentationManager.enqueueActionSheet(selectedReminderAlertController, sourceView: cell)

    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log. Only provide a UIViewController if you wish the spinning checkmark animation to happen.
    private func userPreemptivelyLoggedReminder(forDogUUID: UUID, forReminder: Reminder, forLogAction: LogAction) {
        let log = Log(forLogAction: forLogAction, forLogCustomActionName: forReminder.reminderCustomActionName, forLogStartDate: Date())

        // special case. Once a oneTime reminder executes/ is skipped, it must be delete. Therefore there are special server queries.
        if forReminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder

            // delete the reminder on the server
            RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminderUUIDs: [forReminder.reminderUUID]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                self.dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.removeReminder(forReminderUUID: forReminder.reminderUUID)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                // manually reload table as the self sender doesn't do that
                self.tableView.reloadData()
                
                LogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLog: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    self.dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.addLog(forLog: log)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            forReminder.enableIsSkipping(forSkippedDate: Date())

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminders: [forReminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }
                
                self.dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: forReminder)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)

                LogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLog: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    self.dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.addLog(forLog: log)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                }
            }
        }
    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log. Only provide a UIViewController if you wish the spinning checkmark animation to happen.
    private func userSkippedReminderOnce(forDogUUID: UUID, forReminder: Reminder) {
        guard forReminder.reminderType != .oneTime else {
            return
        }
        
        forReminder.enableIsSkipping(forSkippedDate: Date())
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminders: [forReminder]) { responseStatusReminderUpdate, _ in
            guard responseStatusReminderUpdate != .failureResponse else {
                return
            }
            
            self.dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: forReminder)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
        }
    }
    
    /// If a reminder was skipped, it could have either been a preemptive log (meaning there was a log created) or it was skipped without a log. Thus, locate the log if it exists.
    private func findLogFromSkippedReminder(forDog: Dog, forReminder: Reminder) -> Log? {
        // this is the time that the reminder's next alarm was skipped. at this same moment, a log was added. If this log is still there, with it's date unmodified by the user, then we remove it.
        let dateOfLogToRemove: Date? = {
            if forReminder.reminderType == .weekly {
                return forReminder.weeklyComponents.skippedDate
            }
            else if forReminder.reminderType == .monthly {
                return forReminder.monthlyComponents.skippedDate
            }
            
            return nil
        }()
        
        guard let dateOfLogToRemove = dateOfLogToRemove else {
            return nil
        }
        
        // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
        let logToRemove = forDog.dogLogs.logs.first(where: { log in
            return abs(dateOfLogToRemove.distance(to: log.logStartDate)) < 0.001
        })
        
        return logToRemove
    }

    /// The user went to unlog/unskip a reminder on the reminders page. Must update skipping information. Note: only weekly/monthly reminders can be skipped therefore only they can be unskipped.
    private func userSelectedUnskipReminder(forDog: Dog, forReminder: Reminder) {
        // we can only unskip a weekly/monthly reminder that is currently isSkipping == true
        guard (forReminder.reminderType == .weekly && forReminder.weeklyComponents.isSkipping == true) || (forReminder.reminderType == .monthly && forReminder.monthlyComponents.isSkipping == true) else {
            return
        }

        forReminder.disableIsSkipping()

        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDog.dogUUID, forReminders: [forReminder]) { responseStatusReminderUpdate, _ in
            guard responseStatusReminderUpdate != .failureResponse else {
                return
            }

            self.dogManager.findDog(forDogUUID: forDog.dogUUID)?.dogReminders.addReminder(forReminder: forReminder)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)

            // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
            guard let logToRemove = self.findLogFromSkippedReminder(forDog: forDog, forReminder: forReminder) else {
                return
            }

            // log to remove from unlog event. Attempt to delete the log server side
            LogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDog.dogUUID, forLogUUID: logToRemove.logUUID) { responseStatusLogDelete, _ in
                guard responseStatusLogDelete != .failureResponse else {
                    return
                }

                self.dogManager.findDog(forDogUUID: forDog.dogUUID)?.dogLogs.removeLog(forLogUUID: logToRemove.logUUID)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
            }

        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dogManager.dogs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dogManager.dogs.isEmpty == false else {
            return 0
        }

        return dogManager.dogs[section].dogReminders.reminders.count + 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set the spacing between sections by configuring the header height
        return 25.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Make a blank headerView so that there is a header view
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard dogManager.dogs.isEmpty == false else {
            return UITableViewCell()
        }

        let cell = indexPath.row == 0
        ? tableView.dequeueReusableCell(withIdentifier: "DogsDogTableViewCell", for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: "DogsReminderTableViewCell", for: indexPath)

        if let castedCell = cell as? DogsDogTableViewCell {
            castedCell.setup(forDog: dogManager.dogs[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }
        else if let castedCell = cell as? DogsReminderTableViewCell {
            castedCell.setup(forDogUUID: dogManager.dogs[indexPath.section].dogUUID, forReminder: dogManager.dogs[indexPath.section].dogReminders.reminders[indexPath.row - 1])

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

        if indexPath.row == 0, let dogsDogDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogsDogTableViewCell {
            willShowDogActionSheet(forCell: dogsDogDisplayTableViewCell, forIndexPath: indexPath)
        }
        else if indexPath.row > 0, let dogsReminderDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogsReminderTableViewCell {
            willShowReminderActionSheet(forCell: dogsReminderDisplayTableViewCell, forIndexPath: indexPath)
        }

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete && dogManager.dogs.isEmpty == false else {
            return
        }
        var removeConfirmation: UIAlertController?

        // delete dog
        if indexPath.row == 0, let dogCell = tableView.cellForRow(at: indexPath) as?  DogsDogTableViewCell, let dog = dogCell.dog {
            // cell in question

            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(dog.dogName)?", message: nil, preferredStyle: .alert)

            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    self.dogManager.removeDog(forDogUUID: dog.dogUUID)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)

                }

            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(removeAlertAction)
            removeConfirmation?.addAction(cancelAlertAction)
        }
        // delete reminder
        if indexPath.row > 0, let reminderCell = tableView.cellForRow(at: indexPath) as? DogsReminderTableViewCell, let dogUUID = reminderCell.dogUUID, let dog: Dog = dogManager.findDog(forDogUUID: dogUUID), let reminder = reminderCell.reminder {
            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.fullReadableName(reminderCustomActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)

            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUID, forReminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    dog.dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
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
        dogManager.dogs.count >= 1
    }

}
