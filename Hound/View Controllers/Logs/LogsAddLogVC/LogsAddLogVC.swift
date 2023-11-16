//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsAddLogViewController: UIViewController, LogsAddLogUIResponderDelegate, UIGestureRecognizerDelegate, DropDownUIViewDataSource {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let deepestTouchedView: UIView? = {
            // Given a touch point in our gesture recognizer, which was probably the scroll view, find the firstest nested subview. This will tell us what was truly touched by the user.
            
            // The original touch point of our gesture, which should be converted to our container view
            let originalTouchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            
            if let convertedPoint = gestureRecognizer.view?.convert(originalTouchPoint, to: containerView) {
                // Successfully got touch point in-terms of our containerView
                
                // Check for deepestTouchedView recursively. This looks for the furthest subview
                func findDeepestTouchedView(_ view: UIView, point: CGPoint) -> UIView? {
                    guard view.bounds.contains(point) else {
                        return nil
                    }
                    
                    // Check subviews recursively, .reversed() gives us the furthest nested subview
                    for subview in view.subviews.reversed() {
                        let convertedPoint = view.convert(point, to: subview)
                        
                        if let foundView = findDeepestTouchedView(subview, point: convertedPoint) {
                            // One of the subviews contains the point listed, so there is a further subview (which will be found recursively)
                            return foundView
                        }
                    }
                    
                    // None of the subviews contain the point listed or there are no subviews, so this view is the deepest subview.
                    return view
                }
                
                return findDeepestTouchedView(containerView, point: convertedPoint)
            }
            
            return nil
        }()
        
        print("\nGesture Recognizer")
        print("parentDogLabel", deepestTouchedView?.isDescendant(of: parentDogLabel))
        print("logActionLabel", deepestTouchedView?.isDescendant(of: logActionLabel))
        print("logUnitLabel", deepestTouchedView?.isDescendant(of: logUnitLabel))
        print("logStartDateLabel", deepestTouchedView?.isDescendant(of: logStartDateLabel))
        print("logEndDateLabel", deepestTouchedView?.isDescendant(of: logEndDateLabel))
        print("logNoteTextView", deepestTouchedView?.isDescendant(of: logNoteTextView))
        if let dropDownParentDog = dropDownParentDog {
            print("dropDownParentDog", deepestTouchedView?.isDescendant(of: dropDownParentDog))
        }
        if let dropDownLogAction = dropDownLogAction {
            print("dropDownLogAction", deepestTouchedView?.isDescendant(of: dropDownLogAction))
        }
        if let dropDownLogUnit = dropDownLogUnit {
            print("dropDownLogUnit", deepestTouchedView?.isDescendant(of: dropDownLogUnit))
        }
        
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!
    
    @IBOutlet private weak var parentDogLabel: GeneralUILabel!
    @IBOutlet private weak var parentDogHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var parentDogBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var familyMemberNameLabel: GeneralUILabel!
    @IBOutlet private weak var familyMemberNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var familyMemberNameBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionLabel: GeneralUILabel!
    
    /// Text input for logCustomActionNameName
    @IBOutlet private weak var logCustomActionNameTextField: GeneralUITextField!
    @IBOutlet private weak var logCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logCustomActionNameBottomConstraint: NSLayoutConstraint!
    @IBAction private func didUpdateLogCustomActionName(_ sender: Any) {
        hideDynamicUIElementsIfNeeded()
    }
    
    @IBOutlet private weak var logNumberOfLogUnitsTextField: GeneralUITextField!
    @IBOutlet private weak var logUnitLabel: GeneralUILabel!
    @IBOutlet private weak var logUnitHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logUnitBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteTextView: GeneralUITextView!
    
    @IBOutlet private weak var logStartDateLabel: GeneralUILabel!
    
    @IBOutlet private weak var logEndDateLabel: GeneralUILabel!
    
    @IBOutlet private weak var resetCorrespondingRemindersLabel: GeneralUILabel!
    @IBOutlet private weak var resetCorrespondingRemindersSwitch: UISwitch!
    @IBOutlet private weak var resetCorrespondingRemindersHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var resetCorrespondingRemindersBottomConstraint: NSLayoutConstraint!
    
    private var logStartDateDatePicker: UIDatePicker = UIDatePicker()
     /*
    @IBAction private func didUpdateLogDate(_ sender: Any) {
        self.dismissKeyboard()
    }
     */
    
    @IBOutlet private weak var backButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideBack(_ sender: Any) {
        
        self.dismissKeyboard()
        
        if didUpdateInitialValues == true {
            let unsavedInformationConfirmation = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let exitAlertAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                self.dismiss(animated: true)
            }
            
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(exitAlertAction)
            unsavedInformationConfirmation.addAction(cancelAlertAction)
            
            PresentationManager.enqueueAlert(unsavedInformationConfirmation)
        }
        else {
            self.dismiss(animated: true)
        }
        
    }
    
    @IBOutlet private weak var addLogButton: GeneralWithBackgroundUIButton!
    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()
        
        do {
            guard forDogIdsSelected.count >= 1 else {
                throw ErrorConstant.LogError.parentDogMissing()
            }
            guard let logActionSelected = logActionSelected else {
                throw ErrorConstant.LogError.logActionMissing()
            }
            
            // Check to see if we are updating or adding a log
            guard let dogIdToUpdate = dogIdToUpdate, let logToUpdate = logToUpdate else {
                // Adding a log
                addLogButton.beginSpinning()
                
                // Only retrieve correspondingReminders if switch is on. The switch can only be on if the correspondingReminders array isn't empty and the user turned it on themselves. The switch is hidden when correspondingReminders.isEmpty.
                let correspondingReminders = resetCorrespondingRemindersSwitch.isOn ? self.correspondingReminders : []
                
                let completionTracker = CompletionTracker(numberOfTasks: forDogIdsSelected.count + correspondingReminders.count) {
                    // everytime a task completes, update the dog manager so everything else updates
                    if let dogManager = self.dogManager {
                        self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                    }
                } completedAllTasksCompletionHandler: {
                    // when everything completes, close the page
                    self.addLogButton.endSpinning()
                    self.dismiss(animated: true)
                } failedTaskCompletionHandler: {
                    // if a problem is encountered, then just stop the indicator
                    self.addLogButton.endSpinning()
                }
                
                correspondingReminders.forEach { dogId, reminder in
                    reminder.enableIsSkipping(forSkippedDate: logStartDateDatePicker.date)
                    
                    RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _, _ in
                        guard requestWasSuccessful else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        completionTracker.completedTask()
                    }
                }
                
                let newLog = Log()
                newLog.logAction = logActionSelected
                newLog.logCustomActionName = logCustomActionNameTextField.text ?? ""
                newLog.changeLogUnit(
                    forLogUnit: logUnitSelected,
                    forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
                )
                newLog.logStartDate = logStartDateDatePicker.date
                newLog.logNote = logNoteTextView.text ?? ""
                
                forDogIdsSelected.forEach { dogId in
                    // Each dog needs it's own newLog object.
                    guard let newLog = newLog.copy() as? Log else {
                        return
                    }
                    
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: newLog) { requestWasSuccessful, _, _ in
                        guard requestWasSuccessful else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        let logCustomActionName = newLog.logCustomActionName
                        // request was successful so we can now add the new logCustomActionName (if present)
                        if logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                            LocalConfiguration.addLogCustomAction(forName: logCustomActionName)
                        }
                        
                        self.dogManager?.findDog(forDogId: dogId)?.dogLogs.addLog(forLog: newLog)
                        
                        completionTracker.completedTask()
                    }
                    
                }
                
                return
            }
            
            // Updating a log
            logToUpdate.logStartDate = logStartDateDatePicker.date
            logToUpdate.logAction = logActionSelected
            logToUpdate.logCustomActionName = logActionSelected == LogAction.custom ? logCustomActionNameTextField.text ?? "" : ""
            logToUpdate.changeLogUnit(
                forLogUnit: logUnitSelected,
                forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
            )
            logToUpdate.logNote = logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote
            
            addLogButton.beginSpinning()
            
            LogsRequest.update(invokeErrorManager: true, forDogId: dogIdToUpdate, forLog: logToUpdate) { requestWasSuccessful, _, _ in
                self.addLogButton.endSpinning()
                guard requestWasSuccessful else {
                    return
                }
                
                // request was successful so we can now add the new logCustomActionName (if present)
                let logCustomActionName = logToUpdate.logCustomActionName
                if logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    LocalConfiguration.addLogCustomAction(forName: logCustomActionName)
                }
                
                self.dogManager?.findDog(forDogId: dogIdToUpdate)?.dogLogs.addLog(forLog: logToUpdate)
                
                if let dogManager = self.dogManager {
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                
                self.dismiss(animated: true)
            }
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown().alert()
        }
    }
    
    @IBOutlet private weak var removeLogButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideRemoveLog(_ sender: Any) {
        
        guard let dogIdToUpdate = dogIdToUpdate, let logToUpdate = logToUpdate else {
            return
        }
        
        let removeLogConfirmation = UIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // the user decided to delete so we must query server
            LogsRequest.delete(invokeErrorManager: true, forDogId: dogIdToUpdate, forLogId: logToUpdate.logId) { requestWasSuccessful, _, _ in
                
                guard requestWasSuccessful else {
                    return
                }
                
                if let dog = self.dogManager?.findDog(forDogId: dogIdToUpdate) {
                    for dogLog in dog.dogLogs.logs where dogLog.logId == logToUpdate.logId {
                        dog.dogLogs.removeLog(forLogId: dogLog.logId)
                    }
                }
                
                if let dogManager = self.dogManager {
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                
                self.dismiss(animated: true)
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeLogConfirmation.addAction(removeAlertAction)
        removeLogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeLogConfirmation)
    }
    
    // MARK: - Properties
    
    weak var delegate: LogsAddLogCommunicationDelegate!
    
    private lazy var uiDelegate: LogsAddLogUIInteractionDelegate = {
            let delegate = LogsAddLogUIInteractionDelegate()
            delegate.actionsDelegate = self
            delegate.logCustomActionNameTextField = self.logCustomActionNameTextField
            delegate.logNumberOfLogUnitsTextField = self.logNumberOfLogUnitsTextField
            return delegate
        }()
    
    private var dogManager: DogManager?
    private var dogIdToUpdate: Int?
    private var logToUpdate: Log?
    
    // MARK: Initial Value Tracking
    
    private var initialForDogIdsSelected: [Int] = []
    private var initialLogAction: LogAction?
    private var initialLogCustomActionName: String?
    private var initialLogUnit: LogUnit?
    private var initialLogNumberOfLogUnits: String?
    private var initialLogNote: String?
    private var initialLogStartDate: Date?
    private var initialLogEndDate: Date?
    
    var didUpdateInitialValues: Bool {
        if initialLogAction != logActionSelected {
            return true
        }
        if logActionSelected == LogAction.custom && initialLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        if initialLogUnit != logUnitSelected {
            return true
        }
        if initialLogNumberOfLogUnits != logNumberOfLogUnitsTextField.text {
            return true
        }
        if initialLogNote != logNoteTextView.text {
            return true
        }
        if initialLogStartDate != logStartDateDatePicker.date {
            return true
        }
        if initialLogEndDate != logStartDateDatePicker.date {
            return true
        }
        if initialForDogIdsSelected != forDogIdsSelected {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Parent Dog Drop Down
    
    private let dropDownParentDogIdentifier = "DropDownParentDog"
    private var dropDownParentDog: DropDownUIView?
    private var dropDownParentDogNumberOfRows: Double {
        guard let dogManager = dogManager else {
            return 0.0
        }
        
        return dogManager.dogs.count > 4 ? 4.5 : CGFloat(dogManager.dogs.count)
    }
    private var forDogIdsSelected: [Int] = [] {
        didSet {
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let parentDogLabel = parentDogLabel {
                parentDogLabel.text = {
                    guard let dogManager = dogManager, forDogIdsSelected.count >= 1 else {
                        // If no forDogIdsSelected.isEmpty, we leave the text blank so that the placeholder text will display
                        return nil
                    }
                    
                    // dogSelected is the dog tapped and now that dog is removed, we need to find the name of the remaining dog
                    if forDogIdsSelected.count == 1, let lastRemainingDogId = forDogIdsSelected.first, let lastRemainingDog = dogManager.dogs.first(where: { dog in
                        return dog.dogId == lastRemainingDogId
                    }) {
                        return lastRemainingDog.dogName
                    }
                    else if forDogIdsSelected.count > 1 && forDogIdsSelected.count < dogManager.dogs.count {
                        return "Multiple"
                    }
                    else if forDogIdsSelected.count == dogManager.dogs.count {
                        return "All"
                    }
                    
                    return nil
                }()
            }
        }
        
    }
    
    // MARK: Log Action Drop Down
    
    private let dropDownLogActionIdentifier = "DropDownLogAction"
    private var dropDownLogAction: DropDownUIView?
    private let dropDownLogActionNumberOfRows = 5.5
    /// the name of the selected log action in drop down
    private var logActionSelected: LogAction? {
        didSet {
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let logActionLabel = logActionLabel {
                // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logAction dropdown, so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName", the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
                logActionLabel.text = logActionSelected?.displayActionName(logCustomActionName: nil)
            }
            
            // If log action is changed to something where the current logUnit is no longer valid, change logUnitSelected to nil
            if let logActionSelected = logActionSelected {
                let validLogUnits = LogUnit.logUnits(forLogAction: logActionSelected)
                
                if let logUnitSelected = logUnitSelected, validLogUnits.contains(logUnitSelected) == false {
                    self.logUnitSelected = nil
                }
            }
            else {
                logUnitSelected = nil
            }
        }
    }
    
    // MARK: Log Unit Drop Down
    private let dropDownLogUnitIdentifier = "DropDownLogUnit"
    private var dropDownLogUnit: DropDownUIView?
    private var dropDownLogUnitNumberOfRows: Double {
        guard let logActionSelected = logActionSelected else {
            return 0.0
        }
        
        let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
        
        return logUnits.count > 4 ? 4.5 : CGFloat(logUnits.count)
    }
    /// the name of the selected log unit in drop down
    private var logUnitSelected: LogUnit? {
        didSet {
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let logUnitLabel = logUnitLabel {
                
                if let logUnitSelected = logUnitSelected {
                    logUnitLabel.text = LogUnit.adjustedPluralityString(
                        forLogUnit: logUnitSelected,
                        forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
                    )
                }
                else {
                    logUnitLabel.text = nil
                }
                
            }
            
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let logNumberOfLogUnitsTextField = logNumberOfLogUnitsTextField {
                logNumberOfLogUnitsTextField.isEnabled = logUnitSelected != nil
            }
            
        }
    }
    
    // MARK: Log Start Date Drop Down
    private var logStartDateSelected: Date? {
        didSet {
            if let logStartDateSelected = logStartDateSelected {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(logStartDateSelected) {
                    // logStartDateSelected is the same day as today, so extra information is unnecessary
                    // 7:53 AM
                    dateFormatter.setLocalizedDateFormatFromTemplate("hma")
                }
                else {
                    // logStartDateSelected is not today
                    let logStartDateYear = Calendar.current.component(.year, from: logStartDateSelected)
                    let currentYear = Calendar.current.component(.year, from: Date())
                    
                    // January 25 at 7:53 AM OR January 25, 2023 at 7:53 AM
                    dateFormatter.setLocalizedDateFormatFromTemplate(logStartDateYear == currentYear ? "MMMMdhma" : "MMMMdyyyyhma")
                }
               
                logStartDateLabel.text = dateFormatter.string(from: logStartDateSelected)
            }
            else {
                logStartDateLabel.text = nil
            }
            
        }
    }
    
    // MARK: Log End Date Drop Down
    private var logEndDateSelected: Date? {
        didSet {
            if let logEndDateSelected = logEndDateSelected {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(logEndDateSelected) {
                    // logStartDateSelected is the same day as today, so extra information is unnecessary
                    // 7:53 AM
                    dateFormatter.setLocalizedDateFormatFromTemplate("hma")
                }
                else {
                    // logEndDateSelected is not today
                    let logEndDateYear = Calendar.current.component(.year, from: logEndDateSelected)
                    let currentYear = Calendar.current.component(.year, from: Date())
                    
                    // January 25 at 7:53 AM OR January 25, 2023 at 7:53 AM
                    dateFormatter.setLocalizedDateFormatFromTemplate(logEndDateYear == currentYear ? "MMMMdhma" : "MMMMdyyyyhma")
                }
               
                logEndDateLabel.text = dateFormatter.string(from: logEndDateSelected)
            }
            else {
                logEndDateLabel.text = nil
            }
            
        }
    }
    
    // MARK: Other
    
    /// Iterates through all of the dogs currently selected in the create logs page. Returns any of those dogs' reminders where the reminder's reminderAction and reminderCustomActionName match the logActionSelected and logCustomActionNameTextField.text. This means that the log the user wants to create has a corresponding reminder of the same type under one of the dogs selected.
    private var correspondingReminders: [(Int, Reminder)] {
        guard let dogManager = dogManager else {
            return []
        }
        
        var correspondingReminders: [(Int, Reminder)] = []
        guard logToUpdate == nil else {
            // Only eligible to reset corresponding reminders if creating a log
            return correspondingReminders
        }
        
        guard let logActionSelected = logActionSelected else {
            // Can't find a corresponding reminder if no logAction selected
            return correspondingReminders
        }
        
        // Attempt to translate logAction back into a reminderAction
        guard let selectedReminderAction = {
            for reminderAction in ReminderAction.allCases where logActionSelected.rawValue.contains(reminderAction.rawValue) {
                return reminderAction
            }
            return nil
        }() else {
            // couldn't translate logAction into reminderAction
            return correspondingReminders
        }
        
        // logAction could successfully be translated back into a reminder action (some logAction types, like treat, can't be a reminder action)
        
        // Find the dogs that are currently selected
        let selectedDogs = dogManager.dogs.filter { dog in
            forDogIdsSelected.contains(dog.dogId)
        }
        
        // Search through all of the dogs currently selected. For each dog, find any reminders where the reminderAction and reminderCustomActionName match the logAction and logCustomActionName currently selected on the create log page.
        for selectedDog in selectedDogs {
            correspondingReminders += selectedDog.dogReminders.reminders.filter { selectedDogReminder in
                guard selectedDogReminder.reminderIsEnabled == true else {
                    // Reminder needs to be enabled to be considered
                    return false
                }
                
                guard selectedDogReminder.reminderAction == selectedReminderAction else {
                    // Both reminderActions need to match
                    return false
                }
                
                // If the reminderAction is .custom, then the customActionName need to also match.
                return (selectedDogReminder.reminderAction != .custom)
                || (selectedDogReminder.reminderAction == .custom && selectedDogReminder.reminderCustomActionName == logCustomActionNameTextField.text)
            }
            .map { selectedDogCorrespondingReminder in
                (selectedDog.dogId, selectedDogCorrespondingReminder)
            }
        }
        
        return correspondingReminders
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set forDogIdsSelected = [] to invoke didSet
        forDogIdsSelected = []
        initialForDogIdsSelected = forDogIdsSelected
        
        guard let dogManager = dogManager else {
            return
        }
        
        if let dogIdToUpdate = dogIdToUpdate, logToUpdate != nil {
            pageTitleLabel.text = "Edit Log"
            if let dog = dogManager.findDog(forDogId: dogIdToUpdate) {
                forDogIdsSelected = [dog.dogId]
                initialForDogIdsSelected = forDogIdsSelected
            }
            
            parentDogLabel.isEnabled = false
        }
        else {
            pageTitleLabel.text = "Create Log"
            removeLogButton.removeFromSuperview()
            
            // If the family only has one dog, then force the parent dog selected to be that single dog. otherwise, make the parent dog selected none and force the user to select parent dog(s)
            if dogManager.dogs.count == 1 {
                if let dogId = dogManager.dogs.first?.dogId {
                    forDogIdsSelected = [dogId]
                    initialForDogIdsSelected = forDogIdsSelected
                }
            }
            
            // If there is only one dog in the family, then disable the label
            parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
            parentDogLabel.isEnabled = dogManager.dogs.count == 1 ? false : true
            familyMemberNameLabel.isEnabled = true
        }
        
        // Parent Dog Label
        parentDogLabel.placeholder = dogManager.dogs.count <= 1 ? "Select a dog..." : "Select a dog (or dogs)..."
        
        // Family Member Name
        familyMemberNameLabel.isEnabled = false
        familyMemberNameLabel.text = FamilyInformation.findFamilyMember(forUserId: logToUpdate?.userId)?.displayFullName
        // Theoretically, this can be any random placeholder so that the text for familyMemberNameLabel is indented a space or two for the border on the label
        familyMemberNameLabel.placeholder = familyMemberNameLabel.text
        
        // Log Action
        logActionLabel.isUserInteractionEnabled = true
        logActionSelected = logToUpdate?.logAction
        initialLogAction = logActionSelected
        logActionLabel.placeholder = "Select an action..."
        
        // Log Custom Action Name
        logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
        initialLogCustomActionName = logCustomActionNameTextField.text
        logCustomActionNameTextField.placeholder = " Add a custom action..."
        logCustomActionNameTextField.delegate = uiDelegate
        
        // Log Unit
        let convertedLogUnits: (LogUnit, Double)? = {
            guard let logUnit = logToUpdate?.logUnit, let logNumberOfLogUnits = logToUpdate?.logNumberOfLogUnits else {
                return nil
            }
            
            return UnitConverter.convert(forLogUnit: logUnit, forNumberOfLogUnits: logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        
        logUnitLabel.isUserInteractionEnabled = true
        logUnitSelected = convertedLogUnits?.0
        initialLogUnit = logUnitSelected
        logUnitLabel.placeholder = "Select a unit..."
        
        // Log Number of Log Units
        logNumberOfLogUnitsTextField.text = LogUnit.roundedString(forLogNumberOfLogUnits: convertedLogUnits?.1)
        initialLogNumberOfLogUnits = logNumberOfLogUnitsTextField.text
        logNumberOfLogUnitsTextField.placeholder = " 0" + (Locale.current.decimalSeparator ?? ".") + "0"
        logNumberOfLogUnitsTextField.delegate = uiDelegate

        // Log Start Date
        logStartDateSelected = logToUpdate?.logStartDate ?? Date()
        initialLogStartDate = logStartDateSelected
        logStartDateLabel.placeholder = "Select a start date..."
        
        logStartDateDatePicker.date = logToUpdate?.logStartDate ?? Date()
        
        // Log End Date
        logEndDateSelected = logToUpdate?.logEndDate
        initialLogEndDate = logEndDateSelected
        logEndDateLabel.placeholder = "Select an end date..."
        
        // Log Note
        logNoteTextView.text = logToUpdate?.logNote
        initialLogNote = logNoteTextView.text
        // spaces to align with general label
        logNoteTextView.placeholder = "Add some notes..."
        logNoteTextView.delegate = uiDelegate
        
        // Reset Corresponding Reminders
        // Have to set text property manually for general label space adjustment to work properly
        resetCorrespondingRemindersLabel.text = "Reset Corresponding Reminders"
        // We add a fake placeholder text so the real text gets adjusted by "  " and looks proper with the border on the label
        resetCorrespondingRemindersLabel.placeholder = " "
        
        // Other
        hideDynamicUIElementsIfNeeded()
        
        // MARK: Gestures
        self.view.setupDismissKeyboardOnTap()
        
        let dismissKeyboardGesture: UITapGestureRecognizer = {
            let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            dismissKeyboardGesture.delegate = self
            dismissKeyboardGesture.cancelsTouchesInView = false
            return dismissKeyboardGesture
        }()
        
        let hideDropDownParentDogGesture: UITapGestureRecognizer = {
            let hideDropDownParentDogGesture = UITapGestureRecognizer(target: self, action: #selector(hideDropDownParentDog))
            hideDropDownParentDogGesture.delegate = self
            hideDropDownParentDogGesture.cancelsTouchesInView = false
            return hideDropDownParentDogGesture
        }()
        
        let hideDropDownLogActionGesture: UITapGestureRecognizer = {
            let hideDropDownLogActionGesture = UITapGestureRecognizer(target: self, action: #selector(hideDropDownLogAction))
            hideDropDownLogActionGesture.delegate = self
            hideDropDownLogActionGesture.cancelsTouchesInView = false
            return hideDropDownLogActionGesture
        }()
        
        let hideDropDownLogUnitGesture: UITapGestureRecognizer = {
            let hideDropDownLogUnitGesture = UITapGestureRecognizer(target: self, action: #selector(hideDropDownLogUnit))
            hideDropDownLogUnitGesture.delegate = self
            hideDropDownLogUnitGesture.cancelsTouchesInView = false
            return hideDropDownLogUnitGesture
        }()
        
        scrollview.addGestureRecognizer(dismissKeyboardGesture)
        scrollview.addGestureRecognizer(hideDropDownParentDogGesture)
        scrollview.addGestureRecognizer(hideDropDownLogActionGesture)
        scrollview.addGestureRecognizer(hideDropDownLogUnitGesture)
        
        let parentDogLabelGesture = UITapGestureRecognizer(target: self, action: #selector(objcSelectorShowDropDownParentDog))
        parentDogLabelGesture.delegate = self
        parentDogLabelGesture.cancelsTouchesInView = false
        parentDogLabel.addGestureRecognizer(parentDogLabelGesture)
        // parentDogLabel shouldnt dismiss parent dog drop down
        
        let logActionLabelGesture = UITapGestureRecognizer(target: self, action: #selector(objcSelectorShowDropDownLogAction))
        logActionLabelGesture.delegate = self
        logActionLabelGesture.cancelsTouchesInView = false
        logActionLabel.addGestureRecognizer(logActionLabelGesture)
        // logActionLabel shouldnt dismiss log action drop down
        
        
        let logUnitLabelGesture = UITapGestureRecognizer(target: self, action: #selector(objcSelectorShowDropDownLogUnit))
        logUnitLabelGesture.delegate = self
        logUnitLabelGesture.cancelsTouchesInView = false
        logUnitLabel.addGestureRecognizer(logUnitLabelGesture)
        // logUnitLabel shouldnt hide log unit drop down
        
        // logNoteTextView shouldnt dismiss text field
    }
    
    @IBOutlet weak var scrollview: UIScrollView!
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // LogsAddLogViewController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        // if the user hasn't selected a parent dog, indicating that this is the first time the logsaddlogvc is appearing, then show the drop down. this functionality will make it so when the user taps the plus button to add a new log, we automatically present the parent dog dropdown to them
        if forDogIdsSelected.isEmpty {
            showDropDownParentDog(animated: false)
        }
        // if the user has selected a parent dog (tapping the create log plus button while only having one dog), then show the drop down for log action. this functionality will make it so when the user taps the pluss button to add a new log, and they only have one parent dog to choose from so we automatically select the parent dog, we automatically present the log action drop down to them
        else if logActionSelected == nil {
            showDropDownLogAction(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideDropDownParentDog(removeFromSuperview: true)
        hideDropDownLogAction(removeFromSuperview: true)
        hideDropDownLogUnit(removeFromSuperview: true)
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: LogsAddLogCommunicationDelegate, forDogManager: DogManager, forDogIdToUpdate: Int?, forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogIdToUpdate = forDogIdToUpdate
        logToUpdate = forLogToUpdate
    }
    
    private func hideDynamicUIElementsIfNeeded() {
        // We don't want this page to get too clutter. Therefore, if editting a log, so family member name will be shown, hide parent dog. Parent dog is uneditable as well, so no functionality is lost
        let parentDogIsHidden = dogIdToUpdate != nil && logToUpdate != nil
        parentDogLabel.isHidden = parentDogIsHidden
        parentDogHeightConstraint.constant = parentDogIsHidden ? 0.0 : 45.0
        parentDogBottomConstraint.constant = parentDogIsHidden ? 0.0 : 10.0
        
        // The family member to a log is not editable by a user. Its set internally by the server. Therefore, if creating a log don't show it as it will automatically be the user. If editting a log, show it so a user can know who created this log
        let familyMemberNameIsHidden = dogIdToUpdate == nil || logToUpdate == nil
        familyMemberNameLabel.isHidden = familyMemberNameIsHidden
        familyMemberNameHeightConstraint.constant = familyMemberNameIsHidden ? 0.0 : 45.0
        familyMemberNameBottomConstraint.constant = familyMemberNameIsHidden ? 0.0 : 10.0
        
        let logCustomActionNameIsHidden = logActionSelected != .custom
        logCustomActionNameTextField.isHidden = logCustomActionNameIsHidden
        logCustomActionNameHeightConstraint.constant = logCustomActionNameIsHidden ? 0.0 : 45.0
        logCustomActionNameBottomConstraint.constant = logCustomActionNameIsHidden ? 0.0 : 10.0
        
        let logUnitIsHidden = {
            guard let logActionSelected = logActionSelected else {
                return true
            }
            
            let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
            
            // If logUnits for a logAction isn't empty (meaning a log action has available log units, then the log action should have log units displayed for it
            return logUnits.isEmpty
        }()
        logUnitLabel.isHidden = logUnitIsHidden
        logUnitHeightConstraint.constant = logUnitIsHidden ? 0.0 : 45.0
        logUnitBottomConstraint.constant = logUnitIsHidden ? 0.0 : 10.0
        logNumberOfLogUnitsTextField.isHidden = logUnitIsHidden
        
        let resetCorrespondingRemindersIsHidden = correspondingReminders.isEmpty
        resetCorrespondingRemindersLabel.isHidden = resetCorrespondingRemindersIsHidden
        resetCorrespondingRemindersSwitch.isHidden = resetCorrespondingRemindersIsHidden
        resetCorrespondingRemindersHeightConstraint.constant = resetCorrespondingRemindersIsHidden ? 0.0 : 45.0
        resetCorrespondingRemindersBottomConstraint.constant = resetCorrespondingRemindersIsHidden ? 0.0 : 10.0
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideUIElement) { [self] in
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    @objc private func hideDropDownParentDog(removeFromSuperview: Bool = false) {
        dropDownParentDog?.hideDropDown(removeFromSuperview: removeFromSuperview)
    }
    @objc private func hideDropDownLogAction(removeFromSuperview: Bool = false) {
        dropDownLogAction?.hideDropDown(removeFromSuperview: removeFromSuperview)
    }
    @objc private func hideDropDownLogUnit(removeFromSuperview: Bool = false) {
        dropDownLogUnit?.hideDropDown(removeFromSuperview: removeFromSuperview)
    }
    
    @objc private func objcSelectorShowDropDownParentDog() {
        showDropDownParentDog(animated: true)
    }
    /// Dismisses the keyboard and other dropdowns to show parentDogLabel
    private func showDropDownParentDog(animated: Bool) {
        if dropDownParentDog == nil {
            dropDownParentDog = DropDownUIView()
            if let dropDownParentDog = dropDownParentDog {
                dropDownParentDog.setupDropDown(forDropDownUIViewIdentifier: dropDownParentDogIdentifier, forCellReusableIdentifier: "DropDownCell", forDataSource: self, forNibName: "DropDownTableViewCell", forViewPositionReference: parentDogLabel.frame, forOffset: 2.5, forRowHeight: DropDownUIView.rowHeightForGeneralUILabel)
                
                // We want a hierarchy of views to be maintained
                if let dropDownLogAction = dropDownLogAction {
                    // use .superview so the subview is added to the proper view with the label (this should be some nested view inside the scroll view)
                    parentDogLabel.superview?.insertSubview(dropDownParentDog, aboveSubview: dropDownLogAction)
                }
                else if let dropDownLogUnit = dropDownLogUnit {
                    parentDogLabel.superview?.insertSubview(dropDownParentDog, aboveSubview: dropDownLogUnit)
                }
                else {
                    parentDogLabel.superview?.addSubview(dropDownParentDog)
                }
            }
        }
        
        dropDownParentDog?.showDropDown(numberOfRowsToShow: dropDownParentDogNumberOfRows, animated: animated)
    }
    
    @objc private func objcSelectorShowDropDownLogAction() {
        showDropDownLogAction(animated: true)
    }
    /// Dismisses the keyboard and other dropdowns to show logAction
    private func showDropDownLogAction(animated: Bool) {
        if dropDownLogAction == nil {
            dropDownLogAction = DropDownUIView()
            if let dropDownLogAction = dropDownLogAction {
                dropDownLogAction.setupDropDown(forDropDownUIViewIdentifier: dropDownLogActionIdentifier, forCellReusableIdentifier: "DropDownCell", forDataSource: self, forNibName: "DropDownTableViewCell", forViewPositionReference: logActionLabel.frame, forOffset: 2.5, forRowHeight: DropDownUIView.rowHeightForGeneralUILabel)
                
                // We want a hierarchy of views to be maintained
                if let dropDownParentDog = dropDownParentDog {
                    // use .superview so the subview is added to the proper view with the label (this should be some nested view inside the scroll view)
                    logActionLabel.superview?.insertSubview(dropDownLogAction, belowSubview: dropDownParentDog)
                }
                else if let dropDownLogUnit = dropDownLogUnit {
                    logActionLabel.superview?.insertSubview(dropDownLogAction, aboveSubview: dropDownLogUnit)
                }
                else {
                    logActionLabel.superview?.addSubview(dropDownLogAction)
                }
            }
        }
        
        dropDownLogAction?.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: animated)
    }
    
    @objc private func objcSelectorShowDropDownLogUnit() {
        showDropDownLogUnit(animated: true)
    }
    /// Dismisses the keyboard and other dropdowns to show logUnit
    private func showDropDownLogUnit(animated: Bool) {
        if dropDownLogUnit == nil {
            dropDownLogUnit = DropDownUIView()
            if let dropDownLogUnit = dropDownLogUnit {
                dropDownLogUnit.setupDropDown(forDropDownUIViewIdentifier: dropDownLogUnitIdentifier, forCellReusableIdentifier: "DropDownCell", forDataSource: self, forNibName: "DropDownTableViewCell", forViewPositionReference: logUnitLabel.frame, forOffset: 2.5, forRowHeight: DropDownUIView.rowHeightForGeneralUILabel)
                
                // We want a hierarchy of views to be maintained
                if let dropDownParentDog = dropDownParentDog {
                    // use .superview so the subview is added to the proper view with the label (this should be some nested view inside the scroll view)
                    logUnitLabel.superview?.insertSubview(dropDownLogUnit, belowSubview: dropDownParentDog)
                }
                else if let dropDownLogAction = dropDownLogAction {
                    logUnitLabel.superview?.insertSubview(dropDownLogUnit, belowSubview: dropDownLogAction)
                }
                else {
                    logUnitLabel.superview?.addSubview(dropDownLogUnit)
                }
            }
        }
        
        dropDownLogUnit?.showDropDown(numberOfRowsToShow: dropDownLogUnitNumberOfRows, animated: animated)
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == dropDownParentDogIdentifier, let customCell = cell as? DropDownTableViewCell {
            guard let dogManager = dogManager else {
                return
            }
            
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
            
            let dog = dogManager.dogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: forDogIdsSelected.contains(dog.dogId))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == dropDownLogActionIdentifier, let customCell = cell as? DropDownTableViewCell {
            
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                customCell.label.text = LogAction.allCases[indexPath.row].displayActionName(logCustomActionName: nil)
                
                if let logActionSelected = logActionSelected {
                    // if the user has a logActionSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: LogAction.allCases.firstIndex(of: logActionSelected) == indexPath.row)
                }
            }
            // a user generated custom name
            else {
                customCell.label.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                )
                
                customCell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }
        else if dropDownUIViewIdentifier == dropDownLogUnitIdentifier, let customCell = cell as? DropDownTableViewCell {
            guard let logActionSelected = logActionSelected else {
                return
            }
            
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
            
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            
            let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
            
            if indexPath.row < logUnits.count {
                // inside of the predefined available LogUnits
                let logUnit = logUnits[indexPath.row]
                
                customCell.label.text = LogUnit.adjustedPluralityString(
                    forLogUnit: logUnit,
                    forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text) ?? 0.0
                )
                
                if let logUnitSelected = logUnitSelected {
                    // if the user has a logUnitSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: logUnitSelected == logUnit)
                }
                
            }
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == dropDownParentDogIdentifier {
            guard let dogManager = dogManager else {
                return 0
            }
            
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == dropDownLogActionIdentifier {
            return LogAction.allCases.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        }
        else if dropDownUIViewIdentifier == dropDownLogUnitIdentifier {
            guard let logActionSelected = logActionSelected else {
                return 0
            }
            
            return LogUnit.logUnits(forLogAction: logActionSelected).count
        }
        
        return 0
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == dropDownParentDogIdentifier {
            return 1
        }
        else if dropDownUIViewIdentifier == dropDownLogActionIdentifier {
            return 1
        }
        else if dropDownUIViewIdentifier == dropDownLogUnitIdentifier {
            return 1
        }
        
        return 0
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == dropDownParentDogIdentifier, let selectedCell = dropDownParentDog?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            guard let dogManager = dogManager else {
                return
            }
            
            let dogSelected = dogManager.dogs[indexPath.row]
            let initialNumberOfDogIdsSelected = forDogIdsSelected.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a parent dog, remove it from our array
                forDogIdsSelected.removeAll { dogId in
                    dogId == dogSelected.dogId
                }
            }
            else {
                // The user has selected a parent dog, add it to our array
                forDogIdsSelected.append(dogSelected.dogId)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if initialNumberOfDogIdsSelected == 0 {
                // If initially, there were no dogs selected, then the user selected their first dog, we immediately hide this drop down then open the log action drop down. Allowing them to seemlessly choose the log action next
                hideDropDownParentDog()
                showDropDownLogAction(animated: true)
            }
            else if forDogIdsSelected.count == dogManager.dogs.count {
                // selected every dog in the drop down, close the drop down
                hideDropDownParentDog()
            }
        }
        else if dropDownUIViewIdentifier == dropDownLogActionIdentifier, let selectedCell = dropDownLogAction?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            if selectedCell.isCustomSelected == true {
                selectedCell.setCustomSelectedTableViewCell(forSelected: false)
                logActionSelected = nil
                // Don't hideDropDownLogAction() because user needs to select a log action for log to be valid
            }
            else {
                selectedCell.setCustomSelectedTableViewCell(forSelected: true)
                
                // inside of the predefined LogAction
                if indexPath.row < LogAction.allCases.count {
                    logActionSelected = LogAction.allCases[indexPath.row]
                }
                // a user generated custom name
                else {
                    logActionSelected = LogAction.custom
                    logCustomActionNameTextField.text = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                }
                
                // hideDropDownLogAction() because the user selected a log action
                hideDropDownLogAction()
            }
        }
        else if dropDownUIViewIdentifier == dropDownLogUnitIdentifier, let selectedCell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell, let logActionSelected = logActionSelected {

            if selectedCell.isCustomSelected {
                selectedCell.setCustomSelectedTableViewCell(forSelected: false)
                logUnitSelected = nil
            }
            else {
                let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
                selectedCell.setCustomSelectedTableViewCell(forSelected: true)
                logUnitSelected = logUnits[indexPath.row]
            }
            
            // hideDropDownLogUnit() because the user selected/unselected a log unit, either way its ok to hide
            hideDropDownLogUnit()
        }
        
        hideDynamicUIElementsIfNeeded()
    }
    
}
