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

final class DogsAddTriggerFixedTimeView: HoundView, HoundDropDownDataSource {
    
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
    
    @objc private func didTapLabelForDropDown() {
        self.errorMessage = nil
        // TODO destroy the drop down everytime as if the label above changes, then the forViewPositionReference changes so the current drop down has the wrong position
        delegate?.willDismissKeyboard()
        if dropDown == nil {
            let dd = HoundDropDown()
            dd.setupDropDown(forHoundDropDownIdentifier: "DropDownOffset", forDataSource: self, forViewPositionReference: dayOffsetLabel.frame, forOffset: 2.5, forRowHeight: HoundDropDown.rowHeightForHoundLabel)
            addSubview(dd)
            dropDown = dd
        }
        if dropDown?.isDown == true {
            dropDown?.hideDropDown(animated: true)
        }
        else {
            dropDown?.showDropDown(numberOfRowsToShow: 6.5, animated: true)
        }
    }
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        self.errorMessage = nil
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddTriggerFixedTimeViewDelegate?
    
    private var dropDown: HoundDropDown?
    private var selectedIndex: Int = 0
    private let offsetOptions = [0, 1, 2, 3, 4, 5, 6, 7]
    
    var currentOffset: Int { selectedIndex }
    var currentTimeOfDay: Date { timeOfDayPicker.date }
    
    private var initialDaysOffset: Int = 0
    private var initialTimeOfDay: Date?
    
    var didUpdateInitialValues: Bool {
        if initialDaysOffset != selectedIndex { return true }
        if let initDate = initialTimeOfDay, initDate != currentTimeOfDay { return true }
        return false
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddTriggerFixedTimeViewDelegate, forDaysOffset: Int?, forTimeOfDay: Date?) {
        delegate = forDelegate
        
        initialDaysOffset = forDaysOffset ?? initialDaysOffset
        selectedIndex = forDaysOffset ?? initialDaysOffset
        dayOffsetLabel.text = textForOffset(selectedIndex)
        
        timeOfDayPicker.date = forTimeOfDay ?? timeOfDayPicker.date
        initialTimeOfDay = forTimeOfDay ?? timeOfDayPicker.date
        
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        // Reminder will go off on the same day as the matching log at
        // Reminder will go off 2 days after the matching log
        var text = "Reminder will go off "
        
        switch selectedIndex {
        case 0: text += "on the same day as the log "
        case 1: text += "the day after the log "
        default: text += "\(selectedIndex) days after the log "
        }
        
        text += "at \(timeOfDayPicker.date.formatted(date: .omitted, time: .shortened))"
        
        var emphasizedText: String?
        if selectedIndex == 0 {
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
    
    // MARK: - DropDown Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let cell = cell as? HoundDropDownTableViewCell else { return }
        cell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        cell.label.text = textForOffset(offsetOptions[indexPath.row])
        if indexPath.row == selectedIndex {
            cell.setCustomSelectedTableViewCell(forSelected: true)
        }
        else {
            cell.setCustomSelectedTableViewCell(forSelected: false)
        }
        
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        return offsetOptions.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    // TODO BUG CANT SELECT THINGS IN DROP DOWN

    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        dayOffsetLabel.text = textForOffset(offsetOptions[indexPath.row])
        selectedIndex = indexPath.row
        
        dropDown?.hideDropDown(animated: true)
        delegate?.willDismissKeyboard()
        
        updateDescriptionLabel()
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
            timeOfDayPicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeOfDayPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayPicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayPicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
        
    }
}
