//
//  DogsAddTriggerManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsAddTriggerManagerView: HoundView, UIGestureRecognizerDelegate, DogsAddTriggerTimeDelayViewDelegate, DogsAddTriggerFixedTimeViewDelegate, HoundDropDownDataSource {
    
    // MARK: - Delegate Methods
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }
    
    // MARK: - Elements
    
    private let logActionHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 305, compressionResistancePriority: 305)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "When This Log is Added"
        return label
    }()
    private lazy var logActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select log type(s)..."
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(_:)))
        gesture.name = "Log"
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    
    private let reminderActionHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 295, compressionResistancePriority: 295)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryRegularLabel
        label.textColor = .label
        label.text = "Then Create Reminder"
        return label
    }()
    private lazy var reminderActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select reminder action..."
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(_:)))
        gesture.name = "Reminder"
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
        return view
    }()
    
    private lazy var fixedTimeView: DogsAddTriggerFixedTimeView = {
        let view = DogsAddTriggerFixedTimeView()
        view.isHidden = segmentedControl.selectedSegmentIndex != SegmentedControlSection.fixedTime.rawValue
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
    
    // MARK: - Properties
    
    private var dog: Dog?
    private var triggerToUpdate: Trigger?
    
    private var dropDownLogReactions: HoundDropDown?
    private var availableLogReactions: [TriggerLogReaction] = []
    private var selectedLogReactions: [TriggerLogReaction] = []
    
    private var dropDownReminderAction: HoundDropDown?
    private var dropDownSelectedReminderIndexPath: IndexPath?
    private var availableReminderResults: [TriggerReminderResult] = []
    private var selectedReminderResult: TriggerReminderResult?
    
    // Construct trigger based on current selections
    var currentTrigger: Trigger? {
        // TODO TRIGGER throw errors if conditions are failed
        guard let selectedReminderResult = selectedReminderResult else { return nil }
        
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        
        guard trigger.setTriggerLogReactions(forTriggerLogReactions: selectedLogReactions) else { return nil }
        let reminderActionType = ReminderActionType.find(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId)
        let customName = reminderActionType.allowsCustom ? (reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") : ""
        trigger.triggerReminderResult = TriggerReminderResult(forReminderActionTypeId: selectedReminderResult.reminderActionTypeId, forReminderCustomActionName: customName)
        if segmentedControl.selectedSegmentIndex == SegmentedControlSection.timeDelay.rawValue {
            trigger.triggerType = .timeDelay
            trigger.changeTriggerTimeDelay(forTimeDelay: timeDelayView.currentTimeDelay ?? ClassConstant.TriggerConstant.defaultTriggerTimeDelay)
        }
        else {
            trigger.triggerType = .fixedTime
            trigger.changeTriggerFixedTimeTypeAmount(forAmount: fixedTimeView.currentOffset)
            trigger.changeTriggerFixedTimeUTCHour(forDate: fixedTimeView.currentTimeOfDay)
            trigger.changeTriggerFixedTimeUTCMinute(forDate: fixedTimeView.currentTimeOfDay)
        }
        return trigger
    }
    
    // MARK: - Setup
    
    func setup(forDog: Dog?, forTriggerToUpdate: Trigger?) {
        dog = forDog
        triggerToUpdate = forTriggerToUpdate
        
        availableLogReactions = GlobalTypes.shared.logActionTypes.map { TriggerLogReaction(forLogActionTypeId: $0.logActionTypeId, forLogCustomActionName: nil) }
        var customPairs: [(LogActionType, String)] = []
        var seen = Set<String>()
        for availableLogActionReaction in availableLogReactions {
            let identifier = "\(availableLogActionReaction.logActionTypeId)-\(availableLogActionReaction.logCustomActionName)"
            seen.insert(identifier)
        }
        
        for log in (dog?.dogLogs.dogLogs ?? []) {
            let type = LogActionType.find(forLogActionTypeId: log.logActionTypeId)
            let name = log.logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard type.allowsCustom, !name.isEmpty else { continue }
            let identifier = "\(type.logActionTypeId)-\(name)"
            if seen.insert(identifier).inserted {
                customPairs.append((type, name))
            }
            
        }
        customPairs.sort { $0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending }
        availableLogReactions += customPairs.map { TriggerLogReaction(forLogActionTypeId: $0.0.logActionTypeId, forLogCustomActionName: $0.1) }
        
        // Build available reminder results
        availableReminderResults = GlobalTypes.shared.reminderActionTypes.map {
            TriggerReminderResult(forReminderActionTypeId: $0.reminderActionTypeId, forReminderCustomActionName: "")
        }
        var reminderPairs: [(ReminderActionType, String)] = []
        var seenReminder = Set<String>()
        for result in availableReminderResults {
            let identifier = "\(result.reminderActionTypeId)-\(result.reminderCustomActionName)"
            seenReminder.insert(identifier)
        }
        for reminder in (dog?.dogReminders.dogReminders ?? []) {
            let type = ReminderActionType.find(forReminderActionTypeId: reminder.reminderActionTypeId)
            let name = reminder.reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard type.allowsCustom, !name.isEmpty else { continue }
            let identifier = "\(type.reminderActionTypeId)-\(name)"
            if seenReminder.insert(identifier).inserted {
                reminderPairs.append((type, name))
            }
        }
        reminderPairs.sort { $0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending }
        availableReminderResults += reminderPairs.map { TriggerReminderResult(forReminderActionTypeId: $0.0.reminderActionTypeId, forReminderCustomActionName: $0.1) }
        
        if let trigger = forTriggerToUpdate {
            selectedLogReactions = trigger.triggerLogReactions
            selectedReminderResult = trigger.triggerReminderResult
            reminderActionLabel.text = selectedReminderResult?.readableName
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
        
        timeDelayView.setup(forDelegate: self, forTimeDelay: forTriggerToUpdate?.triggerTimeDelay)
        // TODO this needs to pass the right TOD
        fixedTimeView.setup(forDelegate: self, forDaysOffset: forTriggerToUpdate?.triggerFixedTimeTypeAmount, forTimeOfDay: Date())
        updateDynamicUIElements()
        
    }
    
    private func updateDynamicUIElements() {
        logActionLabel.text = selectedLogReactions.map({ $0.readableName }).joined(separator: ", ")
        
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
    
    @objc private func didTapLabelForDropDown(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
        guard let label = sender.view as? HoundLabel else { return }
        
        if label == logActionLabel {
            if dropDownLogReactions == nil {
                let dd = HoundDropDown()
                dd.setupDropDown(forHoundDropDownIdentifier: "LOG", forDataSource: self, forViewPositionReference: label.frame, forOffset: 2.5, forRowHeight: HoundDropDown.rowHeightForHoundLabel)
                addSubview(dd)
                dropDownLogReactions = dd
            }
            toggle(dropDown: dropDownLogReactions!)
        }
        else if label == reminderActionLabel {
            if dropDownReminderAction == nil {
                let dd = HoundDropDown()
                dd.setupDropDown(forHoundDropDownIdentifier: "REM", forDataSource: self, forViewPositionReference: label.frame, forOffset: 2.5, forRowHeight: HoundDropDown.rowHeightForHoundLabel)
                addSubview(dd)
                dropDownReminderAction = dd
            }
            toggle(dropDown: dropDownReminderAction!)
        }
    }
    
    private func toggle(dropDown: HoundDropDown) {
        if dropDown.isDown {
            dropDown.hideDropDown(animated: true)
        }
        else {
            dropDown.showDropDown(numberOfRowsToShow: 6.5, animated: true)
        }
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let custom = cell as? HoundDropDownTableViewCell else { return }
        custom.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        if dropDownUIViewIdentifier == "LOG" {
            let item = availableLogReactions[indexPath.row]
            custom.label.text = item.readableName
            let selected = selectedLogReactions.contains(item)
            custom.setCustomSelectedTableViewCell(forSelected: selected)
        }
        else {
            let item = availableReminderResults[indexPath.row]
            custom.label.text = item.readableName
            let selected = selectedReminderResult?.isSame(as: item) ?? false
            custom.setCustomSelectedTableViewCell(forSelected: selected)
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "LOG" {
            return availableLogReactions.count
        }
        return GlobalTypes.shared.reminderActionTypes.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int { 1 }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "LOG" {
            let beforeSelectNumberOfLogReactions = selectedLogReactions.count
            let reaction = availableLogReactions[indexPath.row]
            if let index = selectedLogReactions.firstIndex(where: { $0.logActionTypeId == reaction.logActionTypeId && $0.logCustomActionName == reaction.logCustomActionName }) {
                selectedLogReactions.remove(at: index)
            }
            else {
                selectedLogReactions.append(reaction)
            }
            updateDynamicUIElements()
            
            if beforeSelectNumberOfLogReactions == 0 {
                // selected their first log action
                dropDownLogReactions?.hideDropDown(animated: true)
            }
            else if selectedLogReactions.count == availableLogReactions.count {
                // selected every log reaction
                dropDownLogReactions?.hideDropDown(animated: true)
            }
        }
        else {
            if let previous = dropDownSelectedReminderIndexPath,
               let previousCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: previous) as? HoundDropDownTableViewCell {
                previousCell.setCustomSelectedTableViewCell(forSelected: false)
            }
            if let currentCell = dropDownReminderAction?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
                currentCell.setCustomSelectedTableViewCell(forSelected: true)
            }
            dropDownSelectedReminderIndexPath = indexPath
            
            selectedReminderResult = availableReminderResults[indexPath.row]
            reminderActionLabel.text = selectedReminderResult?.readableName
            reminderCustomActionNameTextField.text = selectedReminderResult?.reminderCustomActionName
            dropDownReminderAction?.hideDropDown(animated: true)
            updateDynamicUIElements()
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logActionHeaderLabel)
        addSubview(logActionLabel)
        addSubview(reminderActionHeaderLabel)
        addSubview(reminderActionLabel)
        addSubview(reminderCustomActionNameTextField)
        addSubview(segmentedControl)
        addSubview(triggerViewsStack)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            logActionHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            logActionHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logActionHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        NSLayoutConstraint.activate([
            logActionLabel.topAnchor.constraint(equalTo: logActionHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logActionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            logActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            reminderActionHeaderLabel.topAnchor.constraint(equalTo: logActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderActionHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: reminderActionHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            reminderActionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            reminderActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
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
