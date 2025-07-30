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
    case reminderType = "DropDownReminderType"
    case reminderTimeZone = "DropDownReminderTimeZone"
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
    
    // MARK: - DogsAddReminderCountdownViewDelegate, DogsAddReminderWeeklyViewDelegate, DogsAddReminderMonthlyViewDelegate, DogsAddReminderOneTimeViewDelegate
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }
    
    func didUpdateDescriptionLabel() {
        updateReminderTypeDescriptionLabel()
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
        label.placeholder = "Select a reminder type..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddReminderDropDownTypes.reminderAction,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderAction, label: label, autoscroll: .firstOpen)
        
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
        dropDownManager.register(identifier: .reminderRecipients, label: label, autoscroll: .firstOpen)
        return label
    }()
    private let notificationsDisabledLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        
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
    
    private let reminderTypeHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "How Often"
        return label
    }()
    private lazy var reminderTypeLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddReminderDropDownTypes.reminderType,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderType, label: label, direction: .down, autoscroll: .firstOpen)
        return label
    }()
    private let reminderTypeDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    private lazy var nestedReminderTypeStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(reminderTypeLabel)
        stack.addArrangedSubview(reminderTypeDescriptionLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    private lazy var reminderTypeStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(reminderTypeHeaderLabel)
        stack.addArrangedSubview(nestedReminderTypeStack)
        return stack
    }()
    
    private let timeZoneHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Time Zone"
        return label
    }()
    private lazy var timeZoneLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a time zone..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddReminderDropDownTypes.reminderTimeZone,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderTimeZone, label: label, direction: .up, autoscroll: .firstOpen)
        return label
    }()
    private let timeZoneDisclaimerLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    private lazy var nestedTimeZoneStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(timeZoneLabel)
        stack.addArrangedSubview(timeZoneDisclaimerLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    private lazy var timeZoneStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(timeZoneHeaderLabel)
        stack.addArrangedSubview(nestedTimeZoneStack)
        return stack
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
    
    // MARK: - Properties
    
    private var reminderToUpdate: Reminder?
    private var initialReminder: Reminder?
    
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
    private var availableReminderTypes: [ReminderType] {
        return ReminderType.allCases
    }
    private var availableTimeZones = Array(TimeZone.houndTimeZones.reversed())
    private(set) var selectedReminderAction: ReminderActionType? {
        didSet {
            reminderActionLabel.text = selectedReminderAction?.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            
            let customActionNameIsHidden = selectedReminderAction?.allowsCustom != true
            if reminderCustomActionNameTextField.isHidden != customActionNameIsHidden {
                UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
                    self.reminderCustomActionNameTextField.isHidden = customActionNameIsHidden
                    self.remakeCustomActionNameConstraints()
                }
            }
        }
    }
    var selectedReminderActionIndexPath: IndexPath? {
        guard let selectedReminderAction = selectedReminderAction else { return nil }
        let mapped = availableReminderActions.enumerated().map { index, element -> (ReminderActionType, String?, Int) in
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
    private var selectedRecipientUserIds: Set<String> = []
    private var selectedReminderType: ReminderType = Constant.Class.Reminder.defaultReminderType {
        didSet {
            reminderTypeLabel.text = selectedReminderType.readable
            
            onceView.isHidden = selectedReminderType != ReminderType.oneTime
            countdownView.isHidden = selectedReminderType != ReminderType.countdown
            weeklyView.isHidden = selectedReminderType != ReminderType.weekly
            monthlyView.isHidden = selectedReminderType != ReminderType.monthly
            
            // hide if not any of the views that use TZ
            let timeZoneIsHidden = selectedReminderType != ReminderType.oneTime && selectedReminderType != ReminderType.weekly && selectedReminderType != ReminderType.monthly
            if timeZoneStack.isHidden != timeZoneIsHidden {
                timeZoneStack.isHidden = timeZoneIsHidden
                remakeTimeZoneConstraints()
            }
            
            updateReminderTypeDescriptionLabel()
        }
    }
    private var selectedTimeZone: TimeZone? {
        didSet {
            timeZoneLabel.text = selectedTimeZone?.displayName()
            
            if let selectedTimeZone = selectedTimeZone, selectedTimeZone.identifier != UserConfiguration.timeZone.identifier {
                let timeDiff = selectedTimeZone.secondsFromGMT() - UserConfiguration.timeZone.secondsFromGMT()
                var text = "Your device's time zone is \(UserConfiguration.timeZone.displayName())"
                if timeDiff != 0 {
                    text += " which is \(timeDiff.readable(abbreviationLevel: .short, maxComponents: 3, enforceSequentialComponents: true)) \(timeDiff >= 0 ? "behind" : "ahead")."
                }
                timeZoneDisclaimerLabel.text = text
            }
            else {
                timeZoneDisclaimerLabel.text = nil
            }
            timeZoneDisclaimerLabel.isHidden = timeZoneDisclaimerLabel.text == nil
        }
    }
    
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
        
        switch selectedReminderType {
        case .oneTime, .weekly, .monthly:
            guard let selectedTimeZone = selectedTimeZone else {
                   if showErrorIfFailed {
                       HapticsManager.notification(.error)
                       timeZoneLabel.errorMessage = Constant.Error.ReminderError.reminderTimeZoneMissing
                   }
                   return nil
               }
            
            reminder.reminderTimeZone = selectedTimeZone
        case .countdown:
            break
        }
        
        switch selectedReminderType {
        case .oneTime:
            reminder.changeReminderType(.oneTime)
            reminder.oneTimeComponents.oneTimeDate = onceView.currentComponent.oneTimeDate
        case .countdown:
            reminder.changeReminderType(.countdown)
            reminder.countdownComponents.executionInterval = countdownView.currentComponent.executionInterval
        case .weekly:
            reminder.changeReminderType(.weekly)
            guard let component = weeklyView.currentComponent else {
                if showErrorIfFailed {
                    HapticsManager.notification(.error)
                    weeklyView.weekdayStack.errorMessage = Constant.Error.WeeklyComponentsError.weekdaysInvalid
                }
                return nil
            }
            reminder.weeklyComponents.zonedHour = component.zonedHour
            reminder.weeklyComponents.zonedMinute = component.zonedMinute
            _ = reminder.weeklyComponents.setZonedWeekdays(component.zonedWeekdays)
        case .monthly:
            reminder.changeReminderType(.monthly)
            let component = monthlyView.currentComponent
            reminder.monthlyComponents.apply(from: component)
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
            if !reminder.oneTimeComponents.isSame(as: reminderToUpdate.oneTimeComponents) {
                reminder.resetForNextAlarm()
            }
        case .countdown:
            if !reminder.countdownComponents.isSame(as: reminderToUpdate.countdownComponents) {
                reminder.resetForNextAlarm()
            }
        case .weekly:
            if !reminder.weeklyComponents.isSame(as: reminderToUpdate.weeklyComponents) {
                reminder.resetForNextAlarm()
            }
        case .monthly:
            if !reminder.monthlyComponents.isSame(as: reminderToUpdate.monthlyComponents) {
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
        
        guard let newReminder = constructReminder(showErrorIfFailed: false) else {
            // new reminder has invalid settings so show warning abt exiting
            // we have an initialReminder, so user HAS to be editing, and if newReminder couldn't be saved then user input an invalid setting
            return false
        }
        
        return !initialReminder.isSame(as: newReminder)
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
        
        // reminderTypeLabel
        selectedReminderType = reminderToUpdate?.reminderType ?? Constant.Class.Reminder.defaultReminderType
        
        let timeZone = reminderToUpdate?.reminderTimeZone ?? UserConfiguration.timeZone
        selectedTimeZone = timeZone
        
        // onceView
        if reminderToUpdate?.reminderType == .oneTime {
            let date = Date().distance(to: reminderToUpdate?.oneTimeComponents.oneTimeDate ?? Date()) > 0 ?
            reminderToUpdate?.oneTimeComponents.oneTimeDate : nil
            onceView.setup(
                forDelegate: self,
                forComponents: date != nil ? OneTimeComponents(oneTimeDate: date) : nil,
                forTimeZone: timeZone
            )
        }
        else {
            onceView.setup(forDelegate: self, forComponents: nil, forTimeZone: timeZone)
        }
        
        // countdownView
        if reminderToUpdate?.reminderType == .countdown {
            countdownView.setup(
                forDelegate: self,
                forComponents: reminderToUpdate?.countdownComponents
            )
        }
        else {
            countdownView.setup(forDelegate: self, forComponents: nil)
        }
        
        // weeklyView
        if reminderToUpdate?.reminderType == .weekly {
            weeklyView.setup(
                forDelegate: self,
                forComponents: reminderToUpdate?.weeklyComponents,
                forTimeZone: timeZone
            )
        }
        else {
            weeklyView.setup(forDelegate: self, forComponents: nil, forTimeZone: timeZone)
        }
        
        // monthlyView
        if reminderToUpdate?.reminderType == .monthly {
            monthlyView.setup(
                forDelegate: self,
                forComponents: reminderToUpdate?.monthlyComponents,
                forTimeZone: timeZone
            )
        }
        else {
            monthlyView.setup(forDelegate: self, forComponents: nil, forTimeZone: timeZone)
        }
    }
    
    // MARK: - Functions
    
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
        let hasRecipients = !selectedRecipientUserIds.isEmpty
        let shouldShowDisclaimer =
            !reminderEnabled ||
            !userIsRecipient ||
            (hasRecipients && !UserConfiguration.isNotificationEnabled) ||
            (hasRecipients && !UserConfiguration.isReminderNotificationEnabled)
        
        notificationsDisabledLabel.isHidden = !shouldShowDisclaimer
        
        notificationsDisabledLabel.attributedText = {
            let message = NSMutableAttributedString()
            if !reminderEnabled {
                message.append(NSAttributedString(
                    string: "Your reminder is currently ",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: "off",
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: ", so no alarms will sound.",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
            }
            else if !userIsRecipient {
                message.append(NSAttributedString(
                    string: "You're ",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: "not",
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: " a recipient for this reminder, so you won't be notified.",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
            }
            else if !UserConfiguration.isNotificationEnabled {
                message.append(NSAttributedString(
                    string: "Your notifications are ",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: "disabled",
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: ", so you won't receive any push notifications (you can change this in Hound's settings).",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
            }
            else if !UserConfiguration.isReminderNotificationEnabled {
                message.append(NSAttributedString(
                    string: "Your reminder notifications are ",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: "disabled",
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel]
                ))
                message.append(NSAttributedString(
                    string: ", so you won’t get push notifications for reminders (you can change this in Hound's settings).",
                    attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
                ))
            }
            return message
        }()
    }
    private func updateReminderTypeDescriptionLabel() {
        switch selectedReminderType {
        case .oneTime:
            reminderTypeDescriptionLabel.text = onceView.descriptionLabelText
        case .countdown:
            reminderTypeDescriptionLabel.text = countdownView.descriptionLabelText
        case .weekly:
            reminderTypeDescriptionLabel.text = nil
        case .monthly:
            reminderTypeDescriptionLabel.text = monthlyView.descriptionLabelText
        }
        reminderTypeDescriptionLabel.isHidden = reminderTypeDescriptionLabel.text == nil
    }
    
    // MARK: - Drop Down Handling
    
    @objc func didTapScreen(sender: UITapGestureRecognizer) {
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
            case .reminderType:
                return CGFloat(availableReminderTypes.count)
            case .reminderTimeZone:
                return CGFloat(availableTimeZones.count)
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
                cell.setCustomSelected(selectedReminderActionIndexPath == indexPath, animated: false)
            }
            else {
                cell.setCustomSelected(false, animated: false)
            }
            cell.label.text = option.0.convertToReadableName(customActionName: option.1, includeMatchingEmoji: true)
        case .reminderRecipients:
            let member = availableFamilyMembers[indexPath.row]
            cell.setCustomSelected(selectedRecipientUserIds.contains(member.userId), animated: false)
            cell.label.text = member.displayFullName ?? Constant.Visual.Text.unknownName
        case .reminderType:
            let type = availableReminderTypes[indexPath.row]
            cell.setCustomSelected(selectedReminderType == type, animated: false)
            cell.label.text = type.readable
        case .reminderTimeZone:
            let tz = availableTimeZones[indexPath.row]
            cell.setCustomSelected(selectedTimeZone?.identifier == tz.identifier, animated: false)
            cell.label.text = tz.displayName(currentTimeZone: UserConfiguration.timeZone)
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
        case DogsAddReminderDropDownTypes.reminderType:
            return availableReminderTypes.count
        case DogsAddReminderDropDownTypes.reminderTimeZone:
            return availableTimeZones.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let identifier = identifier as? DogsAddReminderDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: identifier), let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
  
        switch identifier {
        case .reminderAction:
            guard !cell.isCustomSelected else {
                cell.setCustomSelected(false)
                selectedReminderAction = nil
                return
            }
            
            if let previouslySelectedReminderActionIndexPath = selectedReminderActionIndexPath {
                let previousSelectedCell = dropDown.dropDownTableView?.cellForRow(at: previouslySelectedReminderActionIndexPath) as? HoundDropDownTVC
                previousSelectedCell?.setCustomSelected(false)
            }
            
            cell.setCustomSelected(true)
            
            let option = availableReminderActions[indexPath.row]
            selectedReminderAction = option.0
            reminderCustomActionNameTextField.text = option.1
            
            reminderActionLabel.errorMessage = nil
            
            dropDown.hideDropDown(animated: true)
            
            showNextRequiredDropDown(animated: true)
        case .reminderRecipients:
            let member = availableFamilyMembers[indexPath.row]
            
            if cell.isCustomSelected {
                selectedRecipientUserIds.remove(member.userId)
            }
            else {
                selectedRecipientUserIds.insert(member.userId)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            
            // If no one selected, close
            // If all ppl selected, close dropdown
            if selectedRecipientUserIds.isEmpty || selectedRecipientUserIds.count == availableFamilyMembers.count {
                dropDown.hideDropDown(animated: true)
            }
            
            // recipient label text changes and disclaimer label maybe appears/disappears
            updateRecipientsLabel()
            updateDisclaimerLabel()
        case .reminderType:
            let type = availableReminderTypes[indexPath.row]
            
            // prevent deselectiong of reminder type. we shuld always have one selected
            guard type != selectedReminderType else {
                return
            }
            
            cell.setCustomSelected(true)
            selectedReminderType = type
            dropDown.hideDropDown(animated: true)
        case .reminderTimeZone:
            guard !cell.isCustomSelected else {
                cell.setCustomSelected(false)
                selectedTimeZone = nil
                return
            }
            
            if let selectedTimeZone = selectedTimeZone,
               let previouslySelectedIndexPath = availableTimeZones.firstIndex(of: selectedTimeZone),
               let previousSelectedCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: previouslySelectedIndexPath, section: 0)) as? HoundDropDownTVC {
                previousSelectedCell.setCustomSelected(false)
            }
            
            cell.setCustomSelected(true)
            
            let timeZone = availableTimeZones[indexPath.row]
            selectedTimeZone = timeZone
            
            timeZoneLabel.errorMessage = nil
            
            onceView.updateDisplayedTimeZone(timeZone)
            // nothing for countdown view
            weeklyView.updateDisplayedTimeZone(timeZone)
            monthlyView.updateDisplayedTimeZone(timeZone)
            
            dropDown.hideDropDown(animated: true)
        }
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
            guard let identifier = identifier as? DogsAddReminderDropDownTypes else { return nil }
            switch identifier {
            case .reminderAction:
                return selectedReminderActionIndexPath
            case .reminderRecipients:
                if let idx = selectedRecipientUserIds
                    .compactMap({ userId in availableFamilyMembers.firstIndex(where: { $0.userId == userId }) })
                    .min() {
                    return IndexPath(row: idx, section: 0)
                }
            case .reminderType:
                if let idx = availableReminderTypes.firstIndex(of: selectedReminderType) {
                    return IndexPath(row: idx, section: 0)
                }
            case .reminderTimeZone:
                if let selectedTZ = selectedTimeZone,
                   let idx = availableTimeZones.firstIndex(where: { tz in
                       return tz.identifier == selectedTZ.identifier
                   }) {
                    return IndexPath(row: idx, section: 0)
                }
            }
            return nil
        }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(reminderActionStack)
        addSubview(reminderRecipientsStack)
        addSubview(reminderTypeStack)
        addSubview(reminderViewsStack)
        addSubview(timeZoneStack)
        
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
    
    private func remakeTimeZoneConstraints() {
        let shouldHideTimeZone = timeZoneLabel.isHidden || timeZoneStack.isHidden
        
        // they might conflict in the process of updating
        reminderViewsStack.snp.removeConstraints()
        timeZoneStack.snp.removeConstraints()
        timeZoneLabel.snp.removeConstraints()
        
        reminderViewsStack.snp.remakeConstraints { make in
            make.top.equalTo(reminderTypeStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
            if shouldHideTimeZone {
                make.bottom.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteVertInset)
            }
        }
        
        timeZoneStack.snp.remakeConstraints { make in
            if !shouldHideTimeZone {
                make.top.equalTo(reminderViewsStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
                make.bottom.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteVertInset)
                make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
                make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
            }
        }
        
        timeZoneLabel.snp.remakeConstraints { make in
            if !shouldHideTimeZone {
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
        
        reminderTypeStack.snp.makeConstraints { make in
            make.top.equalTo(reminderRecipientsStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        reminderTypeLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        remakeTimeZoneConstraints()
    }
    
}
