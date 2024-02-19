//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsAddLogViewController: GeneralUIViewController, LogsAddLogUIInteractionActionsDelegate, DropDownUIViewDataSource {
    
    // MARK: - LogsAddLogUIInteractionActionsDelegate
    
    func logCustomActionNameTextFieldDidReturn() {
        if logStartDateSelected == nil {
            // If a user input a logCustomActionName in that dynamically-appearing field and logStartDateSelected is nil, that means the normal flow of selecting log action -> selectiong log start date was interrupted. Resume this by openning logStartDate drop down
            showDropDown(.logStartDate, animated: true)
        }
    }
    
    func didUpdateLogNumberOfLogUnits() {
        // When the user enters a number into log units, it could update the plurality of the logUnitLabel (e.g. no number but "pills" then the user enters 1 so "pills" should become "pill"). So by setting logUnitSelected it updates logUnitLabel
        updateDynamicUIElements()
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    /// We use this padding so that the content inside the scroll view is >= the size of the safe area. If it is not, then the drop down menus will clip outside the content area, displaying on the lower half of the region but being un-interactable because they are outside the containerView
    @IBOutlet private weak var containerViewPaddingHeightConstraint: NSLayoutConstraint!
    
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
    
    @IBOutlet private weak var logNumberOfLogUnitsTextField: GeneralUITextField!
    @IBOutlet private weak var logUnitLabel: GeneralUILabel!
    @IBOutlet private weak var logUnitHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logUnitBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteTextView: GeneralUITextView!
    
    @IBOutlet private weak var logStartDateLabel: GeneralUILabel!
    @IBOutlet private weak var logStartDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logStartDatePicker: UIDatePicker!
    @IBAction private func didUpdateLogStartDate(_ sender: Any) {
        self.logStartDateSelected = logStartDatePicker.date
        self.dismissKeyboard()
    }
    
    @IBOutlet private weak var logEndDateLabel: GeneralUILabel!
    @IBOutlet private weak var logEndDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logEndDatePicker: UIDatePicker!
    @IBAction private func didUpdateLogEndDate(_ sender: Any) {
        self.logEndDateSelected = logEndDatePicker.date
        self.dismissKeyboard()
    }
    
    @IBOutlet private weak var backButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideBack(_ sender: Any) {
        if didUpdateInitialValues == true {
            let unsavedInformationConfirmation = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let exitAlertAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                self.dismiss(animated: true) {
                    // Wait for the view to be dismissed, then see if we should request any sort of review from the user (if we don't wait, then the view presented by CheckManager will be dismissed when this view dismisses)
                    CheckManager.checkForReview()
                    CheckManager.checkForSurveyFeedbackAppExperience()
                }
            }
            
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(exitAlertAction)
            unsavedInformationConfirmation.addAction(cancelAlertAction)
            
            PresentationManager.enqueueAlert(unsavedInformationConfirmation)
        }
        else {
            self.dismiss(animated: true) {
                // Wait for the view to be dismissed, then see if we should request any sort of review from the user (if we don't wait, then the view presented by CheckManager will be dismissed when this view dismisses)
                CheckManager.checkForReview()
                CheckManager.checkForSurveyFeedbackAppExperience()
            }
        }
        
    }
    
    @IBOutlet private weak var saveLogButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideSaveLog(_ sender: Any) {
        guard forDogUUIDsSelected.count >= 1 else {
            ErrorConstant.LogError.parentDogMissing().alert()
            return
        }
        guard let logActionSelected = logActionSelected else {
            ErrorConstant.LogError.logActionMissing().alert()
            return
        }
        guard let logStartDateSelected = logStartDateSelected else {
            ErrorConstant.LogError.logStartDateMissing().alert()
            return
        }
        
        // Check to see if we are updating or adding a log
        guard let dogUUIDToUpdate = dogUUIDToUpdate, let logToUpdate = logToUpdate else {
            willAddLog(logActionSelected: logActionSelected, logStartDateSelected: logStartDateSelected)
            return
        }
        
        willUpdateLog(dogUUIDToUpdate: dogUUIDToUpdate, logToUpdate: logToUpdate, logActionSelected: logActionSelected, logStartDateSelected: logStartDateSelected)
    }
    
    @IBOutlet private weak var removeLogButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideRemoveLog(_ sender: Any) {
        guard let dogUUIDToUpdate = dogUUIDToUpdate else {
            return
        }
        guard let logToUpdate = logToUpdate else {
            return
        }
        
        let removeLogConfirmation = UIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // the user decided to delete so we must query server
            LogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUIDToUpdate, forLogUUID: logToUpdate.logUUID) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }
                
                (self.dogManager?.findDog(forDogUUID: dogUUIDToUpdate))?.dogLogs.removeLog(forLogUUID: logToUpdate.logUUID)
                
                if let dogManager = self.dogManager {
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                
                self.dismiss(animated: true) {
                    // Wait for the view to be dismissed, then see if we should request any sort of review from the user (if we don't wait, then the view presented by CheckManager will be dismissed when this view dismisses)
                    CheckManager.checkForReview()
                    CheckManager.checkForSurveyFeedbackAppExperience()
                }
            }
            
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeLogConfirmation.addAction(removeAlertAction)
        removeLogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeLogConfirmation)
    }
    
    // MARK: - Properties
    
    weak var delegate: LogsAddLogDelegate!
    
    private lazy var uiDelegate: LogsAddLogUIInteractionDelegate = {
        let delegate = LogsAddLogUIInteractionDelegate()
        delegate.actionsDelegate = self
        delegate.logCustomActionNameTextField = self.logCustomActionNameTextField
        delegate.logNumberOfLogUnitsTextField = self.logNumberOfLogUnitsTextField
        return delegate
    }()
    
    private var dogManager: DogManager?
    private var dogUUIDToUpdate: UUID?
    private var logToUpdate: Log?
    
    // MARK: Initial Value Tracking
    
    private var initialForDogUUIDsSelected: [UUID] = []
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
        if (logActionSelected == LogAction.medicine || logActionSelected == LogAction.vaccine || logActionSelected == LogAction.custom) && initialLogCustomActionName != logCustomActionNameTextField.text {
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
        if initialLogStartDate != logStartDateSelected {
            return true
        }
        if initialLogEndDate != logEndDateSelected {
            return true
        }
        if initialForDogUUIDsSelected != forDogUUIDsSelected {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Parent Dog Drop Down
    
    private var dropDownParentDog: DropDownUIView?
    private var forDogUUIDsSelected: [UUID] = [] {
        didSet {
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let parentDogLabel = parentDogLabel {
                parentDogLabel.text = {
                    guard let dogManager = dogManager, forDogUUIDsSelected.count >= 1 else {
                        // If no forDogUUIDsSelected.isEmpty, we leave the text blank so that the placeholder text will display
                        return nil
                    }
                    
                    // dogSelected is the dog tapped and now that dog is removed, we need to find the name of the remaining dog
                    if forDogUUIDsSelected.count == 1, let lastRemainingDogUUID = self.forDogUUIDsSelected.first, let lastRemainingDog = dogManager.dogs.first(where: { dog in
                        return dog.dogUUID == lastRemainingDogUUID
                    }) {
                        return lastRemainingDog.dogName
                    }
                    else if forDogUUIDsSelected.count > 1 && forDogUUIDsSelected.count < dogManager.dogs.count {
                        return "Multiple"
                    }
                    else if forDogUUIDsSelected.count == dogManager.dogs.count {
                        return "All"
                    }
                    
                    return nil
                }()
            }
        }
        
    }
    
    // MARK: Log Action Drop Down
    
    private var dropDownLogAction: DropDownUIView?
    /// the name of the selected log action in drop down
    private var logActionSelected: LogAction? {
        didSet {
            updateDynamicUIElements()
            
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let logActionLabel = logActionLabel {
                // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logAction dropdown, so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName", the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
                logActionLabel.text = logActionSelected?.fullReadableName(logCustomActionName: nil)
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
    private var dropDownLogUnit: DropDownUIView?
    /// the name of the selected log unit in drop down
    private var logUnitSelected: LogUnit? {
        didSet {
            updateDynamicUIElements()
        }
    }
    
    // MARK: Log Start Date
    private var dropDownLogStartDate: DropDownUIView?
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
    private var isShowingLogStartDatePicker = false {
        didSet {
            if isShowingLogStartDatePicker == true {
                // If we are showing the logStartDatePicker, then the position for dropDownLogEndDate may now be incorrect and it should be reconstructed
                dropDownLogEndDate?.removeFromSuperview()
                dropDownLogEndDate = nil
                
                // If we are going to show logStartDatePicker, sync its date.
                logStartDatePicker.date = logStartDateSelected ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * logStartDatePicker.minuteInterval), roundingMethod: .toNearestOrAwayFromZero)
                // Now that we have potentially applied a date to the logStartDatePicker, make sure we save this value. Otherwise, if the user doesn't try to update the value, then logStartDateSelected will still be nil
                logStartDateSelected = logStartDatePicker.date
            }
            
            updateDynamicUIElements()
        }
    }
    
    // MARK: Log End Date Drop Down
    private var dropDownLogEndDate: DropDownUIView?
    private var logEndDateSelected: Date? {
        didSet {
            if let logEndDateSelected = logEndDateSelected {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(logEndDateSelected) {
                    // logEndDateSelected is the same day as today, so extra information is unnecessary
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
    private var isShowingLogEndDatePicker = false {
        didSet {
            if isShowingLogEndDatePicker == true {
                // If we are showing the logStartDatePicker, then the position for dropDownLogStartDate may now be incorrect and it should be reconstructed
                dropDownLogStartDate?.removeFromSuperview()
                dropDownLogStartDate = nil
                
                // If we are going to show logEndDatePicker, sync its date.
                logEndDatePicker.date = logEndDateSelected ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * logEndDatePicker.minuteInterval), roundingMethod: .toNearestOrAwayFromZero)
                // Now that we have potentially applied a date to the logEndDatePicker, make sure we save this value. Otherwise, if the user doesn't try to update the value, then logEndDateSelected will still be nil
                logEndDateSelected = logEndDatePicker.date
            }
            
            updateDynamicUIElements()
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // set forDogUUIDsSelected = [] to invoke didSet
        forDogUUIDsSelected = []
        initialForDogUUIDsSelected = forDogUUIDsSelected
        
        guard let dogManager = dogManager else {
            return
        }
        
        if let dogUUIDToUpdate = dogUUIDToUpdate, logToUpdate != nil {
            pageTitleLabel.text = "Edit Log"
            if let dog = dogManager.findDog(forDogUUID: dogUUIDToUpdate) {
                forDogUUIDsSelected = [dog.dogUUID]
                initialForDogUUIDsSelected = forDogUUIDsSelected
            }
            
            parentDogLabel.isEnabled = false
        }
        else {
            pageTitleLabel.text = "Create Log"
            removeLogButton.removeFromSuperview()
            
            // If the family only has one dog, then force the parent dog selected to be that single dog. otherwise, make the parent dog selected none and force the user to select parent dog(s)
            if dogManager.dogs.count == 1 {
                if let dogUUID = dogManager.dogs.first?.dogUUID {
                    forDogUUIDsSelected = [dogUUID]
                    initialForDogUUIDsSelected = forDogUUIDsSelected
                }
            }
            
            // If there is only one dog in the family, then disable the label
            parentDogLabel.isEnabled = dogManager.dogs.count == 1 ? false : true
            familyMemberNameLabel.isEnabled = true
        }
        
        // Parent Dog Label
        parentDogLabel.placeholder = dogManager.dogs.count <= 1 ? "What dog did you take care of?" : "What dog(s) did you take care of?"
        
        // Family Member Name
        familyMemberNameLabel.isEnabled = false
        familyMemberNameLabel.text = FamilyInformation.findFamilyMember(forUserId: logToUpdate?.userId)?.displayFullName
        // Theoretically, this can be any random placeholder so that the text for familyMemberNameLabel is indented a space or two for the border on the label
        familyMemberNameLabel.placeholder = familyMemberNameLabel.text
        
        // Log Action
        logActionSelected = logToUpdate?.logAction
        initialLogAction = logActionSelected
        logActionLabel.placeholder = "What action did you do?"
        
        // Log Custom Action Name
        logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
        initialLogCustomActionName = logCustomActionNameTextField.text
        // This placeholder is dynamic, so its set elsewhere
        logCustomActionNameTextField.delegate = uiDelegate
        
        // Log Unit
        let convertedLogUnits: (LogUnit, Double)? = {
            guard let logUnit = logToUpdate?.logUnit, let logNumberOfLogUnits = logToUpdate?.logNumberOfLogUnits else {
                return nil
            }
            
            return UnitConverter.convert(forLogUnit: logUnit, forNumberOfLogUnits: logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        
        logUnitSelected = convertedLogUnits?.0
        initialLogUnit = logUnitSelected
        logUnitLabel.placeholder = "Add a unit..."
        
        // Log Number of Log Units
        logNumberOfLogUnitsTextField.text = LogUnit.roundedString(forLogNumberOfLogUnits: convertedLogUnits?.1)
        initialLogNumberOfLogUnits = logNumberOfLogUnitsTextField.text
        logNumberOfLogUnitsTextField.placeholder = " 0" + (Locale.current.decimalSeparator ?? ".") + "0"
        logNumberOfLogUnitsTextField.delegate = uiDelegate
        
        // Log Start Date
        logStartDateSelected = logToUpdate?.logStartDate
        initialLogStartDate = logStartDateSelected
        logStartDateLabel.placeholder = "When did this happen?"
        
        // Log End Date
        logEndDateSelected = logToUpdate?.logEndDate
        initialLogEndDate = logEndDateSelected
        logEndDateLabel.placeholder = "Add an end date..."
        
        // Log Note
        logNoteTextView.text = logToUpdate?.logNote
        initialLogNote = logNoteTextView.text
        // spaces to align with general label
        logNoteTextView.placeholder = "Add some notes..."
        logNoteTextView.delegate = uiDelegate
        
        // MARK: Gestures
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
        
        let parentDogLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        parentDogLabelGesture.name = LogsAddLogDropDownTypes.parentDog.rawValue
        parentDogLabelGesture.delegate = uiDelegate
        parentDogLabelGesture.cancelsTouchesInView = false
        parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
        parentDogLabel.addGestureRecognizer(parentDogLabelGesture)
        
        let logActionLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        logActionLabelGesture.name = LogsAddLogDropDownTypes.logAction.rawValue
        logActionLabelGesture.delegate = uiDelegate
        logActionLabelGesture.cancelsTouchesInView = false
        logActionLabel.isUserInteractionEnabled = true
        logActionLabel.addGestureRecognizer(logActionLabelGesture)
        
        let logUnitLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        logUnitLabelGesture.name = LogsAddLogDropDownTypes.logUnit.rawValue
        logUnitLabelGesture.delegate = uiDelegate
        logUnitLabelGesture.cancelsTouchesInView = false
        logUnitLabel.isUserInteractionEnabled = true
        logUnitLabel.addGestureRecognizer(logUnitLabelGesture)
        
        let logStartDateLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        logStartDateLabelGesture.name = LogsAddLogDropDownTypes.logStartDate.rawValue
        logStartDateLabelGesture.delegate = uiDelegate
        logStartDateLabelGesture.cancelsTouchesInView = false
        logStartDateLabel.isUserInteractionEnabled = true
        logStartDateLabel.addGestureRecognizer(logStartDateLabelGesture)
        
        let logEndDateLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        logEndDateLabelGesture.name = LogsAddLogDropDownTypes.logEndDate.rawValue
        logEndDateLabelGesture.delegate = uiDelegate
        logEndDateLabelGesture.cancelsTouchesInView = false
        logEndDateLabel.isUserInteractionEnabled = true
        logEndDateLabel.addGestureRecognizer(logEndDateLabelGesture)
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        updateDynamicUIElements()
        
        // if the user hasn't selected a parent dog, indicating that this is the first time the logsaddlogvc is appearing, then show the drop down. this functionality will make it so when the user taps the plus button to add a new log, we automatically present the parent dog dropdown to them
        if forDogUUIDsSelected.isEmpty {
            showDropDown(.parentDog, animated: false)
        }
        // if the user has selected a parent dog (tapping the create log plus button while only having one dog), then show the drop down for log action. this functionality will make it so when the user taps the pluss button to add a new log, and they only have one parent dog to choose from so we automatically select the parent dog, we automatically present the log action drop down to them
        else if logActionSelected == nil {
            showDropDown(.logAction, animated: false)
        }
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: LogsAddLogDelegate, forDogManager: DogManager, forDogUUIDToUpdate: UUID?, forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogUUIDToUpdate = forDogUUIDToUpdate
        logToUpdate = forLogToUpdate
    }
    
    private func updateDynamicUIElements() {
        // We don't want this page to get too clutter. Therefore, if editting a log, so family member name will be shown, hide parent dog. Parent dog is uneditable as well, so no functionality is lost
        let parentDogIsHidden = dogUUIDToUpdate != nil && logToUpdate != nil
        parentDogLabel?.isHidden = parentDogIsHidden
        parentDogHeightConstraint?.constant = parentDogIsHidden ? 0.0 : 45.0
        parentDogBottomConstraint?.constant = parentDogIsHidden ? 0.0 : 10.0
        
        // The family member to a log is not editable by a user. Its set internally by the server. Therefore, if creating a log don't show it as it will automatically be the user. If editting a log, show it so a user can know who created this log
        let familyMemberNameIsHidden = dogUUIDToUpdate == nil || logToUpdate == nil
        familyMemberNameLabel?.isHidden = familyMemberNameIsHidden
        familyMemberNameHeightConstraint?.constant = familyMemberNameIsHidden ? 0.0 : 45.0
        familyMemberNameBottomConstraint?.constant = familyMemberNameIsHidden ? 0.0 : 10.0
        
        let logCustomActionNameIsHidden = (logActionSelected != .medicine && logActionSelected != .vaccine && logActionSelected != .custom)
        logCustomActionNameTextField?.isHidden = logCustomActionNameIsHidden
        logCustomActionNameTextField.placeholder = {
            // Dynamic placeholder depending upon which reminder action is selected
            if logActionSelected == .vaccine {
                return " Add a custom vaccine..."
            }
            else if logActionSelected == .medicine {
                return " Add a custom medicine..."
            }
            return " Add a custom action..."
        }()
        logCustomActionNameHeightConstraint?.constant = logCustomActionNameIsHidden ? 0.0 : 45.0
        logCustomActionNameBottomConstraint?.constant = logCustomActionNameIsHidden ? 0.0 : 10.0
        
        let logStartDatePickerIsHidden = isShowingLogStartDatePicker == false
        logStartDateLabel?.isHidden = !logStartDatePickerIsHidden
        logStartDateHeightConstraint?.constant = logStartDatePickerIsHidden ? 45.0 : 180.0
        logStartDatePicker?.isHidden = logStartDatePickerIsHidden
        
        let logEndDatePickerIsHidden = isShowingLogEndDatePicker == false
        logEndDateLabel?.isHidden = !logEndDatePickerIsHidden
        logEndDateHeightConstraint?.constant = logEndDatePickerIsHidden ? 45.0 : 180.0
        logEndDatePicker?.isHidden = logEndDatePickerIsHidden
        
        let logUnitIsHidden = {
            guard let logActionSelected = logActionSelected else {
                return true
            }
            
            let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
            
            // If logUnits for a logAction isn't empty (meaning a log action has available log units, then the log action should have log units displayed for it
            return logUnits.isEmpty
        }()
        
        // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
        logUnitLabel?.text = logUnitSelected?.adjustedPluralityString(
            forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
        )
        logUnitLabel?.isHidden = logUnitIsHidden
        logUnitHeightConstraint?.constant = logUnitIsHidden ? 0.0 : 45.0
        logUnitBottomConstraint?.constant = logUnitIsHidden ? 0.0 : 10.0
        
        // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
        logNumberOfLogUnitsTextField?.isEnabled = logUnitSelected != nil
        logNumberOfLogUnitsTextField?.isHidden = logUnitIsHidden
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideUIElement) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            // We have to perform these calculations after the view recalculation finishes. Otherwise they will be inaccurate as the new constraint changes havent taken effect.
            // The actual size of the container view without the padding added
            let containerViewHeightWithoutPadding = self.containerView.frame.height - self.containerViewPaddingHeightConstraint.constant
            // By how much the container view without padding is smaller than the safe area of the view
            let shortFallOfSafeArea = self.view.safeAreaLayoutGuide.layoutFrame.height - containerViewHeightWithoutPadding
            // If the containerView itself doesn't use up the whole safe area, then we add extra padding so it does
            self.containerViewPaddingHeightConstraint.constant = shortFallOfSafeArea > 0.0 ? shortFallOfSafeArea : 0.0
        }
    }
    
    // MARK: Drop Down
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else {
            return
        }
        
        let originalTouchPoint = sender.location(in: senderView)
        
        guard let deepestTouchedView = senderView.hitTest(originalTouchPoint, with: nil) else {
            return
        }
        
        // If the dropDown exist, then we might have to possibly hide it. The only case where we wouldn't want to collapse the drop down is if we click the dropdown itself or its corresponding label
        if let dropDownParentDog = dropDownParentDog, deepestTouchedView.isDescendant(of: parentDogLabel) == false && deepestTouchedView.isDescendant(of: dropDownParentDog) == false {
            dropDownParentDog.hideDropDown(animated: true)
        }
        if let dropDownLogAction = dropDownLogAction, deepestTouchedView.isDescendant(of: logActionLabel) == false && deepestTouchedView.isDescendant(of: dropDownLogAction) == false {
            dropDownLogAction.hideDropDown(animated: true)
        }
        if let dropDownLogUnit = dropDownLogUnit, deepestTouchedView.isDescendant(of: logUnitLabel) == false && deepestTouchedView.isDescendant(of: dropDownLogUnit) == false {
            dropDownLogUnit.hideDropDown(animated: true)
        }
        if let dropDownLogStartDate = dropDownLogStartDate, deepestTouchedView.isDescendant(of: logStartDateLabel) == false && deepestTouchedView.isDescendant(of: dropDownLogStartDate) == false {
            dropDownLogStartDate.hideDropDown(animated: true)
        }
        if let dropDownLogEndDate = dropDownLogEndDate, deepestTouchedView.isDescendant(of: logEndDateLabel) == false && deepestTouchedView.isDescendant(of: dropDownLogEndDate) == false {
            dropDownLogEndDate.hideDropDown(animated: true)
        }
        
        // If the tap was not on text view, we always dismiss keyboard as user clicked out
        // If tap was on text view and keyboard wasn't present, then this does nothing and keyboard shows
        // If tap wasn't on text view and keyboard was present, then this closes the keyboard
        dismissKeyboard()
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        guard let name = sender.name, let targetDropDownType = LogsAddLogDropDownTypes(rawValue: name) else {
            return
        }
        
        let targetDropDown = dropDown(forDropDownType: targetDropDownType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetDropDownType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given LogsAddLogDropDownTypes, return the corresponding dropDown object
    private func dropDown(forDropDownType: LogsAddLogDropDownTypes) -> DropDownUIView? {
        switch forDropDownType {
        case .parentDog:
            return dropDownParentDog
        case .logAction:
            return dropDownLogAction
        case .logUnit:
            return dropDownLogUnit
        case .logStartDate:
            return dropDownLogStartDate
        case .logEndDate:
            return dropDownLogEndDate
        }
    }
    
    /// For a given LogsAddLogDropDownTypes, return the corresponding label that shows the dropdown
    private func labelForDropDown(forDropDownType: LogsAddLogDropDownTypes) -> GeneralUILabel {
        switch forDropDownType {
        case .parentDog:
            return parentDogLabel
        case .logAction:
            return logActionLabel
        case .logUnit:
            return logUnitLabel
        case .logStartDate:
            return logStartDateLabel
        case .logEndDate:
            return logEndDateLabel
        }
    }
    
    /// Dismisses the keyboard and other dropdowns to show parentDogLabel
    private func showDropDown(_ dropDownType: LogsAddLogDropDownTypes, animated: Bool) {
        var targetDropDown = dropDown(forDropDownType: dropDownType)
        let labelForTargetDropDown = labelForDropDown(forDropDownType: dropDownType)
        
        if targetDropDown == nil {
            targetDropDown = DropDownUIView()
            if let targetDropDown = targetDropDown {
                targetDropDown.setupDropDown(
                    forDropDownUIViewIdentifier: dropDownType.rawValue,
                    forCellReusableIdentifier: "DropDownCell",
                    forDataSource: self,
                    forNibName: "DropDownTableViewCell",
                    forViewPositionReference: labelForTargetDropDown.frame,
                    forOffset: 2.5,
                    forRowHeight: DropDownUIView.rowHeightForGeneralUILabel
                )
                
                // Assign our actual drop down variable to the local variable drop down we just created
                switch dropDownType {
                case .parentDog:
                    dropDownParentDog = targetDropDown
                case .logAction:
                    dropDownLogAction = targetDropDown
                case .logUnit:
                    dropDownLogUnit = targetDropDown
                case .logStartDate:
                    dropDownLogStartDate = targetDropDown
                case .logEndDate:
                    dropDownLogEndDate = targetDropDown
                }
                
                // All of our dropDowns ordered by priority, where the lower the index views should be displayed over the higher index views
                let dropDownsOrderedByPriority: [DropDownUIView?] = {
                    return [dropDownParentDog, dropDownLogAction, dropDownLogStartDate, dropDownLogEndDate, dropDownLogUnit]
                }()
                let indexOfTargetDropDown = dropDownsOrderedByPriority.firstIndex(of: targetDropDown)
             
                if let superview = labelForTargetDropDown.superview, let indexOfTargetDropDown = indexOfTargetDropDown {
                    var didInsertSubview = false
                    // Iterate through dropDownsOrderedByPriority backwards, starting at our drop down. If the next nearest dropdown exists, then insert our dropdown below it
                    // E.g. targetDropDown = dropDownLogStartDate -> dropDownLogUnit doesn't exist yet -> dropDownLogAction exists so insert subview directly below it
                    // Insert the target drop down view above all lower indexed (and thus lower priority) drop downs.
                    
                    for i in (0..<indexOfTargetDropDown).reversed() {
                        if let nearestHigherPriorityDropDown = dropDownsOrderedByPriority[i] {
                            superview.insertSubview(targetDropDown, belowSubview: nearestHigherPriorityDropDown)
                            didInsertSubview = true
                            break
                        }
                    }
                    
                    if didInsertSubview == false {
                        // If no lower priority drop downs are visible, add it normally
                        superview.addSubview(targetDropDown)
                    }
                }
            }
        }
        
        // Dynamically show the target dropDown
        targetDropDown?.showDropDown(
            // Either show a maximum of 6.5 rows or the number of rows specified below
            numberOfRowsToShow: min(6.5, {
                switch dropDownType {
                case .parentDog:
                    return CGFloat(dogManager?.dogs.count ?? 0)
                case .logAction:
                    return CGFloat(LogAction.allCases.count)
                case .logUnit:
                    return {
                        guard let logActionSelected = logActionSelected else {
                            return 0.0
                        }
                        
                        return CGFloat(LogUnit.logUnits(forLogAction: logActionSelected).count)
                    }()
                case .logStartDate:
                    return CGFloat(TimeQuickSelectOptions.allCases.count)
                case .logEndDate:
                    return CGFloat(TimeQuickSelectOptions.allCases.count)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? DropDownTableViewCell else {
            return
        }
        
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue {
            guard let dogManager = dogManager else {
                return
            }
            
            let dog = dogManager.dogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: forDogUUIDsSelected.contains(dog.dogUUID))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logAction.rawValue {
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                customCell.label.text = LogAction.allCases[indexPath.row].fullReadableName(logCustomActionName: nil)
                
                if let logActionSelected = logActionSelected {
                    // if the user has a logActionSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: LogAction.allCases.firstIndex(of: logActionSelected) == indexPath.row)
                }
            }
            // a user generated custom name
            else {
                let previousLogCustomActionName = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                
                customCell.label.text = previousLogCustomActionName.logAction.fullReadableName(
                    logCustomActionName: previousLogCustomActionName.logCustomActionName
                )
                
                customCell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue {
            guard let logActionSelected = logActionSelected else {
                return
            }
            
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            
            let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
            
            if indexPath.row < logUnits.count {
                // inside of the predefined available LogUnits
                let logUnit = logUnits[indexPath.row]
                
                customCell.label.text = logUnit.adjustedPluralityString(
                    forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text) ?? 0.0
                )
                
                if let logUnitSelected = logUnitSelected {
                    // if the user has a logUnitSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: logUnitSelected == logUnit)
                }
                
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue || dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            
            if let timeQuickSelect = TimeQuickSelectOptions.allCases.safeIndex(indexPath.row) {
                customCell.label.text = timeQuickSelect.rawValue
                
                // Purposefully don't set the cell as selected. This is because even if a user selects a quick time select cell, its selected state depends upon the current time. For example: if they select 5 mins ago, logStartDate will be set to 5 minutes ago from the present. However, if the user reopens the menu again a few seconds later, logStartDate is now 5 mins and 10 seconds ago.
            }
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue {
            guard let dogManager = dogManager else {
                return 0
            }
            
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logAction.rawValue {
            return LogAction.allCases.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue {
            guard let logActionSelected = logActionSelected else {
                return 0
            }
            
            return LogUnit.logUnits(forLogAction: logActionSelected).count
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue || dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            return TimeQuickSelectOptions.allCases.count
        }
        
        return 0
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue {
            return 1
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logAction.rawValue {
            return 1
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue {
            return 1
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue || dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            return 1
        }
        
        return 0
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue, let selectedCell = dropDownParentDog?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            guard let dogManager = dogManager else {
                return
            }
            
            let dogSelected = dogManager.dogs[indexPath.row]
            let beforeSelectNumberOfDogUUIDsSelected = forDogUUIDsSelected.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a parent dog, remove it from our array
                forDogUUIDsSelected.removeAll { dogUUID in
                    dogUUID == dogSelected.dogUUID
                }
            }
            else {
                // The user has selected a parent dog, add it to our array
                forDogUUIDsSelected.append(dogSelected.dogUUID)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfDogUUIDsSelected == 0 {
                // If initially, there were no dogs selected, then the user selected their first dog, we immediately hide this drop down then open the log action drop down. Allowing them to seemlessly choose the log action next
                dropDownParentDog?.hideDropDown(animated: true)
                showDropDown(.logAction, animated: true)
            }
            else if forDogUUIDsSelected.count == dogManager.dogs.count {
                // selected every dog in the drop down, close the drop down
                dropDownParentDog?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logAction.rawValue, let selectedCell = dropDownLogAction?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            let beforeSelectLogActionSelected = logActionSelected
            
            guard selectedCell.isCustomSelected == false else {
                // The selected cell was already selected, and the user unselected it
                selectedCell.setCustomSelectedTableViewCell(forSelected: false)
                logActionSelected = nil
                // Don't hideDropDownLogAction() because user needs to select a log action for log to be valid
                return
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                logActionSelected = LogAction.allCases[indexPath.row]
                
                if logActionSelected == .medicine || logActionSelected == .vaccine || logActionSelected == .custom {
                    // If a user selected a blank custom log action, automatically start them to type in the field
                    logCustomActionNameTextField.becomeFirstResponder()
                }
            }
            // a user generated custom name
            else {
                let previousLogCustomActionName = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                logActionSelected = previousLogCustomActionName.logAction
                logCustomActionNameTextField.text = previousLogCustomActionName.logCustomActionName
            }
            
            // hideDropDownLogAction() because the user selected a log action
            dropDownLogAction?.hideDropDown(animated: true)
            
            if beforeSelectLogActionSelected == nil && logCustomActionNameTextField.isFirstResponder == false {
                // If initially, there were no log actions selected, then the user selected their first log action, we immediately hide this drop down then open the log start date drop down. Allowing them to seemlessly choose the log start date next
                // The only exception is if the user selected a .custom log action (a blank one, not one stored in localPreviousLogCustomActionNames), then we don't show the dropDown because the keyboard is up
                if isShowingLogStartDatePicker == false {
                    // The logStartDate hasn't been converted into the time selection wheel for a custom time input, therefore we can show the dropdown for the user
                    showDropDown(.logStartDate, animated: true)
                }
                else {
                    // The logStartDate has been converted into the time selection wheel for a custom time input, therefore showing the dropdown would make no sense, as there is no accompanying text field and only a big time selection wheel. Therefore, show the logEndDate drop down instead
                    showDropDown(.logEndDate, animated: true)
                }
                
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue, let selectedCell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell, let logActionSelected = logActionSelected {
            
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
            dropDownLogUnit?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue, let selectedCell = dropDownLogStartDate?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            // a cell for dropDownLogStartDate should never be able to stay selected.
            // If a user selects a cell, the menu closes. If the user reopens the menu, no cells should be selected. As time quick select is dependent on present. So if a user selects 5 mins ago, then reopens the menu, we can't leave 5 mins ago selected as its now 5 mins and 10 seconds ago.
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = TimeQuickSelectOptions.allCases[indexPath.row].convertToDouble()
            
            if let timeIntervalSelected = timeIntervalSelected {
                // Apply the time quick select option
                logStartDateSelected = Date().addingTimeInterval(timeIntervalSelected)
            }
            else {
                isShowingLogStartDatePicker = true
                isShowingLogEndDatePicker = false
            }
            
            dropDownLogStartDate?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue, let selectedCell = dropDownLogEndDate?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            // a cell for dropDownLogStartDate should never be able to stay selected.
            // If a user selects a cell, the menu closes. If the user reopens the menu, no cells should be selected. As time quick select is dependent on present. So if a user selects 5 mins ago, then reopens the menu, we can't leave 5 mins ago selected as its now 5 mins and 10 seconds ago.
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = TimeQuickSelectOptions.allCases[indexPath.row].convertToDouble()
            
            if let timeIntervalSelected = timeIntervalSelected {
                // Apply the time quick select option
                logEndDateSelected = Date().addingTimeInterval(timeIntervalSelected)
            }
            else {
                isShowingLogEndDatePicker = true
                isShowingLogStartDatePicker = false
            }
            
            dropDownLogEndDate?.hideDropDown(animated: true)
        }
    }
    
}

extension LogsAddLogViewController {
    private func willAddLog(logActionSelected: LogAction, logStartDateSelected: Date) {
        saveLogButton.beginSpinning()
        
        // Only retrieve matchingReminders if switch is on.
        let matchingReminders: [(UUID, Reminder)] = {
            return dogManager?.matchingReminders(
                forDogUUIDs: forDogUUIDsSelected,
                forLogAction: logActionSelected,
                forLogCustomActionName: logCustomActionNameTextField.text
            ) ?? []
        }()
        
        let completionTracker = CompletionTracker(numberOfTasks: forDogUUIDsSelected.count + matchingReminders.count) {
            // everytime a task completes, update the dog manager so everything else updates
            if let dogManager = self.dogManager {
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
            }
        } completedAllTasksCompletionHandler: {
            // when everything completes, close the page
            self.saveLogButton.endSpinning()
            self.dismiss(animated: true) {
                // Wait for the view to be dismissed, then see if we should request any sort of review from the user (if we don't wait, then the view presented by CheckManager will be dismissed when this view dismisses)
                CheckManager.checkForReview()
                CheckManager.checkForSurveyFeedbackAppExperience()
            }
        } failedTaskCompletionHandler: {
            // if a problem is encountered, then just stop the indicator
            self.saveLogButton.endSpinning()
        }
        
        matchingReminders.forEach { dogUUID, matchingReminder in
            matchingReminder.enableIsSkipping(forSkippedDate: logStartDateSelected)
            
            RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUID, forReminders: [matchingReminder]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }
                
                completionTracker.completedTask()
            }
        }
        
        let logToAdd = Log()
        logToAdd.logAction = logActionSelected
        logToAdd.logCustomActionName = logCustomActionNameTextField.text ?? ""
        logToAdd.changeLogUnit(
            forLogUnit: logUnitSelected,
            forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
        )
        logToAdd.changeLogDate(forLogStartDate: logStartDateSelected, forLogEndDate: logEndDateSelected)
        logToAdd.logNote = logNoteTextView.text ?? ""
        
        forDogUUIDsSelected.forEach { dogUUIDSelected in
            // Each dog needs it's own newLog object.
            guard let logToAdd = logToAdd.copy() as? Log else {
                return
            }
            
            LogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUIDSelected, forLog: logToAdd) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }
                
                // request was successful so we can now add the new logCustomActionName
                LocalConfiguration.addLogCustomAction(forLogAction: logToAdd.logAction, forLogCustomActionName: logToAdd.logCustomActionName)
                
                self.dogManager?.findDog(forDogUUID: dogUUIDSelected)?.dogLogs.addLog(forLog: logToAdd)
                
                completionTracker.completedTask()
            }
            
        }
        
    }
    
    private func willUpdateLog(dogUUIDToUpdate: UUID, logToUpdate: Log, logActionSelected: LogAction, logStartDateSelected: Date) {
        logToUpdate.changeLogDate(forLogStartDate: logStartDateSelected, forLogEndDate: logEndDateSelected)
        logToUpdate.logAction = logActionSelected
        logToUpdate.logCustomActionName = (logActionSelected == .medicine || logActionSelected == .vaccine || logActionSelected == .custom) ? logCustomActionNameTextField.text ?? "" : ""
        logToUpdate.changeLogUnit(
            forLogUnit: logUnitSelected,
            forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text)
        )
        logToUpdate.logNote = logNoteTextView.text ?? ""
        
        saveLogButton.beginSpinning()
        
        LogsRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dogUUIDToUpdate, forLog: logToUpdate) { responseStatus, _ in
            self.saveLogButton.endSpinning()
            guard responseStatus != .failureResponse else {
                return
            }
            
            // request was successful so we can now add the new logCustomActionName
            LocalConfiguration.addLogCustomAction(forLogAction: logToUpdate.logAction, forLogCustomActionName: logToUpdate.logCustomActionName)
            
            self.dogManager?.findDog(forDogUUID: dogUUIDToUpdate)?.dogLogs.addLog(forLog: logToUpdate)
            
            if let dogManager = self.dogManager {
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
            }
            
            self.dismiss(animated: true) {
                // Wait for the view to be dismissed, then see if we should request any sort of review from the user (if we don't wait, then the view presented by CheckManager will be dismissed when this view dismisses)
                CheckManager.checkForReview()
                CheckManager.checkForSurveyFeedbackAppExperience()
            }
        }
    }
}
