//
//  DogsAddReminderManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsAddReminderManagerView: HoundView, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsAddReminderCountdownViewDelegate, DogsAddReminderWeeklyViewDelegate, HoundDropDownDataSource, DogsAddReminderMonthlyViewDelegate, DogsAddReminderOneTimeViewDelegate {
    
    // MARK: - DogsAddReminderCountdownVCDelegate and DogsAddReminderWeeklyViewDelegate
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // attempt to read the range they are trying to change
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under reminderCustomActionNameCharacterLimit
        return updatedText.count <= ClassConstant.ReminderConstant.reminderCustomActionNameCharacterLimit
    }
    
    // MARK: - Elements
    
    private let onceView = DogsAddReminderOneTimeView()
    private let countdownView = DogsAddReminderCountdownView()
    private let weeklyView = DogsAddReminderWeeklyView()
    private let monthlyView = DogsAddReminderMonthlyView()
    
    private lazy var reminderViewsStack: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [onceView, countdownView, weeklyView, monthlyView])
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
        return stack
    }()
    
    private lazy var reminderActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select an action..."
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private var reminderCustomActionNameTop: GeneralLayoutConstraint!
    private var reminderCustomActionNameHeightMultiplier: GeneralLayoutConstraint!
    private var reminderCustomActionNameMaxHeight: GeneralLayoutConstraint!
    private lazy var reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 280, compressionResistencePriority: 280)
        textField.delegate = self
        
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = " Add a custom name..."
        
        return textField
    }()
    
    private let reminderIsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 310, compressionResistancePriority: 310)
        uiSwitch.isOn = ClassConstant.ReminderConstant.defaultReminderIsEnabled
        return uiSwitch
    }()
    
    private lazy var reminderTypeSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        ReminderType.allCases.enumerated().forEach { index, option in
            segmentedControl.insertSegment(withTitle: option.readableName, at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.addTarget(self, action: #selector(didUpdateReminderType), for: .valueChanged)
        
        return segmentedControl
    }()
    
    @objc private func didUpdateReminderType(_ sender: UISegmentedControl) {
        onceView.isHidden = !(sender.selectedSegmentIndex == ReminderType.oneTime.segmentedControlIndex)
        countdownView.isHidden = !(sender.selectedSegmentIndex == ReminderType.countdown.segmentedControlIndex)
        weeklyView.isHidden = !(sender.selectedSegmentIndex == ReminderType.weekly.segmentedControlIndex)
        monthlyView.isHidden = !(sender.selectedSegmentIndex == ReminderType.monthly.segmentedControlIndex)
    }
    
    // MARK: - Properties
    
    private var dogsReminderOneTimeView: DogsAddReminderOneTimeView?
    private var dogsAddReminderCountdownView: DogsAddReminderCountdownView?
    private var dogsAddReminderWeeklyView: DogsAddReminderWeeklyView?
    private var dogsAddReminderMonthlyView: DogsAddReminderMonthlyView?
    
    private var reminderToUpdate: Reminder?
    private var initialReminderActionType: ReminderActionType!
    private var initialReminderCustomActionName: String?
    private var initialReminderIsEnabled: Bool!
    private var initialReminderTypeSegmentedControlIndex: Int!
    
    /// Given the reminderToUpdate provided, construct a new reminder or updates the one provided with the settings selected inside this view and its subviews. If there are invalid settings (e.g. no weekdays), an error message is sent to the user and nil is returned. If the reminder is valid, a reminder is returned that is ready to be sent to the server.
    var currentReminder: Reminder? {
        do {
            guard let reminderActionTypeSelected = reminderActionTypeSelected else {
                throw ErrorConstant.ReminderError.reminderActionMissing()
            }
            
            guard let reminder: Reminder = reminderToUpdate != nil ? reminderToUpdate?.copy() as? Reminder : Reminder() else {
                return nil
            }
            
            reminder.reminderActionTypeId = reminderActionTypeSelected.reminderActionTypeId
            
            if reminderActionTypeSelected.allowsCustom {
                // if the trimmedReminderCustomActionName is not "", meaning it has text, then we save it. Otherwise, the trimmedReminderCustomActionName is "" or nil so we save its value as nil
                reminder.reminderCustomActionName = reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
            reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
            
            switch reminderTypeSegmentedControl.selectedSegmentIndex {
            case ReminderType.oneTime.segmentedControlIndex:
                reminder.changeReminderType(forReminderType: .oneTime)
                reminder.oneTimeComponents.oneTimeDate = dogsReminderOneTimeView?.oneTimeDate ?? reminder.oneTimeComponents.oneTimeDate
            case ReminderType.countdown.segmentedControlIndex:
                reminder.changeReminderType(forReminderType: .countdown)
                reminder.countdownComponents.executionInterval = dogsAddReminderCountdownView?.currentCountdownDuration ?? reminder.countdownComponents.executionInterval
            case ReminderType.weekly.segmentedControlIndex:
                guard let weekdays = dogsAddReminderWeeklyView?.currentWeekdays else {
                    throw ErrorConstant.WeeklyComponentsError.weekdayArrayInvalid()
                }
                
                reminder.changeReminderType(forReminderType: .weekly)
                
                try reminder.weeklyComponents.changeWeekdays(forWeekdays: weekdays)
                guard let date = dogsAddReminderWeeklyView?.currentTimeOfDay else {
                    break
                }
                reminder.weeklyComponents.changeUTCHour(forDate: date)
                reminder.weeklyComponents.changeUTCMinute(forDate: date)
            case ReminderType.monthly.segmentedControlIndex:
                reminder.changeReminderType(forReminderType: .monthly)
                guard let date = dogsAddReminderMonthlyView?.currentTimeOfDay else {
                    break
                }
                reminder.monthlyComponents.changeUTCDay(forDate: date)
                reminder.monthlyComponents.changeUTCHour(forDate: date)
                reminder.monthlyComponents.changeUTCMinute(forDate: date)
            default: break
            }
            
            // Check if we are updating a reminder
            guard let reminderToUpdate = reminderToUpdate else {
                // Not updating an existing reminder, therefore created a reminder and prepare it for use
                reminder.resetForNextAlarm()
                return reminder
            }
            
            // Updating an existing reminder
            
            // Checks for differences in time of day, execution interval, weekdays, or time of month. If one is detected then we reset the reminder's whole timing to default
            // If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
            switch reminder.reminderType {
            case .oneTime:
                // execution date changed
                if reminder.oneTimeComponents.oneTimeDate != reminderToUpdate.oneTimeComponents.oneTimeDate {
                    reminder.resetForNextAlarm()
                }
            case .countdown:
                // execution interval changed
                if reminder.countdownComponents.executionInterval != reminderToUpdate.countdownComponents.executionInterval {
                    reminder.resetForNextAlarm()
                }
            case .weekly:
                // time of day or weekdays changed
                if reminder.weeklyComponents.weekdays != reminderToUpdate.weeklyComponents.weekdays || reminder.weeklyComponents.UTCHour != reminderToUpdate.weeklyComponents.UTCHour || reminder.weeklyComponents.UTCMinute != reminderToUpdate.weeklyComponents.UTCMinute {
                    reminder.resetForNextAlarm()
                }
            case .monthly:
                // time of day or day of month changed
                if reminder.monthlyComponents.UTCDay != reminderToUpdate.monthlyComponents.UTCDay || reminder.monthlyComponents.UTCHour != reminderToUpdate.monthlyComponents.UTCHour || reminder.monthlyComponents.UTCMinute != reminderToUpdate.monthlyComponents.UTCMinute {
                    reminder.resetForNextAlarm()
                }
            }
            
            return reminder
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown().alert()
            return nil
        }
    }
    var didUpdateInitialValues: Bool {
        if initialReminderActionType != reminderActionTypeSelected {
            return true
        }
        if reminderActionTypeSelected?.allowsCustom == true && initialReminderCustomActionName != reminderCustomActionNameTextField.text {
            return true
        }
        if initialReminderIsEnabled != reminderIsEnabledSwitch.isOn {
            return true
        }
        if initialReminderTypeSegmentedControlIndex != reminderTypeSegmentedControl.selectedSegmentIndex {
            return true
        }
        
        switch reminderTypeSegmentedControl.selectedSegmentIndex {
        case ReminderType.oneTime.segmentedControlIndex:
            return dogsReminderOneTimeView?.didUpdateInitialValues ?? false
        case ReminderType.countdown.segmentedControlIndex:
            return dogsAddReminderCountdownView?.didUpdateInitialValues ?? false
        case ReminderType.weekly.segmentedControlIndex:
            return dogsAddReminderWeeklyView?.didUpdateInitialValues ?? false
        case ReminderType.monthly.segmentedControlIndex:
            return dogsAddReminderMonthlyView?.didUpdateInitialValues ?? false
        default:
            return false
        }
    }
    private(set) var reminderActionTypeSelected: ReminderActionType?
    
    private var dropDownReminderAction: HoundDropDown?
    private var dropDownSelectedIndexPath: IndexPath?
    
    // MARK: - Main
    
    // MARK: - Setup
    
    func setup(forReminderToUpdate reminder: Reminder?) {
        reminderToUpdate = reminder
        
        // reminderActionLabel
        if let reminderToUpdate = reminderToUpdate,
           let index = GlobalTypes.shared.reminderActionTypes.firstIndex(of: reminderToUpdate.reminderActionType) {
            dropDownSelectedIndexPath = IndexPath(row: index, section: 0)
            reminderActionLabel.text = reminderToUpdate.reminderActionType.convertToReadableName(customActionName: nil)
        }
        else {
            reminderActionLabel.text = ""
        }
        reminderActionTypeSelected = reminderToUpdate?.reminderActionType
        initialReminderActionType = reminderToUpdate?.reminderActionType
        
        // reminderCustomActionNameTextField
        reminderCustomActionNameTextField.text = reminderToUpdate?.reminderCustomActionName
        initialReminderCustomActionName = reminderToUpdate?.reminderCustomActionName
        
        // reminderIsEnabledSwitch
        reminderIsEnabledSwitch.isOn = reminderToUpdate?.reminderIsEnabled ?? reminderIsEnabledSwitch.isOn
        initialReminderIsEnabled = reminderIsEnabledSwitch.isOn
        
        // reminderTypeSegmentedControl
        if let reminderToUpdate = reminderToUpdate {
            reminderTypeSegmentedControl.selectedSegmentIndex = reminderToUpdate.reminderType.segmentedControlIndex
        }
        else {
            reminderTypeSegmentedControl.selectedSegmentIndex = ReminderType.countdown.segmentedControlIndex
        }
        onceView.isHidden = reminderTypeSegmentedControl.selectedSegmentIndex != ReminderType.oneTime.segmentedControlIndex
        countdownView.isHidden = reminderTypeSegmentedControl.selectedSegmentIndex != ReminderType.countdown.segmentedControlIndex
        weeklyView.isHidden = reminderTypeSegmentedControl.selectedSegmentIndex != ReminderType.weekly.segmentedControlIndex
        monthlyView.isHidden = reminderTypeSegmentedControl.selectedSegmentIndex != ReminderType.monthly.segmentedControlIndex
        initialReminderTypeSegmentedControlIndex = reminderTypeSegmentedControl.selectedSegmentIndex
        
        // onceView
        if reminderToUpdate?.reminderType == .oneTime {
            onceView.setup(forDelegate: self, forOneTimeDate: Date().distance(to: reminderToUpdate?.oneTimeComponents.oneTimeDate ?? Date()) > 0 ? reminderToUpdate?.oneTimeComponents.oneTimeDate : nil)
        }
        else {
            onceView.setup(forDelegate: self, forOneTimeDate: nil)
        }
        
        // countdownView
        if reminderToUpdate?.reminderType == .countdown {
            countdownView.setup(forDelegate: self, forCountdownDuration: reminderToUpdate?.countdownComponents.executionInterval)
        }
        else {
            countdownView.setup(forDelegate: self, forCountdownDuration: nil)
        }
        
        // weeklyView
        if reminderToUpdate?.reminderType == .weekly {
            weeklyView.setup(forDelegate: self,
                             forTimeOfDay: reminderToUpdate?.weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date()),
                             forWeekdays: reminderToUpdate?.weeklyComponents.weekdays)
        }
        else {
            weeklyView.setup(forDelegate: self, forTimeOfDay: nil, forWeekdays: nil)
        }
        
        // monthlyView
        if reminderToUpdate?.reminderType == .monthly {
            monthlyView.setup(forDelegate: self, forTimeOfDay: reminderToUpdate?.monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date()))
        }
        else {
            monthlyView.setup(forDelegate: self, forTimeOfDay: nil)
        }
        
        updateDynamicUIElements()
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        let reminderCustomActionNameIsHidden = reminderActionTypeSelected?.allowsCustom != true
        
        reminderCustomActionNameTextField.isHidden = reminderCustomActionNameIsHidden
        if reminderCustomActionNameIsHidden {
            reminderCustomActionNameHeightMultiplier.setMultiplier(0.0)
            reminderCustomActionNameMaxHeight.constant = 0.0
            reminderCustomActionNameTop.constant = 0.0
        }
        else {
            reminderCustomActionNameHeightMultiplier.restore()
            reminderCustomActionNameMaxHeight.restore()
            reminderCustomActionNameTop.restore()
        }
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideSingleElement) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    // MARK: - Drop Down Handling
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return }
        
        // If a dropDown exists, hide it unless tap is on its label or itself
        if let dd = dropDownReminderAction, !touched.isDescendant(of: reminderActionLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        
        // Dismiss keyboard if tap was outside text inputs
        dismissKeyboard()
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        dismissKeyboard()
        
        if (dropDownReminderAction?.isDown ?? false) == false {
            if dropDownReminderAction == nil {
                let dropDown = HoundDropDown()
                dropDown.setupDropDown(
                    forHoundDropDownIdentifier: "DROP_DOWN",
                    forDataSource: self,
                    forViewPositionReference: reminderActionLabel.frame,
                    forOffset: 2.5,
                    forRowHeight: HoundDropDown.rowHeightForHoundLabel
                )
                addSubview(dropDown)
                dropDownReminderAction = dropDown
            }
            
            dropDownReminderAction?.showDropDown(numberOfRowsToShow: 6.5, animated: true)
        }
        else {
            dropDownReminderAction?.hideDropDown(animated: true)
        }
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? HoundDropDownTableViewCell else {
            return
        }
        customCell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownSelectedIndexPath == indexPath {
            customCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        else {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
        }
        
        // inside of the predefined ReminderActionType
        if indexPath.row < GlobalTypes.shared.reminderActionTypes.count {
            customCell.label.text = GlobalTypes.shared.reminderActionTypes[indexPath.row].convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - GlobalTypes.shared.reminderActionTypes.count]
            let reminderActionType = ReminderActionType.find(forReminderActionTypeId: previousReminderCustomActionName.reminderActionTypeId)
            customCell.label.text = reminderActionType.convertToReadableName(customActionName: previousReminderCustomActionName.reminderCustomActionName, includeMatchingEmoji: false)
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        GlobalTypes.shared.reminderActionTypes.count + LocalConfiguration.localPreviousReminderCustomActionNames.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if let previousSelectedIndexPath = dropDownSelectedIndexPath, let previousSelectedCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: previousSelectedIndexPath) as? HoundDropDownTableViewCell {
            previousSelectedCell.setCustomSelectedTableViewCell(forSelected: false)
        }
        if let selectedCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        dropDownSelectedIndexPath = indexPath
        
        // inside of the predefined LogActionType
        if indexPath.row < GlobalTypes.shared.reminderActionTypes.count {
            reminderActionLabel.text = GlobalTypes.shared.reminderActionTypes[indexPath.row].convertToReadableName(customActionName: nil)
            reminderActionTypeSelected = GlobalTypes.shared.reminderActionTypes[indexPath.row]
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - GlobalTypes.shared.reminderActionTypes.count]
            let previousReminderReminderActionType = ReminderActionType.find(forReminderActionTypeId: previousReminderCustomActionName.reminderActionTypeId)
            
            reminderActionLabel.text = previousReminderReminderActionType.convertToReadableName(customActionName: previousReminderCustomActionName.reminderCustomActionName)
            reminderActionTypeSelected = previousReminderReminderActionType
            reminderCustomActionNameTextField.text = previousReminderCustomActionName.reminderCustomActionName
        }
        
        dismissKeyboard()
        dropDownReminderAction?.hideDropDown(animated: true)
        updateDynamicUIElements()
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(reminderActionLabel)
        addSubview(reminderIsEnabledSwitch)
        addSubview(reminderCustomActionNameTextField)
        addSubview(reminderTypeSegmentedControl)
        addSubview(reminderViewsStack)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // reminderActionLabel
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderActionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            reminderActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        // reminderIsEnabledSwitch
        NSLayoutConstraint.activate([
            reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            reminderIsEnabledSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset * 2.0),
            reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: reminderActionLabel.centerYAnchor)
        ])
        
        // reminderCustomActionNameTextField
        reminderCustomActionNameTop = GeneralLayoutConstraint(reminderCustomActionNameTextField.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        reminderCustomActionNameHeightMultiplier = GeneralLayoutConstraint(reminderCustomActionNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self))
        reminderCustomActionNameMaxHeight = GeneralLayoutConstraint(reminderCustomActionNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            reminderCustomActionNameTop.constraint,
            reminderCustomActionNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            reminderCustomActionNameHeightMultiplier.constraint,
            reminderCustomActionNameMaxHeight.constraint
        ])
        
        // reminderTypeSegmentedControl
        NSLayoutConstraint.activate([
            reminderTypeSegmentedControl.topAnchor.constraint(equalTo: reminderCustomActionNameTextField.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderTypeSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            reminderTypeSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            reminderTypeSegmentedControl.createHeightMultiplier(ConstraintConstant.Input.segmentedHeightMultiplier, relativeToWidthOf: self),
            reminderTypeSegmentedControl.createMaxHeight(ConstraintConstant.Input.segmentedMaxHeight)
        ])
        
        // reminderViewsStack
        NSLayoutConstraint.activate([
            reminderViewsStack.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderViewsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset),
            reminderViewsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderViewsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
    }
    
}
