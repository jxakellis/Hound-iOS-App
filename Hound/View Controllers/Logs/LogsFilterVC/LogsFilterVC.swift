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
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    /// We use this padding so that the content inside the scroll view is >= the size of the safe area. If it is not, then the drop down menus will clip outside the content area, displaying on the lower half of the region but being un-interactable because they are outside the containerView
    @IBOutlet private weak var containerViewPaddingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dogsLabel: GeneralUILabel!
    @IBOutlet private weak var dogsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogsLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterDogsLabel: GeneralUILabel!
    @IBOutlet private weak var filterDogsHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterDogsBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionsLabel: GeneralUILabel!
    @IBOutlet private weak var logActionsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logActionsLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterLogActionsLabel: GeneralUILabel!
    @IBOutlet private weak var filterLogActionsHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterLogActionsBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var familyMembersLabel: GeneralUILabel!
    @IBOutlet private weak var familyMembersLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var familyMembersLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterFamilyMembersLabel: GeneralUILabel!
    @IBOutlet private weak var filterFamilyMembersHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var filterFamilyMembersBottomConstraint: NSLayoutConstraint!
    
    // appleFilterButton and clearFilterButton both are set to dismiss the view when tapped. Additionally, when the view will disappear, the filter's current state is sent through the delegate. Therefore, we don't need to do any additional logic (other than clearing the filter for the clear button).
    
    @IBAction private func didTapClearFilter(_ sender: Any) {
        filter?.clearAll()
    }
    
    // MARK: - Properties
    
    weak var delegate: LogsFilterDelegate!
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
        let containerViewHeightWithoutPadding = self.containerView.frame.height - self.containerViewPaddingHeightConstraint.constant
        // By how much the container view without padding is smaller than the safe area of the view
        let shortFallOfSafeArea = self.view.safeAreaLayoutGuide.layoutFrame.height - containerViewHeightWithoutPadding
        // If the containerView itself doesn't use up the whole safe area, then we add extra padding so it does
        self.containerViewPaddingHeightConstraint.constant = shortFallOfSafeArea > 0.0 ? shortFallOfSafeArea : 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let filter = filter else {
            return
        }
        
        delegate.didUpdateLogsFilter(forLogsFilter: filter)
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: LogsFilterDelegate, forFilter: LogsFilter) {
        delegate = forDelegate
        filter = forFilter
    }
    
    private func updateDynamicUIElements() {
        let isShowingFilterDogs = (filter?.availableDogs.count ?? 0) > 1
        if isShowingFilterDogs == false {
            // If there is only one availabe dog to filter by, then hide these fields. There is no point in showing them as filtering by 1 element does nothing
            dogsLabel.isHidden = true
            dogsLabelHeightConstraint.constant = 0.0
            dogsLabelBottomConstraint.constant = 0.0
            filterDogsLabel.isHidden = true
            filterDogsHeightConstraint.constant = 0.0
            filterDogsBottomConstraint.constant = 0.0
        }
        
        let isShowingFilterLogActions = (filter?.availableLogActions.count ?? 0) > 1
        if isShowingFilterLogActions == false {
            // If there is only one availabe log action to filter by, then hide these fields. There is no point in showing them as filtering by 1 element does nothing
            logActionsLabel.isHidden = true
            logActionsLabelHeightConstraint.constant = 0.0
            logActionsLabelBottomConstraint.constant = 0.0
            filterLogActionsLabel.isHidden = true
            filterLogActionsHeightConstraint.constant = 0.0
            filterLogActionsBottomConstraint.constant = 0.0
        }
        
        let isShowingFilterFamilyMembers = (filter?.availableFamilyMembers.count ?? 0) > 1
        if isShowingFilterFamilyMembers == false {
            // If there is only one availabe family member to filter by, then hide these fields. There is no point in showing them as filtering by 1 element does nothing
            familyMembersLabel.isHidden = true
            familyMembersLabelHeightConstraint.constant = 0.0
            familyMembersLabelBottomConstraint.constant = 0.0
            filterFamilyMembersLabel.isHidden = true
            filterFamilyMembersHeightConstraint.constant = 0.0
            filterFamilyMembersBottomConstraint.constant = 0.0
        }
        
        // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
        if let filterDogsLabel = filterDogsLabel {
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
            
        }
        if let filterLogActionsLabel = filterLogActionsLabel {
            if let filter = filter, filter.filterLogActions.count >= 1 {
                filterLogActionsLabel.text = {
                    if filter.filterLogActions.count == 1, let lastRemainingLogAction = filter.filterLogActions.first {
                        // The user only has one log action selected to filter by
                        return lastRemainingLogAction.fullReadableName(logCustomActionName: nil, includeMatchingEmoji: true)
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
        }
        if let filterFamilyMembersLabel = filterFamilyMembersLabel {
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
                    forDropDownUIViewIdentifier: dropDownType.rawValue,
                    forCellReusableIdentifier: "DropDownCell",
                    forDataSource: self,
                    forNibName: "DropDownTableViewCell",
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
        guard let filter = filter, let customCell = cell as? DropDownTableViewCell else {
            return
        }
        
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            let dog = filter.availableDogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filterDogs.contains(where: {$0.dogUUID == dog.dogUUID}))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            let logAction = filter.availableLogActions[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: filter.filterLogActions.contains(where: {$0 == logAction}))
            customCell.label.text = logAction.fullReadableName(logCustomActionName: nil, includeMatchingEmoji: true)
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
        
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue, let selectedCell = dropDownFilterDogs?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
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
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue, let selectedCell = dropDownFilterLogActions?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
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
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterFamilyMembers.rawValue, let selectedCell = dropDownFilterFamilyMembers?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
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
}
