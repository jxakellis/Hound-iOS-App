//
//  DogsAddTriggerFixedTimeView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

protocol DogsAddTriggerFixedTimeViewDelegate: AnyObject {
    func willDismissKeyboard()
    func didUpdateDescriptionLabel()
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
    
    private lazy var dayOffsetLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a day offset..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(dropDownManager.showHideDropDownGesture(identifier: .dayOffset, delegate: self))
        dropDownManager.register(identifier: .dayOffset, label: label, autoscroll: .firstOpen)
        return label
    }()
    
    private lazy var timeOfDayPicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 250, compressionResistancePriority: 250)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = UserConfiguration.timeZone
        datePicker.date = Date.roundDate(
            targetDate: Date(),
            roundingInterval: Double(60 * datePicker.minuteInterval),
            roundingMethod: .up
        )
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        return datePicker
    }()
    
    private let timeZoneDisclaimerLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.text = "If your family is spread across time zones, the reminder’s time will be based off whichever device handles this automation first."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.isHidden = FamilyInformation.familyMembers.count <= 1
        return label
    }()
    
    private lazy var disclaimerStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(timeOfDayPicker)
        stack.addArrangedSubview(timeZoneDisclaimerLabel)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        self.errorMessage = nil
        delegate?.didUpdateDescriptionLabel()
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
    
    var currentComponent: TriggerFixedTimeComponents {
        let comps = Calendar.user.dateComponents([.hour, .minute], from: timeOfDayPicker.date)
        let hour = comps.hour ?? Constant.Class.Trigger.defaultTriggerFixedTimeHour
        let minute = comps.minute ?? Constant.Class.Trigger.defaultTriggerFixedTimeMinute
        return TriggerFixedTimeComponents(
            triggerFixedTimeType: .day,
            triggerFixedTimeTypeAmount: selectedDayOffset,
            triggerFixedTimeHour: hour,
            triggerFixedTimeMinute: minute
        )
    }
    
    // MARK: - Setup
    
    func setup(
        delegate: DogsAddTriggerFixedTimeViewDelegate,
        components: TriggerFixedTimeComponents?
    ) {
        self.delegate = delegate
        
        let index = components?.triggerFixedTimeTypeAmount ?? selectedDayOffset
        selectedDayOffset = index
        dayOffsetLabel.text = textForOffset(index)
        
        if let components = components {
            var comps = DateComponents()
            comps.year = 2000
            comps.month = 1
            comps.day = 1
            comps.hour = components.triggerFixedTimeHour
            comps.minute = components.triggerFixedTimeMinute
            comps.second = 0
            comps.timeZone = UserConfiguration.timeZone
            timeOfDayPicker.date = Calendar.user.date(from: comps) ?? timeOfDayPicker.date
        }
        
        delegate.didUpdateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    var descriptionLabelText: String {
        var text = "Reminder be sent "
        
        switch selectedDayOffset {
        case 0: text += "on the same day as the log "
        case 1: text += "the day after the log "
        default: text += "\(selectedDayOffset) days after the log "
        }
        
        let comps = Calendar.user.dateComponents([.hour, .minute], from: timeOfDayPicker.date)
        let hour = comps.hour ?? Constant.Class.Trigger.defaultTriggerFixedTimeHour
        let minute = comps.minute ?? Constant.Class.Trigger.defaultTriggerFixedTimeMinute
        text += "at \(String.convert(hour: hour, minute: minute))"
        
        return text
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
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let type = identifier as? DogsAddTriggerFixedTimeDropDownTypes else { return }
        
        let numberOfRows: CGFloat = {
            switch type {
            case .dayOffset: return CGFloat(availableDayOffsets.count)
            }
        }()
        
        dropDownManager.show(identifier: type, numberOfRowsToShow: min(6.5, numberOfRows), animated: animated)
    }
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? DogsAddTriggerFixedTimeDropDownTypes else { return }
        cell.label.text = textForOffset(availableDayOffsets[indexPath.row])
        
        switch type {
        case .dayOffset:
            cell.setCustomSelected(availableDayOffsets[indexPath.row] == selectedDayOffset, animated: false)
        }
    }
    
    func numberOfRows(section: Int, identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? DogsAddTriggerFixedTimeDropDownTypes else { return 0 }
        switch type {
        case .dayOffset:
            return availableDayOffsets.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        // Each dropdown has a single section
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? DogsAddTriggerFixedTimeDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type), let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else {
            return
        }
        switch type {
        case .dayOffset:
            let previousIndexPath = IndexPath(row: selectedDayOffset, section: 0)
            if previousIndexPath != indexPath {
                let previousCell = dropDown.dropDownTableView?.cellForRow(at: previousIndexPath) as? HoundDropDownTVC
                previousCell?.setCustomSelected(false)
            }
            
            cell.setCustomSelected(true)
            selectedDayOffset = availableDayOffsets[indexPath.row]
            dayOffsetLabel.text = textForOffset(availableDayOffsets[indexPath.row])
            
            dropDown.hideDropDown(animated: true)
            delegate?.willDismissKeyboard()
            
            delegate?.didUpdateDescriptionLabel()
        }
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
            guard let type = identifier as? DogsAddTriggerFixedTimeDropDownTypes else { return nil }
            switch type {
            case .dayOffset:
                if let idx = availableDayOffsets.firstIndex(of: selectedDayOffset) {
                    return IndexPath(row: idx, section: 0)
                }
            }
            return nil
        }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(dayOffsetLabel)
        addSubview(disclaimerStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        dayOffsetLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        disclaimerStack.snp.makeConstraints { make in
            make.top.equalTo(dayOffsetLabel.snp.bottom).offset(Constant.Constraint.Spacing.contentIntraVert)
            make.bottom.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.horizontalEdges.equalToSuperview().inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        timeOfDayPicker.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.megaDatePickerHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.megaDatePickerMaxHeight)
        }
        
    }
}
