//
//  LogsAddLogVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsAddLogVC: HoundScrollViewController,
                          LogsAddLogUIInteractionActionsDelegate,
                          HoundDropDownDataSource {
    
    // TODO BUG this ui is borked
    
    // MARK: - LogsAddLogUIInteractionActionsDelegate
    
    func logCustomActionNameTextFieldDidReturn() {
        showNextRequiredDropDown(animated: true)
    }
    
    @objc func didUpdateLogNumberOfLogUnits() {
        // When the user enters a number into log units, it could update the plurality of the logUnitLabel
        // (e.g. no number but "pills" then the user enters 1 so "pills" should become "pill").
        // So by setting logUnitTypeSelected it updates logUnitLabel.
        updateDynamicUIElements()
    }
    
    // MARK: - Elements
    
    /// We use this padding so that the content inside the scroll view is ≥ the size of the safe area.
    /// If it is not, then the drop down menus will clip outside the content area, displaying on the lower half
    /// of the region but being un-interactable because they are outside the containerView.
    private weak var containerViewExtraPaddingHeight: NSLayoutConstraint!
    private let containerViewExtraPadding: HoundView = {
        let view = HoundView()
        view.isHidden = true
        return view
    }()
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 300, compressionResistancePriority: 300)
        
        view.trailingButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        view.trailingButton.isHidden = false
        
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveLog), for: .touchUpInside)
        
        return view
    }()
    
    private var parentDogHeightMultiplier: GeneralLayoutConstraint!
    private var parentDogMaxHeight: GeneralLayoutConstraint!
    private var parentDogBottom: GeneralLayoutConstraint!
    private lazy var parentDogLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.applyStyle(.thinGrayBorder)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = LogsAddLogDropDownTypes.parentDog.rawValue
        gesture.delegate = uiDelegate
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private var familyMemberNameHeightMultiplier: GeneralLayoutConstraint!
    private var familyMemberNameMaxHeight: GeneralLayoutConstraint!
    private var familyMemberNameBottom: GeneralLayoutConstraint!
    private let familyMemberNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 285, compressionResistancePriority: 285)
        label.applyStyle(.thinGrayBorder)
        return label
    }()
    
    private lazy var logActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.applyStyle(.thinGrayBorder)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = LogsAddLogDropDownTypes.logActionType.rawValue
        gesture.delegate = uiDelegate
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private var logCustomActionNameHeightMultiplier: GeneralLayoutConstraint!
    private var logCustomActionNameMaxHeight: GeneralLayoutConstraint!
    private var logCustomActionNameBottom: GeneralLayoutConstraint!
    /// Text input for logCustomActionNameName
    private let logCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 275, compressionResistencePriority: 775)
        
        textField.applyStyle(.thinGrayBorder)
        
        return textField
    }()
    
    private lazy var logNumberOfLogUnitsTextField: HoundTextField = {
        let textField = HoundTextField()
        
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        
        textField.applyStyle(.thinGrayBorder)
        
        textField.addTarget(self, action: #selector(didUpdateLogNumberOfLogUnits), for: .editingChanged)
        
        return textField
    }()
    
    private var logUnitHeightMultiplier: GeneralLayoutConstraint!
    private var logUnitMaxHeight: GeneralLayoutConstraint!
    private var logUnitBottom: GeneralLayoutConstraint!
    private lazy var logUnitLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 245, compressionResistancePriority: 245)
        label.applyStyle(.thinGrayBorder)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = LogsAddLogDropDownTypes.logUnit.rawValue
        gesture.delegate = uiDelegate
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private let logNoteTextView: HoundTextView = {
        let textView = HoundTextView(huggingPriority: 240, compressionResistancePriority: 240)
        textView.textColor = .label
        textView.applyStyle(.thinGrayBorder)
        return textView
    }()
    
    private lazy var logStartDateLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.applyStyle(.thinGrayBorder)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = LogsAddLogDropDownTypes.logStartDate.rawValue
        gesture.delegate = uiDelegate
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private var logStartDateHeightMultiplier: GeneralLayoutConstraint!
    private var logStartDateMaxHeight: GeneralLayoutConstraint!
    private lazy var logStartDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 265, compressionResistancePriority: 265)
        datePicker.isHidden = true
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.addTarget(self, action: #selector(didUpdateLogStartDate), for: .valueChanged)
        
        return datePicker
    }()
    
    @objc private func didUpdateLogStartDate(_ sender: Any) {
        // By updating logStartDateSelected, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogEndDate?.hideDropDown(animated: true)
        self.logStartDateSelected = logStartDatePicker.date
        self.dismissKeyboard()
    }
    
    private lazy var logEndDateLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.applyStyle(.thinGrayBorder)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = LogsAddLogDropDownTypes.logEndDate.rawValue
        gesture.delegate = uiDelegate
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private var logEndDateHeightMultiplier: GeneralLayoutConstraint!
    private var logEndDateMaxHeight: GeneralLayoutConstraint!
    private lazy var logEndDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 255, compressionResistancePriority: 255)
        datePicker.isHidden = true
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.addTarget(self, action: #selector(didUpdateLogEndDate), for: .valueChanged)
        
        return datePicker
    }()
    
    @objc private func didUpdateLogEndDate(_ sender: Any) {
        // By updating logEndDateSelected, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogStartDate?.hideDropDown(animated: true)
        self.logEndDateSelected = logEndDatePicker.date
        self.dismissKeyboard()
    }
    
    private lazy var backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideBack), for: .touchUpInside)
        
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
    
    private lazy var saveLogButton: HoundButton = {
        let button = HoundButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideSaveLog), for: .touchUpInside)
        
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
                    self.delegate?.didUpdateDogManager(
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
    
    // MARK: - Properties
    
    private weak var delegate: LogsAddLogDelegate?
    
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
    
    private var dropDownParentDog: HoundDropDown?
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
    
    private var dropDownLogAction: HoundDropDown?
    /// The selected log action type
    private var logActionSelected: LogActionType? {
        didSet {
            updateDynamicUIElements()
            
            // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logActionType dropdown,
            // so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName",
            // the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            logActionLabel.text = logActionSelected?.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            
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
    
    private var dropDownLogUnit: HoundDropDown?
    /// The selected log unit type
    private var logUnitTypeSelected: LogUnitType? {
        didSet {
            updateDynamicUIElements()
        }
    }
    
    // MARK: Log Start Date
    
    private var dropDownLogStartDate: HoundDropDown?
    private var dropDownLogStartDateOptions: [TimeAgoQuickSelect] {
        // If logEndDateSelected is nil, all options are valid
        guard let endDate = logEndDateSelected else {
            return TimeAgoQuickSelect.allCases
        }
        return TimeAgoQuickSelect.optionsOccurringBeforeDate(
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
    
    private var dropDownLogEndDate: HoundDropDown?
    private var dropDownLogEndDateOptions: [TimeInQuickSelect] {
        // If logStartDateSelected is nil, all options are valid
        guard let start = logStartDateSelected else {
            return TimeInQuickSelect.allCases
        }
        return TimeInQuickSelect.optionsOccurringAfterDate(
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
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
            editPageHeaderView.setTitle("Edit Log")
            if let dog = dogManager.findDog(forDogUUID: dogUUIDToUpdate) {
                forDogUUIDsSelected = [dog.dogUUID]
                initialForDogUUIDsSelected = forDogUUIDsSelected
            }
            
            parentDogLabel.isEnabled = false
        }
        else {
            editPageHeaderView.setTitle("Create Log")
            
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
        logCustomActionNameTextField.placeholder = "Add a custom name..."
        logCustomActionNameTextField.delegate = uiDelegate
        
        // Log Unit
        let convertedLogUnits: (LogUnitType, Double)? = {
            guard let unitType = logToUpdate?.logUnitType,
                  let numberOfUnits = logToUpdate?.logNumberOfLogUnits else {
                return nil
            }
            return LogUnitTypeConverter.convert(forLogUnitType: unitType, forNumberOfLogUnits: numberOfUnits,
                                                toTargetSystem: UserConfiguration.measurementSystem
            )
        }()
        
        logUnitTypeSelected = convertedLogUnits?.0
        initialLogUnitType = logUnitTypeSelected
        logUnitLabel.placeholder = "Add a unit..."
        
        // Log Number of Log Units
        logNumberOfLogUnitsTextField.text = LogUnitType.readableRoundedNumUnits(
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
        
        parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count != 1
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        updateDynamicUIElements()
        
        showNextRequiredDropDown(animated: false)
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: LogsAddLogDelegate,
               forDogManager: DogManager,
               forDogUUIDToUpdate: UUID?,
               forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogUUIDToUpdate = forDogUUIDToUpdate
        logToUpdate = forLogToUpdate
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        // We don't want this page to get too cluttered. Therefore, if editing a log (so family member name will be shown),
        // hide parent dog. Parent dog is uneditable as well, so no functionality is lost.
        let parentDogIsHidden = dogUUIDToUpdate != nil && logToUpdate != nil
        parentDogLabel.isHidden = parentDogIsHidden
        if parentDogIsHidden {
            parentDogHeightMultiplier.setMultiplier(0.0)
            parentDogMaxHeight.constant = 0.0
            parentDogBottom.constant = 0.0
        }
        else {
            parentDogHeightMultiplier.restore()
            parentDogMaxHeight.restore()
            parentDogBottom.restore()
        }
        
        // The family member to a log is not editable by a user. Its set internally by the server.
        // Therefore, if creating a log, don't show it as it will automatically be the user. If editing a log, show it
        // so a user can know who created this log.
        let familyMemberNameIsHidden = dogUUIDToUpdate == nil || logToUpdate == nil
        familyMemberNameLabel.isHidden = familyMemberNameIsHidden
        if familyMemberNameIsHidden {
            familyMemberNameHeightMultiplier.setMultiplier(0.0)
            familyMemberNameMaxHeight.constant = 0.0
            familyMemberNameBottom.constant = 0.0
        }
        else {
            familyMemberNameHeightMultiplier.restore()
            familyMemberNameMaxHeight.restore()
            familyMemberNameBottom.restore()
        }
        
        let logCustomActionNameIsHidden = logActionSelected?.allowsCustom != true
        logCustomActionNameTextField.isHidden = logCustomActionNameIsHidden
        if logCustomActionNameIsHidden {
            logCustomActionNameHeightMultiplier.setMultiplier(0.0)
            logCustomActionNameMaxHeight.constant = 0.0
            logCustomActionNameBottom.constant = 0.0
        }
        else {
            logCustomActionNameHeightMultiplier.restore()
            logCustomActionNameMaxHeight.restore()
            logCustomActionNameBottom.restore()
        }
        
        logStartDateLabel.isHidden = isShowingLogStartDatePicker
        logStartDatePicker.isHidden = !isShowingLogStartDatePicker
        if !isShowingLogStartDatePicker {
            logStartDateHeightMultiplier.restore()
            logStartDateMaxHeight.restore()
        }
        else {
            if let origMulti = logStartDateHeightMultiplier.originalMultiplier {
                logStartDateHeightMultiplier.setMultiplier(origMulti * 4.0)
            }
            logStartDateMaxHeight.constant = logStartDateMaxHeight.originalConstant * 4.0
        }
        
        logEndDateLabel.isHidden = isShowingLogEndDatePicker
        logEndDatePicker.isHidden = !isShowingLogEndDatePicker
        if !isShowingLogEndDatePicker {
            logEndDateHeightMultiplier.restore()
            logEndDateMaxHeight.restore()
        }
        else {
            if let origMulti = logEndDateHeightMultiplier.originalMultiplier {
                logEndDateHeightMultiplier.setMultiplier(origMulti * 4.0)
            }
            logEndDateMaxHeight.constant = logEndDateMaxHeight.originalConstant * 4.0
        }
        
        let logUnitIsHidden: Bool = {
            guard let selected = logActionSelected else {
                return true
            }
            // If logAction has associated unit types, show logUnit
            return selected.associatedLogUnitTypes.isEmpty
        }()
        
        logUnitLabel.text = logUnitTypeSelected?.pluralReadableValueNoNumUnits(
            forLogNumberOfLogUnits: LogUnitType.convertStringToDouble(
                forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
            )
        )
        logUnitLabel.isHidden = logUnitIsHidden
        logNumberOfLogUnitsTextField.isHidden = logUnitIsHidden
        logNumberOfLogUnitsTextField.isEnabled = logUnitTypeSelected != nil
        if logUnitIsHidden {
            logUnitHeightMultiplier.setMultiplier(0.0)
            logUnitMaxHeight.constant = 0.0
            logUnitBottom.constant = 0.0
        }
        else {
            logUnitHeightMultiplier.restore()
            logUnitMaxHeight.restore()
            logUnitBottom.restore()
        }
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideUIElement) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            // Adjust containerView padding so content fills safe area
            let containerHeightWithoutPadding = self.containerView.frame.height - self.containerViewExtraPaddingHeight.constant
            let shortfall = self.view.safeAreaLayoutGuide.layoutFrame.height - containerHeightWithoutPadding
            self.containerViewExtraPaddingHeight.constant = max(shortfall, 0.0)
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
    private func dropDown(forDropDownType type: LogsAddLogDropDownTypes) -> HoundDropDown? {
        switch type {
        case .parentDog: return dropDownParentDog
        case .logActionType: return dropDownLogAction
        case .logUnit: return dropDownLogUnit
        case .logStartDate: return dropDownLogStartDate
        case .logEndDate: return dropDownLogEndDate
        }
    }
    
    /// For a given dropDownType, return the label that triggers it
    private func labelForDropDown(forDropDownType type: LogsAddLogDropDownTypes) -> HoundLabel {
        switch type {
        case .parentDog: return parentDogLabel
        case .logActionType: return logActionLabel
        case .logUnit: return logUnitLabel
        case .logStartDate: return logStartDateLabel
        case .logEndDate: return logEndDateLabel
        }
    }
    
    /// Determine and show the next required dropdown in the log creation flow
    private func showNextRequiredDropDown(animated: Bool) {
        if forDogUUIDsSelected.isEmpty {
            showDropDown(.parentDog, animated: animated)
        }
        else if logActionSelected == nil {
            showDropDown(.logActionType, animated: animated)
        }
        else if logStartDateSelected == nil && !isShowingLogStartDatePicker {
            showDropDown(.logStartDate, animated: animated)
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
            targetDropDown = HoundDropDown()
            if let targetDropDown = targetDropDown {
                targetDropDown.setupDropDown(
                    forHoundDropDownIdentifier: type.rawValue,
                    forDataSource: self,
                    forViewPositionReference: label.frame,
                    forOffset: 2.5,
                    forRowHeight: HoundDropDown.rowHeightForHoundLabel
                )
                
                switch type {
                case .parentDog: dropDownParentDog = targetDropDown
                case .logActionType: dropDownLogAction = targetDropDown
                case .logUnit: dropDownLogUnit = targetDropDown
                case .logStartDate: dropDownLogStartDate = targetDropDown
                case .logEndDate: dropDownLogEndDate = targetDropDown
                }
                
                // Insert dropdown in correct z-order
                let ordered: [HoundDropDown?] = [
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
        guard let customCell = cell as? HoundDropDownTableViewCell else { return }
        customCell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
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
                    .convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
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
                customCell.label.text = unit.pluralReadableValueNoNumUnits(
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
            if let option = dropDownLogStartDateOptions[safe: indexPath.row] {
                customCell.label.text = option.rawValue
                // Do not set “selected” visually, as quick select depends on current time
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            if let option = dropDownLogEndDateOptions[safe: indexPath.row] {
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
           let cell = dropDownParentDog?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell,
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
                showNextRequiredDropDown(animated: true)
            }
            else if forDogUUIDsSelected.count == dm.dogs.count {
                // If all dogs selected, close dropdown
                dropDownParentDog?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logActionType.rawValue,
                let cell = dropDownLogAction?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
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
                showNextRequiredDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue,
                let cell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell,
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
                let cell = dropDownLogStartDate?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
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
                let cell = dropDownLogEndDate?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = dropDownLogEndDateOptions[indexPath.row].valueInSeconds()
            if let interval = timeIntervalSelected {
                let referenceDate = logStartDateSelected ?? Date()
                logEndDateSelected = referenceDate.addingTimeInterval(interval)
            }
            else {
                isShowingLogEndDatePicker = true
            }
            
            dropDownLogEndDate?.hideDropDown(animated: true)
        }
    }
    
    // MARK: - Add / Update Log Tasks
    
    private func willAddLog(logActionSelected: LogActionType, logStartDateSelected: Date) {
        saveLogButton.isLoading = true
        
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
                self.delegate?.didUpdateDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: dm
                )
            }
        } completedAllTasksCompletionHandler: {
            // When everything completes, close the page
            self.saveLogButton.isLoading = false
            self.dismiss(animated: true) {
                // Request reviews or surveys after dismissal
                ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        } failedTaskCompletionHandler: {
            // If a problem is encountered, stop the indicator
            self.saveLogButton.isLoading = false
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
        
        saveLogButton.isLoading = true
        
        LogsRequest.update(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: dogUUIDToUpdate,
            forLog: logToUpdate
        ) { responseStatus, _ in
            self.saveLogButton.isLoading = false
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
                self.delegate?.didUpdateDogManager(
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
        super.addSubViews()
        view.addSubview(saveLogButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(parentDogLabel)
        containerView.addSubview(familyMemberNameLabel)
        containerView.addSubview(logActionLabel)
        containerView.addSubview(logCustomActionNameTextField)
        containerView.addSubview(logStartDateLabel)
        containerView.addSubview(logStartDatePicker)
        containerView.addSubview(logEndDateLabel)
        containerView.addSubview(logEndDatePicker)
        containerView.addSubview(logUnitLabel)
        containerView.addSubview(logNoteTextView)
        containerView.addSubview(logNumberOfLogUnitsTextField)
        containerView.addSubview(containerViewExtraPadding)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // editPageHeaderView
        NSLayoutConstraint.activate([
            editPageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editPageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editPageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // parentDogLabel
        parentDogBottom = GeneralLayoutConstraint(familyMemberNameLabel.topAnchor.constraint(equalTo: parentDogLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        parentDogHeightMultiplier = GeneralLayoutConstraint(parentDogLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        parentDogMaxHeight = GeneralLayoutConstraint(parentDogLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            parentDogLabel.topAnchor.constraint(equalTo: editPageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            parentDogBottom.constraint,
            parentDogLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            parentDogLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            parentDogHeightMultiplier.constraint,
            parentDogMaxHeight.constraint
        ])
        
        // familyMemberNameLabel
        familyMemberNameBottom = GeneralLayoutConstraint(logActionLabel.topAnchor.constraint(equalTo: familyMemberNameLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        familyMemberNameHeightMultiplier = GeneralLayoutConstraint(familyMemberNameLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        familyMemberNameMaxHeight = GeneralLayoutConstraint(familyMemberNameLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            familyMemberNameBottom.constraint,
            familyMemberNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            familyMemberNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            familyMemberNameHeightMultiplier.constraint,
            familyMemberNameMaxHeight.constraint
        ])
        
        // logActionLabel
        NSLayoutConstraint.activate([
            logActionLabel.bottomAnchor.constraint(equalTo: logCustomActionNameTextField.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert),
            logActionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            logActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        // logCustomActionNameTextField
        logCustomActionNameBottom = GeneralLayoutConstraint(logStartDateLabel.topAnchor.constraint(equalTo: logCustomActionNameTextField.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        logCustomActionNameHeightMultiplier = GeneralLayoutConstraint(logCustomActionNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        logCustomActionNameMaxHeight = GeneralLayoutConstraint(logCustomActionNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            logCustomActionNameBottom.constraint,
            logCustomActionNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logCustomActionNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logCustomActionNameHeightMultiplier.constraint,
            logCustomActionNameMaxHeight.constraint
        ])
        
        // logStartDateLabel & logStartDatePicker
        logStartDateHeightMultiplier = GeneralLayoutConstraint(logStartDateLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        logStartDateMaxHeight = GeneralLayoutConstraint(logStartDateLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            logStartDateLabel.bottomAnchor.constraint(equalTo: logEndDateLabel.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert),
            logStartDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logStartDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logStartDateHeightMultiplier.constraint,
            logStartDateMaxHeight.constraint,
            
            logStartDatePicker.topAnchor.constraint(equalTo: logStartDateLabel.topAnchor),
            logStartDatePicker.leadingAnchor.constraint(equalTo: logStartDateLabel.leadingAnchor),
            logStartDatePicker.trailingAnchor.constraint(equalTo: logStartDateLabel.trailingAnchor),
            logStartDatePicker.bottomAnchor.constraint(equalTo: logStartDateLabel.bottomAnchor)
        ])
        
        // logEndDateLabel & logEndDatePicker
        logEndDateHeightMultiplier = GeneralLayoutConstraint(logEndDateLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        logEndDateMaxHeight = GeneralLayoutConstraint(logEndDateLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            logEndDateLabel.bottomAnchor.constraint(equalTo: logUnitLabel.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert),
            logEndDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logEndDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logEndDateHeightMultiplier.constraint,
            logEndDateMaxHeight.constraint,
            
            logEndDatePicker.topAnchor.constraint(equalTo: logEndDateLabel.topAnchor),
            logEndDatePicker.leadingAnchor.constraint(equalTo: logEndDateLabel.leadingAnchor),
            logEndDatePicker.trailingAnchor.constraint(equalTo: logEndDateLabel.trailingAnchor),
            logEndDatePicker.bottomAnchor.constraint(equalTo: logEndDateLabel.bottomAnchor)
        ])
        
        // logUnitLabel && logNumberOfLogUnitsTextField
        logUnitBottom = GeneralLayoutConstraint(logUnitLabel.bottomAnchor.constraint(equalTo: logNoteTextView.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert))
        logUnitHeightMultiplier = GeneralLayoutConstraint(logUnitLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: view))
        logUnitMaxHeight = GeneralLayoutConstraint(logUnitLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            logNumberOfLogUnitsTextField.centerYAnchor.constraint(equalTo: logUnitLabel.centerYAnchor),
            logNumberOfLogUnitsTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logNumberOfLogUnitsTextField.trailingAnchor.constraint(equalTo: logUnitLabel.leadingAnchor, constant: -ConstraintConstant.Spacing.contentIntraHori),
            logNumberOfLogUnitsTextField.widthAnchor.constraint(equalTo: logUnitLabel.widthAnchor, multiplier: 1.0 / 3.0),
            logNumberOfLogUnitsTextField.heightAnchor.constraint(equalTo: logUnitLabel.heightAnchor),
            
            logUnitBottom.constraint,
            logUnitLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logUnitHeightMultiplier.constraint,
            logUnitMaxHeight.constraint
        ])
        
        // logNoteTextView
        NSLayoutConstraint.activate([
            logNoteTextView.bottomAnchor.constraint(equalTo: containerViewExtraPadding.topAnchor),
            logNoteTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logNoteTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logNoteTextView.createHeightMultiplier(ConstraintConstant.Input.textViewHeightMultiplier, relativeToWidthOf: view),
            logNoteTextView.createMaxHeight(ConstraintConstant.Input.textViewMaxHeight)
        ])
        
        // containerViewExtraPadding
        containerViewExtraPaddingHeight = containerViewExtraPadding.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            containerViewExtraPaddingHeight,
            containerViewExtraPadding.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerViewExtraPadding.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerViewExtraPadding.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // saveLogButton
        NSLayoutConstraint.activate([
            saveLogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleInset),
            saveLogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleInset),
            saveLogButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            saveLogButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight),
            saveLogButton.createSquareAspectRatio()
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteCircleInset),
            backButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
        
    }
    
}
