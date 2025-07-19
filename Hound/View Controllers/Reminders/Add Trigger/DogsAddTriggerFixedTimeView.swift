//
//  DogsAddTriggerFixedTimeView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddTriggerFixedTimeViewDelegate: AnyObject {
    func willDismissKeyboard()
}

enum DogsAddTriggerFixedTimeDropDownTypes: String {
    case dayOffset = "DropDownDayOffset"
}

final class DogsAddTriggerFixedTimeView: HoundView, HoundDropDownDataSource, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Elements
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var dayOffsetLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select the day offset..."
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown))
        gesture.name = DogsAddTriggerFixedTimeDropDownTypes.dayOffset.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    
    private lazy var timeOfDayPicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 250, compressionResistancePriority: 250)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = DevelopmentConstant.triggerMinuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        return datePicker
    }()
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        self.errorMessage = nil
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddTriggerFixedTimeViewDelegate?
    
    private var dropDownDayOffset: HoundDropDown?
    private var selectedDropDownDayOffsetIndexPath: IndexPath?
    private var selectedDayOffset: Int = 0
    private let availableDayOffsets = [0, 1, 2, 3, 4, 5, 6, 7]
    
    var currentOffset: Int { selectedDayOffset }
    var currentTimeOfDay: Date { timeOfDayPicker.date }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddTriggerFixedTimeViewDelegate, forDaysOffset: Int?, forTimeOfDay: Date?) {
        delegate = forDelegate
        
        let index = forDaysOffset ?? selectedDayOffset
        selectedDayOffset = index
        selectedDropDownDayOffsetIndexPath = IndexPath(row: index, section: 0)
        dayOffsetLabel.text = textForOffset(index)
        
        timeOfDayPicker.date = forTimeOfDay ?? timeOfDayPicker.date
        
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        // Reminder will go off on the same day as the matching log at
        // Reminder will go off 2 days after the matching log
        var text = "Reminder will go off "
        
        switch selectedDayOffset {
        case 0: text += "on the same day as the log "
        case 1: text += "the day after the log "
        default: text += "\(selectedDayOffset) days after the log "
        }
        
        text += "at \(timeOfDayPicker.date.formatted(date: .omitted, time: .shortened))"
        
        var emphasizedText: String?
        if selectedDayOffset == 0 {
            emphasizedText = ". If the time has passed, reminder rolls over to the next day"
        }
        let precalculatedDynamicTextColor = UIColor.label
        
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message = NSMutableAttributedString(
                string: text,
                attributes: [.font: VisualConstant.FontConstant.secondaryRegularLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
            )
            
            if let emphasizedText = emphasizedText {
                message.append(NSMutableAttributedString(
                    string: emphasizedText,
                    attributes: [.font: VisualConstant.FontConstant.emphasizedSecondaryRegularLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
                )
            }
            return message
        }
    }
    
    private func textForOffset(_ offset: Int) -> String {
        switch offset {
        case 0: return "Same Day"
        case 1: return "Next Day"
        default: return "After \(offset) Days"
        }
    }
    
    // MARK: - Drop Down Handling
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return }
        
        // If a dropDownDayOffset exists, hide it unless tap is on its label or itself
        if let dd = dropDownDayOffset, !touched.isDescendant(of: dayOffsetLabel) && !touched.isDescendant(of: dd) {
            
            dd.hideDropDown(animated: true)
        }
        
        // Dismiss keyboard if tap was outside text inputs
        dismissKeyboard()
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        guard let name = sender.name,
              let targetType = DogsAddTriggerFixedTimeDropDownTypes(rawValue: name) else { return }
        
        let targetDropDown = dropDown(forDropDownType: targetType)
        
        self.errorMessage = nil
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given dropDownType, return the corresponding dropDownDayOffset UIView
    private func dropDown(forDropDownType type: DogsAddTriggerFixedTimeDropDownTypes) -> HoundDropDown? {
        switch type {
        case .dayOffset: return dropDownDayOffset
        }
    }
    
    /// For a given dropDownType, return the label that triggers it
    private func labelForDropDown(forDropDownType type: DogsAddTriggerFixedTimeDropDownTypes) -> HoundLabel {
        switch type {
        case .dayOffset: return dayOffsetLabel
        }
    }
    
    /// Show or hide the dropdown for the given type
    private func showDropDown(_ type: DogsAddTriggerFixedTimeDropDownTypes, animated: Bool) {
        let label = labelForDropDown(forDropDownType: type)
        let superview = label.superview
        let dropDowns = [dropDownDayOffset]
        
        // work around: ui element or error message couldve been added which is higher in the view than dropdown since dropdown last opened
        // ensure that dropdowns are on top (and in correct order relative to other drop downs)
        dropDowns.forEach { dropDownDayOffset in
            dropDownDayOffset?.removeFromSuperview()
        }
        dropDowns.reversed().forEach { dropDownDayOffset in
            if let dropDownDayOffset = dropDownDayOffset, let superview = superview {
                superview.addSubview(dropDownDayOffset)
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
            case .dayOffset: dropDownDayOffset = targetDropDown
            }
            if let superview = superview, let targetDropDown = targetDropDown {
                superview.addSubview(targetDropDown)
            }
        }
        
        targetDropDown?.showDropDown(
            numberOfRowsToShow: min(6.5, {
                switch type {
                case .dayOffset:
                    return CGFloat(availableDayOffsets.count)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let cell = cell as? HoundDropDownTableViewCell else { return }
        cell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        cell.label.text = textForOffset(availableDayOffsets[indexPath.row])
        
        if indexPath.row == selectedDayOffset {
            cell.setCustomSelectedTableViewCell(forSelected: true)
        }
        else {
            cell.setCustomSelectedTableViewCell(forSelected: false)
        }
        
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        switch dropDownUIViewIdentifier {
        case DogsAddTriggerFixedTimeDropDownTypes.dayOffset.rawValue:
            return availableDayOffsets.count
        default:
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        // TODO BUG THIS ISNT GETTING INVOKED AND CANT SELECT ITEMS
        print("selectItemInDropDown: \(indexPath) for \(dropDownUIViewIdentifier)")
        switch dropDownUIViewIdentifier {
        case DogsAddTriggerFixedTimeDropDownTypes.dayOffset.rawValue:
            if let previousSelectedIndexPath = selectedDropDownDayOffsetIndexPath, let previousSelectedCell = dropDownDayOffset?.dropDownTableView?.cellForRow(at: previousSelectedIndexPath) as? HoundDropDownTableViewCell {
                previousSelectedCell.setCustomSelectedTableViewCell(forSelected: false)
            }
            if let selectedCell = dropDownDayOffset?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
                selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            }
            selectedDropDownDayOffsetIndexPath = indexPath
            let dayOffset = indexPath.row
            selectedDayOffset = dayOffset
            dayOffsetLabel.text = textForOffset(availableDayOffsets[dayOffset])
            
            dropDownDayOffset?.hideDropDown(animated: true)
            delegate?.willDismissKeyboard()
            
            updateDescriptionLabel()
        default:
            return
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(descriptionLabel)
        addSubview(dayOffsetLabel)
        addSubview(timeOfDayPicker)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // dayOffsetLabel
        NSLayoutConstraint.activate([
            dayOffsetLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            dayOffsetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            dayOffsetLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            dayOffsetLabel.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            dayOffsetLabel.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            timeOfDayPicker.topAnchor.constraint(equalTo: dayOffsetLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            timeOfDayPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -200.0),
            timeOfDayPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayPicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayPicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
        
    }
}
