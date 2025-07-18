//
//  DogsAddReminderManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogsAddReminderDropDownTypes: String {
    case reminderAction = "DropDownReminderAction"
}

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
        gesture.name = DogsAddReminderDropDownTypes.reminderAction.rawValue
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
        let textField = HoundTextField(huggingPriority: 280, compressionResistancePriority: 280)
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
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
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
    
    private var reminderToUpdate: Reminder?
    private var initialReminder: Reminder?
    
    private(set) var selectedReminderAction: ReminderActionType?
    /// Options for the reminder action drop down consisting of base types and their previous custom names
    private var availableReminderActions: [(ReminderActionType, String?)] {
        var options: [(ReminderActionType, String?)] = []
        for type in GlobalTypes.shared.reminderActionTypes {
            options.append((type, nil))
            let matching = LocalConfiguration.localPreviousReminderCustomActionNames.filter { $0.reminderActionTypeId == type.reminderActionTypeId }
            for prev in matching {
                options.append((type, prev.reminderCustomActionName))
            }
        }
        return options
    }
    
    private var dropDownReminderAction: HoundDropDown?
    private var selectedDropDownReminderActionIndexPath: IndexPath?
    
    func constructReminder(showErrorIfFailed: Bool) -> Reminder? {
        guard let selectedReminderAction = selectedReminderAction else {
            if showErrorIfFailed {
                reminderActionLabel.errorMessage = ErrorConstant.ReminderError.reminderActionMissing().description
            }
            return nil
        }
        
        guard let reminder: Reminder = reminderToUpdate != nil ? reminderToUpdate?.copy() as? Reminder : Reminder() else {
            return nil
        }
        
        reminder.reminderActionTypeId = selectedReminderAction.reminderActionTypeId
        
        if selectedReminderAction.allowsCustom {
            // if the trimmedReminderCustomActionName is not "", meaning it has text, then we save it. Otherwise, the trimmedReminderCustomActionName is "" or nil so we save its value as nil
            reminder.reminderCustomActionName = reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
        
        switch reminderTypeSegmentedControl.selectedSegmentIndex {
        case ReminderType.oneTime.segmentedControlIndex:
            reminder.changeReminderType(forReminderType: .oneTime)
            reminder.oneTimeComponents.oneTimeDate = onceView.oneTimeDate ?? reminder.oneTimeComponents.oneTimeDate
        case ReminderType.countdown.segmentedControlIndex:
            reminder.changeReminderType(forReminderType: .countdown)
            reminder.countdownComponents.executionInterval = countdownView.currentCountdownDuration ?? reminder.countdownComponents.executionInterval
        case ReminderType.weekly.segmentedControlIndex:
            guard let weekdays = weeklyView.currentWeekdays else {
                if showErrorIfFailed {
                    weeklyView.weekdayStack.errorMessage = ErrorConstant.WeeklyComponentsError.weekdaysInvalid().description
                }
                
                return nil
            }
            
            reminder.changeReminderType(forReminderType: .weekly)
            
            guard reminder.weeklyComponents.changeWeekdays(forWeekdays: weekdays) else {
                if showErrorIfFailed {
                    weeklyView.weekdayStack.errorMessage = ErrorConstant.WeeklyComponentsError.weekdaysInvalid().description
                }
                return nil
            }
            
            guard let date = weeklyView.currentTimeOfDay else {
                break
            }
            reminder.weeklyComponents.changeUTCHour(forDate: date)
            reminder.weeklyComponents.changeUTCMinute(forDate: date)
        case ReminderType.monthly.segmentedControlIndex:
            reminder.changeReminderType(forReminderType: .monthly)
            guard let date = monthlyView.currentTimeOfDay else {
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
    
    var didUpdateInitialValues: Bool {
        guard let initialReminder = initialReminder else {
            // creating new reminder right now, so return true
            return true
        }
        
        guard let reminderToUpdate = reminderToUpdate else {
            // should never happen, if have initialReminder, then should have reminderToUpdate
            return true
        }
        
        return initialReminder.isSame(as: reminderToUpdate) == false
    }
    
    // MARK: - Setup
    
    func setup(forReminderToUpdate: Reminder?) {
        reminderToUpdate = forReminderToUpdate
        initialReminder = forReminderToUpdate?.copy() as? Reminder
        
        // reminderActionLabel
        if let reminderToUpdate = reminderToUpdate,
           let index = GlobalTypes.shared.reminderActionTypes.firstIndex(of: reminderToUpdate.reminderActionType) {
            selectedDropDownReminderActionIndexPath = IndexPath(row: index, section: 0)
            reminderActionLabel.text = reminderToUpdate.reminderActionType.convertToReadableName(customActionName: nil)
        }
        else {
            reminderActionLabel.text = ""
        }
        selectedReminderAction = reminderToUpdate?.reminderActionType
        
        // reminderCustomActionNameTextField
        reminderCustomActionNameTextField.text = reminderToUpdate?.reminderCustomActionName
        
        // reminderIsEnabledSwitch
        reminderIsEnabledSwitch.isOn = reminderToUpdate?.reminderIsEnabled ?? reminderIsEnabledSwitch.isOn
        
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
        let reminderCustomActionNameIsHidden = selectedReminderAction?.allowsCustom != true
        
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
        guard let name = sender.name,
              let targetType = DogsAddReminderDropDownTypes(rawValue: name) else { return }
        
        let targetDropDown = dropDown(forDropDownType: targetType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given dropDownType, return the corresponding dropDown UIView
    private func dropDown(forDropDownType type: DogsAddReminderDropDownTypes) -> HoundDropDown? {
        switch type {
        case .reminderAction: return dropDownReminderAction
        }
    }
    
    /// For a given dropDownType, return the label that triggers it
    private func labelForDropDown(forDropDownType type: DogsAddReminderDropDownTypes) -> HoundLabel {
        switch type {
        case .reminderAction: return reminderActionLabel
        }
    }
    
    /// Determine and show the next required dropdown in the log creation flow
    private func showNextRequiredDropDown(animated: Bool) {
        if selectedReminderAction == nil {
            showDropDown(.reminderAction, animated: animated)
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: DogsAddReminderDropDownTypes, animated: Bool) {
        let label = labelForDropDown(forDropDownType: type)
        let superview = label.superview
        let dropDowns = [dropDownReminderAction]
        
        // work around: ui element or error message couldve been added which is higher in the view than dropdown since dropdown last opened
        // ensure that dropdowns are on top (and in correct order relative to other drop downs)
        dropDowns.forEach { dropDown in
            dropDown?.removeFromSuperview()
        }
        dropDowns.reversed().forEach { dropDown in
            if let dropDown = dropDown, let superview = superview {
                superview.addSubview(dropDown)
            }
        }
        
        var targetDropDown = dropDown(forDropDownType: type)
        if targetDropDown == nil {
            targetDropDown = HoundDropDown()
            targetDropDown?.setupDropDown(
                forHoundDropDownIdentifier: type.rawValue,
                forDataSource: self,
                forViewPositionReference: label.frame,
                forOffset: 2.5,
                forRowHeight: HoundDropDown.rowHeightForHoundLabel
            )
            switch type {
            case .reminderAction: dropDownReminderAction = targetDropDown
            }
            if let superview = superview, let targetDropDown = targetDropDown {
                superview.addSubview(targetDropDown)
            }
        }
        
        targetDropDown?.showDropDown(
            numberOfRowsToShow: min(6.5, {
                switch type {
                case .reminderAction:
                    return CGFloat(availableReminderActions.count)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? HoundDropDownTableViewCell else { return }
        customCell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownUIViewIdentifier == DogsAddReminderDropDownTypes.reminderAction.rawValue {
            customCell.setCustomSelectedTableViewCell(forSelected: selectedDropDownReminderActionIndexPath == indexPath)
            let option = availableReminderActions[indexPath.row]
            customCell.label.text = option.0.convertToReadableName(customActionName: option.1, includeMatchingEmoji: true)
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        switch dropDownUIViewIdentifier {
        case DogsAddReminderDropDownTypes.reminderAction.rawValue:
            return availableReminderActions.count
        default:
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == DogsAddReminderDropDownTypes.reminderAction.rawValue {
            if let previousSelectedIndexPath = selectedDropDownReminderActionIndexPath, let previousSelectedCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: previousSelectedIndexPath) as? HoundDropDownTableViewCell {
                previousSelectedCell.setCustomSelectedTableViewCell(forSelected: false)
            }
            if let selectedCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
                selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            }
            selectedDropDownReminderActionIndexPath = indexPath
            
            let option = availableReminderActions[indexPath.row]
            reminderActionLabel.text = option.0.convertToReadableName(customActionName: option.1, includeMatchingEmoji: true)
            selectedReminderAction = option.0
            
            if let custom = option.1 {
                reminderCustomActionNameTextField.text = custom
            }
            
            reminderActionLabel.errorMessage = nil
            
            dismissKeyboard()
            dropDownReminderAction?.hideDropDown(animated: true)
            updateDynamicUIElements()
            
            showNextRequiredDropDown(animated: true)
        }
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
            reminderViewsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            reminderViewsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderViewsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
    }
    
}
