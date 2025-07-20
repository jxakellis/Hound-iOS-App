//
//  LogsFilterVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsFilterDelegate: AnyObject {
    func didUpdateLogsFilter(forLogsFilter: LogsFilter)
}

class LogsFilterVC: HoundScrollViewController, HoundDropDownDataSource, UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Elements
    
    private let pageHeader: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.pageHeaderLabel.text = "Filter"
        return view
    }()
    
    private let timeRangeLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.text = "Time Range"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private let timeRangeFromLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.text = "From"
        label.font = Constant.VisualFont.primaryRegularLabel
        return label
    }()
    
    private lazy var startDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 330, compressionResistancePriority: 330)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = 5
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeStartDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var startDateSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 325, compressionResistancePriority: 325)
        uiSwitch.addTarget(self, action: #selector(didToggleStartDate), for: .valueChanged)
        return uiSwitch
    }()
    
    private let timeRangeToLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "to"
        label.font = Constant.VisualFont.primaryRegularLabel
        return label
    }()
    
    private lazy var endDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 310, compressionResistancePriority: 310)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = 5
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeEndDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var endDateSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 305, compressionResistancePriority: 305)
        uiSwitch.addTarget(self, action: #selector(didToggleEndDate), for: .valueChanged)
        return uiSwitch
    }()
    
    private let searchLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Search Text"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private lazy var searchTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 295, compressionResistancePriority: 295)
        textField.delegate = self
        textField.placeholder = " Search notes, units, and more..."
        textField.backgroundColor = UIColor.systemBackground
        textField.applyStyle(.thinGrayBorder)
        textField.addTarget(self, action: #selector(didChangeSearchText(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        return textField
    }()
    
    private let dogsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Dogs"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterDogsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = Constant.VisualFont.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a dog (or dogs)..."
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        gesture.name = LogsFilterDropDownTypes.filterDogs.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private let logActionsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Actions"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterLogActionsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = Constant.VisualFont.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select an action (or actions)..."
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        gesture.name = LogsFilterDropDownTypes.filterLogActions.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private let familyMembersLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Family Members"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterFamilyMembersLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 240, compressionResistancePriority: 240)
        label.font = Constant.VisualFont.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a family member (or members)..."
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        gesture.name = LogsFilterDropDownTypes.filterFamilyMembers.rawValue
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        
        return label
    }()
    
    private lazy var clearButton: HoundButton = {
        let button = HoundButton(huggingPriority: 220, compressionResistancePriority: 220)
        
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.VisualFont.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapClearFilter), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var applyButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = Constant.VisualFont.wideButton
        
        button.backgroundColor = UIColor.systemBlue
        
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapApplyFilter), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didChangeStartDate(_ sender: UIDatePicker) {
        filter?.apply(forStartDate: sender.date)
        if sender.date > endDatePicker.date {
            endDatePicker.setDate(sender.date, animated: true)
            filter?.apply(forEndDate: endDateSwitch.isOn ? sender.date : nil)
        }
        startDateSwitch.setOn(true, animated: true)
    }
    
    @objc private func didChangeEndDate(_ sender: UIDatePicker) {
        filter?.apply(forEndDate: sender.date)
        if sender.date < startDatePicker.date {
            startDatePicker.setDate(sender.date, animated: true)
            filter?.apply(forStartDate: startDateSwitch.isOn ? sender.date : nil)
        }
        endDateSwitch.setOn(true, animated: true)
    }
    
    @objc private func didToggleStartDate(_ sender: HoundSwitch) {
        filter?.apply(forStartDate: sender.isOn ? startDatePicker.date : nil)
        startDatePicker.isEnabled = sender.isOn
    }
    
    @objc private func didToggleEndDate(_ sender: HoundSwitch) {
        filter?.apply(forEndDate: sender.isOn ? endDatePicker.date : nil)
        endDatePicker.isEnabled = sender.isOn
    }
    
    @objc private func didChangeSearchText(_ sender: UITextField) {
        filter?.apply(forSearchText: sender.text ?? "")
    }
    
    @objc private func didTapClearFilter(_ sender: Any) {
        filter?.clearAll()
        if let filter = filter {
            delegate?.didUpdateLogsFilter(forLogsFilter: filter)
        }
    }

    @objc private func didTapApplyFilter(_ sender: Any) {
        guard let filter = filter else { return }
        delegate?.didUpdateLogsFilter(forLogsFilter: filter)
    }
    
    // MARK: - Properties
    
    private weak var delegate: LogsFilterDelegate?
    
    private var dropDownFilterDogs: HoundDropDown?
    private var dropDownFilterLogActions: HoundDropDown?
    private var dropDownFilterFamilyMembers: HoundDropDown?
    private var filter: LogsFilter?
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        self.enableSwipeBackToDismiss = true
        
        updateDynamicUIElements()
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else { return }
        
        didSetupCustomSubviews = true
        
        updateDynamicUIElements()
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: LogsFilterDelegate, forFilter: LogsFilter) {
        delegate = forDelegate
        filter = (forFilter.copy() as? LogsFilter) ?? forFilter
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        if let filter = filter {
            searchTextField.text = filter.searchText
        }
        
        if let filter = filter, filter.filteredDogsUUIDs.count >= 1 {
            filterDogsLabel.text = {
                if filter.filteredDogsUUIDs.count == 1, let dogUUID = filter.filteredDogsUUIDs.first {
                    // The user only has one dog selected to filter by
                    return filter.dogManager.findDog(forDogUUID: dogUUID)?.dogName ?? Constant.VisualText.unknownName
                }
                else if filter.filteredDogsUUIDs.count > 1 && filter.filteredDogsUUIDs.count < filter.availableDogs.count {
                    // The user has multiple, but not all, dogs selected to filter by
                    return "Multiple"
                }
                
                // The user has all dogs selected to filter by
                return "All"
            }()
        }
        else {
            // The user has no dogs selected to filter by, so we interpret this as including all dogs in the filter
            filterDogsLabel.text = nil
        }
        
        if let filter = filter, filter.filteredLogActionActionTypeIds.count >= 1 {
            filterLogActionsLabel.text = {
                if filter.filteredLogActionActionTypeIds.count == 1, let logActionTypeId = filter.filteredLogActionActionTypeIds.first {
                    // The user only has one log action selected to filter by
                    return LogActionType.find(forLogActionTypeId: logActionTypeId).convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
                }
                else if filter.filteredLogActionActionTypeIds.count > 1 && filter.filteredLogActionActionTypeIds.count < filter.availableLogActions.count {
                    // The user has multiple, but not all, log actions selected to filter by
                    return "Multiple"
                }
                
                // The user has all log actions selected to filter by
                return "All"
            }()
        }
        else {
            // The user has no log actions selected to filter by, so we interpret this as including all log actions in the filter
            filterLogActionsLabel.text = nil
        }
        
        if let filter = filter, filter.filteredFamilyMemberUserIds.count >= 1 {
            filterFamilyMembersLabel.text = {
                if filter.filteredFamilyMemberUserIds.count == 1, let userId = filter.filteredFamilyMemberUserIds.first {
                    // The user only has one family member selected to filter by
                    return FamilyInformation.findFamilyMember(forUserId: userId)?.displayFullName ?? Constant.VisualText.unknownName
                }
                else if filter.filteredFamilyMemberUserIds.count > 1 && filter.filteredFamilyMemberUserIds.count < filter.availableFamilyMembers.count {
                    // The user has multiple, but not all, family members selected to filter by
                    return "Multiple"
                }
                
                // The user has all family members selected to filter by
                return "All"
            }()
        }
        else {
            // The user has no family member selected to filter by, so we interpret this as including all family members in the filter
            filterFamilyMembersLabel.text = nil
        }
        
        if let filter = filter {
            let noDate = Date()
            let startDate = filter.startDate ?? filter.endDate ?? noDate
            let endDate = filter.endDate ?? filter.startDate ?? noDate
            
            startDatePicker.setDate(startDate, animated: false)
            endDatePicker.setDate(endDate, animated: false)
            
            startDateSwitch.setOn(filter.isStartDateEnabled, animated: false)
            startDatePicker.isEnabled = filter.isStartDateEnabled
            endDateSwitch.setOn(filter.isEndDateEnabled, animated: false)
            endDatePicker.isEnabled = filter.isEndDateEnabled
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    // MARK: Drop Down
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        
        let originalTouchPoint = sender.location(in: senderView)
        
        guard let deepestTouchedView = senderView.hitTest(originalTouchPoint, with: nil) else { return }
        
        if deepestTouchedView.isDescendant(of: searchTextField) == false {
            self.dismissKeyboard()
        }
        
        // If the dropDown exist, then we might have to possibly hide it. The only case where we wouldn't want to collapse the drop down is if we click the dropdown itself or its corresponding label
        if let dropDownFilterDogs = dropDownFilterDogs, deepestTouchedView.isDescendant(of: filterDogsLabel) == false && deepestTouchedView.isDescendant(of: dropDownFilterDogs) == false {
            dropDownFilterDogs.hideDropDown(animated: true)
        }
        if let dropDownFilterLogActions = dropDownFilterLogActions, deepestTouchedView.isDescendant(of: filterLogActionsLabel) == false && deepestTouchedView.isDescendant(of: dropDownFilterLogActions) == false {
            dropDownFilterLogActions.hideDropDown(animated: true)
        }
        if let dropDownFilterFamilyMembers = dropDownFilterFamilyMembers, deepestTouchedView.isDescendant(of: filterFamilyMembersLabel) == false && deepestTouchedView.isDescendant(of: dropDownFilterFamilyMembers) == false {
            dropDownFilterFamilyMembers.hideDropDown(animated: true)
        }
    }
    
    @objc private func didTapLabelForDropDown(sender: UITapGestureRecognizer) {
        guard let name = sender.name, let targetDropDownType = LogsFilterDropDownTypes(rawValue: name) else { return }
        
        let targetDropDown = dropDown(forDropDownType: targetDropDownType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetDropDownType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given LogsFilterDropDownTypes, return the corresponding dropDown object
    private func dropDown(forDropDownType: LogsFilterDropDownTypes) -> HoundDropDown? {
        switch forDropDownType {
        case .filterDogs:
            return dropDownFilterDogs
        case .filterLogActions:
            return dropDownFilterLogActions
        case .filterFamilyMembers:
            return dropDownFilterFamilyMembers
        }
    }
    
    /// For a given LogsFilterDropDownTypes, return the corresponding label that shows the dropdown
    private func labelForDropDown(forDropDownType: LogsFilterDropDownTypes) -> HoundLabel {
        switch forDropDownType {
        case .filterDogs:
            return filterDogsLabel
        case .filterLogActions:
            return filterLogActionsLabel
        case .filterFamilyMembers:
            return filterFamilyMembersLabel
        }
    }
    
    /// Dismisses the keyboard and other dropdowns to show filterDogsLabel
    private func showDropDown(_ dropDownType: LogsFilterDropDownTypes, animated: Bool) {
        var targetDropDown = dropDown(forDropDownType: dropDownType)
        let labelForTargetDropDown = labelForDropDown(forDropDownType: dropDownType)
        
        if targetDropDown == nil {
            targetDropDown = HoundDropDown()
            if let targetDropDown = targetDropDown {
                targetDropDown.setupDropDown(
                    forHoundDropDownIdentifier: dropDownType.rawValue,
                    forDataSource: self,
                    forViewPositionReference: labelForTargetDropDown.frame,
                    forOffset: 2.5,
                    forRowHeight: HoundDropDown.rowHeightForHoundLabel
                )
                
                // Assign our actual drop down variable to the local variable drop down we just created
                switch dropDownType {
                case .filterDogs:
                    dropDownFilterDogs = targetDropDown
                case .filterLogActions:
                    dropDownFilterLogActions = targetDropDown
                case .filterFamilyMembers:
                    dropDownFilterFamilyMembers = targetDropDown
                }
                
                // All of our dropDowns ordered by priority, where the lower the index views should be displayed over the higher index views
                let dropDownsOrderedByPriority: [HoundDropDown?] = {
                    return [dropDownFilterDogs, dropDownFilterLogActions, dropDownFilterFamilyMembers]
                }()
                let indexOfTargetDropDown = dropDownsOrderedByPriority.firstIndex(of: targetDropDown)
                
                if let superview = labelForTargetDropDown.superview, let indexOfTargetDropDown = indexOfTargetDropDown {
                    var didInsertSubview = false
                    // Iterate through dropDownsOrderedByPriority backwards, starting at our drop down. If the next nearest dropdown exists, then insert our dropdown below it
                    // E.g. targetDropDown = dropDownLogStartDate -> dropDownLogUnit doesn't exist yet -> dropDownFilterLogActions exists so insert subview directly below it
                    // Insert the target drop down view above all lower indexed (and thus lower priority) drop downs.
                    
                    for i in (0..<indexOfTargetDropDown).reversed() {
                        if let nearestHigherPriorityDropDown = dropDownsOrderedByPriority[i] {
                            superview.insertSubview(targetDropDown, belowSubview: nearestHigherPriorityDropDown)
                            didInsertSubview = true
                            break
                        }
                    }
                    
                    if didInsertSubview == false {
                        // If no lower priority drop downs are visible, add it normally
                        superview.addSubview(targetDropDown)
                    }
                }
            }
        }
        
        // Dynamically show the target dropDown
        targetDropDown?.showDropDown(
            // Either show a maximum of 6.5 rows or the number of rows specified below
            numberOfRowsToShow: min(6.5, {
                switch dropDownType {
                case .filterDogs:
                    return CGFloat(filter?.availableDogs.count ?? 0)
                case .filterLogActions:
                    return CGFloat(filter?.availableLogActions.count ?? 0)
                case .filterFamilyMembers:
                    return CGFloat(filter?.availableFamilyMembers.count ?? 0)
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let filter = filter, let customCell = cell as? HoundDropDownTableViewCell else { return }
        
        customCell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            let dog = filter.availableDogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filteredDogsUUIDs.contains(dog.dogUUID))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            let logActionType = filter.availableLogActions[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filteredLogActionActionTypeIds.contains(logActionType.logActionTypeId))
            customCell.label.text = logActionType.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue {
            let familyMember = filter.availableFamilyMembers[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filteredFamilyMemberUserIds.contains(familyMember.userId))
            customCell.label.text = familyMember.displayFullName ?? Constant.VisualText.unknownName
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        guard let filter = filter else {
            return 0
        }
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            return filter.availableDogs.count
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            return filter.availableLogActions.count
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue {
            return filter.availableFamilyMembers.count
        }
        
        return 0
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            return 1
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            return 1
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue {
            return 1
        }
        
        return 0
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let filter = filter else { return }
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue, let selectedCell = dropDownFilterDogs?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            let dogSelected = filter.availableDogs[indexPath.row]
            let beforeSelectNumberOfDogsSelected = filter.availableDogs.count
            
            if selectedCell.isCustomSelected == true {
                filter.remove(forFilterDogUUID: dogSelected.dogUUID)
            }
            else {
                filter.add(forFilterDogUUID: dogSelected.dogUUID)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfDogsSelected == 0 {
                // If initially, there were no dogs selected, then the user selected their first dog, we immediately hide this drop down. We assume they only want to filter by one dog, though they could do more
                dropDownFilterDogs?.hideDropDown(animated: true)
            }
            else if filter.filteredDogsUUIDs.count == filter.availableDogs.count {
                // selected every dog in the drop down, close the drop down
                dropDownFilterDogs?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue, let selectedCell = dropDownFilterLogActions?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            let selectedLogAction = filter.availableLogActions[indexPath.row]
            let beforeSelectNumberOfLogActionsSelected = filter.availableLogActions.count
            
            if selectedCell.isCustomSelected == true {
                filter.remove(forLogActionTypeId: selectedLogAction.logActionTypeId)
            }
            else {
                filter.add(forLogActionTypeId: selectedLogAction.logActionTypeId)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfLogActionsSelected == 0 {
                // If initially, there were no log actions selected, then the user selected their first log action, we immediately hide this drop down. We assume they only want to filter by one log action, though they could do more
                dropDownFilterLogActions?.hideDropDown(animated: true)
            }
            else if filter.filteredLogActionActionTypeIds.count == filter.availableLogActions.count {
                // selected every log action in the drop down, close the drop down
                dropDownFilterLogActions?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue, let selectedCell = dropDownFilterFamilyMembers?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            let familyMemberSelected = filter.availableFamilyMembers[indexPath.row]
            let beforeSelectNumberOfFamilyMembersSelected = filter.availableFamilyMembers.count
            
            if selectedCell.isCustomSelected == true {
                filter.remove(forUserId: familyMemberSelected.userId)
            }
            else {
                filter.add(forUserId: familyMemberSelected.userId)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfFamilyMembersSelected == 0 {
                // If initially, there were no family members selected, then the user selected their first family member, we immediately hide this drop down. We assume they only want to filter by one family member, though they could do more
                dropDownFilterFamilyMembers?.hideDropDown(animated: true)
            }
            else if filter.filteredFamilyMemberUserIds.count == filter.availableFamilyMembers.count {
                // selected every family member in the drop down, close the drop down
                dropDownFilterFamilyMembers?.hideDropDown(animated: true)
            }
        }
        
        // Once the selection update is done, then update the UI
        updateDynamicUIElements()
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeader)
        
        containerView.addSubview(timeRangeLabel)
        containerView.addSubview(startDatePicker)
        containerView.addSubview(startDateSwitch)
        containerView.addSubview(timeRangeFromLabel)
        containerView.addSubview(timeRangeToLabel)
        containerView.addSubview(endDatePicker)
        containerView.addSubview(endDateSwitch)
        
        containerView.addSubview(searchLabel)
        containerView.addSubview(searchTextField)
        
        containerView.addSubview(filterDogsLabel)
        containerView.addSubview(dogsLabel)
        
        containerView.addSubview(filterLogActionsLabel)
        containerView.addSubview(logActionsLabel)
        
        containerView.addSubview(filterFamilyMembersLabel)
        containerView.addSubview(familyMembersLabel)
        
        containerView.addSubview(clearButton)
        containerView.addSubview(applyButton)
        
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // timeRangeLabel
        NSLayoutConstraint.activate([
            timeRangeLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            timeRangeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            timeRangeLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // timeRangeFromLabel
        NSLayoutConstraint.activate([
            timeRangeFromLabel.topAnchor.constraint(equalTo: timeRangeLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeFromLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeFromLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // startDatePicker
        NSLayoutConstraint.activate([
            startDatePicker.topAnchor.constraint(equalTo: timeRangeFromLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            startDatePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            startDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: startDateSwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            startDatePicker.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            startDatePicker.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            startDatePicker.createAspectRatio(2.75 * 2)
        ])
        
        // startDateSwitch
        NSLayoutConstraint.activate([
            startDateSwitch.centerYAnchor.constraint(equalTo: startDatePicker.centerYAnchor),
            startDateSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // timeRangeToLabel
        NSLayoutConstraint.activate([
            timeRangeToLabel.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeToLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeToLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // endDatePicker
        NSLayoutConstraint.activate([
            endDatePicker.topAnchor.constraint(equalTo: timeRangeToLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            endDatePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            endDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: endDateSwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            endDatePicker.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            endDatePicker.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            endDatePicker.createAspectRatio(2.75 * 2)
        ])
        
        // endDateSwitch
        NSLayoutConstraint.activate([
            endDateSwitch.centerYAnchor.constraint(equalTo: endDatePicker.centerYAnchor),
            endDateSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // searchLabel
        NSLayoutConstraint.activate([
            searchLabel.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            searchLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            searchLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            searchLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view),
            searchLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight)
        ])
        
        // searchTextField
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: searchLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            searchTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            searchTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            searchTextField.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            searchTextField.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight)
        ])
        
        // dogsLabel
        NSLayoutConstraint.activate([
            dogsLabel.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            dogsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            dogsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            dogsLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            dogsLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // filterDogsLabel
        NSLayoutConstraint.activate([
            filterDogsLabel.topAnchor.constraint(equalTo: dogsLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            filterDogsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            filterDogsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            filterDogsLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight),
            filterDogsLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view)
        ])
        
        // logActionsLabel
        NSLayoutConstraint.activate([
            logActionsLabel.topAnchor.constraint(equalTo: filterDogsLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            logActionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            logActionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            logActionsLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            logActionsLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // filterLogActionsLabel
        NSLayoutConstraint.activate([
            filterLogActionsLabel.topAnchor.constraint(equalTo: logActionsLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            filterLogActionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            filterLogActionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            filterLogActionsLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight),
            filterLogActionsLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view)
            
        ])
        
        // familyMembersLabel
        NSLayoutConstraint.activate([
            familyMembersLabel.topAnchor.constraint(equalTo: filterLogActionsLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            familyMembersLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            familyMembersLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            familyMembersLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            familyMembersLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
            
        ])
        
        // filterFamilyMembersLabel
        NSLayoutConstraint.activate([
            filterFamilyMembersLabel.topAnchor.constraint(equalTo: familyMembersLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            filterFamilyMembersLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            filterFamilyMembersLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            filterFamilyMembersLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight),
            filterFamilyMembersLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view)
        ])
        
        // applyButton
        NSLayoutConstraint.activate([
            applyButton.topAnchor.constraint(equalTo: filterFamilyMembersLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            applyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            applyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            applyButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            applyButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
        
        // clearButton
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: applyButton.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            clearButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset * 2.0),
            clearButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            clearButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            clearButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
    }
    
}
