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
    case triggerType = "DropDownTriggerType"
}
final class DogsAddTriggerManagerView: HoundView,
                                       UIGestureRecognizerDelegate,
                                       DogsAddTriggerTimeDelayViewDelegate,
                                       DogsAddTriggerFixedTimeViewDelegate,
                                       HoundDropDownDataSource,
                                       HoundDropDownManagerDelegate {
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Delegate Methods
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }

    func didUpdateDescriptionLabel() {
        updateTriggerTypeDescriptionLabel()
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
        label.placeholder = "Select one or more types..."
        label.shouldInsetText = true
        label.adjustsFontSizeToFitWidth = false
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddTriggerDropDownTypes.logReactions,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .logReactions, label: label, autoscroll: .firstOpen)
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
        label.text = "If This Log Was..."
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
        label.text = "Then Create This Reminder"
        return label
    }()
    private lazy var reminderResultLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a reminder type..."
        label.shouldInsetText = true
        label.adjustsFontSizeToFitWidth = false
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddTriggerDropDownTypes.reminderResult,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderResult, label: label, autoscroll: .firstOpen)
        return label
    }()
    private lazy var reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField()
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

    private let triggerTypeHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "When Should the Reminder Be Sent?"
        return label
    }()
    private lazy var triggerTypeLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddTriggerDropDownTypes.triggerType,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .triggerType, label: label, autoscroll: .firstOpen)
        return label
    }()
    private let triggerTypeDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    private lazy var nestedTriggerTypeStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(triggerTypeLabel)
        stack.addArrangedSubview(triggerTypeDescriptionLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    private lazy var triggerTypeStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(triggerTypeHeaderLabel)
        stack.addArrangedSubview(nestedTriggerTypeStack)
        return stack
    }()
    
     private lazy var timeDelayView: DogsAddTriggerTimeDelayView = {
        let view = DogsAddTriggerTimeDelayView()
        view.isHidden = selectedTriggerType != .timeDelay
        
        let timeDelayTap = UITapGestureRecognizer(target: self, action: #selector(didInteractWithTimeDelayView))
        timeDelayTap.delegate = self
        timeDelayTap.cancelsTouchesInView = false
        view.addGestureRecognizer(timeDelayTap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var fixedTimeView: DogsAddTriggerFixedTimeView = {
        let view = DogsAddTriggerFixedTimeView()
        view.isHidden = selectedTriggerType != .fixedTime
        
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
    
    private lazy var dropDownManager = HoundDropDownManager<DogsAddTriggerDropDownTypes>(
        rootView: self,
        dataSource: self,
        delegate: self
    )
    
    @objc private func didToggleSwitch(_ sender: Any) {
        if sender as? HoundSwitch == manuallyCreatedSwitch || sender as? HoundSwitch == createdByAlarmSwitch {
            if manuallyCreatedSwitch.isOn || createdByAlarmSwitch.isOn {
                nestedConditionsStack.errorMessage = nil
            }
        }
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
    
    private var availableLogReactions: [TriggerLogReaction] = []
    private var selectedLogReactions: [TriggerLogReaction] = []
    
    private var availableReminderResults: [TriggerReminderResult] = []
    private var selectedReminderResult: TriggerReminderResult?
    private let availableTriggerTypes: [TriggerType] = TriggerType.allCases
    private var selectedTriggerType: TriggerType = Constant.Class.Trigger.defaultTriggerType {
        didSet {
            triggerTypeLabel.text = selectedTriggerType.readable
            timeDelayView.isHidden = selectedTriggerType != .timeDelay
            fixedTimeView.isHidden = selectedTriggerType != .fixedTime
            updateTriggerTypeDescriptionLabel()
        }
    }
    
    var didUpdateInitialValues: Bool {
        guard let initialTrigger = initialTrigger else {
            // creating new trigger right now, so return true
            return true
        }
        
        guard let newTrigger = constructTrigger(showErrorIfFailed: false) else {
            // new trigger has invalid settings so show warning abt exiting
            // we have an initialTrigger, so user HAS to be editing, and if newTrigger couldn't be saved then user input an invalid setting
            return false
        }
        
        return !initialTrigger.isSame(as: newTrigger)
    }
    
    // MARK: - Function
    
    // Construct trigger based on current selections
    func constructTrigger(showErrorIfFailed: Bool) -> Trigger? {
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        
        guard trigger.setTriggerLogReactions(selectedLogReactions) else {
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
        
        let reminderActionType = ReminderActionType.find(reminderActionTypeId: selectedReminderResult.reminderActionTypeId)
        let customName = reminderActionType.allowsCustom ? (reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") : ""
        trigger.triggerReminderResult = TriggerReminderResult(reminderActionTypeId: selectedReminderResult.reminderActionTypeId, reminderCustomActionName: customName)
        
        if selectedTriggerType == .timeDelay {
            trigger.triggerType = .timeDelay
            let component = timeDelayView.currentComponent
            if !trigger.timeDelayComponents.changeTriggerTimeDelay(component.triggerTimeDelay) {
                            if showErrorIfFailed {
                                HapticsManager.notification(.error)
                                timeDelayView.errorMessage = Constant.Error.TriggerError.timeDelayInvalid
                            }
                            return nil
                        }
        }
        else {
            trigger.triggerType = .fixedTime
            let component = fixedTimeView.currentComponent
            if !trigger.fixedTimeComponents.changeFixedTimeHour(component.triggerFixedTimeHour) ||
                !trigger.fixedTimeComponents.changeFixedTimeMinute(component.triggerFixedTimeMinute) ||
                !trigger.fixedTimeComponents.changeTriggerFixedTimeTypeAmount(component.triggerFixedTimeTypeAmount) {
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
        updateTriggerTypeDescriptionLabel()
        
        let customActionNameIsHidden = !(selectedReminderResult.map { ReminderActionType.find(reminderActionTypeId: $0.reminderActionTypeId).allowsCustom } ?? false)
        if reminderCustomActionNameTextField.isHidden != customActionNameIsHidden {
            reminderCustomActionNameTextField.isHidden = customActionNameIsHidden
            remakeCustomActionNameConstraints()
        }
        
        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    private func updateTriggerTypeDescriptionLabel() {
        switch selectedTriggerType {
        case .timeDelay:
            triggerTypeDescriptionLabel.text = timeDelayView.descriptionLabelText
        case .fixedTime:
            triggerTypeDescriptionLabel.text = fixedTimeView.descriptionLabelText
        }
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    // MARK: - Setup
    
    func setup(dog: Dog?, triggerToUpdate: Trigger?) {
        self.dog = dog
        self.triggerToUpdate = triggerToUpdate
        initialTrigger = triggerToUpdate?.copy() as? Trigger
        
        availableLogReactions = []
        let logs = dog?.dogLogs.dogLogs ?? []
        for type in GlobalTypes.shared.logActionTypes {
            availableLogReactions.append(
                TriggerLogReaction(logActionTypeId: type.logActionTypeId)
            )
            var seen = Set<String>()
            for log in logs where log.logActionTypeId == type.logActionTypeId {
                let name = log.logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard type.allowsCustom, !name.isEmpty else { continue }
                if seen.insert(name).inserted {
                    availableLogReactions.append(
                        TriggerLogReaction(logActionTypeId: type.logActionTypeId, logCustomActionName: name)
                    )
                }
                if seen.count >= PreviousLogCustomActionName.maxStored { break }
            }
            
        }
        
        manuallyCreatedSwitch.isOn = triggerToUpdate?.triggerManualCondition ?? Constant.Class.Trigger.defaultTriggerManualCondition
        createdByAlarmSwitch.isOn = triggerToUpdate?.triggerAlarmCreatedCondition ?? Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
        
        // Build available reminder results
        availableReminderResults = []
        let reminders = dog?.dogReminders.dogReminders ?? []
        for type in GlobalTypes.shared.reminderActionTypes {
            availableReminderResults.append(
                TriggerReminderResult(reminderActionTypeId: type.reminderActionTypeId)
            )
            var seen = Set<String>()
            for reminder in reminders where reminder.reminderActionTypeId == type.reminderActionTypeId {
                let name = reminder.reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard type.allowsCustom, !name.isEmpty else { continue }
                if seen.insert(name).inserted {
                    availableReminderResults.append(
                        TriggerReminderResult(reminderActionTypeId: type.reminderActionTypeId, reminderCustomActionName: name)
                    )
                }
                if seen.count >= PreviousReminderCustomActionName.maxStored { break }
            }
        }
        
        if let trigger = triggerToUpdate {
            selectedLogReactions = trigger.triggerLogReactions
            selectedReminderResult = trigger.triggerReminderResult
            selectedTriggerType = trigger.triggerType
        }
        else {
            selectedTriggerType = Constant.Class.Trigger.defaultTriggerType
        }
        
        if triggerToUpdate?.triggerType == .timeDelay {
            timeDelayView.setup(delegate: self, components: triggerToUpdate?.timeDelayComponents)
        }
        else {
            timeDelayView.setup(delegate: self, components: nil)
        }
        
        if triggerToUpdate?.triggerType == .fixedTime {
            fixedTimeView.setup(delegate: self, components: triggerToUpdate?.fixedTimeComponents)
        }
        else {
            fixedTimeView.setup(delegate: self, components: nil)
        }
        
        updateDynamicUIElements()
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
        if selectedLogReactions.isEmpty && selectedReminderResult == nil {
            willShowDropDown(DogsAddTriggerDropDownTypes.logReactions, animated: animated)
        }
        else if selectedReminderResult == nil {
            willShowDropDown(DogsAddTriggerDropDownTypes.reminderResult, animated: animated)
        }
    }
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let type = identifier as? DogsAddTriggerDropDownTypes else { return }
        
        let numberOfRows: CGFloat = {
            switch type {
            case .logReactions:
                return CGFloat(availableLogReactions.count)
            case .reminderResult:
                return CGFloat(availableReminderResults.count)
            case .triggerType:
                return CGFloat(availableTriggerTypes.count)
            }
        }()
        
        dropDownManager.show(
            identifier: type,
            numberOfRowsToShow: min(6.5, numberOfRows),
            animated: animated
        )
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? DogsAddTriggerDropDownTypes else { return }
        
        switch type {
        case .logReactions:
            let item = availableLogReactions[indexPath.row]
            cell.label.text = item.readableName(includeMatchingEmoji: true)
            let selected = selectedLogReactions.contains(item)
            cell.setCustomSelected(selected, animated: false)
        case .reminderResult:
            let item = availableReminderResults[indexPath.row]
            cell.label.text = item.readableName
            let selected = selectedReminderResult?.isSame(as: item) ?? false
            cell.setCustomSelected(selected, animated: false)
        case .triggerType:
            let type = availableTriggerTypes[indexPath.row]
            cell.label.text = type.readable
            cell.setCustomSelected(selectedTriggerType == type, animated: false)
        }
    }
    
    func numberOfRows(section: Int, identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? DogsAddTriggerDropDownTypes else { return 0 }
        switch type {
        case .logReactions:
            return availableLogReactions.count
        case .reminderResult:
            return availableReminderResults.count
        case .triggerType:
            return availableTriggerTypes.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? DogsAddTriggerDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type) else { return }
        guard let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        
        switch type {
        case .logReactions:
            let beforeSelectNumberOfLogReactions = selectedLogReactions.count
            let reaction = availableLogReactions[indexPath.row]
            
            let indexOfReaction = { (target: TriggerLogReaction) -> Int? in
                return self.selectedLogReactions.firstIndex { $0 === target }
            }
            
            if let index = indexOfReaction(reaction) {
                // Deselecting reaction
                cell.setCustomSelected(false)
                selectedLogReactions.remove(at: index)
                
                if reaction.logCustomActionName.hasText() {
                    // Deselect parent if needed
                    if let parentIndex = self.availableLogReactions.firstIndex(where: { $0.logActionTypeId == reaction.logActionTypeId && !$0.logCustomActionName.hasText() }),
                       let selectedParentIndex = indexOfReaction(self.availableLogReactions[parentIndex]) {
                        selectedLogReactions.remove(at: selectedParentIndex)
                        if let parentCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: parentIndex, section: 0)) as? HoundDropDownTVC {
                            parentCell.setCustomSelected(false)
                        }
                    }
                }
                else {
                    // Deselect all children when deselecting parent
                    for (idx, item) in self.availableLogReactions.enumerated() where item.logActionTypeId == reaction.logActionTypeId && item.logCustomActionName.hasText() {
                        if let selectedIdx = indexOfReaction(item) {
                            selectedLogReactions.remove(at: selectedIdx)
                        }
                        if let childCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelected(false)
                        }
                    }
                }
            }
            else {
                // Selecting reaction
                cell.setCustomSelected(true)
                selectedLogReactions.append(reaction)
                logReactionsLabel.errorMessage = nil
                
                if reaction.logCustomActionName.hasText() == false {
                    // Selecting parent selects all children
                    for (idx, item) in self.availableLogReactions.enumerated() where item.logActionTypeId == reaction.logActionTypeId && item.logCustomActionName.hasText() {
                        if indexOfReaction(item) == nil {
                            selectedLogReactions.append(item)
                        }
                        if let childCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelected(true)
                        }
                    }
                }
            }
            
            updateDynamicUIElements()
            
            if beforeSelectNumberOfLogReactions == 0 || selectedLogReactions.count == availableLogReactions.count {
                // selected their first log action
                // selected every log reaction
                dropDown.hideDropDown(animated: true)
                showNextRequiredDropDown(animated: true)
            }
        case .reminderResult:
            let beforeSelection = selectedReminderResult
            
            guard cell.isCustomSelected == false else {
                cell.setCustomSelected(false)
                selectedReminderResult = nil
                updateDynamicUIElements()
                return
            }
            
            if let previousSelected = availableReminderResults.firstIndex(where: { reminderResult in
                return reminderResult.reminderActionTypeId == selectedReminderResult?.reminderActionTypeId
                && ((selectedReminderResult?.reminderCustomActionName.hasText() ?? false)
                    ? reminderResult.reminderCustomActionName == selectedReminderResult?.reminderCustomActionName
                    : true)
            }) {
                let previouslySelectedIndexPath = IndexPath(row: previousSelected, section: 0)
                let previousSelectedCell = dropDown.dropDownTableView?.cellForRow(at: previouslySelectedIndexPath) as? HoundDropDownTVC
                previousSelectedCell?.setCustomSelected(false)
            }
            
            cell.setCustomSelected(true)
            reminderResultLabel.errorMessage = nil
            selectedReminderResult = availableReminderResults[indexPath.row]
            
            if let selectedReminderResult = selectedReminderResult, ReminderActionType.find(reminderActionTypeId: selectedReminderResult.reminderActionTypeId).allowsCustom {
                // If custom action is allowed, begin editing textField
                reminderCustomActionNameTextField.text = selectedReminderResult.reminderCustomActionName
            }
            
            updateDynamicUIElements()
            
            dropDown.hideDropDown(animated: true)
            if beforeSelection == nil && !reminderCustomActionNameTextField.isFirstResponder {
                // First-time selection of reminder result, so open next dropdown
                showNextRequiredDropDown(animated: true)
            }
        case .triggerType:
            let type = availableTriggerTypes[indexPath.row]
            
            // prevent deselectiong of trigger type. we shuld always have one selected
            guard type != selectedTriggerType else {
                return
            }
            
            cell.setCustomSelected(true)
            selectedTriggerType = type
            dropDown.hideDropDown(animated: true)
        }
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
            guard let type = identifier as? DogsAddTriggerDropDownTypes else { return nil }
            switch type {
            case .logReactions:
                if let idx = selectedLogReactions
                    .compactMap({ reaction in availableLogReactions.firstIndex(where: { $0.isSame(as: reaction)}) })
                    .min() {
                    return IndexPath(row: idx, section: 0)
                }
            case .reminderResult:
                if let result = selectedReminderResult,
                   let idx = availableReminderResults.firstIndex(where: { $0.isSame(as: result) }) {
                    return IndexPath(row: idx, section: 0)
                }
            case .triggerType:
                if let idx = TriggerType.allCases.firstIndex(of: selectedTriggerType) {
                    return IndexPath(row: idx, section: 0)
                }
            }
            return nil
        }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logReactionStack)
        addSubview(conditionsStack)
        addSubview(reminderResultStack)
        addSubview(triggerTypeStack)
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

        triggerTypeStack.snp.makeConstraints { make in
            make.top.equalTo(reminderResultStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalToSuperview().offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        triggerTypeLabel.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        triggerViewsStack.snp.makeConstraints { make in
            make.top.equalTo(triggerTypeStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
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
