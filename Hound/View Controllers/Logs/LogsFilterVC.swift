//
//  LogsFilterVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO QOL add a leave without save warning

protocol LogsFilterDelegate: AnyObject {
    func didUpdateLogsFilter(logsFilter: LogsFilter)
}

enum LogsFilterDropDownTypes: String, HoundDropDownType {
    case filterTimeRange = "DropDownFilterTimeRange"
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
    
    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.pageHeaderLabel.text = "Filter"
        return view
    }()
    
    private let timeRangeSectionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.text = "Time Range"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    // TODO UI remove field header label it adds nothing
    private let timeRangeFieldHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.text = "Field"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    // TODO UI this should start blank and have a placeholder. if user tries to save filter w/ from/to on but no field, show an error message
    private lazy var timeRangeFieldLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsFilterDropDownTypes.filterTimeRange,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .filterTimeRange, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    
    private let timeRangeFromHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.text = "From"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private lazy var fromDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 330, compressionResistancePriority: 330)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeFromDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var fromDateSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 325, compressionResistancePriority: 325)
        uiSwitch.addTarget(self, action: #selector(didToggleFromDate), for: .valueChanged)
        return uiSwitch
    }()
    
    private let timeRangeToHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "to"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private lazy var toDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker(huggingPriority: 310, compressionResistancePriority: 310)
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeToDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var toDateSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 305, compressionResistancePriority: 305)
        uiSwitch.addTarget(self, action: #selector(didToggleToDate), for: .valueChanged)
        return uiSwitch
    }()
    
    private let likesOnlySectionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 235, compressionResistancePriority: 235)
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        label.text = "Only Show Likes"
        return label
    }()
    
    private lazy var likesOnlySwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 230, compressionResistancePriority: 230)
        uiSwitch.addTarget(self, action: #selector(didToggleLikesOnly), for: .valueChanged)
        return uiSwitch
    }()
    
    private let searchSectionLabel: HoundLabel = {
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
    
    private let dogsSectionLabel: HoundLabel = {
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
    
    private let logActionsSectionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Actions"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var filterLogActionsSectionLabel: HoundLabel = {
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
    
    private let familyMembersSectionLabel: HoundLabel = {
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
    
    private lazy var resetButton: HoundButton = {
        let button = HoundButton(huggingPriority: 220, compressionResistancePriority: 220)
        
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapResetFilter), for: .touchUpInside)
        
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
    
    @objc private func didChangeFromDate(_ sender: UIDatePicker) {
        filter?.apply(timeRangeFromDate: sender.date)
        if sender.date > toDatePicker.date {
            toDatePicker.setDate(sender.date, animated: true)
            filter?.apply(timeRangeToDate: toDateSwitch.isOn ? sender.date : nil)
        }
        fromDateSwitch.setOn(true, animated: true)
    }
    
    @objc private func didChangeToDate(_ sender: UIDatePicker) {
        filter?.apply(timeRangeToDate: sender.date)
        if sender.date < fromDatePicker.date {
            fromDatePicker.setDate(sender.date, animated: true)
            filter?.apply(timeRangeFromDate: fromDateSwitch.isOn ? sender.date : nil)
        }
        toDateSwitch.setOn(true, animated: true)
    }
    
    @objc private func didToggleFromDate(_ sender: HoundSwitch) {
        filter?.apply(timeRangeFromDate: sender.isOn ? fromDatePicker.date : nil)
        fromDatePicker.isEnabled = sender.isOn
    }
    
    @objc private func didToggleToDate(_ sender: HoundSwitch) {
        filter?.apply(timeRangeToDate: sender.isOn ? toDatePicker.date : nil)
        toDatePicker.isEnabled = sender.isOn
    }
    
    @objc private func didToggleLikesOnly(_ sender: HoundSwitch) {
        filter?.apply(onlyShowLikes: sender.isOn)
    }
    
    @objc private func didChangeSearchText(_ sender: UITextField) {
        filter?.apply(searchText: sender.text ?? "")
    }
    
    @objc private func didTapResetFilter(_ sender: Any) {
        filter?.reset()
        if let filter = filter {
            delegate?.didUpdateLogsFilter(logsFilter: filter)
        }
    }
    
    @objc private func didTapApplyFilter(_ sender: Any) {
        guard let filter = filter else { return }
        delegate?.didUpdateLogsFilter(logsFilter: filter)
    }
    
    // MARK: - Properties
    
    private weak var delegate: LogsFilterDelegate?
    
    private var filter: LogsFilter?
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .pageSheet
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
    
    func setup(delegate: LogsFilterDelegate, filter: LogsFilter) {
        self.delegate = delegate
        self.filter = (filter.copy() as? LogsFilter) ?? filter
        updateDynamicUIElements()
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        if let filter = filter {
            searchTextField.text = filter.searchText
        }
        
        if let filter = filter {
            likesOnlySwitch.setOn(filter.onlyShowLikes, animated: false)
        }
        
        if let filter = filter, filter.filteredDogsUUIDs.count >= 1 {
            filterDogsLabel.text = {
                if filter.filteredDogsUUIDs.count == 1, let dogUUID = filter.filteredDogsUUIDs.first {
                    // The user only has one dog selected to filter by
                    return filter.dogManager.findDog(dogUUID: dogUUID)?.dogName ?? Constant.Visual.Text.unknownName
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
            filterLogActionsSectionLabel.text = {
                if filter.filteredLogActionActionTypeIds.count == 1, let logActionTypeId = filter.filteredLogActionActionTypeIds.first {
                    // The user only has one log action selected to filter by
                    return LogActionType.find(logActionTypeId: logActionTypeId).convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
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
            filterLogActionsSectionLabel.text = nil
        }
        
        if let filter = filter, filter.filteredFamilyMemberUserIds.count >= 1 {
            filterFamilyMembersLabel.text = {
                if filter.filteredFamilyMemberUserIds.count == 1, let userId = filter.filteredFamilyMemberUserIds.first {
                    // The user only has one family member selected to filter by
                    return FamilyInformation.findFamilyMember(userId: userId)?.displayFullName ?? Constant.Visual.Text.unknownName
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
            let fromDate = filter.timeRangeFromDate ?? filter.timeRangeToDate ?? noDate
            let toDate = filter.timeRangeToDate ?? filter.timeRangeFromDate ?? noDate
            
            timeRangeFieldLabel.text = filter.timeRangeField.readableValue
            
            fromDatePicker.setDate(fromDate, animated: false)
            toDatePicker.setDate(toDate, animated: false)
            
            fromDateSwitch.setOn(filter.isFromDateEnabled, animated: false)
            fromDatePicker.isEnabled = filter.isFromDateEnabled
            toDateSwitch.setOn(filter.isToDateEnabled, animated: false)
            toDatePicker.isEnabled = filter.isToDateEnabled
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
            case .filterTimeRange: return CGFloat(filter?.availableTimeRangeFields.count ?? 0)
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
        case .filterTimeRange:
            let timeRangeField = filter.availableTimeRangeFields[indexPath.row]
            cell.setCustomSelected(filter.timeRangeField == timeRangeField, animated: false)
            cell.label.text = timeRangeField.readableValue
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
    
    func numberOfRows(section: Int, identifier: any HoundDropDownType) -> Int {
        guard let filter = filter else {
            return 0
        }
        guard let type = identifier as? LogsFilterDropDownTypes else { return 0 }
        switch type {
        case .filterTimeRange:
            return filter.availableTimeRangeFields.count
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
        case .filterTimeRange, .filterDogs, .filterLogActions, .filterFamilyMembers:
            return 1
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let filter = filter else { return }
        guard let type = identifier as? LogsFilterDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type) else { return }
        guard let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        
        switch type {
        case .filterTimeRange:
            let type = filter.availableTimeRangeFields[indexPath.row]
            
            // prevent deselectiong of time range field. we shuld always have one selected
            guard type != filter.timeRangeField else {
                return
            }
            
            cell.setCustomSelected(true)
            filter.apply(timeRangeField: type)
            dropDown.hideDropDown(animated: true)
        case .filterDogs:
            let dogSelected = filter.availableDogs[indexPath.row]
            let beforeSelectNumberOfDogsSelected = filter.availableDogs.count
            if cell.isCustomSelected == true {
                filter.remove(filterDogUUID: dogSelected.dogUUID)
            }
            else {
                filter.add(filterDogUUID: dogSelected.dogUUID)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            if beforeSelectNumberOfDogsSelected == 0 || filter.filteredDogsUUIDs.count == filter.availableDogs.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterLogActions:
            let selectedLogAction = filter.availableLogActions[indexPath.row]
            let beforeSelectNumberOfLogActionsSelected = filter.availableLogActions.count
            if cell.isCustomSelected == true {
                filter.remove(logActionTypeId: selectedLogAction.logActionTypeId)
            }
            else {
                filter.add(logActionTypeId: selectedLogAction.logActionTypeId)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            if beforeSelectNumberOfLogActionsSelected == 0 || filter.filteredLogActionActionTypeIds.count == filter.availableLogActions.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterFamilyMembers:
            let familyMemberSelected = filter.availableFamilyMembers[indexPath.row]
            let beforeSelectNumberOfFamilyMembersSelected = filter.availableFamilyMembers.count
            if cell.isCustomSelected == true {
                filter.remove(userId: familyMemberSelected.userId)
            }
            else {
                filter.add(userId: familyMemberSelected.userId)
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
        case .filterTimeRange:
            if let idx = filter.availableTimeRangeFields
                .firstIndex(where: { $0 == filter.timeRangeField }) {
                return IndexPath(row: idx, section: 0)
            }
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
        containerView.addSubview(pageHeaderView)
        
        containerView.addSubview(timeRangeSectionLabel)
        
        containerView.addSubview(timeRangeFieldHeaderLabel)
        containerView.addSubview(timeRangeFieldLabel)
        
        containerView.addSubview(timeRangeFromHeaderLabel)
        containerView.addSubview(fromDatePicker)
        containerView.addSubview(fromDateSwitch)
        
        containerView.addSubview(timeRangeToHeaderLabel)
        containerView.addSubview(toDatePicker)
        containerView.addSubview(toDateSwitch)
        
        containerView.addSubview(likesOnlySectionLabel)
        containerView.addSubview(likesOnlySwitch)
        
        containerView.addSubview(searchSectionLabel)
        containerView.addSubview(searchTextField)
        
        containerView.addSubview(filterDogsLabel)
        containerView.addSubview(dogsSectionLabel)
        
        containerView.addSubview(filterLogActionsSectionLabel)
        containerView.addSubview(logActionsSectionLabel)
        
        containerView.addSubview(filterFamilyMembersLabel)
        containerView.addSubview(familyMembersSectionLabel)
        
        containerView.addSubview(resetButton)
        containerView.addSubview(applyButton)
        
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderView
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // timeRangeSectionLabel
        NSLayoutConstraint.activate([
            timeRangeSectionLabel.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            timeRangeSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            timeRangeSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // timeRangeFieldHeaderLabel
        NSLayoutConstraint.activate([
            timeRangeFieldHeaderLabel.topAnchor.constraint(equalTo: timeRangeSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeFieldHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeFieldHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // timeRangeFieldLabel
        NSLayoutConstraint.activate([
            timeRangeFieldLabel.topAnchor.constraint(equalTo: timeRangeFieldHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeFieldLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeFieldLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeFieldLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            timeRangeFieldLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight)
        ])
        
        // timeRangeFromHeaderLabel
        NSLayoutConstraint.activate([
            timeRangeFromHeaderLabel.topAnchor.constraint(equalTo: timeRangeFieldLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeFromHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeFromHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // fromDatePicker
        NSLayoutConstraint.activate([
            fromDatePicker.topAnchor.constraint(equalTo: timeRangeFromHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            fromDatePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            fromDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: fromDateSwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            fromDatePicker.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            fromDatePicker.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            fromDatePicker.createAspectRatio(2.75 * 2)
        ])
        
        // fromDateSwitch
        NSLayoutConstraint.activate([
            fromDateSwitch.centerYAnchor.constraint(equalTo: fromDatePicker.centerYAnchor),
            fromDateSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // timeRangeToHeaderLabel
        NSLayoutConstraint.activate([
            timeRangeToHeaderLabel.topAnchor.constraint(equalTo: fromDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeRangeToHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeRangeToHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // toDatePicker
        NSLayoutConstraint.activate([
            toDatePicker.topAnchor.constraint(equalTo: timeRangeToHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            toDatePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            toDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: toDateSwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            toDatePicker.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            toDatePicker.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            toDatePicker.createAspectRatio(2.75 * 2)
        ])
        
        // toDateSwitch
        NSLayoutConstraint.activate([
            toDateSwitch.centerYAnchor.constraint(equalTo: toDatePicker.centerYAnchor),
            toDateSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // likesOnlySectionLabel
        NSLayoutConstraint.activate([
            likesOnlySectionLabel.topAnchor.constraint(equalTo: toDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            likesOnlySectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            likesOnlySectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: likesOnlySwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            likesOnlySectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view),
            likesOnlySectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight)
        ])
        
        // likesOnlySwitch
        NSLayoutConstraint.activate([
            likesOnlySwitch.centerYAnchor.constraint(equalTo: likesOnlySectionLabel.centerYAnchor),
            likesOnlySwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // searchSectionLabel
        NSLayoutConstraint.activate([
            searchSectionLabel.topAnchor.constraint(equalTo: likesOnlySectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            searchSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            searchSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            searchSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view),
            searchSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight)
        ])
        
        // searchTextField
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: searchSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            searchTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            searchTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            searchTextField.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            searchTextField.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight)
        ])
        
        // dogsSectionLabel
        NSLayoutConstraint.activate([
            dogsSectionLabel.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            dogsSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            dogsSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            dogsSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            dogsSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // filterDogsLabel
        NSLayoutConstraint.activate([
            filterDogsLabel.topAnchor.constraint(equalTo: dogsSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            filterDogsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            filterDogsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            filterDogsLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight),
            filterDogsLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view)
        ])
        
        // logActionsSectionLabel
        NSLayoutConstraint.activate([
            logActionsSectionLabel.topAnchor.constraint(equalTo: filterDogsLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            logActionsSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            logActionsSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            logActionsSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            logActionsSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
        ])
        
        // filterLogActionsSectionLabel
        NSLayoutConstraint.activate([
            filterLogActionsSectionLabel.topAnchor.constraint(equalTo: logActionsSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            filterLogActionsSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            filterLogActionsSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            filterLogActionsSectionLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight),
            filterLogActionsSectionLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view)
            
        ])
        
        // familyMembersSectionLabel
        NSLayoutConstraint.activate([
            familyMembersSectionLabel.topAnchor.constraint(equalTo: filterLogActionsSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            familyMembersSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            familyMembersSectionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            familyMembersSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            familyMembersSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view)
            
        ])
        
        // filterFamilyMembersLabel
        NSLayoutConstraint.activate([
            filterFamilyMembersLabel.topAnchor.constraint(equalTo: familyMembersSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
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
        
        // resetButton
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: applyButton.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            resetButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset * 2.0),
            resetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            resetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            resetButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            resetButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
    }
    
}
