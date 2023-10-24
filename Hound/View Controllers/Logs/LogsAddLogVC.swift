//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsAddLogViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, DropDownUIViewDataSource {

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

        // make sure the result is logCustomActionNameCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logCustomActionNameCharacterLimit
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't allow the user to add a new line. If they do, we interpret that as the user hitting the done button.
        guard text != "\n" else {
            self.dismissKeyboard()
            return false
        }
        
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // make sure the result is under logNoteCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logNoteCharacterLimit
    }

    // if extra space is added, removes it and ends editing, makes done button function like done instead of adding new line
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            self.dismissKeyboard()
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: - IB

    @IBOutlet private weak var backgroundGestureView: UIView!

    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!

    @IBOutlet private weak var parentDogLabel: GeneralUILabel!
    
    @IBOutlet private weak var familyMemberNameLabel: GeneralUILabel!
    @IBOutlet private weak var familyMemberNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var familyMemberNameBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logActionLabel: GeneralUILabel!

    /// Text input for logCustomActionNameName
    @IBOutlet private weak var logCustomActionNameTextField: GeneralUITextField!
    @IBOutlet private weak var logCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logCustomActionNameBottomConstraint: NSLayoutConstraint!

    @IBAction private func didUpdateLogCustomActionName(_ sender: Any) {
        hideResetCorrespondingRemindersIfNeeded()
    }

    @IBOutlet private weak var resetCorrespondingRemindersLabel: GeneralUILabel!
    @IBOutlet private weak var resetCorrespondingRemindersSwitch: UISwitch!
    @IBOutlet private weak var resetCorrespondingRemindersHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var resetCorrespondingRemindersBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logNoteTextView: GeneralUITextView!

    @IBOutlet private weak var logDateDatePicker: UIDatePicker!
    @IBAction private func didUpdateLogDate(_ sender: Any) {
        self.dismissKeyboard()
    }

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
            guard let forDogIdsSelected = forDogIdsSelected, forDogIdsSelected.count >= 1 else {
                throw ErrorConstant.LogError.parentDogNotSelected()
            }
            guard let logActionSelected = logActionSelected else {
                throw ErrorConstant.LogError.logActionBlank()
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
                    reminder.enableIsSkipping(forSkippedDate: logDateDatePicker.date)

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
                try newLog.changeLogCustomActionName(forLogCustomActionName: logCustomActionNameTextField.text ?? "")
                newLog.logDate = logDateDatePicker.date
                try newLog.changeLogNote(forLogNote: logNoteTextView.text ?? "")

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
            logToUpdate.logDate = logDateDatePicker.date
            logToUpdate.logAction = logActionSelected
            try logToUpdate.changeLogCustomActionName(forLogCustomActionName: logActionSelected == LogAction.custom ? logCustomActionNameTextField.text ?? "" : "")
            try logToUpdate.changeLogNote(forLogNote: logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote)

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

    weak var delegate: LogsAddLogViewControllerDelegate!

    private var dogManager: DogManager?
    private var dogIdToUpdate: Int?
    private var logToUpdate: Log?

    // MARK: Initial Value Tracking

    private var initialForDogIdsSelected: [Int]?
    private var initialLogAction: LogAction?
    private var initialLogCustomActionName: String?
    private var initialLogNote: String!
    private var initialLogDate: Date!
    var didUpdateInitialValues: Bool {
        if initialLogAction != logActionSelected {
            return true
        }
        if logActionSelected == LogAction.custom && initialLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        if initialLogNote != logNoteTextView.text {
            return true
        }
        if initialLogDate != logDateDatePicker.date {
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

    /// drop down for changing the parent dog name
    private let dropDownParentDog = DropDownUIView()
    private var dropDownParentDogNumberOfRows: Double {
        guard let dogManager = dogManager else {
            return 0.0
        }

        return dogManager.dogs.count > 5 ? 5.5 : CGFloat(dogManager.dogs.count)
    }

    private var forDogIdsSelected: [Int]?

    // MARK: Log Action Drop Down

    /// drop down for changing the log type
    private let dropDownLogAction = DropDownUIView()
    private let dropDownLogActionNumberOfRows = 6.5

    /// the name of the selected log action in drop down
    private var logActionSelected: LogAction?

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
            (forDogIdsSelected ?? []).contains(dog.dogId)
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

        guard let dogManager = dogManager else {
            return
        }

        if let dogIdToUpdate = dogIdToUpdate, logToUpdate != nil {
            pageTitleLabel.text = "Edit Log"
            if let dog = dogManager.findDog(forDogId: dogIdToUpdate) {
                parentDogLabel.text = dog.dogName
                forDogIdsSelected = [dog.dogId]
            }

            parentDogLabel.isEnabled = false
        }
        else {
            pageTitleLabel.text = "Create Log"
            removeLogButton.removeFromSuperview()

            // If the family only has one dog, then force the parent dog selected to be that single dog. otherwise, make the parent dog selected none and force the user to select parent dog(s)
            if let dogId = dogManager.dogs.first?.dogId {
                forDogIdsSelected = [dogId]
            }
            else {
                forDogIdsSelected = nil
            }

            parentDogLabel.text = dogManager.dogs.first?.dogName

            // If there is only one dog in the family, then disable the label
            parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
            parentDogLabel.isEnabled = dogManager.dogs.count == 1 ? false : true
            familyMemberNameLabel.isEnabled = true
            
        }
        initialForDogIdsSelected = forDogIdsSelected

        parentDogLabel.placeholder = dogManager.dogs.count <= 1 ? "Select a dog..." : "Select a dog (or dogs)..."
        
        familyMemberNameLabel.isEnabled = false
        familyMemberNameLabel.text = FamilyInformation.findFamilyMember(forUserId: logToUpdate?.userId)?.displayFullName
        // Theoretically, this can be any random placeholder so that the text for familyMemberNameLabel is indented a space or two for the border on the label
        familyMemberNameLabel.placeholder = "No Name"
        hideFamilyMemberNameIfNeeded()

        // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logAction dropdown, so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName", the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
        logActionLabel.text = logToUpdate?.logAction.displayActionName(logCustomActionName: nil)
        logActionSelected = logToUpdate?.logAction
        initialLogAction = logActionSelected
        logActionLabel.placeholder = "Select an action..."

        logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
        initialLogCustomActionName = logCustomActionNameTextField.text
        logCustomActionNameTextField.placeholder = " Add a custom action..."
        logCustomActionNameTextField.delegate = self
        hideLogCustomActionNameIfNeeded()

        logNoteTextView.text = logToUpdate?.logNote
        initialLogNote = logNoteTextView.text
        // spaces to align with general label
        logNoteTextView.placeholder = "Add a note... (optional)"
        logNoteTextView.delegate = self

        // Have to set text property manually for general label space adjustment to work properly
        resetCorrespondingRemindersLabel.text = "Reset Corresponding Reminders"
        // We add a fake placeholder text so the real text gets adjusted by "  " and looks proper with the border on the label
        resetCorrespondingRemindersLabel.placeholder = " "
        hideResetCorrespondingRemindersIfNeeded()

        logDateDatePicker.date = logToUpdate?.logDate ?? Date()
        initialLogDate = logDateDatePicker.date

        // MARK: Gestures
        self.view.setupDismissKeyboardOnTap()

        var dismissKeyboardGesture: UITapGestureRecognizer {
            let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            dismissKeyboardGesture.delegate = self
            dismissKeyboardGesture.cancelsTouchesInView = false
            return dismissKeyboardGesture
        }

        var dismissDropDownParentDogGesture: UITapGestureRecognizer {
            let dismissDropDownParentDogGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDropDownParentDog))
            dismissDropDownParentDogGesture.delegate = self
            dismissDropDownParentDogGesture.cancelsTouchesInView = false
            return dismissDropDownParentDogGesture
        }

        var dismissDropDownLogActionGesture: UITapGestureRecognizer {
            let dismissDropDownLogActionGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDropDownLogAction))
            dismissDropDownLogActionGesture.delegate = self
            dismissDropDownLogActionGesture.cancelsTouchesInView = false
            return dismissDropDownLogActionGesture
        }

        backgroundGestureView.addGestureRecognizer(dismissKeyboardGesture)
        backgroundGestureView.addGestureRecognizer(dismissDropDownParentDogGesture)
        backgroundGestureView.addGestureRecognizer(dismissDropDownLogActionGesture)

        // Only allow use of parentDogLabel if they are creating a log, not updating
        parentDogLabel.isUserInteractionEnabled = dogIdToUpdate == nil
        parentDogLabel.isEnabled = dogIdToUpdate == nil
        let parentDogLabelGesture = UITapGestureRecognizer(target: self, action: #selector(showDropDownParentDog))
        parentDogLabelGesture.delegate = self
        parentDogLabelGesture.cancelsTouchesInView = false
        parentDogLabel.addGestureRecognizer(parentDogLabelGesture)
        parentDogLabel.addGestureRecognizer(dismissKeyboardGesture)
        parentDogLabel.addGestureRecognizer(dismissDropDownLogActionGesture)

        logActionLabel.isUserInteractionEnabled = true
        let logActionLabelGesture = UITapGestureRecognizer(target: self, action: #selector(showDropDownLogAction))
        logActionLabelGesture.delegate = self
        logActionLabelGesture.cancelsTouchesInView = false
        logActionLabel.addGestureRecognizer(logActionLabelGesture)
        logActionLabel.addGestureRecognizer(dismissKeyboardGesture)
        logActionLabel.addGestureRecognizer(dismissDropDownParentDogGesture)

        logCustomActionNameTextField.addGestureRecognizer(dismissDropDownParentDogGesture)
        logCustomActionNameTextField.addGestureRecognizer(dismissDropDownLogActionGesture)

        logNoteTextView.addGestureRecognizer(dismissDropDownParentDogGesture)
        logNoteTextView.addGestureRecognizer(dismissDropDownLogActionGesture)

        logDateDatePicker.addGestureRecognizer(dismissKeyboardGesture)
        logDateDatePicker.addGestureRecognizer(dismissDropDownParentDogGesture)
        logDateDatePicker.addGestureRecognizer(dismissDropDownLogActionGesture)

        backButton.addGestureRecognizer(dismissKeyboardGesture)
        backButton.addGestureRecognizer(dismissDropDownParentDogGesture)
        backButton.addGestureRecognizer(dismissDropDownLogActionGesture)

        addLogButton.addGestureRecognizer(dismissKeyboardGesture)
        addLogButton.addGestureRecognizer(dismissDropDownParentDogGesture)
        addLogButton.addGestureRecognizer(dismissDropDownLogActionGesture)
    }

    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // LogsAddLogViewController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).

        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
            return
        }

        didSetupCustomSubviews = true

        // MARK: Setup Drop Down
        dropDownParentDog.setupDropDown(forDropDownUIViewIdentifier: "DropDownParentDog", forCellReusableIdentifier: "DropDownCell", forDataSource: self, forNibName: "DropDownTableViewCell", forViewPositionReference: parentDogLabel.frame, forOffset: 2.5, forRowHeight: DropDownUIView.rowHeightForGeneralUILabel)
        view.addSubview(dropDownParentDog)

        dropDownLogAction.setupDropDown(forDropDownUIViewIdentifier: "DropDownLogAction", forCellReusableIdentifier: "DropDownCell", forDataSource: self, forNibName: "DropDownTableViewCell", forViewPositionReference: logActionLabel.frame, forOffset: 2.5, forRowHeight: DropDownUIView.rowHeightForGeneralUILabel)
        view.addSubview(dropDownLogAction)

        // MARK: Show Drop Down

        // if the user hasn't selected a parent dog, indicating that this is the first time the logsaddlogvc is appearing, then show the drop down. this functionality will make it so when the user taps the plus button to add a new log, we automatically present the parent dog dropdown to them
        if forDogIdsSelected == nil {
            dropDownParentDog.showDropDown(numberOfRowsToShow: dropDownParentDogNumberOfRows, animated: false)
        }
        // if the user has selected a parent dog (tapping the create log plus button while only having one dog), then show the drop down for log action. this functionality will make it so when the user taps the pluss button to add a new log, and they only have one parent dog to choose from so we automatically select the parent dog, we automatically present the log action drop down to them
        else if logActionSelected == nil {
            dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDownLogAction.hideDropDown(removeFromSuperview: true)
        dropDownParentDog.hideDropDown(removeFromSuperview: true)
    }

    // MARK: - Functions

    func setup(forDelegate: LogsAddLogViewControllerDelegate, forDogManager: DogManager, forDogIdToUpdate: Int?, forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogIdToUpdate = forDogIdToUpdate
        logToUpdate = forLogToUpdate
    }

    private func hideFamilyMemberNameIfNeeded() {
        // If this page is create a log, then the field should be hidden, if updating a log, show the field.
        let isHidden = dogIdToUpdate == nil || logToUpdate == nil
        
        familyMemberNameLabel.isHidden = isHidden
        familyMemberNameHeightConstraint.constant = isHidden ? 0.0 : 45.0
        familyMemberNameBottomConstraint.constant = isHidden ? 0.0 : 10.0
    }
    
    private func hideLogCustomActionNameIfNeeded() {
        let isHidden = logActionSelected != .custom

        logCustomActionNameTextField.isHidden = isHidden
        logCustomActionNameHeightConstraint.constant = isHidden ? 0.0 : 45.0
        logCustomActionNameBottomConstraint.constant = isHidden ? 0.0 : 10.0

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    /// If correspondingReminders.isEmpty, hides the label and switch for reset corresponding remiders should be hidden
    private func hideResetCorrespondingRemindersIfNeeded() {
        let shouldHideResetCorrespondingReminders = correspondingReminders.isEmpty

        resetCorrespondingRemindersLabel.isHidden = shouldHideResetCorrespondingReminders
        resetCorrespondingRemindersSwitch.isHidden = shouldHideResetCorrespondingReminders
        resetCorrespondingRemindersHeightConstraint.constant = shouldHideResetCorrespondingReminders ? 0.0 : 45.0
        resetCorrespondingRemindersBottomConstraint.constant = shouldHideResetCorrespondingReminders ? 0.0 : 10.0

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc private func dismissDropDownParentDog() {
        dropDownParentDog.hideDropDown()
    }

    @objc private func dismissDropDownLogAction() {
        dropDownLogAction.hideDropDown()
    }

    /// Dismisses the keyboard and other dropdowns to show parentDogLabel
    @objc private func showDropDownParentDog() {
        dropDownParentDog.showDropDown(numberOfRowsToShow: dropDownParentDogNumberOfRows, animated: true)
    }

    /// Dismisses the keyboard and other dropdowns to show logAction
    @objc private func showDropDownLogAction() {
        dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: true)
    }

    // MARK: - Drop Down Data Source

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let dogManager = dogManager else {
            return
        }

        if dropDownUIViewIdentifier == "DropDownParentDog", let customCell = cell as? DropDownTableViewCell {
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)

            let dog = dogManager.dogs[indexPath.row]

            customCell.setCustomSelectedTableViewCell(forSelected: (forDogIdsSelected ?? []).contains(dog.dogId))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let customCell = cell as? DropDownTableViewCell {

            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)

            customCell.setCustomSelectedTableViewCell(forSelected: false)

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
            }
        }
    }

    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        guard let dogManager = dogManager else {
            return 0
        }

        if dropDownUIViewIdentifier == "DropDownParentDog"{
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction"{
            return LogAction.allCases.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        }
        else {
            return 0
        }
    }

    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "DropDownParentDog"{
            return 1
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction"{
            return 1
        }
        else {
            return 0
        }
    }

    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let dogManager = dogManager else {
            return
        }

        if dropDownUIViewIdentifier == "DropDownParentDog", let selectedCell = dropDownParentDog.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {

            let dogSelected = dogManager.dogs[indexPath.row]
            let initialForDogIdsSelected = forDogIdsSelected
            
            // check if the dog the user tapped on was already part of the parent dogs selected, if so then we remove its selection
            let isAlreadySelected = forDogIdsSelected?.contains(dogSelected.dogId) ?? false

            // Since we are flipping the selection state of the cell, that means if the dogId isn't in the array, we need to add it and if is in the array we remove it
            if isAlreadySelected {
                forDogIdsSelected?.removeAll { dogId in
                    dogId == dogSelected.dogId
                }
            }
            else {
                // since the user has selected a parent dog, make sure we give them an array to append to
                forDogIdsSelected = forDogIdsSelected ?? []
                forDogIdsSelected?.append(dogSelected.dogId)
            }
            
            // Flip is selected state
            selectedCell.setCustomSelectedTableViewCell(forSelected: !isAlreadySelected)

            parentDogLabel.text = {
                guard let forDogIdsSelected = forDogIdsSelected, forDogIdsSelected.count >= 1 else {
                    // If no forDogIdsSelected.isEmpty, we leave the text blank so that the placeholder text will display
                    return nil
                }

                // dogSelected is the dog tapped and now that dog is removed, we need to find the name of the remaining dog
                if forDogIdsSelected.count == 1, let lastRemainingDogId = forDogIdsSelected.first, let lastRemainingDog = dogManager.dogs.first(where: { dog in
                    return dog.dogId == lastRemainingDogId
                }) {
                    return lastRemainingDog.dogName
                }
                // forDogIdsSelected.count >= 2
                else if forDogIdsSelected.count == dogManager.dogs.count {
                    return "All"
                }
                else {
                    return "Multiple"
                }
            }()

            // If its the first time of a user selecting a dog, assume they only want to create a log for one dog. We therefore hide the drop down immediately after.
            // However, if the user opens this dropdown again, initialForDogIdsSelected won't be nil and the dropdown will stay open for multiple selections. This allows the user to easily leave the dropdown open for selecting multiple parent dogs
            if initialForDogIdsSelected == nil {
                dropDownParentDog.hideDropDown()
                // Since its the first time a user is selecting a dog, go through the normal flow of creating a log. next open the log action drop down for them
                dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: true)
            }
            // selected every dog in the drop down, close the drop down
            else if forDogIdsSelected?.count == dogManager.dogs.count {
                dropDownParentDog.hideDropDown()
            }
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let selectedCell = dropDownLogAction.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)

            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                logActionLabel.text = LogAction.allCases[indexPath.row].displayActionName(logCustomActionName: nil)
                logActionSelected = LogAction.allCases[indexPath.row]
            }
            // a user generated custom name
            else {
                logActionLabel.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                    )
                logActionSelected = LogAction.custom
                logCustomActionNameTextField.text = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
            }
            
            /*
             xcrun simctl status_bar "booted" override --time "3:35" --dataNetwork "5g+" --wifiMode "active" --wifiBars 3 --cellularMode "active" --cellularBars 4 --operatorName ""
             */

            // set logActionSelected to correct value

            dropDownLogAction.hideDropDown()

            hideLogCustomActionNameIfNeeded()
        }

        hideResetCorrespondingRemindersIfNeeded()
    }

}
