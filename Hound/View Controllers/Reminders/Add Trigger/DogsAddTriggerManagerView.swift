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
    
    // TODO TRIGGGERS these placeholders need to be changed to accurately reflect what these fields are
    private lazy var logActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select log type..."
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(_:)))
        gesture.name = "Log"
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    
    private var logCustomNameTop: GeneralLayoutConstraint!
    private var logCustomNameHeight: GeneralLayoutConstraint!
    private var logCustomNameMaxHeight: GeneralLayoutConstraint!
    private lazy var logCustomNameTextField: HoundTextField = {
        // TODO TRIGGERS there should really be a way to do multiple custom names
        let textField = HoundTextField(huggingPriority: 280, compressionResistancePriority: 280)
        textField.delegate = self
        textField.applyStyle(.thinGrayBorder)
        textField.placeholder = " Add a custom name..."
        return textField
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
    
    private lazy var triggerTypeSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        segmentedControl.insertSegment(withTitle: "Time Delay", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Fixed Time", at: 1, animated: false)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.addTarget(self, action: #selector(didUpdateTriggerType), for: .valueChanged)
        return segmentedControl
    }()
    
    private let timeDelayView = DogsAddTriggerTimeDelayView()
    private let fixedTimeView = DogsAddTriggerFixedTimeView()
    private lazy var triggerViewsStack: HoundStackView = {
        let stack = HoundStackView(arrangedSubviews: [timeDelayView, fixedTimeView])
        stack.axis = .vertical
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didUpdateTriggerType(_ sender: UISegmentedControl) {
        timeDelayView.isHidden = !(sender.selectedSegmentIndex == 0)
        fixedTimeView.isHidden = !(sender.selectedSegmentIndex == 1)
    }
    
    // MARK: - Properties
    
    private var triggerToUpdate: Trigger?
    private var dropDownLogAction: HoundDropDown?
    private var dropDownReminderAction: HoundDropDown?
    // TODO TRIGGERS needs multiple selections
    private var selectedLogActionType: LogActionType?
    private var selectedReminderActionType: ReminderActionType?
    
    // Construct trigger based on current selections
    var currentTrigger: Trigger? {
        guard let logAction = selectedLogActionType, let reminderAction = selectedReminderActionType else { return nil }
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        trigger.setLogActionReactions(forLogActionReactions: [logAction.logActionTypeId])
        if logAction.allowsCustom {
            let name = logCustomNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            trigger.setLogCustomActionNameReactions(forLogCustomActionNameReactions: [name])
        }
        trigger.resultReminderActionTypeId = reminderAction.reminderActionTypeId
        if triggerTypeSegmentedControl.selectedSegmentIndex == 0 {
            trigger.triggerType = .timeDelay
            trigger.changeTriggerTimeDelay(forTimeDelay: timeDelayView.currentTimeDelay ?? ClassConstant.TriggerConstant.defaultTriggerTimeDelay)
        }
        else {
            trigger.triggerType = .fixedTime
            trigger.triggerFixedTimeType = .day
            trigger.changeTriggerFixedTimeTypeAmount(forAmount: fixedTimeView.currentOffset)
            trigger.changeTriggerFixedTimeUTCHour(forDate: fixedTimeView.currentTimeOfDay)
            trigger.changeTriggerFixedTimeUTCMinute(forDate: fixedTimeView.currentTimeOfDay)
        }
        return trigger
    }
    
    // MARK: - Setup
    
    func setup(forTriggerToUpdate trigger: Trigger?) {
        triggerToUpdate = trigger
        if let trigger = trigger {
            if let reactionLogActionTypeId = trigger.reactionLogActionTypeIds.first {
                selectedLogActionType = LogActionType.find(forLogActionTypeId: reactionLogActionTypeId)
                logActionLabel.text = LogActionType.find(forLogActionTypeId: reactionLogActionTypeId).convertToReadableName(customActionName: nil)
            }
            
            selectedReminderActionType = ReminderActionType.find(forReminderActionTypeId: trigger.resultReminderActionTypeId)
            reminderActionLabel.text = ReminderActionType.find(forReminderActionTypeId: trigger.resultReminderActionTypeId).convertToReadableName(customActionName: nil)
            
            if trigger.triggerType == .fixedTime {
                triggerTypeSegmentedControl.selectedSegmentIndex = 1
            }
            else {
                triggerTypeSegmentedControl.selectedSegmentIndex = 0
            }
        }
        else {
            triggerTypeSegmentedControl.selectedSegmentIndex = 0
        }
        didUpdateTriggerType(triggerTypeSegmentedControl)
        timeDelayView.setup(forDelegate: self, forTimeDelay: trigger?.triggerTimeDelay)
        fixedTimeView.setup(forDelegate: self, forDaysOffset: trigger?.triggerFixedTimeTypeAmount, forTimeOfDay: Date())
        updateDynamicUIElements()
    }
    
    private func updateDynamicUIElements() {
        let hidden = selectedLogActionType?.allowsCustom != true
        logCustomNameTextField.isHidden = hidden
        if hidden {
            logCustomNameHeight.setMultiplier(0.0)
            logCustomNameMaxHeight.constant = 0.0
            logCustomNameTop.constant = 0.0
        }
        else {
            logCustomNameHeight.restore()
            logCustomNameMaxHeight.restore()
            logCustomNameTop.restore()
        }
        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideSingleElement) {
            self.setNeedsLayout(); self.layoutIfNeeded()
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
            if dropDownLogAction == nil {
                let dd = HoundDropDown()
                dd.setupDropDown(forHoundDropDownIdentifier: "LOG", forDataSource: self, forViewPositionReference: label.frame, forOffset: 2.5, forRowHeight: HoundDropDown.rowHeightForHoundLabel)
                addSubview(dd)
                dropDownLogAction = dd
            }
            toggle(dropDown: dropDownLogAction!)
        } else if label == reminderActionLabel {
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
        if dropDown.isDown { dropDown.hideDropDown(animated: true) } else { dropDown.showDropDown(numberOfRowsToShow: 6.5, animated: true) }
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let custom = cell as? HoundDropDownTableViewCell else { return }
        custom.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        if dropDownUIViewIdentifier == "LOG" {
            custom.label.text = GlobalTypes.shared.logActionTypes[indexPath.row].convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            custom.setCustomSelectedTableViewCell(forSelected: selectedLogActionType == GlobalTypes.shared.logActionTypes[indexPath.row])
        } else {
            custom.label.text = GlobalTypes.shared.reminderActionTypes[indexPath.row].convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            custom.setCustomSelectedTableViewCell(forSelected: selectedReminderActionType == GlobalTypes.shared.reminderActionTypes[indexPath.row])
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "LOG" {
            return GlobalTypes.shared.logActionTypes.count
        }
        return GlobalTypes.shared.reminderActionTypes.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int { 1 }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "LOG" {
            selectedLogActionType = GlobalTypes.shared.logActionTypes[indexPath.row]
            logActionLabel.text = selectedLogActionType?.convertToReadableName(customActionName: nil)
            dropDownLogAction?.hideDropDown(animated: true)
        } else {
            selectedReminderActionType = GlobalTypes.shared.reminderActionTypes[indexPath.row]
            reminderActionLabel.text = selectedReminderActionType?.convertToReadableName(customActionName: nil)
            dropDownReminderAction?.hideDropDown(animated: true)
        }
        updateDynamicUIElements()
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logActionLabel)
        addSubview(logCustomNameTextField)
        addSubview(reminderActionLabel)
        addSubview(triggerTypeSegmentedControl)
        addSubview(triggerViewsStack)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            logActionLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            logActionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            logActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        logCustomNameTop = GeneralLayoutConstraint(logCustomNameTextField.topAnchor.constraint(equalTo: logActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))
        logCustomNameHeight = GeneralLayoutConstraint(logCustomNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self))
        logCustomNameMaxHeight = GeneralLayoutConstraint(logCustomNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        
        NSLayoutConstraint.activate([
            logCustomNameTop.constraint,
            logCustomNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            logCustomNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logCustomNameHeight.constraint,
            logCustomNameMaxHeight.constraint
        ])
        
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: logCustomNameTextField.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            reminderActionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            reminderActionLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            reminderActionLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            triggerTypeSegmentedControl.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            triggerTypeSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            triggerTypeSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset / 2.0),
            triggerTypeSegmentedControl.createHeightMultiplier(ConstraintConstant.Input.segmentedHeightMultiplier, relativeToWidthOf: self),
            triggerTypeSegmentedControl.createMaxHeight(ConstraintConstant.Input.segmentedMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            triggerViewsStack.topAnchor.constraint(equalTo: triggerTypeSegmentedControl.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
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
