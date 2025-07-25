//
//  DogsAddReminderManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

enum DogsAddReminderDropDownTypes: String, HoundDropDownType {
    case reminderAction = "DropDownReminderAction"
    case reminderRecipients = "DropDownReminderRecipients"
}

final class DogsAddReminderManagerView: HoundView,
                                        UITextFieldDelegate,
                                        UIGestureRecognizerDelegate,
                                        DogsAddReminderCountdownViewDelegate,
                                        DogsAddReminderWeeklyViewDelegate,
                                        HoundDropDownDataSource,
                                        HoundDropDownManagerDelegate,
                                        DogsAddReminderMonthlyViewDelegate,
                                        DogsAddReminderOneTimeViewDelegate {
    
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
        return updatedText.count <= Constant.Class.Reminder.reminderCustomActionNameCharacterLimit
    }
    
    // MARK: - Elements
    
    private let reminderActionHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Remind About"
        return label
    }()
    private lazy var reminderActionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select an action..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddReminderDropDownTypes.reminderAction,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderAction, label: label)
        
        return label
    }()
    private lazy var reminderIsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 300, compressionResistancePriority: 300)
        uiSwitch.isOn = Constant.Class.Reminder.defaultReminderIsEnabled
        uiSwitch.addTarget(self, action: #selector(didToggleIsReminderEnabled), for: .valueChanged)
        return uiSwitch
    }()
    private lazy var reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField()
        textField.delegate = self
        
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = "Add a custom name... (optional)"
        textField.shouldInsetText = true
        
        return textField
    }()
    private lazy var nestedReminderLabelStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(reminderActionLabel)
        
        // reminderIsEnabledSwitch needs an extra Constant.Constraint.Spacing.absoluteHoriInset before the end of the stack
        let extraPaddingAfterSwitch = HoundView()
        let paddedSwitchStack = HoundStackView(arrangedSubviews: [reminderIsEnabledSwitch, extraPaddingAfterSwitch])
        extraPaddingAfterSwitch.snp.makeConstraints { make in
            make.width.equalTo(Constant.Constraint.Spacing.absoluteHoriInset)
            make.height.equalTo(reminderIsEnabledSwitch.snp.height)
        }
        stack.addArrangedSubview(paddedSwitchStack)
        
        stack.axis = .horizontal
        stack.spacing = Constant.Constraint.Spacing.absoluteHoriInset
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    private lazy var reminderActionStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(reminderActionHeaderLabel)
        
        let nestedStack = HoundStackView()
        nestedStack.addArrangedSubview(nestedReminderLabelStack)
        nestedStack.addArrangedSubview(reminderCustomActionNameTextField)
        nestedStack.axis = .vertical
        nestedStack.spacing = Constant.Constraint.Spacing.contentIntraVert
        
        stack.addArrangedSubview(nestedStack)
        
        return stack
    }()
    
    private let reminderRecipientsHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Notify These People"
        return label
    }()
    private lazy var reminderRecipientsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 295, compressionResistancePriority: 295)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select family members... (optional)"
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddReminderDropDownTypes.reminderRecipients,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderRecipients, label: label)
        return label
    }()
    private let notificationsDisabledLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        // label.textColor set in func
        label.numberOfLines = 0
        
        return label
    }()
    private lazy var nestedRecipientsLabelStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(reminderRecipientsLabel)
        stack.addArrangedSubview(notificationsDisabledLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    private lazy var reminderRecipientsStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(reminderRecipientsHeaderLabel)
        stack.addArrangedSubview(nestedRecipientsLabelStack)
        return stack
    }()
    
    private lazy var segmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
        ReminderType.allCases.enumerated().forEach { index, option in
            segmentedControl.insertSegment(withTitle: option.readableName, at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.addTarget(self, action: #selector(didUpdateReminderType), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private let onceView = DogsAddReminderOneTimeView()
    private let countdownView = DogsAddReminderCountdownView()
    private let weeklyView = DogsAddReminderWeeklyView()
    private let monthlyView = DogsAddReminderMonthlyView()
    
    private lazy var reminderViewsStack: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [onceView, countdownView, weeklyView, monthlyView])
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    private lazy var dropDownManager = HoundDropDownManager<DogsAddReminderDropDownTypes>(
        rootView: self,
        dataSource: self,
        delegate: self
    )
    
    @objc private func didToggleIsReminderEnabled(_ sender: HoundSwitch) {
        updateRecipientsLabel()
        updateDisclaimerLabel()
        if !reminderIsEnabledSwitch.isOn {
            let dropDown = dropDownManager.dropDown(for: .reminderRecipients)
            dropDown?.hideDropDown(animated: true)
        }
    }
    @objc private func didUpdateReminderType(_ sender: HoundSegmentedControl) {
        onceView.isHidden = !(sender.selectedSegmentIndex == ReminderType.oneTime.segmentedControlIndex)
        countdownView.isHidden = !(sender.selectedSegmentIndex == ReminderType.countdown.segmentedControlIndex)
        weeklyView.isHidden = !(sender.selectedSegmentIndex == ReminderType.weekly.segmentedControlIndex)
        monthlyView.isHidden = !(sender.selectedSegmentIndex == ReminderType.monthly.segmentedControlIndex)
    }
    
    // MARK: - Properties
    
    private var reminderToUpdate: Reminder?
    private var initialReminder: Reminder?
    
    private(set) var selectedReminderAction: ReminderActionType? {
        didSet {
            reminderActionLabel.text = selectedReminderAction?.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
        }
    }
    var selectedReminderActionIndexPath: IndexPath? {
        guard let selectedReminderAction = selectedReminderAction else { return nil }
        let mapped = availableReminderActions.enumerated().map { index, element -> (ReminderActionType, String?, Int) in // swiftlint:disable:this large_tuple
            return (element.0, element.1, index)
        }
        
        let matchingTypes = mapped.filter { type, _, _ in
            return type.reminderActionTypeId == selectedReminderAction.reminderActionTypeId
        }
        
        guard let first = matchingTypes.first else {
            return nil
        }
        
        // if we only find 1 match for a given reminder type, then there are no PreviousReminderCustomNames or in the mix, so the one availableReminderActions of type selectedReminderAction is our selected guy
        guard matchingTypes.count > 1 && (reminderCustomActionNameTextField.text?.hasText() ?? false) else {
            // first.2 is just the index of selectedReminderAction in availableReminderActions
            return IndexPath(row: first.2, section: 0)
        }
        
        // we have multiple of the same reminder type, so try to match based upon custom name
        let typesWithCustomNames = matchingTypes.filter { _, customName, _ in
            return customName?.hasText() ?? false
        }
        let typesWithoutCustomNames = matchingTypes.filter { _, customName, _ in
            return (customName?.hasText() ?? false) == false
        }
        
        for typesWithCustomName in typesWithCustomNames where reminderCustomActionNameTextField.text == typesWithCustomName.1 {
            // matched reminder type and custom name
            return IndexPath(row: typesWithCustomName.2, section: 0)
        }
        
        // no match, revert to just custom name only
        if let noName = typesWithoutCustomNames.first {
            return IndexPath(row: noName.2, section: 0)
        }
        return nil
    }
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
    private var availableFamilyMembers: [FamilyMember] {
        FamilyInformation.familyMembers
    }
    
    private var selectedRecipientUserIds: Set<String> = []
    
    func constructReminder(showErrorIfFailed: Bool) -> Reminder? {
        guard let selectedReminderAction = selectedReminderAction else {
            if showErrorIfFailed {
                HapticsManager.notification(.error)
                reminderActionLabel.errorMessage = Constant.Error.ReminderError.reminderActionMissing
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
        reminder.reminderRecipientUserIds = Array(selectedRecipientUserIds)
        
        switch segmentedControl.selectedSegmentIndex {
        case ReminderType.oneTime.segmentedControlIndex:
            reminder.changeReminderType(forReminderType: .oneTime)
            reminder.oneTimeComponents.oneTimeDate = onceView.oneTimeDate ?? reminder.oneTimeComponents.oneTimeDate
        case ReminderType.countdown.segmentedControlIndex:
            reminder.changeReminderType(forReminderType: .countdown)
            reminder.countdownComponents.executionInterval = countdownView.currentCountdownDuration ?? reminder.countdownComponents.executionInterval
        case ReminderType.weekly.segmentedControlIndex:
            guard let weekdays = weeklyView.currentWeekdays else {
                if showErrorIfFailed {
                    HapticsManager.notification(.error)
                    weeklyView.weekdayStack.errorMessage = Constant.Error.WeekdayComponentsError.weekdaysInvalid
                }
                
                return nil
            }
            
            reminder.changeReminderType(forReminderType: .weekly)
            
            guard reminder.weeklyComponents.changeWeekdays(forWeekdays: weekdays) else {
                if showErrorIfFailed {
                    HapticsManager.notification(.error)
                    weeklyView.weekdayStack.errorMessage = Constant.Error.WeekdayComponentsError.weekdaysInvalid
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
        
        return !initialReminder.isSame(as: reminderToUpdate)
    }
    
    // MARK: - Setup
    
    func setup(forReminderToUpdate: Reminder?) {
        reminderToUpdate = forReminderToUpdate
        initialReminder = forReminderToUpdate?.copy() as? Reminder
        
        // reminderActionLabel
        selectedReminderAction = reminderToUpdate?.reminderActionType
        
        // reminderCustomActionNameTextField
        reminderCustomActionNameTextField.text = reminderToUpdate?.reminderCustomActionName
        
        // reminderIsEnabledSwitch
        reminderIsEnabledSwitch.isOn = reminderToUpdate?.reminderIsEnabled ?? reminderIsEnabledSwitch.isOn
        selectedRecipientUserIds = Set(reminderToUpdate?.reminderRecipientUserIds ?? FamilyInformation.familyMembers.map { $0.userId })
        updateRecipientsLabel()
        updateDisclaimerLabel()
        
        // segmentedControl
        if let reminderToUpdate = reminderToUpdate {
            segmentedControl.selectedSegmentIndex = reminderToUpdate.reminderType.segmentedControlIndex
        }
        else {
            segmentedControl.selectedSegmentIndex = ReminderType.countdown.segmentedControlIndex
        }
        onceView.isHidden = segmentedControl.selectedSegmentIndex != ReminderType.oneTime.segmentedControlIndex
        countdownView.isHidden = segmentedControl.selectedSegmentIndex != ReminderType.countdown.segmentedControlIndex
        weeklyView.isHidden = segmentedControl.selectedSegmentIndex != ReminderType.weekly.segmentedControlIndex
        monthlyView.isHidden = segmentedControl.selectedSegmentIndex != ReminderType.monthly.segmentedControlIndex
        
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
        let customActionNameIsHidden = selectedReminderAction?.allowsCustom != true
        if reminderCustomActionNameTextField.isHidden != customActionNameIsHidden {
            reminderCustomActionNameTextField.isHidden = customActionNameIsHidden
            remakeCustomActionNameConstraints()
        }
        
        updateRecipientsLabel()
        updateDisclaimerLabel()
        
        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    private func updateRecipientsLabel() {
        reminderRecipientsLabel.isEnabled = reminderIsEnabledSwitch.isOn
        if selectedRecipientUserIds.isEmpty {
            reminderRecipientsLabel.text = nil
        }
        else if selectedRecipientUserIds.count == 1, let userId = selectedRecipientUserIds.first, userId == UserInformation.userId {
            reminderRecipientsLabel.text = "Me"
        }
        else if selectedRecipientUserIds.count == 1, let userId = selectedRecipientUserIds.first {
            reminderRecipientsLabel.text = FamilyInformation.findFamilyMember(forUserId: userId)?.displayFullName ?? Constant.Visual.Text.unknownName
        }
        else if  selectedRecipientUserIds.count == FamilyInformation.familyMembers.count {
            reminderRecipientsLabel.text = "Everyone"
        }
        else {
            reminderRecipientsLabel.text = "Multiple"
        }
    }
    private func updateDisclaimerLabel() {
        let reminderEnabled = reminderIsEnabledSwitch.isOn
        let userIsRecipient = selectedRecipientUserIds.contains(UserInformation.userId ?? Constant.Visual.Text.unknownUserId)
        
        notificationsDisabledLabel.isHidden = selectedRecipientUserIds.isEmpty || (reminderEnabled &&
            (!userIsRecipient || (UserConfiguration.isNotificationEnabled && UserConfiguration.isReminderNotificationEnabled)))
        
        let precalculatedDynamicTextColor = UIColor.secondaryLabel
        
        notificationsDisabledLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message = NSMutableAttributedString()
            if !reminderEnabled {
                message.append(NSAttributedString(
                    string: "Your reminder is currently ",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: "off",
                    attributes: [
                        .font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: ", so no alarms will sound.",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
            }
            else if !UserConfiguration.isNotificationEnabled {
                message.append(NSAttributedString(
                    string: "Your notifications are ",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: "disabled",
                    attributes: [
                        .font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: ", so you won't receive any push notifications (you can change this in Hound's settings).",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
            }
            else if !UserConfiguration.isReminderNotificationEnabled {
                message.append(NSAttributedString(
                    string: "Your reminder notifications are ",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: "disabled",
                    attributes: [
                        .font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
                message.append(NSAttributedString(
                    string: ", so you won’t get push notifications for reminders (you can change this in Hound's settings).",
                    attributes: [
                        .font: Constant.Visual.Font.secondaryColorDescLabel,
                        .foregroundColor: precalculatedDynamicTextColor as Any
                    ]
                ))
            }
            return message
        }
    }
    
    // MARK: - Drop Down Handling
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        dropDownManager.hideDropDownIfNotTapped(sender: sender)
        if let senderView = sender.view {
            let point = sender.location(in: senderView)
            if let deepestTouchedView = senderView.hitTest(point, with: nil), !deepestTouchedView.isDescendant(of: reminderCustomActionNameTextField) {
                dismissKeyboard()
            }
        }
    }
    
    /// Determine and show the next required dropdown in the log creation flow
    private func showNextRequiredDropDown(animated: Bool) {
        if selectedReminderAction == nil {
            willShowDropDown(DogsAddReminderDropDownTypes.reminderAction, animated: animated)
        }
    }
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let type = identifier as? DogsAddReminderDropDownTypes else { return }
        
        let numberOfRows: CGFloat = {
            switch type {
            case .reminderAction:
                return CGFloat(availableReminderActions.count)
            case .reminderRecipients:
                return CGFloat(availableFamilyMembers.count)
            }
        }()
        
        dropDownManager.show(
            identifier: type,
            numberOfRowsToShow: min(6.5, numberOfRows),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let identifier = identifier as? DogsAddReminderDropDownTypes else { return }
        
        switch identifier {
        case .reminderAction:
            let option = availableReminderActions[indexPath.row]
            if let selectedReminderActionIndexPath = selectedReminderActionIndexPath {
                cell.setCustomSelectedTableViewCell(forSelected: selectedReminderActionIndexPath == indexPath)
            }
            else {
                cell.setCustomSelectedTableViewCell(forSelected: false)
            }
            cell.label.text = option.0.convertToReadableName(customActionName: option.1, includeMatchingEmoji: true)
        case .reminderRecipients:
            let member = availableFamilyMembers[indexPath.row]
            cell.setCustomSelectedTableViewCell(forSelected: selectedRecipientUserIds.contains(member.userId))
            cell.label.text = member.displayFullName ?? Constant.Visual.Text.unknownName
        }
    }
    
    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int {
        guard let identifier = identifier as? DogsAddReminderDropDownTypes else {
            return 0
        }
        
        switch identifier {
        case DogsAddReminderDropDownTypes.reminderAction:
            return availableReminderActions.count
        case DogsAddReminderDropDownTypes.reminderRecipients:
            return availableFamilyMembers.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let identifier = identifier as? DogsAddReminderDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: identifier), let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        
        switch identifier {
        case DogsAddReminderDropDownTypes.reminderAction:
            guard !cell.isCustomSelected else {
                cell.setCustomSelectedTableViewCell(forSelected: false)
                selectedReminderAction = nil
                updateDynamicUIElements()
                return
            }
            
            if let previouslySelectedReminderActionIndexPath = selectedReminderActionIndexPath {
                let previousSelectedCell = dropDown.dropDownTableView?.cellForRow(at: previouslySelectedReminderActionIndexPath) as? HoundDropDownTVC
                previousSelectedCell?.setCustomSelectedTableViewCell(forSelected: false)
            }
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            
            let option = availableReminderActions[indexPath.row]
            selectedReminderAction = option.0
            reminderCustomActionNameTextField.text = option.1
            
            reminderActionLabel.errorMessage = nil
            
            dropDown.hideDropDown(animated: true)
            updateDynamicUIElements()
            
            showNextRequiredDropDown(animated: true)
        case DogsAddReminderDropDownTypes.reminderRecipients:
            let member = availableFamilyMembers[indexPath.row]
            
            if cell.isCustomSelected {
                selectedRecipientUserIds.remove(member.userId)
            }
            else {
                selectedRecipientUserIds.insert(member.userId)
            }
            cell.setCustomSelectedTableViewCell(forSelected: !cell.isCustomSelected)
            
            // If no one selected, close
            // If all ppl selected, close dropdown
            if selectedRecipientUserIds.isEmpty || selectedRecipientUserIds.count == availableFamilyMembers.count {
                dropDown.hideDropDown(animated: true)
            }
            
            // recipient label text changes and disclaimer label maybe appears/disappears
            updateDynamicUIElements()
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(reminderActionStack)
        addSubview(reminderRecipientsStack)
        addSubview(segmentedControl)
        addSubview(reminderViewsStack)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        addGestureRecognizer(didTapScreenGesture)
    }
    
    private func remakeCustomActionNameConstraints() {
        reminderCustomActionNameTextField.snp.makeConstraints { make in
            if !reminderCustomActionNameTextField.isHidden {
                make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        reminderActionStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            // add extra inset for the switch inside
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        }
        reminderActionLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        remakeCustomActionNameConstraints()
        
        reminderRecipientsStack.snp.makeConstraints { make in
            make.top.equalTo(reminderActionStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        reminderRecipientsLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(reminderRecipientsStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset / 2.0)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset / 2.0)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.segmentedHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        reminderViewsStack.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.bottom.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
    }
    
}
