//
//  DogsAddTriggerManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

enum DogsAddTriggerDropDownTypes: String, HoundDropDownType {
    case logReactions = "DropDownLogReactions"
    case reminderResult = "DropDownReminderResult"
}

final class DogsAddTriggerManagerView: HoundView, UIGestureRecognizerDelegate, DogsAddTriggerTimeDelayViewDelegate, DogsAddTriggerFixedTimeViewDelegate, HoundDropDownDataSource {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Delegate Methods
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }
    
    // MARK: - Elements
    
    private let logReactionsHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "When This Log is Added"
        return label
    }()
    private lazy var logReactionsLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select log type(s)..."
        label.shouldInsetText = true
        label.adjustsFontSizeToFitWidth = false
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = DogsAddTriggerDropDownTypes.logReactions.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    private lazy var logReactionStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(logReactionsHeaderLabel)
        stack.addArrangedSubview(logReactionsLabel)
        return stack
    }()
    
    private let conditionsHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Matching These Conditions"
        return label
    }()
    private let manuallyCreatedLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 250, compressionResistancePriority: 250)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.textColor = .label
        label.text = "Added Manually"
        return label
    }()
    private let createdByAlarmLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 250, compressionResistancePriority: 250)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.textColor = .label
        label.text = "Added by Alarm"
        return label
    }()
    private lazy var manuallyCreatedSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        return uiSwitch
    }()
    private lazy var createdByAlarmSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        return uiSwitch
    }()
    private lazy var nestedConditionsStack: HoundStackView = {
        let manuallyCreatedStack = HoundStackView()
        manuallyCreatedStack.addArrangedSubview(manuallyCreatedLabel)
        manuallyCreatedStack.addArrangedSubview(manuallyCreatedSwitch)
        manuallyCreatedStack.axis = .horizontal
        manuallyCreatedStack.alignment = .center
        manuallyCreatedStack.spacing = Constant.Constraint.Spacing.contentIntraHori
        
        let createdByAlarmStack = HoundStackView()
        createdByAlarmStack.addArrangedSubview(createdByAlarmLabel)
        createdByAlarmStack.addArrangedSubview(createdByAlarmSwitch)
        createdByAlarmStack.axis = .horizontal
        createdByAlarmStack.alignment = .center
        createdByAlarmStack.spacing = Constant.Constraint.Spacing.contentIntraHori
        
        let nestedStack = HoundStackView()
        nestedStack.addArrangedSubview(manuallyCreatedStack)
        nestedStack.addArrangedSubview(createdByAlarmStack)
        nestedStack.axis = .vertical
        nestedStack.spacing = Constant.Constraint.Spacing.contentTallIntraVert
        
        nestedStack.errorMessageChangesBorder = false
        
        return nestedStack
    }()
    private lazy var conditionsStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(conditionsHeaderLabel)
        stack.addArrangedSubview(nestedConditionsStack)
        
        return stack
    }()
    
    private let reminderResultHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Then Create Reminder"
        return label
    }()
    private lazy var reminderResultLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select reminder action..."
        label.shouldInsetText = true
        label.adjustsFontSizeToFitWidth = false
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLabelForDropDown(sender:))
        )
        gesture.name = DogsAddTriggerDropDownTypes.reminderResult.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    private lazy var reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField()
        textField.font = Constant.Visual.Font.secondaryRegularLabel
        textField.delegate = self
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = "Add a custom name... (optional)"
        textField.shouldInsetText = true
        return textField
    }()
    private lazy var reminderResultStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(reminderResultHeaderLabel)
        
        let nestedStack = HoundStackView()
        nestedStack.addArrangedSubview(reminderResultLabel)
        nestedStack.addArrangedSubview(reminderCustomActionNameTextField)
        nestedStack.axis = .vertical
        nestedStack.spacing = Constant.Constraint.Spacing.contentIntraVert
        
        stack.addArrangedSubview(nestedStack)
        
        return stack
    }()
    
    private enum SegmentedControlSection: Int, CaseIterable {
        case timeDelay
        case fixedTime
        
        var title: String {
            switch self {
            case .timeDelay: return "After a Delay"
            case .fixedTime: return "At a Specific Time"
            }
        }
        
        static func index(of section: SegmentedControlSection) -> Int { section.rawValue }
    }
    
    private lazy var segmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        SegmentedControlSection.allCases.enumerated().forEach { index, section in
            segmentedControl.insertSegment(withTitle: section.title, at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        
        segmentedControl.selectedSegmentIndex = SegmentedControlSection.timeDelay.rawValue
        
        segmentedControl.addTarget(self, action: #selector(didUpdateTriggerType), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var timeDelayView: DogsAddTriggerTimeDelayView = {
        let view = DogsAddTriggerTimeDelayView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.timeDelay.rawValue
        
        let timeDelayTap = UITapGestureRecognizer(target: self, action: #selector(didInteractWithTimeDelayView))
        timeDelayTap.delegate = self
                timeDelayTap.cancelsTouchesInView = false
        view.addGestureRecognizer(timeDelayTap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var fixedTimeView: DogsAddTriggerFixedTimeView = {
        let view = DogsAddTriggerFixedTimeView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.fixedTime.rawValue
        
        let fixedTimeTap = UITapGestureRecognizer(target: self, action: #selector(didInteractWithFixedTimeView))
        fixedTimeTap.delegate = self
        fixedTimeTap.cancelsTouchesInView = false
        view.addGestureRecognizer(fixedTimeTap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var triggerViewsStack: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [timeDelayView, fixedTimeView])
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didToggleSwitch(_ sender: Any) {
        if sender as? HoundSwitch == manuallyCreatedSwitch || sender as? HoundSwitch == createdByAlarmSwitch {
            if manuallyCreatedSwitch.isOn || createdByAlarmSwitch.isOn {
                nestedConditionsStack.errorMessage = nil
            }
        }
    }
    
    @objc private func didUpdateTriggerType(_ sender: HoundSegmentedControl) {
        timeDelayView.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.timeDelay.rawValue
        fixedTimeView.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.fixedTime.rawValue
    }
    
    @objc private func didInteractWithTimeDelayView() {
        timeDelayView.errorMessage = nil
    }
    
    @objc private func didInteractWithFixedTimeView() {
        fixedTimeView.errorMessage = nil
    }
    
    // MARK: - Properties
    
    private var dog: Dog?
    private var initialTrigger: Trigger?
    private var triggerToUpdate: Trigger?
    
    private var dropDownLogReactions: HoundDropDown?
    private var availableLogReactions: [TriggerLogReaction] = []
    private var selectedLogReactions: [TriggerLogReaction] = []
    
    private var dropDownReminderResult: HoundDropDown?
    private var dropDownSelectedReminderIndexPath: IndexPath?
    private var availableReminderResults: [TriggerReminderResult] = []
    private var selectedReminderResult: TriggerReminderResult?
    
    var didUpdateInitialValues: Bool {
        guard let initialTrigger = initialTrigger else {
            // creating new trigger right now, so return true
            return true
        }
        
        guard let triggerToUpdate = triggerToUpdate else {
            // should never happen, if have initialTrigger, then should have triggerToUpdate
            return true
        }
        
        return !initialTrigger.isSame(as: triggerToUpdate)
    }
    
    // MARK: - Function
    
    // Construct trigger based on current selections
    func constructTrigger(showErrorIfFailed: Bool) -> Trigger? {
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        
        guard trigger.setTriggerLogReactions(forTriggerLogReactions: selectedLogReactions) else {
            if showErrorIfFailed {
                HapticsManager.notification(.error)
                logReactionsLabel.errorMessage = Constant.Error.TriggerError.logReactionMissing
            }
            return nil
        }
        
        guard manuallyCreatedSwitch.isOn || createdByAlarmSwitch.isOn else {
            if showErrorIfFailed {
                HapticsManager.notification(.error)
                nestedConditionsStack.errorMessage = Constant.Error.TriggerError.conditionsInvalid
            }
            return nil
        }
        trigger.triggerManualCondition = manuallyCreatedSwitch.isOn
        trigger.triggerAlarmCreatedCondition = createdByAlarmSwitch.isOn
        
        guard let selectedReminderResult = selectedReminderResult else {
            if showErrorIfFailed {
                HapticsManager.notification(.error)
                reminderResultLabel.errorMessage = Constant.Error.TriggerError.reminderResultMissing
            }
            
            return nil
        }
        
        let reminderActionType = ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId)
        let customName = reminderActionType.allowsCustom ? (reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") : ""
        trigger.triggerReminderResult = TriggerReminderResult(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId, forReminderCustomActionName: customName)
        
        if segmentedControl.selectedSegmentIndex == SegmentedControlSection.timeDelay.rawValue {
            trigger.triggerType = .timeDelay
            if !trigger.changeTriggerTimeDelay(forTimeDelay: timeDelayView.currentTimeDelay ?? Constant.Class.Trigger.defaultTriggerTimeDelay) {
                if showErrorIfFailed {
                    HapticsManager.notification(.error)
                    timeDelayView.errorMessage = Constant.Error.TriggerError.timeDelayInvalid
                }
                return nil
            }
        }
        else {
            trigger.triggerType = .fixedTime
            trigger.changeTriggerFixedTimeUTCHour(forDate: fixedTimeView.currentTimeOfDay)
            trigger.changeTriggerFixedTimeUTCMinute(forDate: fixedTimeView.currentTimeOfDay)
            
            if !trigger.changeTriggerFixedTimeTypeAmount(forAmount: fixedTimeView.currentOffset) {
                if showErrorIfFailed {
                    HapticsManager.notification(.error)
                    fixedTimeView.errorMessage = Constant.Error.TriggerError.fixedTimeTypeAmountInvalid
                }
                return nil
            }
        }
        return trigger
    }
    
    private func updateDynamicUIElements() {
        logReactionsLabel.text = selectedLogReactions.map({ $0.readableName(includeMatchingEmoji: true) }).joined(separator: ", ")
        reminderResultLabel.text = selectedReminderResult?.readableName
        reminderCustomActionNameTextField.text = selectedReminderResult?.reminderCustomActionName
        
        let customActionNameIsHidden = !(selectedReminderResult.map { ReminderActionType.find(forReminderActionTypeId: $0.reminderActionTypeId).allowsCustom } ?? false)
        if reminderCustomActionNameTextField.isHidden != customActionNameIsHidden {
            reminderCustomActionNameTextField.isHidden = customActionNameIsHidden
            remakeCustomActionNameConstraints()
        }
        
        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    // MARK: - Setup
    
    func setup(forDog: Dog?, forTriggerToUpdate: Trigger?) {
        dog = forDog
        triggerToUpdate = forTriggerToUpdate
        initialTrigger = forTriggerToUpdate?.copy() as? Trigger
        
        availableLogReactions = []
        let logs = dog?.dogLogs.dogLogs ?? []
        for type in GlobalTypes.shared.logActionTypes {
            availableLogReactions.append(
                TriggerLogReaction(forLogActionTypeId: type.logActionTypeId)
            )
            var seen = Set<String>()
            for log in logs where log.logActionTypeId == type.logActionTypeId {
                let name = log.logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard type.allowsCustom, !name.isEmpty else { continue }
                if seen.insert(name).inserted {
                    availableLogReactions.append(
                        TriggerLogReaction(forLogActionTypeId: type.logActionTypeId, forLogCustomActionName: name)
                    )
                }
                if seen.count >= PreviousLogCustomActionName.maxStored { break }
            }
            
        }
        
        manuallyCreatedSwitch.isOn = forTriggerToUpdate?.triggerManualCondition ?? Constant.Class.Trigger.defaultTriggerManualCondition
        createdByAlarmSwitch.isOn = forTriggerToUpdate?.triggerAlarmCreatedCondition ?? Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
        
        // Build available reminder results
        availableReminderResults = []
        let reminders = dog?.dogReminders.dogReminders ?? []
        for type in GlobalTypes.shared.reminderActionTypes {
            availableReminderResults.append(
                TriggerReminderResult(forReminderActionTypeId: type.reminderActionTypeId)
            )
            var seen = Set<String>()
            for reminder in reminders where reminder.reminderActionTypeId == type.reminderActionTypeId {
                let name = reminder.reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard type.allowsCustom, !name.isEmpty else { continue }
                if seen.insert(name).inserted {
                    availableReminderResults.append(
                        TriggerReminderResult(forReminderActionTypeId: type.reminderActionTypeId, forReminderCustomActionName: name)
                    )
                }
                if seen.count >= PreviousReminderCustomActionName.maxStored { break }
            }
        }
        
        if let trigger = forTriggerToUpdate {
            selectedLogReactions = trigger.triggerLogReactions
            selectedReminderResult = trigger.triggerReminderResult
            segmentedControl.selectedSegmentIndex = trigger.triggerType == .timeDelay ? SegmentedControlSection.timeDelay.rawValue : SegmentedControlSection.fixedTime.rawValue
        }
        else {
            segmentedControl.selectedSegmentIndex = SegmentedControlSection.timeDelay.rawValue
        }
        
        if forTriggerToUpdate?.triggerType == .timeDelay {
            timeDelayView.setup(forDelegate: self, forTimeDelay: forTriggerToUpdate?.triggerTimeDelay)
        }
        else {
            timeDelayView.setup(forDelegate: self, forTimeDelay: nil)
        }
        
        if forTriggerToUpdate?.triggerType == .fixedTime {
            fixedTimeView.setup(forDelegate: self, forDaysOffset: forTriggerToUpdate?.triggerFixedTimeTypeAmount, forTimeOfDay: forTriggerToUpdate?.nextReminderDate(afterDate: Date()))
        }
        else {
            fixedTimeView.setup(forDelegate: self, forDaysOffset: nil, forTimeOfDay: nil)
        }
        
        updateDynamicUIElements()
    }
    
    // MARK: - Drop Down Handling
    
    @objc func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return }
        
        // If a dropDown exists, hide it unless tap is on its label or itself
        if let dd = dropDownLogReactions, !touched.isDescendant(of: logReactionsLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        if let dd = dropDownReminderResult, !touched.isDescendant(of: reminderResultLabel) && !touched.isDescendant(of: dd) {
            dd.hideDropDown(animated: true)
        }
        
        // Dismiss keyboard if tap was outside text inputs
        dismissKeyboard()
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        guard let name = sender.name,
              let targetType = DogsAddTriggerDropDownTypes(rawValue: name) else { return }
        
        let targetDropDown = dropDown(forDropDownType: targetType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given dropDownType, return the corresponding dropDown UIView
    private func dropDown(forDropDownType type: DogsAddTriggerDropDownTypes) -> HoundDropDown? {
        switch type {
        case .logReactions: return dropDownLogReactions
        case .reminderResult: return dropDownReminderResult
        }
    }
    
    /// For a given dropDownType, return the label that triggers it
    private func labelForDropDown(forDropDownType type: DogsAddTriggerDropDownTypes) -> HoundLabel {
        switch type {
        case .logReactions: return logReactionsLabel
        case .reminderResult: return reminderResultLabel
        }
    }
    
    /// Determine and show the next required dropdown in the log creation flow
    private func showNextRequiredDropDown(animated: Bool) {
        if selectedLogReactions.isEmpty && selectedReminderResult == nil {
            showDropDown(.logReactions, animated: animated)
        }
        else if selectedReminderResult == nil {
            showDropDown(.reminderResult, animated: animated)
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: DogsAddTriggerDropDownTypes, animated: Bool) {
        let label = labelForDropDown(forDropDownType: type)
        var targetDropDown = dropDown(forDropDownType: type)
        
        // cannot insert dropdown inside of a stack, so need basic view
        let rootView = self
        let referenceFrame = label.superview?.convert(label.frame, to: rootView) ?? label.frame
        
        let dropDowns = [dropDownLogReactions, dropDownReminderResult]
        // work around: ui element or error message couldve been added which is higher in the view than dropdown since dropdown last opened
        // ensure that dropdowns are on top (and in correct order relative to other drop downs)
        dropDowns.forEach { dropDown in
            dropDown?.removeFromSuperview()
        }
        dropDowns.reversed().forEach { dropDown in
            if let dropDown = dropDown {
                rootView.addSubview(dropDown)
            }
        }
        
        if targetDropDown == nil {
            targetDropDown = HoundDropDown()
            targetDropDown?.setupDropDown(
                forHoundDropDownIdentifier: type.rawValue,
                forDataSource: self,
                forViewPositionReference: referenceFrame,
                forOffset: 2.5,
                forRowHeight: HoundDropDown.rowHeightForHoundLabel
            )
            switch type {
            case .logReactions: dropDownLogReactions = targetDropDown
            case .reminderResult: dropDownReminderResult = targetDropDown
            }
            if let targetDropDown = targetDropDown {
                rootView.addSubview(targetDropDown)
            }
        }
        
        targetDropDown?.showDropDown(
            numberOfRowsToShow: min(6.5, {
                switch type {
                case .logReactions:
                    return CGFloat(availableLogReactions.count)
                case .reminderResult:
                    return CGFloat(availableReminderResults.count)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let custom = cell as? HoundDropDownTVC else { return }
        custom.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownUIViewIdentifier == DogsAddTriggerDropDownTypes.logReactions.rawValue {
            let item = availableLogReactions[indexPath.row]
            custom.label.text = item.readableName(includeMatchingEmoji: true)
            let selected = selectedLogReactions.contains(item)
            custom.setCustomSelectedTableViewCell(forSelected: selected, animated: false)
        }
        else if dropDownUIViewIdentifier == DogsAddTriggerDropDownTypes.reminderResult.rawValue {
            let item = availableReminderResults[indexPath.row]
            custom.label.text = item.readableName
            let selected = selectedReminderResult?.isSame(as: item) ?? false
            custom.setCustomSelectedTableViewCell(forSelected: selected, animated: false)
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        switch dropDownUIViewIdentifier {
        case DogsAddTriggerDropDownTypes.logReactions.rawValue:
            return availableLogReactions.count
        case DogsAddTriggerDropDownTypes.reminderResult.rawValue:
            return availableReminderResults.count
        default:
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == DogsAddTriggerDropDownTypes.logReactions.rawValue {
            let currentCell = dropDownLogReactions?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC

            let beforeSelectNumberOfLogReactions = selectedLogReactions.count
            let reaction = availableLogReactions[indexPath.row]

            // Helper to find index of a reaction instance in selected array
            let indexOfReaction = { (target: TriggerLogReaction) -> Int? in
                return self.selectedLogReactions.firstIndex { $0 === target }
            }

            if let index = indexOfReaction(reaction) {
                // Deselecting reaction
                currentCell?.setCustomSelectedTableViewCell(forSelected: false)
                selectedLogReactions.remove(at: index)

                if reaction.logCustomActionName.hasText() {
                    // Deselect parent if needed
                    if let parentIndex = self.availableLogReactions.firstIndex(where: { $0.logActionTypeId == reaction.logActionTypeId && !$0.logCustomActionName.hasText() }),
                       let selectedParentIndex = indexOfReaction(self.availableLogReactions[parentIndex]) {
                        selectedLogReactions.remove(at: selectedParentIndex)
                        if let parentCell = dropDownLogReactions?.dropDownTableView?.cellForRow(at: IndexPath(row: parentIndex, section: 0)) as? HoundDropDownTVC {
                            parentCell.setCustomSelectedTableViewCell(forSelected: false)
                        }
                    }
                }
                else {
                    // Deselect all children when deselecting parent
                    for (idx, item) in self.availableLogReactions.enumerated() where item.logActionTypeId == reaction.logActionTypeId && item.logCustomActionName.hasText() {
                        if let selectedIdx = indexOfReaction(item) {
                            selectedLogReactions.remove(at: selectedIdx)
                        }
                        if let childCell = dropDownLogReactions?.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelectedTableViewCell(forSelected: false)
                        }
                    }
                }
            }
            else {
                // Selecting reaction
                currentCell?.setCustomSelectedTableViewCell(forSelected: true)
                selectedLogReactions.append(reaction)
                logReactionsLabel.errorMessage = nil

                if reaction.logCustomActionName.hasText() == false {
                    // Selecting parent selects all children
                    for (idx, item) in self.availableLogReactions.enumerated() where item.logActionTypeId == reaction.logActionTypeId && item.logCustomActionName.hasText() {
                        if indexOfReaction(item) == nil {
                            selectedLogReactions.append(item)
                        }
                        if let childCell = dropDownLogReactions?.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelectedTableViewCell(forSelected: true)
                        }
                    }
                }
            }

            updateDynamicUIElements()

            if beforeSelectNumberOfLogReactions == 0 {
                // selected their first log action
                dropDownLogReactions?.hideDropDown(animated: true)
                showNextRequiredDropDown(animated: true)
            }
            else if selectedLogReactions.count == availableLogReactions.count {
                // selected every log reaction
                dropDownLogReactions?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == DogsAddTriggerDropDownTypes.reminderResult.rawValue {
            let currentCell = dropDownReminderResult?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC
            let beforeSelection = selectedReminderResult
            
            guard currentCell?.isCustomSelected == false else {
                currentCell?.setCustomSelectedTableViewCell(forSelected: false)
                dropDownSelectedReminderIndexPath = nil
                selectedReminderResult = nil
                updateDynamicUIElements()
                return
            }
            
            if let previous = dropDownSelectedReminderIndexPath,
               let previousCell = dropDownReminderResult?.dropDownTableView?.cellForRow(at: previous) as? HoundDropDownTVC {
                previousCell.setCustomSelectedTableViewCell(forSelected: false)
            }
            
            currentCell?.setCustomSelectedTableViewCell(forSelected: true)
            reminderResultLabel.errorMessage = nil
            
            dropDownSelectedReminderIndexPath = indexPath
            selectedReminderResult = availableReminderResults[indexPath.row]
            
            if let selectedReminderResult = selectedReminderResult, ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId).allowsCustom {
                // If custom action is allowed, begin editing textField
                reminderCustomActionNameTextField.text = selectedReminderResult.reminderCustomActionName
                reminderCustomActionNameTextField.becomeFirstResponder()
            }
            
            updateDynamicUIElements()
            
            dropDownReminderResult?.hideDropDown(animated: true)
            if beforeSelection == nil && !reminderCustomActionNameTextField.isFirstResponder {
                // First-time selection of reminder result, so open next dropdown
                showNextRequiredDropDown(animated: true)
            }
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logReactionStack)
        addSubview(conditionsStack)
        addSubview(reminderResultStack)
        addSubview(segmentedControl)
        addSubview(triggerViewsStack)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        addGestureRecognizer(didTapScreenGesture)
    }
    
    private func remakeCustomActionNameConstraints() {
        reminderCustomActionNameTextField.snp.remakeConstraints { make in
            if !reminderCustomActionNameTextField.isHidden {
                make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        logReactionStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        logReactionsLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        conditionsStack.snp.makeConstraints { make in
            make.top.equalTo(logReactionStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            // add extra inset for the switches inside
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        }
        
        reminderResultStack.snp.makeConstraints { make in
            make.top.equalTo(conditionsStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        reminderResultLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        remakeCustomActionNameConstraints()
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(reminderResultStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset / 2.0)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset / 2.0)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.segmentedHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        triggerViewsStack.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.bottom.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension DogsAddTriggerManagerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(); return false
    }
}
