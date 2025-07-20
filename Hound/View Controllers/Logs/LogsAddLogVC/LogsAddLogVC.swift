//
//  LogsAddLogVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

protocol LogsAddLogDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsAddLogVC: HoundScrollViewController,
                          LogsAddLogUIInteractionActionsDelegate,
                          HoundDropDownDataSource {
    
    // TODO BUG this ui is borked
    // TODO add headers to each field (similar to DogsAddTriggerVC). Header should contain the majority of the info (e.g. "What dog(s) did you take care of?") then the input field placeholder has simplier info (e.g. "Select dog(s)..."). If a field is optional, you can add that (e.g. "Add an end date... (optional))
    // TODO change error messages to use .errorMessage property on labels instead of showing a banner
    
    // MARK: - LogsAddLogUIInteractionActionsDelegate
    
    func logCustomActionNameTextFieldDidReturn() {
        showNextRequiredDropDown(animated: true)
    }
    
    @objc func didUpdateLogNumberOfLogUnits() {
        // When the user enters a number into log units, it could update the plurality of the logUnitLabel
        // (e.g. no number but "pills" then the user enters 1 so "pills" should become "pill").
        // So by setting selectedLogUnitType it updates logUnitLabel.
        updateDynamicUIElements()
    }
    
    // MARK: - Elements
    
    // MARK: editPageHeaderView
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 300, compressionResistancePriority: 300)
        
        view.trailingButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        view.trailingButton.isHidden = false
        
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveLog), for: .touchUpInside)
        
        return view
    }()
    
    // MARK: familyMemberLabel
    private lazy var familyMemberHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "Log created by"
        return label
    }()
    private let familyMemberLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 285, compressionResistancePriority: 285)
        label.applyStyle(.thinGrayBorder)
        // only for showing family member, not actually editable
        label.isEnabled = false
        return label
    }()
    private lazy var familyMemberStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(familyMemberHeaderLabel)
        stack.addArrangedSubview(familyMemberLabel)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: parentDogLabel
    private lazy var parentDogHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        // label.text set in setup
        return label
    }()
    private lazy var parentDogLabel: HoundLabel = {
        let label = HoundLabel()
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
    private lazy var parentDogStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(parentDogHeaderLabel)
        stack.addArrangedSubview(parentDogLabel)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logActionLabel
    private lazy var logActionHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "What action did you do?"
        return label
    }()
    private lazy var logActionLabel: HoundLabel = {
        let label = HoundLabel()
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
    private lazy var logActionStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logActionHeaderLabel)
        stack.addArrangedSubview(logActionLabel)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logCustomActionNameTextField
    private lazy var logCustomActionNameHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "What was this action called?"
        return label
    }()
    private lazy var logCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField()
        textField.delegate = uiDelegate
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = " Add a custom name... (optional)"
        return textField
    }()
    private lazy var logCustomActionNameStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logActionHeaderLabel)
        stack.addArrangedSubview(logActionLabel)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logStartDate
    private lazy var logStartDateHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "When did this happen?"
        return label
    }()
    private lazy var logStartDateLabel: HoundLabel = {
        let label = HoundLabel()
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Add a start date..."
        
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
    private lazy var logStartDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.addTarget(self, action: #selector(didUpdateLogStartDate), for: .valueChanged)
        
        return datePicker
    }()
    private lazy var nestedLogStartDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logStartDateLabel)
        stack.addArrangedSubview(logStartDatePicker)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    private lazy var logStartDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logStartDateHeaderLabel)
        stack.addArrangedSubview(nestedLogStartDateStack)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logEndDate
    private lazy var logEndDateHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "When did this end?"
        return label
    }()
    private lazy var logEndDateLabel: HoundLabel = {
        let label = HoundLabel()
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Add an end date... (optional)"
        
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
    private lazy var logEndDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.addTarget(self, action: #selector(didUpdateLogEndDate), for: .valueChanged)
        
        return datePicker
    }()
    private lazy var nestedLogEndDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logEndDateLabel)
        stack.addArrangedSubview(logEndDatePicker)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    private lazy var logEndDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logEndDateHeaderLabel)
        stack.addArrangedSubview(nestedLogEndDateStack)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logUnit
    private lazy var logUnitHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "How many units was this?"
        return label
    }()
    private lazy var logNumberOfLogUnitsTextField: HoundTextField = {
        let textField = HoundTextField()
        textField.delegate = uiDelegate
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = " 0" + (Locale.current.decimalSeparator ?? ".") + "0"
        
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        
        textField.addTarget(self, action: #selector(didUpdateLogNumberOfLogUnits), for: .editingChanged)
        
        return textField
    }()
    private lazy var logUnitLabel: HoundLabel = {
        let label = HoundLabel()
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Add a unit... (optional)"
        
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
    private lazy var nestedLogUnitStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logNumberOfLogUnitsTextField)
        stack.addArrangedSubview(logUnitLabel)
        stack.axis = .horizontal
        stack.spacing = ConstraintConstant.Spacing.contentIntraHori
        return stack
    }()
    private lazy var logUnitStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logUnitHeaderLabel)
        stack.addArrangedSubview(nestedLogUnitStack)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    // MARK: logNote
    private lazy var logNoteHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        label.textColor = .label
        label.text = "Anything extra?"
        return label
    }()
    private lazy var logNoteTextView: HoundTextView = {
        let textView = HoundTextView()
        textView.delegate = uiDelegate
        textView.textColor = UIColor.label
        textView.applyStyle(.thinGrayBorder)
        textView.placeholder = "Add some notes... (optional)"
        return textView
    }()
    private lazy var logNoteStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logNoteHeaderLabel)
        stack.addArrangedSubview(logNoteStack)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentTightIntraVert
        return stack
    }()
    
    private lazy var stackView: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(familyMemberStack)
        stack.addArrangedSubview(parentDogStack)
        stack.addArrangedSubview(logActionStack)
        stack.addArrangedSubview(logCustomActionNameStack)
        stack.addArrangedSubview(logStartDateStack)
        stack.addArrangedSubview(logEndDateStack)
        stack.addArrangedSubview(logUnitStack)
        stack.addArrangedSubview(logNoteStack)
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
        return stack
    }()
    
    private lazy var backButton: HoundButton = {
        let button = HoundButton()
        
        button.tintColor = UIColor.systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideBack), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var saveLogButton: HoundButton = {
        let button = HoundButton()
        
        button.tintColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideSaveLog), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didUpdateLogStartDate(_ sender: Any) {
        // By updating selectedLogStartDate, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogEndDate?.hideDropDown(animated: true)
        self.selectedLogStartDate = logStartDatePicker.date
        self.dismissKeyboard()
    }
    
    @objc private func didUpdateLogEndDate(_ sender: Any) {
        // By updating selectedLogEndDate, it can invalidate the quick time select options in the open drop down.
        // If a user then selects an invalid option, it will lead to incorrect data or crashing.
        self.dropDownLogStartDate?.hideDropDown(animated: true)
        self.selectedLogEndDate = logEndDatePicker.date
        self.dismissKeyboard()
    }
    
    @objc private func didTouchUpInsideBack(_ sender: Any) {
        guard didUpdateInitialValues else {
            self.dismiss(animated: true) {
                // Wait for the view to be dismissed, then see if we should request any sort of review from the user
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
            return
        }
        
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
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        unsavedInformationConfirmation.addAction(exitAlertAction)
        unsavedInformationConfirmation.addAction(cancelAlertAction)
        
        PresentationManager.enqueueAlert(unsavedInformationConfirmation)
    }
    
    @objc private func didTouchUpInsideSaveLog(_ sender: Any) {
        // TODO ERRORs add error messages
        guard selectedDogUUIDs.count >= 1 else {
            ErrorConstant.LogError.parentDogMissing().alert()
            return
        }
        guard let selectedLogAction = selectedLogAction else {
            ErrorConstant.LogError.logActionMissing().alert()
            return
        }
        guard let selectedLogStartDate = selectedLogStartDate else {
            ErrorConstant.LogError.logStartDateMissing().alert()
            return
        }
        
        // Check to see if we are updating or adding a log
        guard let dogUUIDToUpdate = dogUUIDToUpdate, let logToUpdate = logToUpdate else {
            willAddLog(selectedLogAction: selectedLogAction, selectedLogStartDate: selectedLogStartDate)
            return
        }
        
        willUpdateLog(dogUUIDToUpdate: dogUUIDToUpdate,
                      logToUpdate: logToUpdate,
                      selectedLogAction: selectedLogAction,
                      selectedLogStartDate: selectedLogStartDate)
    }
    
    @objc private func didTouchUpInsideRemoveLog(_ sender: Any) {
        guard let dogUUIDToUpdate = dogUUIDToUpdate else { return }
        guard let logToUpdate = logToUpdate else { return }
        
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
                
                self.dogManager.findDog(forDogUUID: dogUUIDToUpdate)?
                    .dogLogs.removeLog(forLogUUID: logToUpdate.logUUID)
                
                self.delegate?.didUpdateDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: self.dogManager
                )
                
                self.dismiss(animated: true) {
                    // Wait for the view to be dismissed, then see if we should request any sort of review from the user
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
    
    private var dogManager: DogManager = DogManager()
    private var dogUUIDToUpdate: UUID?
    private var logToUpdate: Log?
    
    // MARK: Initial Value Tracking
    
    private var initialSelectedDogUUIDs: [UUID] = []
    private var initialLogActionType: LogActionType?
    private var initialLogCustomActionName: String?
    private var initialLogUnitType: LogUnitType?
    private var initialLogNumberOfLogUnits: String?
    private var initialLogNote: String?
    private var initialLogStartDate: Date?
    private var initialLogEndDate: Date?
    
    private var didUpdateInitialValues: Bool {
        if initialLogActionType != selectedLogAction { return true }
        if selectedLogAction?.allowsCustom == true && initialLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        if initialLogUnitType != selectedLogUnitType { return true }
        if initialLogNumberOfLogUnits != logNumberOfLogUnitsTextField.text { return true }
        if initialLogNote != logNoteTextView.text { return true }
        if initialLogStartDate != selectedLogStartDate { return true }
        if initialLogEndDate != selectedLogEndDate { return true }
        if initialSelectedDogUUIDs != selectedDogUUIDs { return true }
        return false
    }
    
    private var dropDownParentDog: HoundDropDown?
    private var selectedDogUUIDs: [UUID] = [] {
        didSet {
            parentDogLabel.text = {
                guard !selectedDogUUIDs.isEmpty else {
                    // If no parent dog selected, leave text blank so placeholder displays
                    return nil
                }
                
                // If only one dog selected, show that dog's name
                if selectedDogUUIDs.count == 1,
                   let lastRemainingDogUUID = self.selectedDogUUIDs.first,
                   let lastRemainingDog = dogManager.dogs.first(where: { $0.dogUUID == lastRemainingDogUUID }) {
                    return lastRemainingDog.dogName
                }
                // If multiple but not all dogs selected, show "Multiple"
                else if selectedDogUUIDs.count > 1 && selectedDogUUIDs.count < dogManager.dogs.count {
                    return "Multiple"
                }
                // If all dogs selected, show "All"
                else if selectedDogUUIDs.count == dogManager.dogs.count {
                    return "All"
                }
                
                return nil
            }()
        }
    }
    
    private var dropDownLogAction: HoundDropDown?
    /// Options for the log action drop down consisting of base types and their previous custom names
    private var availableLogActions: [(LogActionType, String?)] = []
    /// The selected log action type
    private var selectedLogAction: LogActionType? {
        didSet {
            updateDynamicUIElements()
            
            // READ ME BEFORE CHANGING CODE BELOW: this is for the label for the logActionType dropdown,
            // so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName",
            // the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            logActionLabel.text = selectedLogAction?.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            
            // If log action changed to something where the current logUnit is no longer valid, clear selectedLogUnitType
            if let selected = selectedLogAction {
                let validUnits = selected.associatedLogUnitTypes
                if let currentUnit = selectedLogUnitType, !validUnits.contains(currentUnit) {
                    selectedLogUnitType = nil
                }
            }
            else {
                selectedLogUnitType = nil
            }
        }
    }
    
    private var dropDownLogUnit: HoundDropDown?
    private var selectedLogUnitType: LogUnitType?
    
    private var dropDownLogStartDate: HoundDropDown?
    private var availableLogStartDateOptions: [TimeAgoQuickSelect] = []
    private var selectedLogStartDate: Date? {
        didSet {
            guard let start = selectedLogStartDate else {
                logStartDateLabel.text = nil
                return
            }
            
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
    }
    private var isShowingLogStartDatePicker = false {
        didSet {
            if isShowingLogStartDatePicker {
                // If showing the logStartDatePicker, dropDownLogEndDate might be out of place; remove and rebuild
                dropDownLogEndDate?.removeFromSuperview()
                dropDownLogEndDate = nil
                
                logStartDatePicker.maximumDate = selectedLogEndDate
                logStartDatePicker.date = selectedLogStartDate
                ?? Date.roundDate(
                    targetDate: Date(),
                    roundingInterval: Double(60 * logStartDatePicker.minuteInterval),
                    roundingMethod: .toNearestOrAwayFromZero
                )
                selectedLogStartDate = logStartDatePicker.date
            }
            logStartDatePicker.isHidden = !isShowingLogStartDatePicker
            logStartDateLabel.isHidden = isShowingLogStartDatePicker
            
            updateDynamicUIElements()
        }
    }
    
    private var dropDownLogEndDate: HoundDropDown?
    private var availableLogEndDateOptions: [TimeInQuickSelect] = []
    private var selectedLogEndDate: Date? {
        didSet {
            guard let end = selectedLogEndDate else {
                logEndDateLabel.text = nil
                return
            }
            
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
    }
    private var isShowingLogEndDatePicker = false {
        didSet {
            if isShowingLogEndDatePicker {
                // If showing the logEndDatePicker, dropDownLogStartDate might be out of place; remove and rebuild
                dropDownLogStartDate?.removeFromSuperview()
                dropDownLogStartDate = nil
                
                logEndDatePicker.minimumDate = selectedLogStartDate
                logEndDatePicker.date = selectedLogEndDate
                ?? Date.roundDate(
                    targetDate: Date(),
                    roundingInterval: Double(60 * logEndDatePicker.minuteInterval),
                    roundingMethod: .toNearestOrAwayFromZero
                )
                selectedLogEndDate = logEndDatePicker.date
            }
            logEndDatePicker.isHidden = !isShowingLogEndDatePicker
            logEndDateLabel.isHidden = isShowingLogEndDatePicker
            
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
        self.enableSwipeBackToDismiss = true
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // Get the minimum top edge of both buttons (handles if either is higher)
//        let saveButtonTop = saveLogButton.convert(saveLogButton.bounds, to: view).minY
//        let backButtonTop = backButton.convert(backButton.bounds, to: view).minY
//        let buttonTop = min(saveButtonTop, backButtonTop)
//        
//        // Find distance from bottom of view to top edge of highest button
//        let distanceFromBottom = view.bounds.height - buttonTop
//
//        // Optionally add a little padding (e.g., 16 for comfort)
//        let minInset = distanceFromBottom + 16
//
//        // Only increase the inset if needed (so you don't shrink it below other requirements)
//        scrollView.contentInset.bottom = max(scrollView.contentInset.bottom, minInset)
//    }
    
    // MARK: - Setup
    
    func setup(forDelegate: LogsAddLogDelegate,
               forDogManager: DogManager,
               forDogUUIDToUpdate: UUID?,
               forLogToUpdate: Log?) {
        delegate = forDelegate
        dogManager = forDogManager
        dogUUIDToUpdate = forDogUUIDToUpdate
        logToUpdate = forLogToUpdate
        
        if let dogUUIDToUpdate = dogUUIDToUpdate, logToUpdate != nil {
            editPageHeaderView.setTitle("Edit Log")
            if let dog = dogManager.findDog(forDogUUID: dogUUIDToUpdate) {
                selectedDogUUIDs = [dog.dogUUID]
                initialSelectedDogUUIDs = selectedDogUUIDs
            }
            else {
                selectedDogUUIDs = []
                initialSelectedDogUUIDs = selectedDogUUIDs
            }
            
            // parent dog is set once log is created
            parentDogLabel.isEnabled = false
        }
        else {
            editPageHeaderView.setTitle("Create Log")
            
            // If the family only has one dog, then force the parent dog selected to be that single dog.
            // Otherwise, leave list empty so user must select.
            if dogManager.dogs.count == 1, let uuid = dogManager.dogs.first?.dogUUID {
                selectedDogUUIDs = [uuid]
                initialSelectedDogUUIDs = selectedDogUUIDs
            }
            else {
                selectedDogUUIDs = []
                initialSelectedDogUUIDs = selectedDogUUIDs
            }
            
            parentDogLabel.isEnabled = dogManager.dogs.count != 1
        }
        
        parentDogHeaderLabel.text = logToUpdate != nil ? "Dog taken care of"
        : dogManager.dogs.count <= 1
        ? "What dog did you take care of?"
        : "What dog(s) did you take care of?"
        
        familyMemberLabel.text = FamilyInformation.findFamilyMember(forUserId: logToUpdate?.userId)?.displayFullName
        
        selectedLogAction = logToUpdate?.logActionType
        initialLogActionType = logToUpdate?.logActionType
        availableLogActions = {
            var options: [(LogActionType, String?)] = []
            for type in GlobalTypes.shared.logActionTypes {
                options.append((type, nil))
                let matching = LocalConfiguration.localPreviousLogCustomActionNames.filter { $0.logActionTypeId == type.logActionTypeId }
                for prev in matching {
                    options.append((type, prev.logCustomActionName))
                }
            }
            return options
        }()
        
        logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
        initialLogCustomActionName = logToUpdate?.logCustomActionName
        
        let convertedLogUnits: (LogUnitType, Double)? = {
            guard let unitType = logToUpdate?.logUnitType,
                  let numberOfUnits = logToUpdate?.logNumberOfLogUnits else {
                return nil
            }
            return LogUnitTypeConverter.convert(forLogUnitType: unitType, forNumberOfLogUnits: numberOfUnits,
                                                toTargetSystem: UserConfiguration.measurementSystem
            )
        }()
        
        selectedLogUnitType = convertedLogUnits?.0
        initialLogUnitType = convertedLogUnits?.0
        
        logNumberOfLogUnitsTextField.text = LogUnitType.readableRoundedNumUnits(forLogNumberOfLogUnits: convertedLogUnits?.1)
        initialLogNumberOfLogUnits = LogUnitType.readableRoundedNumUnits(forLogNumberOfLogUnits: convertedLogUnits?.1)
        
        selectedLogStartDate = logToUpdate?.logStartDate
        initialLogStartDate = logToUpdate?.logStartDate
        availableLogStartDateOptions = {
            // If selectedLogEndDate is nil, all options are valid
            guard let endDate = selectedLogEndDate else {
                return TimeAgoQuickSelect.allCases
            }
            return TimeAgoQuickSelect.optionsOccurringBeforeDate(
                startingPoint: Date(),
                occurringOnOrBefore: endDate
            )
        }()
        
        selectedLogEndDate = logToUpdate?.logEndDate
        initialLogEndDate = selectedLogEndDate
        availableLogEndDateOptions = {
            // If selectedLogStartDate is nil, all options are valid
            guard let start = logToUpdate?.logStartDate else {
                return TimeInQuickSelect.allCases
            }
            return TimeInQuickSelect.optionsOccurringAfterDate(
                startingPoint: Date(),
                occurringOnOrAfter: start
            )
        }()
        
        logNoteTextView.text = logToUpdate?.logNote
        initialLogNote = logNoteTextView.text
        
        showNextRequiredDropDown(animated: false)
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        remakeFamilyMemberConstraints()
        remakeStartDateConstraints()
        remakeCustomActionNameConstraints()
        remakeStartDateConstraints()
        remakeEndDateConstraints()
        remakeLogUnitConstraints()
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideSingleElement) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
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
        if selectedDogUUIDs.isEmpty {
            showDropDown(.parentDog, animated: animated)
        }
        else if selectedLogAction == nil {
            showDropDown(.logActionType, animated: animated)
        }
        else if selectedLogStartDate == nil && !isShowingLogStartDatePicker {
            showDropDown(.logStartDate, animated: animated)
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: LogsAddLogDropDownTypes, animated: Bool) {
        // If showing start date and only "custom" and "now" are valid, show picker
        if type == .logStartDate && availableLogStartDateOptions.count <= 1 {
            isShowingLogStartDatePicker = true
            return
        }
        // If showing end date and only "custom" is valid, show picker
        if type == .logEndDate && availableLogEndDateOptions.count <= 1 {
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
                    return CGFloat(dogManager.dogs.count)
                case .logActionType:
                    return CGFloat(availableLogActions.count)
                case .logUnit:
                    guard let selected = selectedLogAction else { return 0.0 }
                    return CGFloat(selected.associatedLogUnitTypes.count)
                case .logStartDate:
                    return CGFloat(availableLogStartDateOptions.count)
                case .logEndDate:
                    return CGFloat(availableLogEndDateOptions.count)
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
            let dog = dogManager.dogs[indexPath.row]
            customCell.setCustomSelectedTableViewCell(
                forSelected: selectedDogUUIDs.contains(dog.dogUUID)
            )
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logActionType.rawValue {
            let option = availableLogActions[indexPath.row]
            customCell.label.text = option.0.convertToReadableName(
                customActionName: option.1,
                includeMatchingEmoji: true
            )
            if option.1 == nil,
               let selected = selectedLogAction,
               selected.logActionTypeId == option.0.logActionTypeId {
                customCell.setCustomSelectedTableViewCell(forSelected: true)
            }
            else {
                customCell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue {
            guard let selectedAction = selectedLogAction else { return }
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            let unitTypes = selectedAction.associatedLogUnitTypes
            if indexPath.row < unitTypes.count {
                let unit = unitTypes[indexPath.row]
                customCell.label.text = unit.pluralReadableValueNoNumUnits(
                    forLogNumberOfLogUnits: LogUnitType.convertStringToDouble(
                        forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
                    ) ?? 0.0
                )
                if let selectedUnit = selectedLogUnitType, selectedUnit == unit {
                    customCell.setCustomSelectedTableViewCell(forSelected: true)
                }
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            if let option = availableLogStartDateOptions[safe: indexPath.row] {
                customCell.label.text = option.rawValue
                // Do not set “selected” visually, as quick select depends on current time
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            if let option = availableLogEndDateOptions[safe: indexPath.row] {
                customCell.label.text = option.rawValue
                // Do not set “selected” visually, as quick select depends on current time
            }
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        switch dropDownUIViewIdentifier {
        case LogsAddLogDropDownTypes.parentDog.rawValue:
            return dogManager.dogs.count
        case LogsAddLogDropDownTypes.logActionType.rawValue:
            return availableLogActions.count
        case LogsAddLogDropDownTypes.logUnit.rawValue:
            guard let selected = selectedLogAction else { return 0 }
            return selected.associatedLogUnitTypes.count
        case LogsAddLogDropDownTypes.logStartDate.rawValue:
            return availableLogStartDateOptions.count
        case LogsAddLogDropDownTypes.logEndDate.rawValue:
            return availableLogEndDateOptions.count
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
           let cell = dropDownParentDog?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
            let dog = dogManager.dogs[indexPath.row]
            let beforeCount = selectedDogUUIDs.count
            
            if cell.isCustomSelected {
                // Unselect parent dog
                selectedDogUUIDs.removeAll { $0 == dog.dogUUID }
            }
            else {
                // Select parent dog
                selectedDogUUIDs.append(dog.dogUUID)
            }
            cell.setCustomSelectedTableViewCell(forSelected: !cell.isCustomSelected)
            
            if beforeCount == 0 {
                // After first selection, hide parent dropdown and open log action dropdown
                dropDownParentDog?.hideDropDown(animated: true)
                showNextRequiredDropDown(animated: true)
            }
            else if selectedDogUUIDs.count == dogManager.dogs.count {
                // If all dogs selected, close dropdown
                dropDownParentDog?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logActionType.rawValue,
                let cell = dropDownLogAction?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
            let beforeSelection = selectedLogAction
            
            if cell.isCustomSelected {
                // Unselect current log action
                cell.setCustomSelectedTableViewCell(forSelected: false)
                selectedLogAction = nil
                // Do not hide dropdown, need selection for valid log
                return
            }
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let option = availableLogActions[indexPath.row]
            selectedLogAction = option.0
            if let custom = option.1 {
                logCustomActionNameTextField.text = custom
            }
            else if selectedLogAction?.allowsCustom == true {
                // If custom log action is allowed, begin editing textField
                logCustomActionNameTextField.becomeFirstResponder()
            }
            
            dropDownLogAction?.hideDropDown(animated: true)
            
            if beforeSelection == nil && !logCustomActionNameTextField.isFirstResponder {
                // First-time selection of log action, so open next dropdown
                showNextRequiredDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logUnit.rawValue,
                let cell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell,
                let selectedAction = selectedLogAction {
            
            if cell.isCustomSelected {
                cell.setCustomSelectedTableViewCell(forSelected: false)
                selectedLogUnitType = nil
            }
            else {
                let unitTypes = selectedAction.associatedLogUnitTypes
                cell.setCustomSelectedTableViewCell(forSelected: true)
                selectedLogUnitType = unitTypes[indexPath.row]
            }
            
            dropDownLogUnit?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logStartDate.rawValue,
                let cell = dropDownLogStartDate?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
            // Time quick select cells should never stay visually selected.
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = availableLogStartDateOptions[indexPath.row].valueInSeconds()
            if let interval = timeIntervalSelected {
                // Apply the quick select option
                selectedLogStartDate = Date().addingTimeInterval(interval)
            }
            else {
                isShowingLogStartDatePicker = true
            }
            
            dropDownLogStartDate?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsAddLogDropDownTypes.logEndDate.rawValue,
                let cell = dropDownLogEndDate?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = availableLogEndDateOptions[indexPath.row].valueInSeconds()
            if let interval = timeIntervalSelected {
                let referenceDate = selectedLogStartDate ?? Date()
                selectedLogEndDate = referenceDate.addingTimeInterval(interval)
            }
            else {
                isShowingLogEndDatePicker = true
            }
            
            dropDownLogEndDate?.hideDropDown(animated: true)
        }
    }
    
    // MARK: - Add / Update Log Tasks
    
    private func willAddLog(selectedLogAction: LogActionType, selectedLogStartDate: Date) {
        saveLogButton.isLoading = true
        
        // Only retrieve matchingReminders if switch is on.
        let matchingReminders: [(UUID, Reminder)] = dogManager.matchingReminders(
            forDogUUIDs: selectedDogUUIDs,
            forLogActionType: selectedLogAction,
            forLogCustomActionName: logCustomActionNameTextField.text
        )
        
        let completionTracker = CompletionTracker(
            numberOfTasks: selectedDogUUIDs.count + matchingReminders.count
        ) {
            // Each time a task completes, update the dog manager so everything else updates
            self.delegate?.didUpdateDogManager(
                sender: Sender(origin: self, localized: self),
                forDogManager: self.dogManager
            )
        } completedAllTasksCompletionHandler: {
            // When everything completes, close the page
            self.saveLogButton.isLoading = false
            self.dismiss(animated: true) {
                // Request reviews or surveys after dismissal
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        } failedTaskCompletionHandler: {
            // If a problem is encountered, stop the indicator
            self.saveLogButton.isLoading = false
        }
        
        matchingReminders.forEach { dogUUID, matchingReminder in
            matchingReminder.enableIsSkipping(forSkippedDate: selectedLogStartDate)
            
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
        
        for selectedDogUUID in selectedDogUUIDs {
            // Each dog needs its own newLog object with its own unique UUID
            let logToAdd = Log(
                forLogActionTypeId: selectedLogAction.logActionTypeId,
                forLogCustomActionName: logCustomActionNameTextField.text,
                forLogStartDate: selectedLogStartDate,
                forLogEndDate: selectedLogEndDate,
                forLogNote: logNoteTextView.text,
                forLogUnitTypeId: selectedLogUnitType?.logUnitTypeId,
                forLogNumberOfUnits: LogUnitType.convertStringToDouble(
                    forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text
                )
            )
            
            LogsRequest.create(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: selectedDogUUID,
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
                
                self.dogManager.findDog(forDogUUID: selectedDogUUID)?
                    .dogLogs.addLog(forLog: logToAdd, invokeDogTriggers: true)
                
                completionTracker.completedTask()
            }
        }
    }
    
    private func willUpdateLog(
        dogUUIDToUpdate: UUID,
        logToUpdate: Log,
        selectedLogAction: LogActionType,
        selectedLogStartDate: Date
    ) {
        logToUpdate.changeLogDate(
            forLogStartDate: selectedLogStartDate,
            forLogEndDate: selectedLogEndDate
        )
        logToUpdate.logActionTypeId = selectedLogAction.logActionTypeId
        logToUpdate.logCustomActionName = selectedLogAction.allowsCustom
        ? (logCustomActionNameTextField.text ?? "")
        : ""
        logToUpdate.changeLogUnit(
            forLogUnitTypeId: selectedLogUnitType?.logUnitTypeId,
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
            
            self.dogManager.findDog(forDogUUID: dogUUIDToUpdate)?
                .dogLogs.addLog(forLog: logToUpdate, invokeDogTriggers: false)
            self.delegate?.didUpdateDogManager(
                sender: Sender(origin: self, localized: self),
                forDogManager: self.dogManager
            )
            
            self.dismiss(animated: true) {
                // Request reviews or surveys after dismissal
                ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
            }
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveLogButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(stackView)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    private func remakeFamilyMemberConstraints() {
        familyMemberLabel.snp.remakeConstraints { make in
            if !familyMemberLabel.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }
    }
    private func remakeCustomActionNameConstraints() {
        logCustomActionNameTextField.snp.makeConstraints { make in
            if !logCustomActionNameTextField.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }
    }
    private func remakeStartDateConstraints() {
        logStartDateLabel.snp.remakeConstraints { make in
            if !logStartDateLabel.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }
        logStartDatePicker.snp.remakeConstraints { make in
            if !logStartDatePicker.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.datePickerHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.datePickerMaxHeight)
            }
        }
    }
    private func remakeEndDateConstraints() {
        logEndDateLabel.snp.remakeConstraints { make in
            if !logEndDateLabel.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }

        logEndDatePicker.snp.remakeConstraints { make in
            if !logStartDatePicker.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.datePickerHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.datePickerMaxHeight)
            }
        }
    }
    private func remakeLogUnitConstraints() {
        logNumberOfLogUnitsTextField.snp.makeConstraints { make in
            make.width.equalTo(logUnitLabel.snp.width).multipliedBy(1.0 / 3.0)
            if !logNumberOfLogUnitsTextField.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }
        logUnitLabel.snp.makeConstraints { make in
            if !logUnitLabel.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        editPageHeaderView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(editPageHeaderView.snp.bottom).offset(ConstraintConstant.Spacing.contentTallIntraVert)
            make.bottom.equalTo(containerView.snp.bottom)
            make.leading.equalTo(containerView.snp.leading).offset(ConstraintConstant.Spacing.absoluteHoriInset)
            make.trailing.equalTo(containerView.snp.trailing).inset(ConstraintConstant.Spacing.absoluteHoriInset)
        }
        
        parentDogLabel.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
        }
        
        remakeFamilyMemberConstraints()
        
        logActionLabel.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textFieldMaxHeight)
        }
        
        remakeCustomActionNameConstraints()
    
        remakeStartDateConstraints()
        
        remakeEndDateConstraints()
        
        remakeLogUnitConstraints()
        
        logNoteTextView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textViewHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Input.textViewMaxHeight)
        }
        
        saveLogButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(ConstraintConstant.Spacing.absoluteVertInset)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(ConstraintConstant.Spacing.absoluteCircleHoriInset)
            make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Button.circleHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Button.circleMaxHeight)
            make.width.equalTo(saveLogButton.snp.height)
        }

        backButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(ConstraintConstant.Spacing.absoluteVertInset)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(ConstraintConstant.Spacing.absoluteCircleHoriInset)
            make.height.equalTo(view.snp.width).multipliedBy(ConstraintConstant.Button.circleHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(view.snp.width).multipliedBy(ConstraintConstant.Button.circleMaxHeight)
            make.width.equalTo(backButton.snp.height)
        }
        
    }
    
}
