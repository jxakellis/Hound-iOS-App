//
//  LogsFilterViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsFilterDelegate: AnyObject {
    func didUpdateLogsFilter(forLogsFilter: LogsFilter)
}

class LogsFilterViewController: GeneralUIViewController, DropDownUIViewDataSource {
    
    // MARK: - Elements
    
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// We use this padding so that the content inside the scroll view is ≥ the size of the safe area.
    /// If it is not, then the drop down menus will clip outside the content area, displaying on the lower half
    /// of the region but being un-interactable because they are outside the containerView.
    private weak var containerViewExtraPaddingHeightConstraint: NSLayoutConstraint!
    private let containerViewExtraPadding: GeneralUIView = {
        let view = GeneralUIView()
        view.isHidden = true
        return view
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Filter"
        label.font = .systemFont(ofSize: 32.5, weight: .bold)
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.shouldRoundCorners = true
        button.backgroundCircleTintColor = .systemBackground
        
        button.shouldDismissParentViewController = true
        return button
    }()
    
    
    private weak var dogsLabelHeightMultiplier: NSLayoutConstraint!
    private weak var dogsLabelBottomConstraint: NSLayoutConstraint!
    /// We use this padding so that the content inside the scroll view is >= the size of the safe area. If it is not, then the drop down menus will clip outside the content area, displaying on the lower half of the region but being un-interactable because they are outside the containerView
    
