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

enum DogsAddTriggerFixedTimeDropDownTypes: String, HoundDropDownType {
    case dayOffset = "DropDownDayOffset"
}

final class DogsAddTriggerFixedTimeView: HoundView, HoundDropDownDataSource, HoundDropDownManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - Elements
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var dayOffsetLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select the day offset..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        dropDownManager.register(identifier: .dayOffset, label: label)
        label.addGestureRecognizer(dropDownManager.showHideDropDownGesture(identifier: .dayOffset, delegate: self))
        return label
    }()
    
    private lazy var timeOfDayPicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 250, compressionResistancePriority: 250)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = Constant.Development.minuteInterval
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
    
    private lazy var dropDownManager = HoundDropDownManager<DogsAddTriggerFixedTimeDropDownTypes>(rootView: self, dataSource: self, delegate: self)
    private var selectedDayOffset: Int = 0 {
        didSet {
            self.errorMessage = nil
        }
    }
    private let availableDayOffsets = [0, 1, 2, 3, 4, 5, 6, 7]
    
    var currentOffset: Int { selectedDayOffset }
    var currentTimeOfDay: Date { timeOfDayPicker.date }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddTriggerFixedTimeViewDelegate, forDaysOffset: Int?, forTimeOfDay: Date?) {
        delegate = forDelegate
        
        let index = forDaysOffset ?? selectedDayOffset
        selectedDayOffset = index
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
        
        text += "at \(timeOfDayPicker.date.houndFormatted(.formatStyle(date: .omitted, time: .shortened)))"
        
        var emphasizedText: String?
        if selectedDayOffset == 0 {
            emphasizedText = ". If the time has passed, reminder rolls over to the next day"
        }
        let precalculatedDynamicTextColor = UIColor.label
        
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message = NSMutableAttributedString(
                string: text,
                attributes: [.font: Constant.Visual.Font.secondaryRegularLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
            )
            
            if let emphasizedText = emphasizedText {
                message.append(NSMutableAttributedString(
                    string: emphasizedText,
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryRegularLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
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
        dropDownManager.hideDropDownIfNotTapped(sender: sender)
        dismissKeyboard()
    }
    
    
    // MARK: - DropDown Data Source
    
    func willShowDropDown(_ identifier: String, animated: Bool) {
        guard let type = DogsAddTriggerFixedTimeDropDownTypes(rawValue: identifier) else { return }
        let numberOfRows: CGFloat = {
            switch type {
            case .dayOffset: return CGFloat(availableDayOffsets.count)
            }
        }()
        dropDownManager.show(identifier: type, numberOfRowsToShow: min(6.5, numberOfRows), animated: animated)
    }
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let identifier = DogsAddTriggerFixedTimeDropDownTypes(rawValue: identifier.rawValue) else { return }
        guard let cell = cell as? HoundDropDownTVC else { return }
        cell.label.text = textForOffset(availableDayOffsets[indexPath.row])

        if identifier == .dayOffset {
            if indexPath.row == selectedDayOffset {
                cell.setCustomSelectedTableViewCell(forSelected: true)
            } else {
                cell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }

    }

    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int {
        guard let identifier = DogsAddTriggerFixedTimeDropDownTypes(rawValue: identifier.rawValue) else { return 0 }
        switch identifier {
        case .dayOffset:
            return availableDayOffsets.count
        }
    }

    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        // Each dropdown has a single section
        return 1
    }

    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let identifier = DogsAddTriggerFixedTimeDropDownTypes(rawValue: identifier.rawValue) else { return }
        guard let dropDown = dropDownManager.dropDown(for: identifier), let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else {
            return
        }
        switch identifier {
        case .dayOffset:
            let previousIndexPath = IndexPath(row: selectedDayOffset, section: 0)
            if previousIndexPath != indexPath {
                let previousCell = dropDown.dropDownTableView?.cellForRow(at: previousIndexPath) as? HoundDropDownTVC
                previousCell?.setCustomSelectedTableViewCell(forSelected: false)
            }
            
            cell.setCustomSelectedTableViewCell(forSelected: true)
            let dayOffset = indexPath.row
            selectedDayOffset = dayOffset
            dayOffsetLabel.text = textForOffset(availableDayOffsets[dayOffset])

            dropDownManager.hide(identifier: .dayOffset, animated: true)
            delegate?.willDismissKeyboard()

            updateDescriptionLabel()
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(descriptionLabel)
        addSubview(dayOffsetLabel)
        addSubview(timeOfDayPicker)
        
        DogsAddTriggerFixedTimeDropDownTypes.allCases.forEach { type in
            switch type {
                case .dayOffset:
                    dropDownManager.register(identifier: type, label: dayOffsetLabel)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // dayOffsetLabel
        NSLayoutConstraint.activate([
            dayOffsetLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            dayOffsetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            dayOffsetLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            dayOffsetLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: self),
            dayOffsetLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            timeOfDayPicker.topAnchor.constraint(equalTo: dayOffsetLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeOfDayPicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeOfDayPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeOfDayPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            timeOfDayPicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayPicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
        
    }
}
