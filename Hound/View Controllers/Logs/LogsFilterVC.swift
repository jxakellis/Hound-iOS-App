//
//  LogsFilterVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

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
                    UITextFieldDelegate,
                    UIAdaptivePresentationControllerDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !didUpdateInitialFilter
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if didUpdateInitialFilter {
            presentUnsavedChangesAlert()
        }
    }
    
    // MARK: - Elements
    
    private lazy var pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.pageHeaderLabel.text = "Filter"
        view.backButton.shouldDismissParentViewController = false
        view.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return view
    }()
    
    private let timeRangeSectionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.text = "Time Range"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var timeRangeFieldLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 335, compressionResistancePriority: 335)
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        label.placeholder = "Select a date to filter by..."
        
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
    
    private lazy var timeRangeFromDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
        picker.addTarget(self, action: #selector(didChangeFromDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private let timeRangeToHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "to"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private lazy var timeRangeToDatePicker: HoundDatePicker = {
        let picker = HoundDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = Constant.Development.minuteInterval
        picker.addTarget(self, action: #selector(didChangeToDate(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var timeRangeDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(timeRangeFromDatePicker)
        stack.addArrangedSubview(timeRangeToHeaderLabel)
        stack.addArrangedSubview(timeRangeToDatePicker)
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    private lazy var timeRangeStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(timeRangeSectionLabel)
        stack.addArrangedSubview(timeRangeFieldLabel)
        stack.addArrangedSubview(timeRangeDateStack)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    private let onlyShowMyLikesSectionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 235, compressionResistancePriority: 235)
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        label.text = "Only Show My Likes"
        return label
    }()
    
    private lazy var onlyShowMyLikesSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 230, compressionResistancePriority: 230)
        uiSwitch.addTarget(self, action: #selector(didToggleOnlyShowMyLikes), for: .valueChanged)
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
        
        button.addTarget(self, action: #selector(didTapApplyFilter), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dropDownManager = HoundDropDownManager<LogsFilterDropDownTypes>(
        rootView: containerView,
        dataSource: self,
        delegate: self
    )
    
    @objc private func didTapBack(_ sender: Any) {
        guard didUpdateInitialFilter else {
            self.dismiss(animated: true)
            return
        }
        presentUnsavedChangesAlert()
    }
    
    @objc private func didChangeFromDate(_ sender: UIDatePicker) {
        guard let filter = filter else { return }
        filter.setTimeRangeFromDate(sender.date)
        // timeRangeFromDate could have overwritten timeRangeToDate, so timeRangeToDate could have been rewritten
        timeRangeToDatePicker.setDate(filter.timeRangeToDate, animated: true)
    }
    
    @objc private func didChangeToDate(_ sender: UIDatePicker) {
        guard let filter = filter else { return }
        filter.setTimeRangeToDate(sender.date)
        // timeRangeToDate could have overwritten timeRangeFromDate, so timeRangeFromDate could have been rewritten
        timeRangeFromDatePicker.setDate(filter.timeRangeFromDate, animated: true)
    }
    
    @objc private func didToggleOnlyShowMyLikes(_ sender: HoundSwitch) {
        filter?.onlyShowMyLikes = sender.isOn
    }
    
    @objc private func didChangeSearchText(_ sender: UITextField) {
        filter?.searchText = sender.text ?? ""
    }
    
    @objc private func didTapResetFilter(_ sender: Any) {
        filter?.reset()
        if let filter = filter {
            delegate?.didUpdateLogsFilter(logsFilter: filter)
        }
        self.dismiss(animated: true)
    }
    
    @objc private func didTapApplyFilter(_ sender: Any) {
        guard let filter = filter else { return }
        
        delegate?.didUpdateLogsFilter(logsFilter: filter)
        self.dismiss(animated: true)
    }
    
    // MARK: - Properties
    
    private weak var delegate: LogsFilterDelegate?
    
    private var filter: LogsFilter?
    private var initialFilter: LogsFilter?
    
    private var didUpdateInitialFilter: Bool {
        guard let filter = filter, let initialFilter = initialFilter else { return false }
        return filter != initialFilter
    }
    
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
        
        self.presentationController?.delegate = self
    }
    
    // MARK: - Setup
    
    func setup(delegate: LogsFilterDelegate, filter: LogsFilter) {
        self.delegate = delegate
        self.filter = (filter.copy() as? LogsFilter) ?? filter
        self.initialFilter = (filter.copy() as? LogsFilter) ?? self.initialFilter
        
        updateTimeRangeField(animated: false)
        
        timeRangeFromDatePicker.setDate(filter.timeRangeFromDate, animated: false)
        timeRangeToDatePicker.setDate(filter.timeRangeToDate, animated: false)
        
        searchTextField.text = filter.searchText
        onlyShowMyLikesSwitch.setOn(filter.onlyShowMyLikes, animated: false)
        
        updateFilterDogText()
        updateFilterLogActionsText()
        updateFilterFamilyMembersText()
    }
    
    // MARK: - Functions
    
    private func updateTimeRangeField(animated: Bool) {
        guard let filter = filter else { return }
        timeRangeFieldLabel.text = filter.timeRangeField?.readableValue
        let isHidden = filter.timeRangeField == nil
        
        guard timeRangeDateStack.isHidden != isHidden else { return }
        timeRangeDateStack.isHidden = isHidden
        remakeTimeRangeDateConstraints()
        
        UIView.animate(withDuration: isHidden ? Constant.Visual.Animation.hideMultipleElements : Constant.Visual.Animation.showMultipleElements) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    private func updateFilterDogText() {
        if let filter = filter, filter.filteredDogsUUIDs.count >= 1 {
            filterDogsLabel.text = {
                if filter.filteredDogsUUIDs.count == 1, let dogUUID = filter.filteredDogsUUIDs.first {
                    // The user only has one dog selected to filter by
                    return filter.dogManagerForDogUUIDs.findDog(dogUUID: dogUUID)?.dogName ?? Constant.Visual.Text.unknownName
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
    }
    private func updateFilterLogActionsText() {
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
    }
    private func updateFilterFamilyMembersText() {
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
            guard !cell.isCustomSelected else {
                cell.setCustomSelected(false)
                filter.timeRangeField = nil
                updateTimeRangeField(animated: true)
                return
            }
            
            if let previouslySelected = filter.timeRangeField, let previouslySelectedIndex = filter.availableTimeRangeFields.firstIndex(of: previouslySelected) {
                let previouslySelectedIndexPath = IndexPath(row: previouslySelectedIndex, section: 0)
                let previousSelectedCell = dropDown.dropDownTableView?.cellForRow(at: previouslySelectedIndexPath) as? HoundDropDownTVC
                previousSelectedCell?.setCustomSelected(false)
            }
            
            cell.setCustomSelected(true)
            
            let type = filter.availableTimeRangeFields[indexPath.row]
            filter.timeRangeField = type
            updateTimeRangeField(animated: true)
            
            dropDown.hideDropDown(animated: true)
        case .filterDogs:
            let dogSelected = filter.availableDogs[indexPath.row]
            let beforeSelectNumberOfDogsSelected = filter.availableDogs.count
            if cell.isCustomSelected == true {
                filter.filteredDogsUUIDs.remove(dogSelected.dogUUID)
            }
            else {
                filter.filteredDogsUUIDs.insert(dogSelected.dogUUID)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            updateFilterDogText()
            
            if beforeSelectNumberOfDogsSelected == 0 || filter.filteredDogsUUIDs.count == filter.availableDogs.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterLogActions:
            let selectedLogAction = filter.availableLogActions[indexPath.row]
            let beforeSelectNumberOfLogActionsSelected = filter.availableLogActions.count
            if cell.isCustomSelected == true {
                filter.filteredLogActionActionTypeIds.remove(selectedLogAction.logActionTypeId)
            }
            else {
                filter.filteredLogActionActionTypeIds.insert(selectedLogAction.logActionTypeId)
            }
            
            cell.setCustomSelected(!cell.isCustomSelected)
            updateFilterLogActionsText()
            
            if beforeSelectNumberOfLogActionsSelected == 0 || filter.filteredLogActionActionTypeIds.count == filter.availableLogActions.count {
                dropDown.hideDropDown(animated: true)
            }
        case .filterFamilyMembers:
            let familyMemberSelected = filter.availableFamilyMembers[indexPath.row]
            let beforeSelectNumberOfFamilyMembersSelected = filter.availableFamilyMembers.count
            if cell.isCustomSelected == true {
                filter.filteredFamilyMemberUserIds.remove(familyMemberSelected.userId)
            }
            else {
                filter.filteredFamilyMemberUserIds.insert(familyMemberSelected.userId)
            }
            cell.setCustomSelected(!cell.isCustomSelected)
            updateFilterFamilyMembersText()
            
            if beforeSelectNumberOfFamilyMembersSelected == 0 || filter.filteredFamilyMemberUserIds.count == filter.availableFamilyMembers.count {
                dropDown.hideDropDown(animated: true)
            }
        }
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
        
        containerView.addSubview(timeRangeStack)
        
        containerView.addSubview(onlyShowMyLikesSectionLabel)
        containerView.addSubview(onlyShowMyLikesSwitch)
        
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
    
    private func remakeTimeRangeDateConstraints() {
        timeRangeFromDatePicker.snp.remakeConstraints { make in
            if !timeRangeDateStack.isHidden && !timeRangeFromDatePicker.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(Constant.Constraint.Input.segmentedHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Input.segmentedMaxHeight)
            }
        }
        
        timeRangeToDatePicker.snp.remakeConstraints { make in
            if !timeRangeDateStack.isHidden && !timeRangeToDatePicker.isHidden {
                make.height.equalTo(view.snp.width).multipliedBy(Constant.Constraint.Input.segmentedHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Input.segmentedMaxHeight)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderView
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        timeRangeStack.snp.makeConstraints { make in
            make.top.equalTo(pageHeaderView.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.trailing.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        timeRangeSectionLabel.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(Constant.Constraint.Text.sectionLabelHeightMultipler).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Text.sectionLabelMaxHeight)
        }
        timeRangeFieldLabel.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        remakeTimeRangeDateConstraints()
        
        // onlyShowMyLikesSectionLabel
        NSLayoutConstraint.activate([
            onlyShowMyLikesSectionLabel.topAnchor.constraint(equalTo: timeRangeStack.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            onlyShowMyLikesSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            onlyShowMyLikesSectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: onlyShowMyLikesSwitch.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            onlyShowMyLikesSectionLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: view),
            onlyShowMyLikesSectionLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight)
        ])
        
        // onlyShowMyLikesSwitch
        NSLayoutConstraint.activate([
            onlyShowMyLikesSwitch.centerYAnchor.constraint(equalTo: onlyShowMyLikesSectionLabel.centerYAnchor),
            onlyShowMyLikesSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // searchSectionLabel
        NSLayoutConstraint.activate([
            searchSectionLabel.topAnchor.constraint(equalTo: onlyShowMyLikesSectionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
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
