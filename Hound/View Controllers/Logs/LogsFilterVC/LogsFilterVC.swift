//
//  LogsFilterViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsFilterDelegate: AnyObject {
    func placeholder()
}

class LogsFilterViewController: GeneralUIViewController, DropDownUIViewDataSource {
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    /// We use this padding so that the content inside the scroll view is >= the size of the safe area. If it is not, then the drop down menus will clip outside the content area, displaying on the lower half of the region but being un-interactable because they are outside the containerView
    @IBOutlet private weak var containerViewPaddingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var filterDogsLabel: GeneralUILabel!
    
    @IBOutlet private weak var filterLogActionsLabel: GeneralUILabel!
    
    @IBOutlet private weak var filterFamilyMembersLabel: GeneralUILabel!
    
    // MARK: - Properties
    
    weak var delegate: LogsFilterDelegate!
    private lazy var uiDelegate = LogsFilterUIInteractionDelegate()
    
    private var dogManager: DogManager?
    
    private var dropDownFilterDogs: DropDownUIView?
    private var dogIdsSelected: [Int] = [] {
        didSet {
            // UI Element could potentially not be loaded in yet, therefore check explict ! anyways to see if its defined
            if let filterDogsLabel = filterDogsLabel {
                filterDogsLabel.text = {
                    guard let dogManager = dogManager, dogIdsSelected.count >= 1 else {
                        // The user has no dogs selected to filter by, so we interpret this as including all dogs in the filter
                        return "All"
                    }
                    
                    // dogSelected is the dog tapped and now that dog is removed, we need to find the name of the remaining dog
                    if dogIdsSelected.count == 1, let lastRemainingDogId = dogIdsSelected.first, let lastRemainingDog = dogManager.dogs.first(where: { dog in
                        return dog.dogId == lastRemainingDogId
                    }) {
                        // The user only has one dog selected to filter by
                        return lastRemainingDog.dogName
                    }
                    else if dogIdsSelected.count > 1 && dogIdsSelected.count < dogManager.dogs.count {
                        // The user has multiple, but not all, dogs selected to filter by
                        return "Multiple"
                    }
                    
                    // The user has all dogs selected to filter by
                    return "All"
                }()
            }
        }
    }
    
    private var dropDownFilterLogActions: DropDownUIView?
    private var logActionsSelected: [LogAction] = [] {
        didSet {
            
        }
    }
    
