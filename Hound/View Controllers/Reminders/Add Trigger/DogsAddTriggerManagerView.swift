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
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddTriggerDropDownTypes.logReactions,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .logReactions, label: label)
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
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: DogsAddTriggerDropDownTypes.reminderResult,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .reminderResult, label: label)
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
    
    private var availableLogReactions: [TriggerLogReaction] = []
    private var selectedLogReactions: [TriggerLogReaction] = []
    
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
        
        let reminderActionType = ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId)
        let customName = reminderActionType.allowsCustom ? (reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") : ""
        trigger.triggerReminderResult = TriggerReminderResult(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId, forReminderCustomActionName: customName)
        
        if segmentedControl.selectedSegmentIndex == SegmentedControlSection.timeDelay.rawValue {
            trigger.triggerType = .timeDelay
            let component = timeDelayView.currentComponent
            if !trigger.timeDelayComponents.changeTriggerTimeDelay(forTimeDelay: component.triggerTimeDelay) {
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
            if !trigger.fixedTimeComponents.changeFixedTimeHour(forHour: component.triggerFixedTimeHour) ||
                !trigger.fixedTimeComponents.changeFixedTimeMinute(forMinute: component.triggerFixedTimeMinute) ||
                !trigger.fixedTimeComponents.changeTriggerFixedTimeTypeAmount(forAmount: component.triggerFixedTimeTypeAmount) {
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
            timeDelayView.setup(forDelegate: self, forComponents: forTriggerToUpdate?.timeDelayComponents)
        }
        else {
            timeDelayView.setup(forDelegate: self, forComponents: nil)
        }
        
        if forTriggerToUpdate?.triggerType == .fixedTime {
            fixedTimeView.setup(forDelegate: self, forComponents: forTriggerToUpdate?.fixedTimeComponents)
        }
        else {
            fixedTimeView.setup(forDelegate: self, forComponents: nil)
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
            case .logReactions: return CGFloat(availableLogReactions.count)
            case .reminderResult: return CGFloat(availableReminderResults.count)
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
            cell.setCustomSelectedTableViewCell(forSelected: selected, animated: false)
        case .reminderResult:
            let item = availableReminderResults[indexPath.row]
            cell.label.text = item.readableName
            let selected = selectedReminderResult?.isSame(as: item) ?? false
            cell.setCustomSelectedTableViewCell(forSelected: selected, animated: false)
        }
    }
    
    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? DogsAddTriggerDropDownTypes else { return 0 }
        switch type {
        case .logReactions:
            return availableLogReactions.count
        case .reminderResult:
            return availableReminderResults.count
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
                cell.setCustomSelectedTableViewCell(forSelected: false)
                selectedLogReactions.remove(at: index)
                
                if reaction.logCustomActionName.hasText() {
                    // Deselect parent if needed
                    if let parentIndex = self.availableLogReactions.firstIndex(where: { $0.logActionTypeId == reaction.logActionTypeId && !$0.logCustomActionName.hasText() }),
                       let selectedParentIndex = indexOfReaction(self.availableLogReactions[parentIndex]) {
                        selectedLogReactions.remove(at: selectedParentIndex)
                        if let parentCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: parentIndex, section: 0)) as? HoundDropDownTVC {
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
                        if let childCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelectedTableViewCell(forSelected: false)
                        }
                    }
                }
            }
            else {
                // Selecting reaction
                cell.setCustomSelectedTableViewCell(forSelected: true)
                selectedLogReactions.append(reaction)
                logReactionsLabel.errorMessage = nil
                
                if reaction.logCustomActionName.hasText() == false {
                    // Selecting parent selects all children
                    for (idx, item) in self.availableLogReactions.enumerated() where item.logActionTypeId == reaction.logActionTypeId && item.logCustomActionName.hasText() {
                        if indexOfReaction(item) == nil {
                            selectedLogReactions.append(item)
                        }
                        if let childCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: idx, section: 0)) as? HoundDropDownTVC {
                            childCell.setCustomSelectedTableViewCell(forSelected: true)
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
                cell.setCustomSelectedTableViewCell(forSelected: false)
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
                previousSelectedCell?.setCustomSelectedTableViewCell(forSelected: false)
            }
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            reminderResultLabel.errorMessage = nil
            selectedReminderResult = availableReminderResults[indexPath.row]
            
            if let selectedReminderResult = selectedReminderResult, ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId).allowsCustom {
                // If custom action is allowed, begin editing textField
                reminderCustomActionNameTextField.text = selectedReminderResult.reminderCustomActionName
            }
            
            updateDynamicUIElements()
            
            dropDown.hideDropDown(animated: true)
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