    private let dogsLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Dogs"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private weak var filterDogsHeightMultiplier: NSLayoutConstraint!
    private weak var filterDogsBottomConstraint: NSLayoutConstraint!
    private let filterDogsLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = .systemFont(ofSize: 17.5)
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        label.shouldRoundCorners = true
        return label
    }()
    
    private weak var logActionsLabelHeightMultiplier: NSLayoutConstraint!
    private weak var logActionsLabelBottomConstraint: NSLayoutConstraint!
    private let logActionsLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Actions"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private weak var filterLogActionsHeightMultiplier: NSLayoutConstraint!
    private weak var filterLogActionsBottomConstraint: NSLayoutConstraint!
    private let filterLogActionsLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.font = .systemFont(ofSize: 17.5)
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        label.shouldRoundCorners = true
        return label
    }()
    
    private weak var familyMembersLabelHeightMultiplier: NSLayoutConstraint!
    private weak var familyMembersLabelBottomConstraint: NSLayoutConstraint!
    private let familyMembersLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Family Members"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private weak var filterFamilyMembersHeightMultiplier: NSLayoutConstraint!
    private weak var filterFamilyMembersBottomConstraint: NSLayoutConstraint!
    private let filterFamilyMembersLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 240, compressionResistancePriority: 240)
        label.font = .systemFont(ofSize: 17.5)
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        label.shouldRoundCorners = true
        return label
    }()
    
    
    private let alignmentViewForClearButton: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 220, compressionResistancePriority: 220)
        view.isHidden = true
        return view
    }()
    
    private let clearButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 220, compressionResistancePriority: 220)
        
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        return button
    }()
    
    private let applyButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBlue
        
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        return button
    }()
    
    // appleFilterButton and clearFilterButton both are set to dismiss the view when tapped. Additionally, when the view will disappear, the filter's current state is sent through the delegate. Therefore, we don't need to do any additional logic (other than clearing the filter for the clear button).
    
    @objc private func didTapClearFilter(_ sender: Any) {
        filter?.clearAll()
    }
    
    // MARK: - Properties
    
    private weak var delegate: LogsFilterDelegate?
    private lazy var uiDelegate = LogsFilterUIInteractionDelegate()
    
    private var dropDownFilterDogs: DropDownUIView?
    private var dropDownFilterLogActions: DropDownUIView?
    private var dropDownFilterFamilyMembers: DropDownUIView?
    private var filter: LogsFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        filterDogsLabel.placeholder = "Select a dog (or dogs)..."
        filterLogActionsLabel.placeholder = "Select an action (or actions)..."
        filterFamilyMembersLabel.placeholder = "Select a family member (or members)..."
        
        updateDynamicUIElements()
        
        // MARK: Gestures
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
        
        let filterDogsLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterDogsLabelGesture.name = LogsFilterDropDownTypes.filterDogs.rawValue
        filterDogsLabelGesture.delegate = uiDelegate
        filterDogsLabelGesture.cancelsTouchesInView = false
        filterDogsLabel.isUserInteractionEnabled = true
        filterDogsLabel.addGestureRecognizer(filterDogsLabelGesture)
        
        let filterLogActionsLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterLogActionsLabelGesture.name = LogsFilterDropDownTypes.filterLogActions.rawValue
        filterLogActionsLabelGesture.delegate = uiDelegate
        filterLogActionsLabelGesture.cancelsTouchesInView = false
        filterLogActionsLabel.isUserInteractionEnabled = true
        filterLogActionsLabel.addGestureRecognizer(filterLogActionsLabelGesture)
        
        let filterFamilyMembersLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterFamilyMembersLabelGesture.name = LogsFilterDropDownTypes.filterFamilyMembers.rawValue
        filterFamilyMembersLabelGesture.delegate = uiDelegate
        filterFamilyMembersLabelGesture.cancelsTouchesInView = false
        filterFamilyMembersLabel.isUserInteractionEnabled = true
        filterFamilyMembersLabel.addGestureRecognizer(filterFamilyMembersLabelGesture)
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        // We have to perform these calculations after the view recalculation finishes. Otherwise they will be inaccurate as the new constraint changes havent taken effect.
        // The actual size of the container view without the padding added
        let containerViewHeightWithoutPadding = self.containerView.frame.height - self.containerViewExtraPaddingHeightConstraint.constant
        // By how much the container view without padding is smaller than the safe area of the view
        let shortFallOfSafeArea = self.view.safeAreaLayoutGuide.layoutFrame.height - containerViewHeightWithoutPadding
        // If the containerView itself doesn't use up the whole safe area, then we add extra padding so it does
        self.containerViewExtraPaddingHeightConstraint.constant = max(shortFallOfSafeArea, 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let filter = filter else {
            return
        }
        
        delegate?.didUpdateLogsFilter(forLogsFilter: filter)
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: LogsFilterDelegate, forFilter: LogsFilter) {
        delegate = forDelegate
        filter = forFilter
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        print("updateDynamicUIElements", filter)
        
        if let filter = filter, filter.filterDogs.count >= 1 {
            filterDogsLabel.text = {
                if filter.filterDogs.count == 1, let lastRemainingDog = filter.filterDogs.first {
                    // The user only has one dog selected to filter by
                    return lastRemainingDog.dogName
                }
                else if filter.filterDogs.count > 1 && filter.filterDogs.count < filter.availableDogs.count {
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
        if let filter = filter, filter.filterLogActions.count >= 1 {
            filterLogActionsLabel.text = {
                if filter.filterLogActions.count == 1, let lastRemainingLogAction = filter.filterLogActions.first {
                    // The user only has one log action selected to filter by
                    return lastRemainingLogAction.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
                }
                else if filter.filterLogActions.count > 1 && filter.filterLogActions.count < filter.availableLogActions.count {
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
        if let filter = filter, filter.filterFamilyMembers.count >= 1 {
            filterFamilyMembersLabel.text = {
                if filter.filterFamilyMembers.count == 1, let lastRemainingFamilyMember = filter.filterFamilyMembers.first {
                    // The user only has one family member selected to filter by
                    return lastRemainingFamilyMember.displayFullName ?? VisualConstant.TextConstant.unknownName
                }
                else if filter.filterFamilyMembers.count > 1 && filter.filterFamilyMembers.count < filter.availableFamilyMembers.count {
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
    
    // MARK: Drop Down
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else {
            return
        }
        
        let originalTouchPoint = sender.location(in: senderView)
        
        guard let deepestTouchedView = senderView.hitTest(originalTouchPoint, with: nil) else {
            return
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
        guard let name = sender.name, let targetDropDownType = LogsFilterDropDownTypes(rawValue: name) else {
            return
        }
        
        let targetDropDown = dropDown(forDropDownType: targetDropDownType)
        
        if (targetDropDown?.isDown ?? false) == false {
            showDropDown(targetDropDownType, animated: true)
        }
        else {
            targetDropDown?.hideDropDown(animated: true)
        }
    }
    
    /// For a given LogsFilterDropDownTypes, return the corresponding dropDown object
    private func dropDown(forDropDownType: LogsFilterDropDownTypes) -> DropDownUIView? {
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
    private func labelForDropDown(forDropDownType: LogsFilterDropDownTypes) -> GeneralUILabel {
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
            targetDropDown = DropDownUIView()
            if let targetDropDown = targetDropDown {
                targetDropDown.setupDropDown(
                    forDropDownUIViewIdentifier: "DROP_DOWN",
                    forDataSource: self,
                    forViewPositionReference: labelForTargetDropDown.frame,
                    forOffset: 2.5,
                    forRowHeight: DropDownUIView.rowHeightForGeneralUILabel
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
                let dropDownsOrderedByPriority: [DropDownUIView?] = {
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
        guard let filter = filter, let customCell = cell as? DropDownTVC else {
            return
        }
        
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            let dog = filter.availableDogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filterDogs.contains(where: {$0.dogUUID == dog.dogUUID}))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            let logActionType = filter.availableLogActions[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filterLogActions.contains(where: {$0 == logActionType}))
            customCell.label.text = logActionType.convertToReadableName(customActionName: nil, includeMatchingEmoji: true)
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue {
            let familyMember = filter.availableFamilyMembers[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filterFamilyMembers.contains(where: {$0.userId == familyMember.userId}))
            customCell.label.text = familyMember.displayFullName ?? VisualConstant.TextConstant.unknownName
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
        guard let filter = filter else {
            return
        }
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue, let selectedCell = dropDownFilterDogs?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            let dogSelected = filter.availableDogs[indexPath.row]
            let beforeSelectNumberOfDogsSelected = filter.availableDogs.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a dog, remove it from our array
                filter.apply(forFilterDogs: filter.filterDogs.filter { filterDog in
                    return filterDog.dogUUID != dogSelected.dogUUID
                })
            }
            else {
                // The user has selected a parent dog, add it to our array
                filter.apply(forFilterDogs: filter.filterDogs + [dogSelected])
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfDogsSelected == 0 {
                // If initially, there were no dogs selected, then the user selected their first dog, we immediately hide this drop down. We assume they only want to filter by one dog, though they could do more
                dropDownFilterDogs?.hideDropDown(animated: true)
            }
            else if filter.filterDogs.count == filter.availableDogs.count {
                // selected every dog in the drop down, close the drop down
                dropDownFilterDogs?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue, let selectedCell = dropDownFilterLogActions?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            let logActionSelected = filter.availableLogActions[indexPath.row]
            let beforeSelectNumberOfLogActionsSelected = filter.availableLogActions.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a log action, remove it from our array
                filter.apply(forFilterLogActions: filter.filterLogActions.filter { filterLogAction in
                    return filterLogAction != logActionSelected
                })
            }
            else {
                // The user has selected a log action, add it to our array
                filter.apply(forFilterLogActions: filter.filterLogActions + [logActionSelected])
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfLogActionsSelected == 0 {
                // If initially, there were no log actions selected, then the user selected their first log action, we immediately hide this drop down. We assume they only want to filter by one log action, though they could do more
                dropDownFilterLogActions?.hideDropDown(animated: true)
            }
            else if filter.filterLogActions.count == filter.availableLogActions.count {
                // selected every log action in the drop down, close the drop down
                dropDownFilterLogActions?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue, let selectedCell = dropDownFilterFamilyMembers?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
            let familyMemberSelected = filter.availableFamilyMembers[indexPath.row]
            let beforeSelectNumberOfFamilyMembersSelected = filter.availableFamilyMembers.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a family member, remove it from our array
                filter.apply(forFilterFamilyMembers: filter.filterFamilyMembers.filter { filterFamilyMember in
                    return filterFamilyMember.userId != familyMemberSelected.userId
                })
            }
            else {
                // The user has selected a family member, add it to our array
                filter.apply(forFilterFamilyMembers: filter.filterFamilyMembers + [familyMemberSelected])
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfFamilyMembersSelected == 0 {
                // If initially, there were no family members selected, then the user selected their first family member, we immediately hide this drop down. We assume they only want to filter by one family member, though they could do more
                dropDownFilterFamilyMembers?.hideDropDown(animated: true)
            }
            else if filter.filterFamilyMembers.count == filter.availableFamilyMembers.count {
                // selected every family member in the drop down, close the drop down
                dropDownFilterFamilyMembers?.hideDropDown(animated: true)
            }
        }
        
        // Once the selection update is done, then update the UI
        updateDynamicUIElements()
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(headerLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(filterDogsLabel)
        containerView.addSubview(dogsLabel)
        containerView.addSubview(filterLogActionsLabel)
        containerView.addSubview(logActionsLabel)
        containerView.addSubview(filterFamilyMembersLabel)
        containerView.addSubview(familyMembersLabel)
        containerView.addSubview(alignmentViewForClearButton)
        containerView.addSubview(clearButton)
        containerView.addSubview(applyButton)
        containerView.addSubview(containerViewExtraPadding)
        
        clearButton.addTarget(self, action: #selector(didTapClearFilter), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // headerLabel
        let headerLabelHeightMultiplier = headerLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Header.labelHeightMultipler
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Global.contentInset),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            headerLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Header.labelMaxHeight),
            headerLabelHeightMultiplier
        ])

        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Button.miniCircleInset),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Button.miniCircleInset),
            backButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier).withPriority(.defaultHigh),
            backButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareConstraint()
        ])

        // dogsLabel
        dogsLabelHeightMultiplier = dogsLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.sectionTitleHeightMultipler
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            dogsLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            dogsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            dogsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            dogsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.sectionTitleMaxHeight),
            dogsLabelHeightMultiplier
        ])
        dogsLabelBottomConstraint = filterDogsLabel.topAnchor.constraint(equalTo: dogsLabel.bottomAnchor, constant: ConstraintConstant.Input.intraSectionVerticalSpacing)
        dogsLabelBottomConstraint.isActive = true

        // Dogs Input Label
        filterDogsHeightMultiplier = filterDogsLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.heightMultiplier
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            filterDogsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            filterDogsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            filterDogsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.maxHeight),
            filterDogsHeightMultiplier
        ])
        filterDogsBottomConstraint = logActionsLabel.topAnchor.constraint(equalTo: filterDogsLabel.bottomAnchor, constant: ConstraintConstant.Input.interSectionVerticalSpacing)
        filterDogsBottomConstraint.isActive = true

        // logActionsLabel
        logActionsLabelHeightMultiplier = logActionsLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.sectionTitleHeightMultipler
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            logActionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            logActionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            logActionsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.sectionTitleMaxHeight),
            logActionsLabelHeightMultiplier
        ])
        logActionsLabelBottomConstraint = filterLogActionsLabel.topAnchor.constraint(equalTo: logActionsLabel.bottomAnchor, constant: ConstraintConstant.Input.intraSectionVerticalSpacing)
        logActionsLabelBottomConstraint.isActive = true

        // filterLogActionsLabel
        filterLogActionsHeightMultiplier = filterLogActionsLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.heightMultiplier
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            filterLogActionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            filterLogActionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            filterLogActionsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.maxHeight),
            filterLogActionsHeightMultiplier
        ])
        filterLogActionsBottomConstraint = familyMembersLabel.topAnchor.constraint(equalTo: filterLogActionsLabel.bottomAnchor, constant: ConstraintConstant.Input.interSectionVerticalSpacing)
        filterLogActionsBottomConstraint.isActive = true

        // familyMembersLabel
        familyMembersLabelHeightMultiplier = familyMembersLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.sectionTitleHeightMultipler
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            familyMembersLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            familyMembersLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            familyMembersLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.sectionTitleMaxHeight),
            familyMembersLabelHeightMultiplier
        ])
        familyMembersLabelBottomConstraint = filterFamilyMembersLabel.topAnchor.constraint(equalTo: familyMembersLabel.bottomAnchor, constant: ConstraintConstant.Input.intraSectionVerticalSpacing)
        familyMembersLabelBottomConstraint.isActive = true

        // filterFamilyMembersLabel
        filterFamilyMembersHeightMultiplier = filterFamilyMembersLabel.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ConstraintConstant.Input.heightMultiplier
        ).withPriority(.defaultHigh)
        NSLayoutConstraint.activate([
            filterFamilyMembersLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            filterFamilyMembersLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            filterFamilyMembersLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Input.maxHeight),
            filterFamilyMembersHeightMultiplier
        ])
        filterFamilyMembersBottomConstraint = applyButton.topAnchor.constraint(equalTo: filterFamilyMembersLabel.bottomAnchor, constant: ConstraintConstant.Input.interSectionVerticalSpacing)
        filterFamilyMembersBottomConstraint.isActive = true

        // applyButton
        NSLayoutConstraint.activate([
            applyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            applyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            applyButton.heightAnchor.constraint(equalTo: applyButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            applyButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.screenWideMaxHeight),
            applyButton.topAnchor.constraint(equalTo: filterFamilyMembersLabel.bottomAnchor, constant: ConstraintConstant.Input.interSectionVerticalSpacing)
        ])

        // clearButton
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: applyButton.bottomAnchor, constant: ConstraintConstant.Input.interSectionVerticalSpacing),
            clearButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentInset),
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset),
            clearButton.heightAnchor.constraint(equalTo: applyButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            clearButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.screenWideMaxHeight)
        ])

        // containerViewExtraPadding
        containerViewExtraPaddingHeightConstraint = containerViewExtraPadding.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            containerViewExtraPadding.topAnchor.constraint(equalTo: clearButton.bottomAnchor),
            containerViewExtraPadding.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerViewExtraPadding.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerViewExtraPadding.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerViewExtraPaddingHeightConstraint
        ])
    }

}