    private var dropDownFilterFamilyMembers: DropDownUIView?
    private var familyMemberUserIdsSelected: [String] = [] {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // TODO NOW set selected array equal to passed thru logs filter
        
        // set forDogIdsSelected = [] to invoke didSet
        dogIdsSelected = []
        logActionsSelected = []
        familyMemberUserIdsSelected = []
        
        guard let dogManager = dogManager else {
            return
        }
        
        // MARK: Gestures
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = uiDelegate
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
        
        let filterDogsLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterDogsLabelGesture.name = LogsFilterDropDownTypes.filterDogs.rawValue
        filterDogsLabelGesture.delegate = uiDelegate
        filterDogsLabelGesture.cancelsTouchesInView = false
        filterDogsLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
        filterDogsLabel.addGestureRecognizer(filterDogsLabelGesture)
        
        let filterLogActionsLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterLogActionsLabelGesture.name = LogsFilterDropDownTypes.filterLogActions.rawValue
        filterLogActionsLabelGesture.delegate = uiDelegate
        filterLogActionsLabelGesture.cancelsTouchesInView = false
        filterLogActionsLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
        filterLogActionsLabel.addGestureRecognizer(filterLogActionsLabelGesture)
        
        let filterFamilyMembersLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabelForDropDown(sender:)))
        filterFamilyMembersLabelGesture.name = LogsFilterDropDownTypes.filterFamilyMembers.rawValue
        filterFamilyMembersLabelGesture.delegate = uiDelegate
        filterFamilyMembersLabelGesture.cancelsTouchesInView = false
        filterFamilyMembersLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
        filterFamilyMembersLabel.addGestureRecognizer(filterFamilyMembersLabelGesture)
        
    }
    
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // LogsFilterViewController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
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
    
    // MARK: - Functions
    
    func setup(forDelegate: LogsFilterDelegate, forDogManager: DogManager) {
        delegate = forDelegate
        dogManager = forDogManager
        // TODO NOW allow pass thru of existing filter
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
                // TODO NOW once we can actually calculate these, put them in
                switch dropDownType {
                case .filterDogs:
                    return 1.5
                case .filterLogActions:
                    return 1.5
                case .filterFamilyMembers:
                    return 1.5
                }
            }()),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? DropDownTableViewCell else {
            return
        }
        
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
        // TODO NOW once we can actually calcualte the dogs/logactions/family members present in all of the user's logs, do logic below
        
        /*
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterDogs.rawValue {
            guard let dogManager = dogManager else {
                return
            }
            
            let dog = dogManager.dogs[indexPath.row]
            
            customCell.setCustomSelectedTableViewCell(forSelected: dogIdsSelected.contains(dog.dogId))
            customCell.label.text = dog.dogName
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.filterLogActions.rawValue {
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                customCell.label.text = LogAction.allCases[indexPath.row].displayActionName(logCustomActionName: nil)
                
                if let logActionSelected = logActionSelected {
                    // if the user has a logActionSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: LogAction.allCases.firstIndex(of: logActionSelected) == indexPath.row)
                }
            }
            // a user generated custom name
            else {
                customCell.label.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
                )
                
                customCell.setCustomSelectedTableViewCell(forSelected: false)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logUnit.rawValue {
            guard let logActionSelected = logActionSelected else {
                return
            }
            
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            
            let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
            
            if indexPath.row < logUnits.count {
                // inside of the predefined available LogUnits
                let logUnit = logUnits[indexPath.row]
                
                customCell.label.text = logUnit.adjustedPluralityString(
                    forLogNumberOfLogUnits: LogUnit.fromRoundedString(forLogNumberOfLogUnits: logNumberOfLogUnitsTextField.text) ?? 0.0
                )
                
                if let logUnitSelected = logUnitSelected {
                    // if the user has a logUnitSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.setCustomSelectedTableViewCell(
                        forSelected: logUnitSelected == logUnit)
                }
                
            }
        }
        */
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        // TODO NOW once we can actually calcualte the dogs/logactions/family members present in all of the user's logs, do logic below
        
        return 0
        /*
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.parentDog.rawValue {
            guard let dogManager = dogManager else {
                return 0
            }
            
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logAction.rawValue {
            return LogAction.allCases.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logUnit.rawValue {
            guard let logActionSelected = logActionSelected else {
                return 0
            }
            
            return LogUnit.logUnits(forLogAction: logActionSelected).count
        }
        */
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
        // TODO NOW once we can actually calcualte the dogs/logactions/family members present in all of the user's logs, do logic below
        
        /*
        if dropDownUIViewIdentifier == LogsFilterDropDownTypes.parentDog.rawValue, let selectedCell = dropDownFilterDogs?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            guard let dogManager = dogManager else {
                return
            }
            
            let dogSelected = dogManager.dogs[indexPath.row]
            let beforeSelectNumberOfDogIdsSelected = forDogIdsSelected.count
            
            if selectedCell.isCustomSelected == true {
                // The user has unselected a parent dog, remove it from our array
                forDogIdsSelected.removeAll { dogId in
                    dogId == dogSelected.dogId
                }
            }
            else {
                // The user has selected a parent dog, add it to our array
                forDogIdsSelected.append(dogSelected.dogId)
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
            
            if beforeSelectNumberOfDogIdsSelected == 0 {
                // If initially, there were no dogs selected, then the user selected their first dog, we immediately hide this drop down then open the log action drop down. Allowing them to seemlessly choose the log action next
                dropDownFilterDogs?.hideDropDown(animated: true)
                showDropDown(.logAction, animated: true)
            }
            else if forDogIdsSelected.count == dogManager.dogs.count {
                // selected every dog in the drop down, close the drop down
                dropDownFilterDogs?.hideDropDown(animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logAction.rawValue, let selectedCell = dropDownFilterLogActions?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            let beforeSelectLogActionSelected = logActionSelected
            
            guard selectedCell.isCustomSelected == false else {
                // The selected cell was already selected, and the user unselected it
                selectedCell.setCustomSelectedTableViewCell(forSelected: false)
                logActionSelected = nil
                // Don't hideDropDownLogAction() because user needs to select a log action for log to be valid
                return
            }
            
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                logActionSelected = LogAction.allCases[indexPath.row]
                
                if logActionSelected == .custom {
                    // If a user selected a blank custom log action, automatically start them to type in the field
                    logCustomActionNameTextField.becomeFirstResponder()
                }
            }
            // a user generated custom name
            else {
                logActionSelected = LogAction.custom
                logCustomActionNameTextField.text = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
            }
            
            // hideDropDownLogAction() because the user selected a log action
            dropDownFilterLogActions?.hideDropDown(animated: true)
            
            if beforeSelectLogActionSelected == nil && logCustomActionNameTextField.isFirstResponder == false {
                // If initially, there were no log actions selected, then the user selected their first log action, we immediately hide this drop down then open the log start date drop down. Allowing them to seemlessly choose the log start date next
                // The only exception is if the user selected a .custom log action (a blank one, not one stored in localPreviousLogCustomActionNames), then we don't show the dropDown because the keyboard is up
                showDropDown(.logStartDate, animated: true)
            }
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logUnit.rawValue, let selectedCell = dropDownLogUnit?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell, let logActionSelected = logActionSelected {
            
            if selectedCell.isCustomSelected {
                selectedCell.setCustomSelectedTableViewCell(forSelected: false)
                logUnitSelected = nil
            }
            else {
                let logUnits = LogUnit.logUnits(forLogAction: logActionSelected)
                selectedCell.setCustomSelectedTableViewCell(forSelected: true)
                logUnitSelected = logUnits[indexPath.row]
            }
            
            // hideDropDownLogUnit() because the user selected/unselected a log unit, either way its ok to hide
            dropDownLogUnit?.hideDropDown(animated: true)
        }
        else if dropDownUIViewIdentifier == LogsFilterDropDownTypes.logStartDate.rawValue, let selectedCell = dropDownLogStartDate?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            // a cell for dropDownLogStartDate should never be able to stay selected.
            // If a user selects a cell, the menu closes. If the user reopens the menu, no cells should be selected. As time quick select is dependent on present. So if a user selects 5 mins ago, then reopens the menu, we can't leave 5 mins ago selected as its now 5 mins and 10 seconds ago.
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
            
            let timeIntervalSelected = TimeQuickSelectOptions.allCases[indexPath.row].convertToTimeInterval()
            
            if let timeIntervalSelected = timeIntervalSelected {
                // Apply the time quick select option
                logStartDateSelected = Date().addingTimeInterval(timeIntervalSelected)
            }
            else {
                isShowingLogStartDatePicker = true
                isShowingLogEndDatePicker = false
            }
            
            dropDownLogStartDate?.hideDropDown(animated: true)
        }
        */
    }
}
