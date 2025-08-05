//
//  LogsFilterVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TOOD rename clear button to reset
// TODO add an exit without save warning btn
// TODO to filter is broken for time filter, it only checks end date but it should be adaptive
// TODO make time filter be able to go off of start date, end date, modified date, or created date

protocol LogsFilterDelegate: AnyObject {
    func didUpdateLogsFilter(forLogsFilter: LogsFilter)
}

enum LogsFilterDropDownTypes: String, HoundDropDownType {
    case filterDogs = "DropDownFilterDogs"
    case filterLogActions = "DropDownFilterLogActions"
    case filterFamilyMembers = "DropDownFilterFamilyMembers"
}

class LogsFilterVC: HoundScrollViewController,
                    HoundDropDownDataSource,
                    HoundDropDownManagerDelegate,
                    UITextFieldDelegate {
    
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
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let timeRangeFromLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.text = "From"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private lazy var startDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 330, compressionResistancePriority: 330)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
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
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private lazy var endDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 310, compressionResistancePriority: 310)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
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
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var searchTextField: HoundTextField = {
        let textField = HoundTextField(huggingPriority: 295, compressionResistancePriority: 295)
        textField.delegate = self
        textField.placeholder = "Search notes, units, and more..."
        textField.shouldInsetText = true
        textField.backgroundColor = UIColor.systemBackground
        textField.applyStyle(.thinGrayBorder)
        textField.addTarget(self, action: #selector(didChangeSearchText(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        return textField
    }()
    
    private let dogsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Dogs"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterDogsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a dog (or dogs)..."
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsFilterDropDownTypes.filterDogs,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .filterDogs, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    
    private let logActionsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Actions"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterLogActionsLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select an action (or actions)..."
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsFilterDropDownTypes.filterLogActions,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .filterLogActions, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    
    private let familyMembersLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Family Members"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterFamilyMembersLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 240, compressionResistancePriority: 240)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a family member (or members)..."
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsFilterDropDownTypes.filterFamilyMembers,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .filterFamilyMembers, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    
    private lazy var clearButton: HoundButton = {
        let button = HoundButton(huggingPriority: 220, compressionResistancePriority: 220)
        
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
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
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBlue
        
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapApplyFilter), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dropDownManager = HoundDropDownManager<LogsFilterDropDownTypes>(
        rootView: containerView,
        dataSource: self,
        delegate: self
    )
    
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
                    return filter.dogManager.findDog(forDogUUID: dogUUID)?.dogName ?? Constant.Visual.Text.unknownName
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
                    return FamilyInformation.findFamilyMember(forUserId: userId)?.displayFullName ?? Constant.Visual.Text.unknownName
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
    
    // MARK: - Drop Down
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        dropDownManager.hideDropDownIfNotTapped(sender: sender)
        if let senderView = sender.view {
            let point = sender.location(in: senderView)
            if let deepestTouchedView = senderView.hitTest(point, with: nil),
               deepestTouchedView.isDescendant(of: searchTextField) == false {
                dismissKeyboard()
            }
        }
    }
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let type = identifier as? LogsFilterDropDownTypes else { return }
        
        let rows: CGFloat = {
            switch type {
            case .filterDogs: return CGFloat(filter?.availableDogs.count ?? 0)
            case .filterLogActions: return CGFloat(filter?.availableLogActions.count ?? 0)
            case .filterFamilyMembers: return CGFloat(filter?.availableFamilyMembers.count ?? 0)
            }
        }()
        
        dropDownManager.show(
            identifier: type,
            numberOfRowsToShow: min(6.5, rows),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let filter = filter else { return }
        guard let type = identifier as? LogsFilterDropDownTypes else { return }
        switch type {
        case .filterDogs:
            let dog = filter.availableDogs[indexPath.row]
            cell.setCustomSelected(filter.filteredDogsUUIDs.contains(dog.dogUUID), animated: false)
            cell.label.text = dog.dogName
        case .filterLogActions:
            let logActionType = filter.availableLogActions[indexPath.row]
            cell.setCustomSelected(filter.filteredLogActionActionTypeIds.contains(logActionType.logActionTypeId), animated: false)
            cell.label.text = logActionType.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
        case .filterFamilyMembers:
            let familyMember = filter.availableFamilyMembers[indexPath.row]
            cell.setCustomSelected(filter.filteredFamilyMemberUserIds.contains(familyMember.userId), animated: false)
            cell.label.text = familyMember.displayFullName ?? Constant.Visual.Text.unknownName
        }
    }
    
    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int {
        guard let filter = filter else {
            return 0
        }
        guard let type = identifier as? LogsFilterDropDownTypes else { return 0 }
        switch type {
        case .filterDogs:
            return filter.availableDogs.count
        case .filterLogActions:
            return filter.availableLogActions.count
        case .filterFamilyMembers:
            return filter.availableFamilyMembers.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? LogsFilterDropDownTypes else { return 0 }
        switch type {
        case .filterDogs, .filterLogActions, .filterFamilyMembers:
            return 1
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let filter = filter else { return }
        guard let type = identifier as? LogsFilterDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type) else { return }
        guard let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        
        switch type {
        case .filterDogs:
            let dogSelected = filter.availableDogs[indexPath.row]
            let beforeSelectNumberOfDogsSelected = filter.availableDogs.count
            if cell.isCustomSelected == true {
                filter.remove(forFilterDogUUID: dogSelected.dogUUID)
            }
            else {
                filter.add(forFilterDogUUID: dogSelected.dogUUID)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            if beforeSelectNumberOfDogsSelected == 0 || filter.filteredDogsUUIDs.count == filter.availableDogs.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterLogActions:
            let selectedLogAction = filter.availableLogActions[indexPath.row]
            let beforeSelectNumberOfLogActionsSelected = filter.availableLogActions.count
            if cell.isCustomSelected == true {
                filter.remove(forLogActionTypeId: selectedLogAction.logActionTypeId)
            }
            else {
                filter.add(forLogActionTypeId: selectedLogAction.logActionTypeId)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            if beforeSelectNumberOfLogActionsSelected == 0 || filter.filteredLogActionActionTypeIds.count == filter.availableLogActions.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterFamilyMembers:
            let familyMemberSelected = filter.availableFamilyMembers[indexPath.row]
            let beforeSelectNumberOfFamilyMembersSelected = filter.availableFamilyMembers.count
            if cell.isCustomSelected == true {
                filter.remove(forUserId: familyMemberSelected.userId)
            }
            else {
                filter.add(forUserId: familyMemberSelected.userId)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            if beforeSelectNumberOfFamilyMembersSelected == 0 || filter.filteredFamilyMemberUserIds.count == filter.availableFamilyMembers.count {
                dropDown.hideDropDown(animated: true)
            }
        }
        updateDynamicUIElements()
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
            guard let filter = filter else { return nil }
            guard let type = identifier as? LogsFilterDropDownTypes else { return nil }
            switch type {
            case .filterDogs:
                if let idx = filter.filteredDogsUUIDs
                    .compactMap({ uuid in filter.availableDogs.firstIndex(where: { $0.dogUUID == uuid }) })
                    .min() {
                    return IndexPath(row: idx, section: 0)
                }
            case .filterLogActions:
                if let idx = filter.filteredLogActionActionTypeIds
                    .compactMap({ id in filter.availableLogActions.firstIndex(where: { $0.logActionTypeId == id }) })
                    .min() {
                    return IndexPath(row: idx, section: 0)
                }
            case .filterFamilyMembers:
                if let idx = filter.filteredFamilyMemberUserIds
                    .compactMap({ userId in filter.availableFamilyMembers.firstIndex(where: { $0.userId == userId }) })
                    .min() {
                    return IndexPath(row: idx, section: 0)
                }
            }
            return nil
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
