//
//  DogsAddTriggerManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogsAddTriggerDropDownTypes: String {
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
        let label = HoundLabel(huggingPriority: 305, compressionResistancePriority: 305)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "When This Log is Added"
        return label
    }()
    private lazy var logReactionsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select log type(s)..."
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
    
    private let reminderResultHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 295, compressionResistancePriority: 295)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Then Create Reminder"
        return label
    }()
    private lazy var reminderResultLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select reminder action..."
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
    
    private var reminderCustomActionNameTop: GeneralLayoutConstraint!
    private var reminderCustomActionNameHeightMultiplier: GeneralLayoutConstraint!
    private var reminderCustomActionNameMaxHeight: GeneralLayoutConstraint!
    private lazy var reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 285, compressionResistancePriority: 285)
        textField.delegate = self
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = " Add a custom name..."
        return textField
    }()
    
    private enum SegmentedControlSection: Int, CaseIterable {
        case timeDelay
        case fixedTime
        
        var title: String {
            switch self {
            case .timeDelay: return "Time Delay"
            case .fixedTime: return "Fixed Time"
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
        
        let attributes: [NSAttributedString.Key: Any] = [.font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
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
        view.addGestureRecognizer(timeDelayTap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var fixedTimeView: DogsAddTriggerFixedTimeView = {
        let view = DogsAddTriggerFixedTimeView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.fixedTime.rawValue
        
        let fixedTimeTap = UITapGestureRecognizer(target: self, action: #selector(didInteractWithFixedTimeView))
        view.addGestureRecognizer(fixedTimeTap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var triggerViewsStack: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [timeDelayView, fixedTimeView])
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didUpdateTriggerType(_ sender: UISegmentedControl) {
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
    private var triggerToUpdate: Trigger?
    
    private var dropDownLogReactions: HoundDropDown?
    private var availableLogReactions: [TriggerLogReaction] = []
    private var selectedLogReactions: [TriggerLogReaction] = []
    
    private var dropDownReminderResult: HoundDropDown?
    private var dropDownSelectedReminderIndexPath: IndexPath?
    private var availableReminderResults: [TriggerReminderResult] = []
    private var selectedReminderResult: TriggerReminderResult?
    
    // Construct trigger based on current selections
    var currentTrigger: Trigger? {
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        
        guard trigger.setTriggerLogReactions(forTriggerLogReactions: selectedLogReactions) else {
            logReactionsLabel.errorMessage = ErrorConstant.TriggerError.logReactionMissing().description
            return nil
        }
        
        guard let selectedReminderResult = selectedReminderResult else {
            reminderResultLabel.errorMessage = ErrorConstant.TriggerError.reminderResultMissing().description
            return nil
        }
        
        let reminderActionType = ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId)
        let customName = reminderActionType.allowsCustom ? (reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") : ""
        trigger.triggerReminderResult = TriggerReminderResult(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId, forReminderCustomActionName: customName)
        
        if segmentedControl.selectedSegmentIndex == SegmentedControlSection.timeDelay.rawValue {
            trigger.triggerType = .timeDelay
            if !trigger.changeTriggerTimeDelay(forTimeDelay: timeDelayView.currentTimeDelay ?? ClassConstant.TriggerConstant.defaultTriggerTimeDelay) {
                timeDelayView.errorMessage = ErrorConstant.TriggerError.timeDelayInvalid().description
                return nil
            }
        }
        else {
            trigger.triggerType = .fixedTime
            trigger.changeTriggerFixedTimeUTCHour(forDate: fixedTimeView.currentTimeOfDay)
            trigger.changeTriggerFixedTimeUTCMinute(forDate: fixedTimeView.currentTimeOfDay)
            
            if !trigger.changeTriggerFixedTimeTypeAmount(forAmount: fixedTimeView.currentOffset) {
                fixedTimeView.errorMessage = ErrorConstant.TriggerError.fixedTimeTypeAmountInvalid().description
                return nil
            }
        }
        return trigger
    }
    
    // MARK: - Setup
    
    func setup(forDog: Dog?, forTriggerToUpdate: Trigger?) {
        dog = forDog
        triggerToUpdate = forTriggerToUpdate
        
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
                if seen.count >= 5 { break }
            }
            
        }
        
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
                if seen.count >= 5 { break }
            }
        }
        
        if let trigger = forTriggerToUpdate {
            selectedLogReactions = trigger.triggerLogReactions
            selectedReminderResult = trigger.triggerReminderResult
            reminderResultLabel.text = selectedReminderResult?.readableName
            reminderCustomActionNameTextField.text = selectedReminderResult?.reminderCustomActionName
            
            if trigger.triggerType == .timeDelay {
                segmentedControl.selectedSegmentIndex = SegmentedControlSection.timeDelay.rawValue
            }
            else {
                segmentedControl.selectedSegmentIndex = SegmentedControlSection.fixedTime.rawValue
            }
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
    
    private func updateDynamicUIElements() {
        logReactionsLabel.text = selectedLogReactions.map({ $0.readableName }).joined(separator: ", ")
        
        let allowsCustom = selectedReminderResult.map {
            ReminderActionType.find(forReminderActionTypeId: $0.reminderActionTypeId).allowsCustom
        } ?? false
        
        reminderCustomActionNameTextField.isHidden = !allowsCustom
        if allowsCustom {
            reminderCustomActionNameHeightMultiplier.restore()
            reminderCustomActionNameMaxHeight.restore()
            reminderCustomActionNameTop.restore()
        }
        else {
            reminderCustomActionNameHeightMultiplier.setMultiplier(0.0)
            reminderCustomActionNameMaxHeight.constant = 0.0
            reminderCustomActionNameTop.constant = 0.0
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
        if selectedLogReactions.isEmpty {
            showDropDown(.logReactions, animated: animated)
        }
        else if selectedReminderResult == nil {
            showDropDown(.reminderResult, animated: animated)
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: DogsAddTriggerDropDownTypes, animated: Bool) {
        let label = labelForDropDown(forDropDownType: type)
        let superview = label.superview
        let dropDowns = [dropDownLogReactions, dropDownReminderResult]
        
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
            case .logReactions: dropDownLogReactions = targetDropDown
            case .reminderResult: dropDownReminderResult = targetDropDown
            }
            if let superview = superview, let targetDropDown = targetDropDown {
                superview.addSubview(targetDropDown)
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
        guard let custom = cell as? HoundDropDownTableViewCell else { return }
        custom.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownUIViewIdentifier == DogsAddTriggerDropDownTypes.logReactions.rawValue {
            let item = availableLogReactions[indexPath.row]
            custom.label.text = item.readableName
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
            let currentCell = dropDownLogReactions?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell
            
            let beforeSelectNumberOfLogReactions = selectedLogReactions.count
            let reaction = availableLogReactions[indexPath.row]
            
            if let index = selectedLogReactions.firstIndex(where: { $0.logActionTypeId == reaction.logActionTypeId && $0.logCustomActionName == reaction.logCustomActionName }) {
                currentCell?.setCustomSelectedTableViewCell(forSelected: false)
                selectedLogReactions.remove(at: index)
            }
            else {
                currentCell?.setCustomSelectedTableViewCell(forSelected: true)
                selectedLogReactions.append(reaction)
                logReactionsLabel.errorMessage = nil
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
            if let previous = dropDownSelectedReminderIndexPath,
               let previousCell = dropDownReminderResult?.dropDownTableView?.cellForRow(at: previous) as? HoundDropDownTableViewCell {
                previousCell.setCustomSelectedTableViewCell(forSelected: false)
            }
            if let currentCell = dropDownReminderResult?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
                currentCell.setCustomSelectedTableViewCell(forSelected: true)
                reminderResultLabel.errorMessage = nil
            }
            dropDownSelectedReminderIndexPath = indexPath
            
            selectedReminderResult = availableReminderResults[indexPath.row]
            reminderResultLabel.text = selectedReminderResult?.readableName
            reminderCustomActionNameTextField.text = selectedReminderResult?.reminderCustomActionName
            
            updateDynamicUIElements()
            
            dropDownReminderResult?.hideDropDown(animated: true)
            showNextRequiredDropDown(animated: true)
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logReactionsHeaderLabel)
        addSubview(logReactionsLabel)
        addSubview(reminderResultHeaderLabel)
        addSubview(reminderResultLabel)
        addSubview(reminderCustomActionNameTextField)
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
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            logReactionsHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            logReactionsHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logReactionsHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        NSLayoutConstraint.activate([
            logReactionsLabel.topAnchor.constraint(equalTo: logReactionsHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logReactionsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logReactionsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logReactionsLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            logReactionsLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            reminderResultHeaderLabel.topAnchor.constraint(equalTo: logReactionsLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderResultHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderResultHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        NSLayoutConstraint.activate([
            reminderResultLabel.topAnchor.constraint(equalTo: reminderResultHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            reminderResultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderResultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            reminderResultLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            reminderResultLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        reminderCustomActionNameTop = GeneralLayoutConstraint(reminderCustomActionNameTextField.topAnchor.constraint(equalTo: reminderResultLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        reminderCustomActionNameHeightMultiplier = GeneralLayoutConstraint(reminderCustomActionNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self))
        reminderCustomActionNameMaxHeight = GeneralLayoutConstraint(reminderCustomActionNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        NSLayoutConstraint.activate([
            reminderCustomActionNameTop.constraint,
            reminderCustomActionNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            reminderCustomActionNameHeightMultiplier.constraint,
            reminderCustomActionNameMaxHeight.constraint
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: reminderCustomActionNameTextField.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            segmentedControl.createHeightMultiplier(ConstraintConstant.Input.segmentedHeightMultiplier, relativeToWidthOf: self),
            segmentedControl.createMaxHeight(ConstraintConstant.Input.segmentedMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            triggerViewsStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            triggerViewsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            triggerViewsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            triggerViewsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
    }
}

extension DogsAddTriggerManagerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(); return false
    }
}
