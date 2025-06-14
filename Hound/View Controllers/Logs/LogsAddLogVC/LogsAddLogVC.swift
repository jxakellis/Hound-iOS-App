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

final class LogsAddLogViewController: GeneralUIViewController,
                                      LogsAddLogUIInteractionActionsDelegate,
                                      DropDownUIViewDataSource {
    
    // MARK: - LogsAddLogUIInteractionActionsDelegate
    
    func logCustomActionNameTextFieldDidReturn() {
        if logStartDateSelected == nil {
            // If a user input a logCustomActionName in that dynamically-appearing field and logStartDateSelected is nil,
            // that means the normal flow of selecting log action -> selecting log start date was interrupted. Resume this
            // by opening logStartDate dropdown.
            showDropDown(.logStartDate, animated: true)
        }
    }
    
    @objc func didUpdateLogNumberOfLogUnits() {
        // When the user enters a number into log units, it could update the plurality of the logUnitLabel
        // (e.g. no number but "pills" then the user enters 1 so "pills" should become "pill").
        // So by setting logUnitTypeSelected it updates logUnitLabel.
        updateDynamicUIElements()
    }
    
    // MARK: - UI Elements (formerly IBOutlets)
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // TODO UIKIT make the nslayout stuff work
    /// We use this padding so that the content inside the scroll view is ≥ the size of the safe area.
    /// If it is not, then the drop down menus will clip outside the content area, displaying on the lower half
    /// of the region but being un-interactable because they are outside the containerView.
    private weak var containerViewExtraPaddingHeightConstraint: NSLayoutConstraint!
    private let containerViewExtraPadding: GeneralUIView = {
        let view = GeneralUIView()
        return view
    }()
    
    private let pageTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Create Log"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 35)
        label.textColor = .systemBlue
        return label
    }()
    
    private let parentDogLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.font = .systemFont(ofSize: 17.5)
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        label.shouldRoundCorners = true
        return label
    }()
    
    private var parentDogHeightConstraint: NSLayoutConstraint!
    private var parentDogBottomConstraint: NSLayoutConstraint!
    
    private let familyMemberNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 285, compressionResistancePriority: 285)
        label.font = .systemFont(ofSize: 17.5)
        label.shouldRoundCorners = true
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        return label
    }()
    
    private var familyMemberNameHeightConstraint: NSLayoutConstraint!
    private var familyMemberNameBottomConstraint: NSLayoutConstraint!
    
    private let logActionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
      
        label.shouldRoundCorners = true
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        return label
    }()
    
    /// Text input for logCustomActionNameName
    private let logCustomActionNameTextField: GeneralUITextField = {
        let textField = GeneralUITextField(huggingPriority: 275, compressionResistencePriority: 775)
        
        textField.borderColor = .systemGray2
        textField.borderWidth = 0.5
        textField.shouldRoundCorners = true
        
        return textField
    }()
    
    private var logCustomActionNameHeightConstraint: NSLayoutConstraint!
    private var logCustomActionNameBottomConstraint: NSLayoutConstraint!
    
    private let logNumberOfLogUnitsTextField: GeneralUITextField = {
        let textField = GeneralUITextField()
        
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        
        textField.borderColor = .systemGray2
        textField.borderWidth = 0.5
        textField.shouldRoundCorners = true

        return textField
    }()
    
    private let logUnitLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 245, compressionResistancePriority: 245)
        label.font = .systemFont(ofSize: 17.5)
        label.shouldRoundCorners = true
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        return label
    }()
    
    private var logUnitHeightConstraint: NSLayoutConstraint!
    private var logUnitBottomConstraint: NSLayoutConstraint!
    
    private let logNoteTextView: GeneralUITextView = {
        let textView = GeneralUITextView(huggingPriority: 240, compressionResistancePriority: 240)
        
        textView.text = "Log Note"
        
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 17.5)
        textView.shouldRoundCorners = true
        textView.borderColor = .systemGray2
        textView.borderWidth = 0.5
        return textView
    }()
    
    private let logStartDateLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.font = .systemFont(ofSize: 17.5)
        label.shouldRoundCorners = true
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        return label
    }()
    
    private var logStartDateHeightConstraint: NSLayoutConstraint!
    private let logStartDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 265, compressionResistancePriority: 265)
        datePicker.isHidden = true
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    @objc private func didUpdateLogStartDate(_ sender: Any) {
        // By updating logStartDateSelected, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogEndDate?.hideDropDown(animated: true)
        self.logStartDateSelected = logStartDatePicker.date
        self.dismissKeyboard()
    }
    
    private let logEndDateLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = .systemFont(ofSize: 17.5)
        label.shouldRoundCorners = true
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        return label
    }()
    
    private var logEndDateHeightConstraint: NSLayoutConstraint!
    private let logEndDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 255, compressionResistancePriority: 255)
        datePicker.isHidden = true
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    @objc private func didUpdateLogEndDate(_ sender: Any) {
        // By updating logEndDateSelected, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogStartDate?.hideDropDown(animated: true)
        self.logEndDateSelected = logEndDatePicker.date
        self.dismissKeyboard()
    }
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        return button
    }()
    
    @objc private func didTouchUpInsideBack(_ sender: Any) {
        if didUpdateInitialValues == true {
            let unsavedInformationConfirmation = UIAlertController(
                title: "Are you sure you want to exit?",
                message: nil,
                preferredStyle: .alert
            )
            
            let exitAlertAction = UIAlertAction(
                title: "Yes, I don't want to save changes",
                style: .default
            ) { _ in
                self.dismiss(animated: true) {
                    // Wait for the view to be dismissed, then see if we should request any sort of review from the user
                    // (if we don't wait, then the view presented by ShowBonusInformationManager will be dismissed when this view dismisses)
                    ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                    ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                }
            }
            
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(exitAlertAction)
            unsavedInformationConfirmation.addAction(cancelAlertAction)
            
            PresentationManager.enqueueAlert(unsavedInformationConfirmation)
        }
        else {
            self.dismiss(animated: true) {
                // Wait for the view to be dismissed, then see if we should request any sort of review from the user
                ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        }
    }
    
    private let saveLogButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        return button
    }()
    
    @objc private func didTouchUpInsideSaveLog(_ sender: Any) {
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
        
        willUpdateLog(dogUUIDToUpdate: dogUUIDToUpdate,
                      logToUpdate: logToUpdate,
                      logActionSelected: logActionSelected,
                      logStartDateSelected: logStartDateSelected)
    }
    
    private let removeLogButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        return button
    }()
    
    @objc private func didTouchUpInsideRemoveLog(_ sender: Any) {
        guard let dogUUIDToUpdate = dogUUIDToUpdate else {
            return
        }
        guard let logToUpdate = logToUpdate else {
            return
        }
        
        let removeLogConfirmation = UIAlertController(
            title: "Are you sure you want to delete this log?",
            message: nil,
            preferredStyle: .alert
        )
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // The user decided to delete so we must query server
            LogsRequest.delete(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: dogUUIDToUpdate,
                forLogUUID: logToUpdate.logUUID
            ) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }
                
                self.dogManager?.findDog(forDogUUID: dogUUIDToUpdate)?
                    .dogLogs.removeLog(forLogUUID: logToUpdate.logUUID)
                
                if let dogManager = self.dogManager {
                    self.delegate.didUpdateDogManager(
                        sender: Sender(origin: self, localized: self),
                        forDogManager: dogManager
                    )
                }
                
                self.dismiss(animated: true) {
                    // Wait for the view to be dismissed, then see if we should request any sort of review from the user
                    ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                    ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                }
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeLogConfirmation.addAction(removeAlertAction)
        removeLogConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(removeLogConfirmation)
    }
    
    // MARK: - Additional UI Elements
    
    private let contentScrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        return scrollView
    }()
    
    private let bottomSpacerView: GeneralUIView = {
        let view = GeneralUIView()
        view.isHidden = true
        return view
    }()
    
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
    private var initialLogActionType: LogActionType?
    private var initialLogCustomActionName: String?
    private var initialLogUnitType: LogUnitType?
    private var initialLogNumberOfLogUnits: String?
    private var initialLogNote: String?
    private var initialLogStartDate: Date?
    private var initialLogEndDate: Date?
    
    private var didUpdateInitialValues: Bool {
        if initialLogActionType != logActionSelected { return true }
        if logActionSelected?.allowsCustom == true && initialLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        if initialLogUnitType != logUnitTypeSelected { return true }
        if initialLogNumberOfLogUnits != logNumberOfLogUnitsTextField.text { return true }
        if initialLogNote != logNoteTextView.text { return true }
        if initialLogStartDate != logStartDateSelected { return true }
        if initialLogEndDate != logEndDateSelected { return true }
        if initialForDogUUIDsSelected != forDogUUIDsSelected { return true }
        return false
    }
    
    // MARK: Parent Dog Drop Down
    
    private var dropDownParentDog: DropDownUIView?
    private var forDogUUIDsSelected: [UUID] = [] {
        didSet {
            parentDogLabel.text = {
                guard let dogManager = dogManager, !forDogUUIDsSelected.isEmpty else {
                    // If no parent dog selected, leave text blank so placeholder displays
                    return nil
                }
                
                // If only one dog selected, show that dog's name
                if forDogUUIDsSelected.count == 1,
                   let lastRemainingDogUUID = self.forDogUUIDsSelected.first,
                   let lastRemainingDog = dogManager.dogs.first(where: { $0.dogUUID == lastRemainingDogUUID }) {
                    return lastRemainingDog.dogName
                }
                // If multiple but not all dogs selected, show "Multiple"
                else if forDogUUIDsSelected.count > 1 && forDogUUIDsSelected.count < dogManager.dogs.count {
                    return "Multiple"
                }
                // If all dogs selected, show "All"
                else if forDogUUIDsSelected.count == dogManager.dogs.count {
                    return "All"
                }
                
                return nil
            }()
        }
    }
    
    // MARK: Log Action Drop Down
    
    private var dropDownLogAction: DropDownUIView?
    /// The selected log action type
    private var logActionSelected: LogActionType? {
        didSet {
            updateDynamicUIElements()
            
            // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logActionType dropdown,
            // so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName",
            // the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            logActionLabel.text = logActionSelected?.convertToReadableName(customActionName: nil)
            
            // If log action changed to something where the current logUnit is no longer valid, clear logUnitTypeSelected
            if let selected = logActionSelected {
                let validUnits = selected.associatedLogUnitTypes
                if let currentUnit = logUnitTypeSelected, !validUnits.contains(currentUnit) {
                    logUnitTypeSelected = nil
                }
            }
            else {
                logUnitTypeSelected = nil
            }
        }
    }
    
    // MARK: Log Unit Drop Down
    
    private var dropDownLogUnit: DropDownUIView?
    /// The selected log unit type
    private var logUnitTypeSelected: LogUnitType? {
        didSet {
            updateDynamicUIElements()
        }
    }
    
    // MARK: Log Start Date
    
    private var dropDownLogStartDate: DropDownUIView?
    private var dropDownLogStartDateOptions: [TimeQuickSelectOptions] {
        // If logEndDateSelected is nil, all options are valid
        guard let endDate = logEndDateSelected else {
            return TimeQuickSelectOptions.allCases
        }
        return TimeQuickSelectOptions.optionsOccurringBeforeDate(
            startingPoint: Date(),
            occurringOnOrBefore: endDate
        )
    }
    private var logStartDateSelected: Date? {
        didSet {
            if let start = logStartDateSelected {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(start) {
                    // If the start date is today, show only time
                    dateFormatter.setLocalizedDateFormatFromTemplate("hma") // 7:53 AM
                }
                else {
                    // If start date is not today, show month/day and possibly year
                    let yearOfStart = Calendar.current.component(.year, from: start)
                    let currentYear = Calendar.current.component(.year, from: Date())
                    let format = (yearOfStart == currentYear) ? "MMMMdhma" : "MMMMdyyyyhma"
                    dateFormatter.setLocalizedDateFormatFromTemplate(format)
                }
                logStartDateLabel.text = dateFormatter.string(from: start)
            }
            else {
                logStartDateLabel.text = nil
            }
        }
    }
    private var isShowingLogStartDatePicker = false {
        didSet {
            if isShowingLogStartDatePicker {
                isShowingLogEndDatePicker = false
                // If showing the logStartDatePicker, dropDownLogEndDate might be out of place; remove and rebuild
                dropDownLogEndDate?.removeFromSuperview()
                dropDownLogEndDate = nil
                
                // Ensure start date ≤ end date if end date already set
                if let endDate = logEndDateSelected {
                    logStartDatePicker.maximumDate = endDate
                }
                
                // Sync date picker’s date
                logStartDatePicker.date = logStartDateSelected
                ?? Date.roundDate(
                    targetDate: Date(),
                    roundingInterval: Double(60 * logStartDatePicker.minuteInterval),
                    roundingMethod: .toNearestOrAwayFromZero
                )
                // Save this value so that if user doesn’t manually change it, we preserve it
                logStartDateSelected = logStartDatePicker.date
            }
            
            updateDynamicUIElements()
        }
    }
    
    // MARK: Log End Date Drop Down
    
    private var dropDownLogEndDate: DropDownUIView?
    private var dropDownLogEndDateOptions: [TimeQuickSelectOptions] {
        // If logStartDateSelected is nil, all options are valid
        guard let start = logStartDateSelected else {
            return TimeQuickSelectOptions.allCases
        }
        return TimeQuickSelectOptions.optionsOccurringAfterDate(
            startingPoint: Date(),
            occurringOnOrAfter: start
        )
    }
    private var logEndDateSelected: Date? {
        didSet {
            if let end = logEndDateSelected {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(end) {
                    // If end date is today, show only time
                    dateFormatter.setLocalizedDateFormatFromTemplate("hma")
                }
                else {
                    // If end date is not today, show month/day and possibly year
                    let yearOfEnd = Calendar.current.component(.year, from: end)
                    let currentYear = Calendar.current.component(.year, from: Date())
                    let format = (yearOfEnd == currentYear) ? "MMMMdhma" : "MMMMdyyyyhma"
                    dateFormatter.setLocalizedDateFormatFromTemplate(format)
                }
                logEndDateLabel.text = dateFormatter.string(from: end)
            }
            else {
                logEndDateLabel.text = nil
            }
        }
    }
    private var isShowingLogEndDatePicker = false {
        didSet {
            if isShowingLogEndDatePicker {
                isShowingLogStartDatePicker = false
                // If showing the logEndDatePicker, dropDownLogStartDate might be out of place; remove and rebuild
                dropDownLogStartDate?.removeFromSuperview()
                dropDownLogStartDate = nil
                
                // Ensure end date ≥ start date if start date already set
                if let start = logStartDateSelected {
                    logEndDatePicker.minimumDate = start
                }
                
                // Sync date picker’s date
                logEndDatePicker.date = logEndDateSelected
                ?? Date.roundDate(
                    targetDate: Date(),
                    roundingInterval: Double(60 * logEndDatePicker.minuteInterval),
                    roundingMethod: .toNearestOrAwayFromZero
                )
                // Save this value so that if user doesn’t manually change it, we preserve it
                logEndDateSelected = logEndDatePicker.date
            }
            
            updateDynamicUIElements()
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // Set forDogUUIDsSelected = [] to invoke didSet and initialize label text appropriately
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
            
            // If the family only has one dog, then force the parent dog selected to be that single dog.
            // Otherwise, leave list empty so user must select.
            if dogManager.dogs.count == 1 {
                if let uuid = dogManager.dogs.first?.dogUUID {
                    forDogUUIDsSelected = [uuid]
                    initialForDogUUIDsSelected = forDogUUIDsSelected
                }
            }
            
            // Disable parentDogLabel if only one dog in family
            parentDogLabel.isEnabled = dogManager.dogs.count != 1
            familyMemberNameLabel.isEnabled = true
        }
        
        // Parent Dog Label placeholder logic
        parentDogLabel.placeholder = dogManager.dogs.count <= 1
        ? "What dog did you take care of?"
        : "What dog(s) did you take care of?"
        
        // Family Member Name
        familyMemberNameLabel.isEnabled = false
        familyMemberNameLabel.text = FamilyInformation.findFamilyMember(forUserId: logToUpdate?.userId)?.displayFullName
        // This placeholder is dynamic; show family member name or keep blank for indentation
        familyMemberNameLabel.placeholder = familyMemberNameLabel.text
        
        // Log Action
        logActionSelected = logToUpdate?.logActionType
        initialLogActionType = logActionSelected
        logActionLabel.placeholder = "What action did you do?"
        
        // Log Custom Action Name
        logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
        initialLogCustomActionName = logCustomActionNameTextField.text
        // Placeholder is dynamic, so set elsewhere
        logCustomActionNameTextField.delegate = uiDelegate
        
        // Log Unit
        let convertedLogUnits: (LogUnitType, Double)? = {
            guard let unitType = logToUpdate?.logUnitType,
                  let numberOfUnits = logToUpdate?.logNumberOfLogUnits else {
                return nil
            }
            return LogUnitTypeConverter.convert(
                forLogUnitType: unitType,
                forNumberOfLogUnits: numberOfUnits,
                toTargetSystem: UserConfiguration.measurementSystem
            )
        }()
        
        logUnitTypeSelected = convertedLogUnits?.0
        initialLogUnitType = logUnitTypeSelected
        logUnitLabel.placeholder = "Add a unit..."
        
        // Log Number of Log Units
        logNumberOfLogUnitsTextField.text = LogUnitType.convertDoubleToRoundedString(
            forLogNumberOfLogUnits: convertedLogUnits?.1
        )
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
        // Spaces to align with general label
        logNoteTextView.placeholder = "Add some notes..."
        logNoteTextView.delegate = uiDelegate
        
        // MARK: Gestures
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
        
        let parentDogLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        parentDogLabelGesture.name = LogsAddLogDropDownTypes.parentDog.rawValue
        parentDogLabelGesture.delegate = uiDelegate
        parentDogLabelGesture.cancelsTouchesInView = false
        parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count != 1
        parentDogLabel.addGestureRecognizer(parentDogLabelGesture)
        
        let logActionLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        logActionLabelGesture.name = LogsAddLogDropDownTypes.logActionType.rawValue
        logActionLabelGesture.delegate = uiDelegate
        logActionLabelGesture.cancelsTouchesInView = false
        logActionLabel.isUserInteractionEnabled = true
        logActionLabel.addGestureRecognizer(logActionLabelGesture)
        
        let logUnitLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        logUnitLabelGesture.name = LogsAddLogDropDownTypes.logUnit.rawValue
        logUnitLabelGesture.delegate = uiDelegate
        logUnitLabelGesture.cancelsTouchesInView = false
        logUnitLabel.isUserInteractionEnabled = true
        logUnitLabel.addGestureRecognizer(logUnitLabelGesture)
        
        let logStartDateLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        logStartDateLabelGesture.name = LogsAddLogDropDownTypes.logStartDate.rawValue
        logStartDateLabelGesture.delegate = uiDelegate
        logStartDateLabelGesture.cancelsTouchesInView = false
        logStartDateLabel.isUserInteractionEnabled = true
        logStartDateLabel.addGestureRecognizer(logStartDateLabelGesture)
        
        let logEndDateLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
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
        
        // If the user hasn't selected a parent dog (first time the VC appears), show parent dog dropdown
        if forDogUUIDsSelected.isEmpty {
            showDropDown(.parentDog, animated: false)
        }
        // Else if user has a parent dog selected (only one dog in family), show log action dropdown
        else if logActionSelected == nil {
            showDropDown(.logActionType, animated: false)
        }
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: LogsAddLogDelegate,
               forDogManager: DogManager,
               forDogUUIDToUpdate: UUID?,
               forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogUUIDToUpdate = forDogUUIDToUpdate
        logToUpdate = forLogToUpdate
    }
    
    private func updateDynamicUIElements() {
        // We don't want this page to get too cluttered. Therefore, if editing a log (so family member name will be shown),
        // hide parent dog. Parent dog is uneditable as well, so no functionality is lost.
        let parentDogIsHidden = dogUUIDToUpdate != nil && logToUpdate != nil
        parentDogLabel.isHidden = parentDogIsHidden
        parentDogHeightConstraint.constant = parentDogIsHidden ? 0.0 : 45.0
        parentDogBottomConstraint.constant = parentDogIsHidden ? 0.0 : 10.0
        
        // The family member to a log is not editable by a user. Its set internally by the server.
        // Therefore, if creating a log, don't show it as it will automatically be the user. If editing a log, show it
        // so a user can know who created this log.
        let familyMemberNameIsHidden = dogUUIDToUpdate == nil || logToUpdate == nil
        familyMemberNameLabel.isHidden = familyMemberNameIsHidden
        familyMemberNameHeightConstraint.constant = familyMemberNameIsHidden ? 0.0 : 45.0
        familyMemberNameBottomConstraint.constant = familyMemberNameIsHidden ? 0.0 : 10.0
        
        let logCustomActionNameIsHidden = logActionSelected?.allowsCustom != true
        logCustomActionNameTextField.isHidden = logCustomActionNameIsHidden
        logCustomActionNameHeightConstraint.constant = logCustomActionNameIsHidden ? 0.0 : 45.0
        logCustomActionNameBottomConstraint.constant = logCustomActionNameIsHidden ? 0.0 : 10.0
        
        let logStartDatePickerIsHidden = !isShowingLogStartDatePicker
        logStartDateLabel.isHidden = !logStartDatePickerIsHidden
        logStartDateHeightConstraint.constant = logStartDatePickerIsHidden ? 45.0 : 180.0
        logStartDatePicker.isHidden = logStartDatePickerIsHidden
        
        let logEndDatePickerIsHidden = !isShowingLogEndDatePicker
        logEndDateLabel.isHidden = !logEndDatePickerIsHidden
        logEndDateHeightConstraint.constant = logEndDatePickerIsHidden ? 45.0 : 180.0
        logEndDatePicker.isHidden = logEndDatePickerIsHidden
        
        let logUnitIsHidden: Bool = {
            guard let selected = logActionSelected else {
                return true
            }
            // If logAction has associated unit types, show logUnit
            return selected.associatedLogUnitTypes.isEmpty
        }()
        
        logUnitLabel.text = logUnitTypeSelected?.convertDoubleToPluralityString(
            forLogNumberOfLogUnits: LogUnitType.convertStringToDouble(
                forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
            )
        )
        logUnitLabel.isHidden = logUnitIsHidden
        logUnitHeightConstraint.constant = logUnitIsHidden ? 0.0 : 45.0
        logUnitBottomConstraint.constant = logUnitIsHidden ? 0.0 : 10.0
        
        logNumberOfLogUnitsTextField.isEnabled = logUnitTypeSelected != nil
        logNumberOfLogUnitsTextField.isHidden = logUnitIsHidden
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideUIElement) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            // Adjust containerView padding so content fills safe area
            let containerHeightWithoutPadding = self.containerView.frame.height - self.containerViewPaddingHeightConstraint.constant
            let shortfall = self.view.safeAreaLayoutGuide.layoutFrame.height - containerHeightWithoutPadding
            self.containerViewPaddingHeightConstraint.constant = shortfall > 0.0 ? shortfall : 0.0
        }
    }
    
    // MARK: - Drop Down Handling
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return }
        
        // If a dropDown exists, hide it unless tap is on its label or itself
        if let dd = dropDownParentDog, !touched.isDescendant(of: parentDogLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        if let dd = dropDownLogAction, !touched.isDescendant(of: logActionLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        if let dd = dropDownLogUnit, !touched.isDescendant(of: logUnitLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        if let dd = dropDownLogStartDate, !touched.isDescendant(of: logStartDateLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        if let dd = dropDownLogEndDate, !touched.isDescendant(of: logEndDateLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        
        // Dismiss keyboard if tap was outside text inputs
        dismissKeyboard()
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        guard let name = sender.name,
              let targetType = LogsAddLogDropDownTypes(rawValue: name) else { return }
        
        let targetDropDown = dropDown(forDropDownType: targetType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given dropDownType, return the corresponding dropDown UIView
    private func dropDown(forDropDownType type: LogsAddLogDropDownTypes) -> DropDownUIView? {
        switch type {
        case .parentDog: return dropDownParentDog
        case .logActionType: return dropDownLogAction
        case .logUnit: return dropDownLogUnit
        case .logStartDate: return dropDownLogStartDate
        case .logEndDate: return dropDownLogEndDate
        }
    }
    
    /// For a given dropDownType, return the label that triggers it
    private func labelForDropDown(forDropDownType type: LogsAddLogDropDownTypes) -> GeneralUILabel {
        switch type {
        case .parentDog: return parentDogLabel
        case .logActionType: return logActionLabel
        case .logUnit: return logUnitLabel
        case .logStartDate: return logStartDateLabel
        case .logEndDate: return logEndDateLabel
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: LogsAddLogDropDownTypes, animated: Bool) {
        // If showing start date and only "custom" and "now" are valid, show picker
        if type == .logStartDate && dropDownLogStartDateOptions.count <= 1 {
            isShowingLogStartDatePicker = true
            return
        }
        // If showing end date and only "custom" is valid, show picker
        if type == .logEndDate && dropDownLogEndDateOptions.count <= 1 {
            isShowingLogEndDatePicker = true
            return
        }
        
        var targetDropDown = dropDown(forDropDownType: type)
        let label = labelForDropDown(forDropDownType: type)
        
        if targetDropDown == nil {
            targetDropDown = DropDownUIView()
            if let targetDropDown = targetDropDown {
                targetDropDown.setupDropDown(
                    forDropDownUIViewIdentifier: type.rawValue,
                    forDataSource: self,
                    forViewPositionReference: label.frame,
                    forOffset: 2.5,
                    forRowHeight: DropDownUIView.rowHeightForGeneralUILabel
                )
                
                switch type {
                case .parentDog: dropDownParentDog = targetDropDown
                case .logActionType: dropDownLogAction = targetDropDown
                case .logUnit: dropDownLogUnit = targetDropDown
                case .logStartDate: dropDownLogStartDate = targetDropDown
                case .logEndDate: dropDownLogEndDate = targetDropDown
                }
                
                // Insert dropdown in correct z-order
                let ordered: [DropDownUIView?] = [
                    dropDownParentDog,
                    dropDownLogAction,
                    dropDownLogStartDate,
                    dropDownLogEndDate,
                    dropDownLogUnit
                ]
                if let superview = label.superview,
                   let index = ordered.firstIndex(of: targetDropDown) {
                    var inserted = false
                    for i in (0..<index).reversed() {
                        if let higher = ordered[i] {
                            superview.insertSubview(targetDropDown, belowSubview: higher)
                            inserted = true
                            break
                        }
                    }
                    if !inserted {
                        superview.addSubview(targetDropDown)
                    }
                }
            }
        }
        
        // Dynamically show the dropdown
        targetDropDown?.showDropDown(
            numberOfRowsToShow: min(6.5, {
                switch type {
                case .parentDog:
                    return CGFloat(dogManager?.dogs.count ?? 0)
                case .logActionType:
                    return CGFloat(GlobalTypes.shared.logActionTypes.count)
                    + CGFloat(LocalConfiguration.localPreviousLogCustomActionNames.count)
                case .logUnit:
                    guard let selected = logActionSelected else { return 0.0 }
                    return CGFloat(selected.associatedLogUnitTypes.count)
                case .logStartDate:
                    return CGFloat(dropDownLogStartDateOptions.count)
                case .logEndDate:
                    return CGFloat(dropDownLogEndDateOptions.count)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? DropDownTVC else { return }
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue {
            guard let dm = dogManager else { return }
            let dog = dm.dogs[indexPath.row]
            customCell.setCustomSelectedTableViewCell(
                forSelected: forDogUUIDsSelected.contains(dog.dogUUID)
            )
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logActionType.rawValue {
            // Predefined LogActionTypes
            if indexPath.row < GlobalTypes.shared.logActionTypes.count {
                customCell.label.text = GlobalTypes.shared.logActionTypes[indexPath.row]
                    .convertToReadableName(customActionName: nil)
                if let selected = logActionSelected,
                   GlobalTypes.shared.logActionTypes.firstIndex(of: selected) == indexPath.row {
                    customCell.setCustomSelectedTableViewCell(forSelected: true)
                }
                else {
                    customCell.setCustomSelectedTableViewCell(forSelected: false)
                }
            }
            // User-generated custom names
            else {
                let prev = LocalConfiguration.localPreviousLogCustomActionNames[
                    indexPath.row - GlobalTypes.shared.logActionTypes.count
                ]
                customCell.label.text = LogActionType.find(
                    forLogActionTypeId: prev.logActionTypeId
                ).convertToReadableName(customActionName: prev.logCustomActionName)
                customCell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue {
            guard let selectedAction = logActionSelected else { return }
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            let unitTypes = selectedAction.associatedLogUnitTypes
            if indexPath.row < unitTypes.count {
                let unit = unitTypes[indexPath.row]
                customCell.label.text = unit.convertDoubleToPluralityString(
                    forLogNumberOfLogUnits: LogUnitType.convertStringToDouble(
                        forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
                    ) ?? 0.0
                )
                if let selectedUnit = logUnitTypeSelected, selectedUnit == unit {
                    customCell.setCustomSelectedTableViewCell(forSelected: true)
                }
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            if let option = dropDownLogStartDateOptions.safeIndex(indexPath.row) {
                customCell.label.text = option.rawValue
                // Do not set “selected” visually, as quick select depends on current time
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            if let option = dropDownLogEndDateOptions.safeIndex(indexPath.row) {
                customCell.label.text = option.rawValue
                // Do not set “selected” visually, as quick select depends on current time
            }
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        switch dropDownUIViewIdentifier {
        case LogsAddLogDropDownTypes.parentDog.rawValue:
            return dogManager?.dogs.count ?? 0
        case LogsAddLogDropDownTypes.logActionType.rawValue:
            return GlobalTypes.shared.logActionTypes.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        case LogsAddLogDropDownTypes.logUnit.rawValue:
            guard let selected = logActionSelected else { return 0 }
            return selected.associatedLogUnitTypes.count
        case LogsAddLogDropDownTypes.logStartDate.rawValue:
            return dropDownLogStartDateOptions.count
        case LogsAddLogDropDownTypes.logEndDate.rawValue:
            return dropDownLogEndDateOptions.count
        default:
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.parentDog.rawValue,
           let cell = dropDownParentDog?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC,
           let dm = dogManager {
            
            let dog = dm.dogs[indexPath.row]
            let beforeCount = forDogUUIDsSelected.count
            
            if cell.isCustomSelected {
                // Unselect parent dog
                forDogUUIDsSelected.removeAll { $0 == dog.dogUUID }
            }
            else {
                // Select parent dog
                forDogUUIDsSelected.append(dog.dogUUID)
            }
            cell.setCustomSelectedTableViewCell(forSelected: !cell.isCustomSelected)
            
            if beforeCount == 0 {
                // After first selection, hide parent dropdown and open log action dropdown
                dropDownParentDog?.hideDropDown(animated: true)
                showDropDown(.logActionType, animated: true)
            }
            else if forDogUUIDsSelected.count == dm.dogs.count {
                // If all dogs selected, close dropdown
                dropDownParentDog?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logActionType.rawValue,
                let cell = dropDownLogAction?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            
            let beforeSelection = logActionSelected
            
            if cell.isCustomSelected {
                // Unselect current log action
                cell.setCustomSelectedTableViewCell(forSelected: false)
                logActionSelected = nil
                // Do not hide dropdown, need selection for valid log
                return
            }
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            if indexPath.row < GlobalTypes.shared.logActionTypes.count {
                logActionSelected = GlobalTypes.shared.logActionTypes[indexPath.row]
                if logActionSelected?.allowsCustom == true {
                    // If custom log action is allowed, begin editing textField
                    logCustomActionNameTextField.becomeFirstResponder()
                }
            }
            else {
                let prev = LocalConfiguration.localPreviousLogCustomActionNames[
                    indexPath.row - GlobalTypes.shared.logActionTypes.count
                ]
                logActionSelected = LogActionType.find(forLogActionTypeId: prev.logActionTypeId)
                logCustomActionNameTextField.text = prev.logCustomActionName
            }
            
            dropDownLogAction?.hideDropDown(animated: true)
            
            if beforeSelection == nil && !logCustomActionNameTextField.isFirstResponder {
                // First-time selection of log action, so open next dropdown
                if !isShowingLogStartDatePicker {
                    showDropDown(.logStartDate, animated: true)
                }
                else {
                    showDropDown(.logEndDate, animated: true)
                }
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue,
                let cell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC,
                let selectedAction = logActionSelected {
            
            if cell.isCustomSelected {
                cell.setCustomSelectedTableViewCell(forSelected: false)
                logUnitTypeSelected = nil
            }
            else {
                let unitTypes = selectedAction.associatedLogUnitTypes
                cell.setCustomSelectedTableViewCell(forSelected: true)
                logUnitTypeSelected = unitTypes[indexPath.row]
            }
            
            dropDownLogUnit?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue,
                let cell = dropDownLogStartDate?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            
            // Time quick select cells should never stay visually selected.
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = dropDownLogStartDateOptions[indexPath.row].valueInSeconds()
            if let interval = timeIntervalSelected {
                // Apply the quick select option
                logStartDateSelected = Date().addingTimeInterval(interval)
            }
            else {
                isShowingLogStartDatePicker = true
            }
            
            dropDownLogStartDate?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue,
                let cell = dropDownLogEndDate?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = dropDownLogEndDateOptions[indexPath.row].valueInSeconds()
            if let interval = timeIntervalSelected {
                logEndDateSelected = Date().addingTimeInterval(interval)
            }
            else {
                isShowingLogEndDatePicker = true
            }
            
            dropDownLogEndDate?.hideDropDown(animated: true)
        }
    }
    
    // MARK: - Add / Update Log Tasks
    
    private func willAddLog(logActionSelected: LogActionType, logStartDateSelected: Date) {
        saveLogButton.beginSpinning()
        
        // Only retrieve matchingReminders if switch is on.
        let matchingReminders: [(UUID, Reminder)] = {
            return dogManager?.matchingReminders(
                forDogUUIDs: forDogUUIDsSelected,
                forLogActionType: logActionSelected,
                forLogCustomActionName: logCustomActionNameTextField.text
            ) ?? []
        }()
        
        let completionTracker = CompletionTracker(
            numberOfTasks: forDogUUIDsSelected.count + matchingReminders.count
        ) {
            // Each time a task completes, update the dog manager so everything else updates
            if let dm = self.dogManager {
                self.delegate.didUpdateDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: dm
                )
            }
        } completedAllTasksCompletionHandler: {
            // When everything completes, close the page
            self.saveLogButton.endSpinning()
            self.dismiss(animated: true) {
                // Request reviews or surveys after dismissal
                ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        } failedTaskCompletionHandler: {
            // If a problem is encountered, stop the indicator
            self.saveLogButton.endSpinning()
        }
        
        matchingReminders.forEach { dogUUID, matchingReminder in
            matchingReminder.enableIsSkipping(forSkippedDate: logStartDateSelected)
            
            RemindersRequest.update(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: dogUUID,
                forReminders: [matchingReminder]
            ) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }
                completionTracker.completedTask()
            }
        }
        
        for dogUUIDSelected in forDogUUIDsSelected {
            // Each dog needs its own newLog object with its own unique UUID
            let logToAdd = Log(
                forLogActionTypeId: logActionSelected.logActionTypeId,
                forLogCustomActionName: logCustomActionNameTextField.text,
                forLogStartDate: logStartDateSelected,
                forLogEndDate: logEndDateSelected,
                forLogNote: logNoteTextView.text,
                forLogUnitTypeId: logUnitTypeSelected?.logUnitTypeId,
                forLogNumberOfUnits: LogUnitType.convertStringToDouble(
                    forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
                )
            )
            
            LogsRequest.create(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: dogUUIDSelected,
                forLog: logToAdd
            ) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    completionTracker.failedTask()
                    return
                }
                
                // Request was successful, so add the new custom action name locally
                LocalConfiguration.addLogCustomAction(
                    forLogActionType: logToAdd.logActionType,
                    forLogCustomActionName: logToAdd.logCustomActionName
                )
                
                self.dogManager?.findDog(forDogUUID: dogUUIDSelected)?
                    .dogLogs.addLog(forLog: logToAdd)
                
                completionTracker.completedTask()
            }
        }
    }
    
    private func willUpdateLog(
        dogUUIDToUpdate: UUID,
        logToUpdate: Log,
        logActionSelected: LogActionType,
        logStartDateSelected: Date
    ) {
        logToUpdate.changeLogDate(
            forLogStartDate: logStartDateSelected,
            forLogEndDate: logEndDateSelected
        )
        logToUpdate.logActionTypeId = logActionSelected.logActionTypeId
        logToUpdate.logCustomActionName = logActionSelected.allowsCustom
        ? (logCustomActionNameTextField.text ?? "")
        : ""
        logToUpdate.changeLogUnit(
            forLogUnitTypeId: logUnitTypeSelected?.logUnitTypeId,
            forLogNumberOfLogUnits: LogUnitType.convertStringToDouble(
                forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
            )
        )
        logToUpdate.logNote = logNoteTextView.text ?? ""
        
        saveLogButton.beginSpinning()
        
        LogsRequest.update(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: dogUUIDToUpdate,
            forLog: logToUpdate
        ) { responseStatus, _ in
            self.saveLogButton.endSpinning()
            guard responseStatus != .failureResponse else {
                return
            }
            
            // Request was successful, so store the custom action name locally
            LocalConfiguration.addLogCustomAction(
                forLogActionType: logToUpdate.logActionType,
                forLogCustomActionName: logToUpdate.logCustomActionName
            )
            
            self.dogManager?.findDog(forDogUUID: dogUUIDToUpdate)?
                .dogLogs.addLog(forLog: logToUpdate)
            
            if let dm = self.dogManager {
                self.delegate.didUpdateDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: dm
                )
            }
            
            self.dismiss(animated: true) {
                // Request reviews or surveys after dismissal
                ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(contentScrollView)
        view.addSubview(saveLogButton)
        view.addSubview(backButton)
        
        contentScrollView.addSubview(containerView)
        containerView.addSubview(pageTitleLabel)
        containerView.addSubview(parentDogLabel)
        containerView.addSubview(familyMemberNameLabel)
        containerView.addSubview(logActionLabel)
        containerView.addSubview(logCustomActionNameTextField)
        containerView.addSubview(logStartDateLabel)
        containerView.addSubview(logStartDatePicker)
        containerView.addSubview(removeLogButton)
        containerView.addSubview(logEndDateLabel)
        containerView.addSubview(logEndDatePicker)
        containerView.addSubview(logUnitLabel)
        containerView.addSubview(logNoteTextView)
        containerView.addSubview(bottomSpacerView)
        containerView.addSubview(logNumberOfLogUnitsTextField)
        containerView.addSubview(containerViewExtraPadding)
        
        saveLogButton.addTarget(self, action: #selector(didTouchUpInsideSaveLog), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTouchUpInsideBack), for: .touchUpInside)
        removeLogButton.addTarget(self, action: #selector(didTouchUpInsideRemoveLog), for: .touchUpInside)
        logStartDatePicker.addTarget(self, action: #selector(didUpdateLogStartDate), for: .valueChanged)
        logEndDatePicker.addTarget(self, action: #selector(didUpdateLogEndDate), for: .valueChanged)
        logNumberOfLogUnitsTextField.addTarget(self, action: #selector(didUpdateLogNumberOfLogUnits), for: .editingChanged)
    }
    
    override func setupConstraints() {
        
        parentDogHeightConstraint = parentDogLabel.heightAnchor.constraint(equalToConstant: 45)
        parentDogBottomConstraint = parentDogLabel.bottomAnchor.constraint(equalTo: familyMemberNameLabel.topAnchor, constant: -10)
        
        familyMemberNameHeightConstraint = familyMemberNameLabel.heightAnchor.constraint(equalToConstant: 45)
        familyMemberNameBottomConstraint = familyMemberNameLabel.bottomAnchor.constraint(equalTo: logActionLabel.topAnchor, constant: -10)
        
        logCustomActionNameHeightConstraint = logCustomActionNameTextField.heightAnchor.constraint(equalToConstant: 45)
        logCustomActionNameBottomConstraint = logCustomActionNameTextField.bottomAnchor.constraint(equalTo: logStartDateLabel.topAnchor, constant: -10)
        
        logStartDateHeightConstraint = logStartDateLabel.heightAnchor.constraint(equalToConstant: 45)
       
        logEndDateHeightConstraint = logEndDateLabel.heightAnchor.constraint(equalToConstant: 45)
        
        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            pageTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            pageTitleLabel.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            removeLogButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            removeLogButton.leadingAnchor.constraint(equalTo: pageTitleLabel.trailingAnchor, constant: 10),
            removeLogButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor),
            removeLogButton.widthAnchor.constraint(equalTo: removeLogButton.heightAnchor),
            
            parentDogLabel.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 15),
            parentDogLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            parentDogLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            parentDogHeightConstraint,
            parentDogBottomConstraint,
            
            familyMemberNameLabel.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            familyMemberNameLabel.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            familyMemberNameHeightConstraint,
            familyMemberNameBottomConstraint,
            
            logActionLabel.topAnchor.constraint(equalTo: familyMemberNameLabel.bottomAnchor, constant: 10),
            logActionLabel.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logActionLabel.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            logActionLabel.heightAnchor.constraint(equalToConstant: 45),
            
            logCustomActionNameTextField.topAnchor.constraint(equalTo: logActionLabel.bottomAnchor, constant: 10),
            logCustomActionNameTextField.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logCustomActionNameTextField.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            logCustomActionNameHeightConstraint,
            logCustomActionNameBottomConstraint,
            
            logStartDateLabel.topAnchor.constraint(equalTo: logCustomActionNameTextField.bottomAnchor, constant: 10),
            logStartDateLabel.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logStartDateLabel.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
        
            logStartDatePicker.topAnchor.constraint(equalTo: logStartDateLabel.topAnchor),
            logStartDatePicker.leadingAnchor.constraint(equalTo: logStartDateLabel.leadingAnchor),
            logStartDatePicker.trailingAnchor.constraint(equalTo: logStartDateLabel.trailingAnchor),
            logStartDateHeightConstraint,
            logStartDateLabel.bottomAnchor.constraint(equalTo: logEndDateLabel.topAnchor, constant: -10),
            
            logEndDateLabel.topAnchor.constraint(equalTo: logStartDateLabel.bottomAnchor, constant: 10),
            logEndDateLabel.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logEndDateLabel.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            logEndDateLabel.bottomAnchor.constraint(equalTo: logUnitLabel.topAnchor, constant: -10),
            logEndDateHeightConstraint,
            
            logEndDatePicker.topAnchor.constraint(equalTo: logEndDateLabel.topAnchor),
            logEndDatePicker.leadingAnchor.constraint(equalTo: logEndDateLabel.leadingAnchor),
            logEndDatePicker.trailingAnchor.constraint(equalTo: logEndDateLabel.trailingAnchor)
        ])
        
        // MARK: LogUnitLabel and Number TextField
        let unitHeight = logUnitLabel.heightAnchor.constraint(equalToConstant: 45)
        let unitBottom = logUnitLabel.bottomAnchor.constraint(equalTo: logNoteTextView.topAnchor, constant: -10)
        unitHeight.isActive = true
        unitBottom.isActive = true
        
        logUnitHeightConstraint = unitHeight
        logUnitBottomConstraint = unitBottom
        
        NSLayoutConstraint.activate([
            logUnitLabel.topAnchor.constraint(equalTo: logEndDateLabel.bottomAnchor, constant: 10),
            logUnitLabel.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            
            logNumberOfLogUnitsTextField.centerYAnchor.constraint(equalTo: logUnitLabel.centerYAnchor),
            logNumberOfLogUnitsTextField.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logNumberOfLogUnitsTextField.widthAnchor.constraint(equalToConstant: 80),
            logNumberOfLogUnitsTextField.heightAnchor.constraint(equalTo: logUnitLabel.heightAnchor)
        ])
        
        // MARK: LogNoteTextView
        NSLayoutConstraint.activate([
            logNoteTextView.topAnchor.constraint(equalTo: logUnitLabel.bottomAnchor, constant: 10),
            logNoteTextView.leadingAnchor.constraint(equalTo: parentDogLabel.leadingAnchor),
            logNoteTextView.trailingAnchor.constraint(equalTo: parentDogLabel.trailingAnchor),
            logNoteTextView.heightAnchor.constraint(equalToConstant: 135)
        ])
        
        // MARK: bottomSpacerView (placeholder view)
        NSLayoutConstraint.activate([
            bottomSpacerView.topAnchor.constraint(equalTo: logNoteTextView.bottomAnchor, constant: 25),
            bottomSpacerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomSpacerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomSpacerView.heightAnchor.constraint(equalToConstant: 50),
            bottomSpacerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // MARK: contentScrollView and Container
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: saveLogButton.topAnchor, constant: -10),
            
            containerView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        // MARK: saveLogButton
        NSLayoutConstraint.activate([
            saveLogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveLogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            saveLogButton.widthAnchor.constraint(equalTo: saveLogButton.heightAnchor),
            saveLogButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100.0 / 414.0),
            saveLogButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // MARK: backButton
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100.0 / 414.0),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // MARK: containerView padding height (dynamic based on safe area)
        let padding = containerView.heightAnchor.constraint(equalToConstant: 0)
        padding.isActive = true
        containerViewPaddingHeightConstraint = padding
    }
}
