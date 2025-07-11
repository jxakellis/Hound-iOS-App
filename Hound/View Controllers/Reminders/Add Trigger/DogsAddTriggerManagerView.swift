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
    
    private var dog: Dog = Dog()
    private var triggerToUpdate: Trigger?
    private var dropDownLogAction: HoundDropDown?
    private var dropDownReminderAction: HoundDropDown?
    // TODO TRIGGERS needs multiple selections
    private var selectedLogActionTypes: [LogActionType] = []
    private var selectedLogCustomActionsNames: [String] = []
    private var selectedReminderActionType: ReminderActionType?
    
    // Construct trigger based on current selections
    var currentTrigger: Trigger? {
        guard let selectedLogActionTypes = selectedLogActionTypes, let selectedReminderActionType = selectedReminderActionType else { return nil }
        
        let trigger: Trigger = triggerToUpdate?.copy() as? Trigger ?? Trigger()
        
        
        trigger.setLogActionReactions(forLogActionReactions: [logAction.logActionTypeId])
        trigger.resultReminderActionTypeId = reminderAction.reminderActionTypeId
        if segmentedControl.selectedSegmentIndex == SegmentedControlSection.timeDelay.rawValue {
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
    
    func setup(forDog: Dog, forTriggerToUpdate: Trigger?) {
        dog = forDog
        triggerToUpdate = forTriggerToUpdate
        if let trigger = forTriggerToUpdate {
            selectedLogActionTypes = trigger.reactionLogActionTypeIds.map({ LogActionType.find(forLogActionTypeId: $0)})
            if let reactionLogActionTypeId = trigger.reactionLogActionTypeIds.first {
                logActionLabel.text = LogActionType.find(forLogActionTypeId: reactionLogActionTypeId).convertToReadableName(customActionName: nil)
            }
            
            selectedReminderActionType = ReminderActionType.find(forReminderActionTypeId: trigger.resultReminderActionTypeId)
            reminderActionLabel.text = ReminderActionType.find(forReminderActionTypeId: trigger.resultReminderActionTypeId).convertToReadableName(customActionName: nil)
            
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
        
        didUpdateTriggerType(segmentedControl)
        timeDelayView.setup(forDelegate: self, forTimeDelay: forTriggerToUpdate?.triggerTimeDelay)
        // TODO this needs to pass the right TOD
        fixedTimeView.setup(forDelegate: self, forDaysOffset: forTriggerToUpdate?.triggerFixedTimeTypeAmount, forTimeOfDay: Date())
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    private func updateLogActionLabel() {
        logActionLabel.text = selectedLogActionTypes.sorted()
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
        if dropDown.isDown { dropDown.hideDropDown(animated: true) }
        else { dropDown.showDropDown(numberOfRowsToShow: 6.5, animated: true) }
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let custom = cell as? HoundDropDownTableViewCell else { return }
        custom.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        if dropDownUIViewIdentifier == "LOG" {
            custom.label.text = GlobalTypes.shared.logActionTypes[indexPath.row].convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
            custom.setCustomSelectedTableViewCell(forSelected: selectedLogActionType == GlobalTypes.shared.logActionTypes[indexPath.row])
        }
        else {
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
        }
        else {
            selectedReminderActionType = GlobalTypes.shared.reminderActionTypes[indexPath.row]
            reminderActionLabel.text = selectedReminderActionType?.convertToReadableName(customActionName: nil)
            dropDownReminderAction?.hideDropDown(animated: true)
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(logActionHeaderLabel)
        addSubview(logActionLabel)
        addSubview(reminderActionHeaderLabel)
        addSubview(reminderActionLabel)
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
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
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
