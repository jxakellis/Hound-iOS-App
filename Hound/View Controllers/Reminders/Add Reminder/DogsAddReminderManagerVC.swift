//
//  DogsAddReminderManagerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsAddReminderManagerView: HoundView, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsAddReminderCountdownVCDelegate, DogsAddReminderWeeklyVCDelegate, HoundDropDownDataSource, DogsAddReminderMonthlyVCDelegate, DogsAddReminderOneTimeVCDelegate {
    
    // MARK: - DogsAddReminderCountdownVCDelegate and DogsAddReminderWeeklyViewDelegate
    
    func willDismissKeyboard() {
        dismissKeyboard()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // attempt to read the range they are trying to change
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under reminderCustomActionNameCharacterLimit
        return updatedText.count <= ClassConstant.ReminderConstant.reminderCustomActionNameCharacterLimit
    }
    
    // MARK: - Elements
    
    private let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let onceView = DogsAddReminderOneTimeView()
    private let countdownView = DogsAddReminderCountdownView()
    private let weeklyView = DogsAddReminderWeeklyView()
    private let monthlyView = DogsAddReminderMonthlyView()
    
    private let reminderActionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        return label
    }()
    
    private var reminderCustomActionNameHeightMultiplier: GeneralLayoutConstraint!
    private var reminderCustomActionNameMaxHeight: GeneralLayoutConstraint!
    private var reminderCustomActionNameBottom: GeneralLayoutConstraint!
    private let reminderCustomActionNameTextField: HoundTextField = {
        let textField = HoundTextField()
        
        textField.applyStyle(.thinGrayBorder)
        
        return textField
    }()
    
    private let reminderIsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch()
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    private let reminderTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.contentHorizontalAlignment = .left
        segmentedControl.contentVerticalAlignment = .top
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        return segmentedControl
    }()
    
    @objc private func didUpdateReminderType(_ sender: UISegmentedControl) {
        onceView.isHidden = !(sender.selectedSegmentIndex == 0)
        countdownView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyView.isHidden = !(sender.selectedSegmentIndex == 3)
    }
    
    // MARK: - Properties
    
    private var dogsReminderOneTimeView: DogsAddReminderOneTimeView?
    private var dogsAddReminderCountdownView: DogsAddReminderCountdownView?
    private var dogsAddReminderWeeklyView: DogsAddReminderWeeklyView?
    private var dogsAddReminderMonthlyView: DogsAddReminderMonthlyView?
    
    private var reminderToUpdate: Reminder?
    private var initialReminderActionType: ReminderActionType!
    private var initialReminderCustomActionName: String?
    private var initialReminderIsEnabled: Bool!
    private var initialReminderTypeSegmentedControlIndex: Int!
    
    /// Given the reminderToUpdate provided, construct a new reminder or updates the one provided with the settings selected inside this view and its subviews. If there are invalid settings (e.g. no weekdays), an error message is sent to the user and nil is returned. If the reminder is valid, a reminder is returned that is ready to be sent to the server.
    var currentReminder: Reminder? {
        do {
            guard let reminderActionTypeSelected = reminderActionTypeSelected else {
                throw ErrorConstant.ReminderError.reminderActionMissing()
            }
            
            guard let reminder: Reminder = reminderToUpdate != nil ? reminderToUpdate?.copy() as? Reminder : Reminder() else {
                return nil
            }
            
            reminder.reminderActionTypeId = reminderActionTypeSelected.reminderActionTypeId
            
            if reminderActionTypeSelected.allowsCustom {
                // if the trimmedReminderCustomActionName is not "", meaning it has text, then we save it. Otherwise, the trimmedReminderCustomActionName is "" or nil so we save its value as nil
                reminder.reminderCustomActionName = reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
            reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
            
            switch reminderTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                reminder.changeReminderType(forReminderType: .oneTime)
                reminder.oneTimeComponents.oneTimeDate = dogsReminderOneTimeView?.oneTimeDate ?? reminder.oneTimeComponents.oneTimeDate
            case 1:
                reminder.changeReminderType(forReminderType: .countdown)
                reminder.countdownComponents.executionInterval = dogsAddReminderCountdownView?.currentCountdownDuration ?? reminder.countdownComponents.executionInterval
            case 2:
                guard let weekdays = dogsAddReminderWeeklyView?.currentWeekdays else {
                    throw ErrorConstant.WeeklyComponentsError.weekdayArrayInvalid()
                }
                
                reminder.changeReminderType(forReminderType: .weekly)
                
                try reminder.weeklyComponents.changeWeekdays(forWeekdays: weekdays)
                guard let date = dogsAddReminderWeeklyView?.currentTimeOfDay else {
                    break
                }
                reminder.weeklyComponents.changeUTCHour(forDate: date)
                reminder.weeklyComponents.changeUTCMinute(forDate: date)
            case 3:
                reminder.changeReminderType(forReminderType: .monthly)
                guard let date = dogsAddReminderMonthlyView?.currentTimeOfDay else {
                    break
                }
                reminder.monthlyComponents.changeUTCDay(forDate: date)
                reminder.monthlyComponents.changeUTCHour(forDate: date)
                reminder.monthlyComponents.changeUTCMinute(forDate: date)
            default: break
            }
            
            // Check if we are updating a reminder
            guard let reminderToUpdate = reminderToUpdate else {
                // Not updating an existing reminder, therefore created a reminder and prepare it for use
                reminder.resetForNextAlarm()
                return reminder
            }
            
            // Updating an existing reminder
            
            // Checks for differences in time of day, execution interval, weekdays, or time of month. If one is detected then we reset the reminder's whole timing to default
            // If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
            switch reminder.reminderType {
            case .oneTime:
                // execution date changed
                if reminder.oneTimeComponents.oneTimeDate != reminderToUpdate.oneTimeComponents.oneTimeDate {
                    reminder.resetForNextAlarm()
                }
            case .countdown:
                // execution interval changed
                if reminder.countdownComponents.executionInterval != reminderToUpdate.countdownComponents.executionInterval {
                    reminder.resetForNextAlarm()
                }
            case .weekly:
                // time of day or weekdays changed
                if reminder.weeklyComponents.weekdays != reminderToUpdate.weeklyComponents.weekdays || reminder.weeklyComponents.UTCHour != reminderToUpdate.weeklyComponents.UTCHour || reminder.weeklyComponents.UTCMinute != reminderToUpdate.weeklyComponents.UTCMinute {
                    reminder.resetForNextAlarm()
                }
            case .monthly:
                // time of day or day of month changed
                if reminder.monthlyComponents.UTCDay != reminderToUpdate.monthlyComponents.UTCDay || reminder.monthlyComponents.UTCHour != reminderToUpdate.monthlyComponents.UTCHour || reminder.monthlyComponents.UTCMinute != reminderToUpdate.monthlyComponents.UTCMinute {
                    reminder.resetForNextAlarm()
                }
            }
            
            return reminder
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown().alert()
            return nil
        }
    }
    var didUpdateInitialValues: Bool {
        if initialReminderActionType != reminderActionTypeSelected {
            return true
        }
        if reminderActionTypeSelected?.allowsCustom == true && initialReminderCustomActionName != reminderCustomActionNameTextField.text {
            return true
        }
        if initialReminderIsEnabled != reminderIsEnabledSwitch.isOn {
            return true
        }
        if initialReminderTypeSegmentedControlIndex != reminderTypeSegmentedControl.selectedSegmentIndex {
            return true
        }
        
        switch reminderTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            return dogsReminderOneTimeView?.didUpdateInitialValues ?? false
        case 1:
            return dogsAddReminderCountdownView?.didUpdateInitialValues ?? false
        case 2:
            return dogsAddReminderWeeklyView?.didUpdateInitialValues ?? false
        case 3:
            return dogsAddReminderMonthlyView?.didUpdateInitialValues ?? false
        default:
            return false
        }
    }
    private(set) var reminderActionTypeSelected: ReminderActionType?
    
    private var reminderActionDropDown: HoundDropDown?
    private var dropDownSelectedIndexPath: IndexPath?
    
    // MARK: - Main
    
    // MARK: - Setup
    
    func setup(forReminderToUpdate reminder: Reminder?) {
        reminderToUpdate = reminder

        if let reminderToUpdate = reminderToUpdate,
           let index = GlobalTypes.shared.reminderActionTypes.firstIndex(of: reminderToUpdate.reminderActionType) {
            dropDownSelectedIndexPath = IndexPath(row: index, section: 0)
            reminderActionLabel.text = reminderToUpdate.reminderActionType.convertToReadableName(customActionName: nil)
        } else {
            reminderActionLabel.text = ""
        }

        reminderActionLabel.placeholder = "Select an action..."
        reminderActionTypeSelected = reminderToUpdate?.reminderActionType
        initialReminderActionType = reminderActionTypeSelected

        reminderCustomActionNameTextField.text = reminderToUpdate?.reminderCustomActionName
        initialReminderCustomActionName = reminderCustomActionNameTextField.text
        reminderCustomActionNameTextField.delegate = self

        reminderIsEnabledSwitch.isOn = reminderToUpdate?.reminderIsEnabled ?? ClassConstant.ReminderConstant.defaultReminderIsEnabled
        initialReminderIsEnabled = reminderIsEnabledSwitch.isOn

        countdownView.setup(forDelegate: self, forCountdownDuration: reminderToUpdate?.reminderType == .countdown ? reminderToUpdate?.countdownComponents.executionInterval : nil)

        let weeklyTime = reminderToUpdate?.reminderType == .weekly ? reminderToUpdate?.weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date()) : nil
        let weekdays = reminderToUpdate?.reminderType == .weekly ? reminderToUpdate?.weeklyComponents.weekdays : nil
        weeklyView.setup(forDelegate: self, forTimeOfDay: weeklyTime, forWeekdays: weekdays)

        let monthlyTime = reminderToUpdate?.reminderType == .monthly ? reminderToUpdate?.monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date()) : nil
        monthlyView.setup(forDelegate: self, forTimeOfDay: monthlyTime)

        let oneTimeDate = reminderToUpdate?.reminderType == .oneTime && Date().distance(to: reminderToUpdate?.oneTimeComponents.oneTimeDate ?? Date()) > 0 ? reminderToUpdate?.oneTimeComponents.oneTimeDate : nil
        onceView.setup(forDelegate: self, forOneTimeDate: oneTimeDate)

        reminderTypeSegmentedControl.setTitleTextAttributes([.font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel], for: .normal)
        reminderTypeSegmentedControl.backgroundColor = .systemGray4

        onceView.isHidden = true
        countdownView.isHidden = true
        weeklyView.isHidden = true
        monthlyView.isHidden = true

        if let reminderToUpdate = reminderToUpdate {
            switch reminderToUpdate.reminderType {
            case .oneTime:
                reminderTypeSegmentedControl.selectedSegmentIndex = 0
                onceView.isHidden = false
            case .countdown:
                reminderTypeSegmentedControl.selectedSegmentIndex = 1
                countdownView.isHidden = false
            case .weekly:
                reminderTypeSegmentedControl.selectedSegmentIndex = 2
                weeklyView.isHidden = false
            case .monthly:
                reminderTypeSegmentedControl.selectedSegmentIndex = 3
                monthlyView.isHidden = false
            }
        } else {
            reminderTypeSegmentedControl.selectedSegmentIndex = 1
            countdownView.isHidden = false
        }
        initialReminderTypeSegmentedControlIndex = reminderTypeSegmentedControl.selectedSegmentIndex

        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndDropDown))
        dismissGesture.delegate = self
        dismissGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(dismissGesture)

        reminderActionLabel.isUserInteractionEnabled = true
        let reminderActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderActionTapped))
        reminderActionTapGesture.delegate = self
        reminderActionTapGesture.cancelsTouchesInView = false
        reminderActionLabel.addGestureRecognizer(reminderActionTapGesture)

        updateDynamicUIElements()
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        let reminderCustomActionNameIsHidden = reminderActionTypeSelected?.allowsCustom != true
        
        reminderCustomActionNameTextField.isHidden = reminderCustomActionNameIsHidden
        if reminderCustomActionNameIsHidden {
            reminderCustomActionNameHeightMultiplier.setMultiplier(0.0)
            reminderCustomActionNameMaxHeight.constant = 0.0
            reminderCustomActionNameBottom.constant = 0.0
        } else {
            reminderCustomActionNameHeightMultiplier.restore()
            reminderCustomActionNameMaxHeight.restore()
            reminderCustomActionNameBottom.restore()
        }
        
        reminderCustomActionNameTextField.placeholder = " Add a custom name..."

        UIView.animate(withDuration: VisualConstant.AnimationConstant.showOrHideUIElement) {
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
        }
    }
    
    @objc private func reminderActionTapped() {
        dismissKeyboard()
        
        if reminderActionDropDown == nil {
            let dropDown = HoundDropDown()
            dropDown.setupDropDown(
                forHoundDropDownIdentifier: "DROP_DOWN",
                forDataSource: self,
                forViewPositionReference: reminderActionLabel.frame,
                forOffset: 2.5,
                forRowHeight: HoundDropDown.rowHeightForHoundLabel
            )
            addSubview(dropDown)
            reminderActionDropDown = dropDown
        }
        
        reminderActionDropDown?.showDropDown(numberOfRowsToShow: 6.5, animated: true)
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        endEditing(true)
    }
    
    @objc private func dismissKeyboardAndDropDown() {
        dismissKeyboard()
        reminderActionDropDown?.hideDropDown(animated: true)
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? HoundDropDownTableViewCell else {
            return
        }
        customCell.adjustLeadingTrailing(newConstant: HoundDropDown.insetForHoundLabel)
        
        if dropDownSelectedIndexPath == indexPath {
            customCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        else {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
        }
        
        // inside of the predefined ReminderActionType
        if indexPath.row < GlobalTypes.shared.reminderActionTypes.count {
            customCell.label.text = GlobalTypes.shared.reminderActionTypes[indexPath.row].convertToReadableName(customActionName: nil)
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - GlobalTypes.shared.reminderActionTypes.count]
            let reminderActionType = ReminderActionType.find(forReminderActionTypeId: previousReminderCustomActionName.reminderActionTypeId)
            customCell.label.text = reminderActionType.convertToReadableName(customActionName: previousReminderCustomActionName.reminderCustomActionName)
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        GlobalTypes.shared.reminderActionTypes.count + LocalConfiguration.localPreviousReminderCustomActionNames.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if let selectedCell = reminderActionDropDown?.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTableViewCell {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        dropDownSelectedIndexPath = indexPath
        
        // inside of the predefined LogActionType
        if indexPath.row < GlobalTypes.shared.reminderActionTypes.count {
            reminderActionLabel.text = GlobalTypes.shared.reminderActionTypes[indexPath.row].convertToReadableName(customActionName: nil)
            reminderActionTypeSelected = GlobalTypes.shared.reminderActionTypes[indexPath.row]
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - GlobalTypes.shared.reminderActionTypes.count]
            let previousReminderReminderActionType = ReminderActionType.find(forReminderActionTypeId: previousReminderCustomActionName.reminderActionTypeId)
            
            reminderActionLabel.text = previousReminderReminderActionType.convertToReadableName(customActionName: previousReminderCustomActionName.reminderCustomActionName)
            reminderActionTypeSelected = previousReminderReminderActionType
            reminderCustomActionNameTextField.text = previousReminderCustomActionName.reminderCustomActionName
        }
        
        dismissKeyboardAndDropDown()
        updateDynamicUIElements()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddReminderCountdownView = segue.destination as?  DogsAddReminderCountdownView {
            self.dogsAddReminderCountdownView = dogsAddReminderCountdownView
            dogsAddReminderCountdownView.setup(forDelegate: self, forCountdownDuration: reminderToUpdate?.reminderType == .countdown ? reminderToUpdate?.countdownComponents.executionInterval : nil)
        }
        else if let dogsAddReminderWeeklyView = segue.destination as? DogsAddReminderWeeklyView {
            self.dogsAddReminderWeeklyView = dogsAddReminderWeeklyView
            let timeOfDay = reminderToUpdate?.reminderType == .weekly
            ? reminderToUpdate?.weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date())
            : nil
            let weekdays = reminderToUpdate?.reminderType == .weekly
            ? reminderToUpdate?.weeklyComponents.weekdays
            : nil
            
            dogsAddReminderWeeklyView.setup(forDelegate: self, forTimeOfDay: timeOfDay, forWeekdays: weekdays)
        }
        else if let dogsAddReminderMonthlyView = segue.destination as? DogsAddReminderMonthlyView {
            self.dogsAddReminderMonthlyView = dogsAddReminderMonthlyView
            let timeOfDay = reminderToUpdate?.reminderType == .monthly
            ? reminderToUpdate?.monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date())
            : nil
            
            dogsAddReminderMonthlyView.setup(forDelegate: self, forTimeOfDay: timeOfDay)
        }
        else if let dogsReminderOneTimeView = segue.destination as? DogsAddReminderOneTimeView {
            self.dogsReminderOneTimeView = dogsReminderOneTimeView
            let oneTimeDate = reminderToUpdate?.reminderType == .oneTime && Date().distance(to: reminderToUpdate?.oneTimeComponents.oneTimeDate ?? Date()) > 0
            ? reminderToUpdate?.oneTimeComponents.oneTimeDate
            : nil
            
            dogsReminderOneTimeView.setup(forDelegate: self, forOneTimeDate: oneTimeDate)
        }
        
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(containerView)
        addSubview(reminderActionLabel)
        containerView.addSubview(onceView)
        containerView.addSubview(reminderIsEnabledSwitch)
        containerView.addSubview(reminderTypeSegmentedControl)
        reminderTypeSegmentedControl.addTarget(self, action: #selector(didUpdateReminderType), for: .valueChanged)
        containerView.addSubview(countdownView)
        containerView.addSubview(weeklyView)
        containerView.addSubview(monthlyView)
        containerView.addSubview(reminderCustomActionNameTextField)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // reminderCustomActionNameTextField
        reminderCustomActionNameHeightMultiplier = GeneralLayoutConstraint(reminderCustomActionNameTextField.createHeightMultiplier(ConstraintConstant.Input.textFieldHeightMultiplier, relativeToWidthOf: self))
        reminderCustomActionNameMaxHeight = GeneralLayoutConstraint(reminderCustomActionNameTextField.createMaxHeight(ConstraintConstant.Input.textFieldMaxHeight))
        let reminderCustomActionNameTextFieldTop = reminderCustomActionNameTextField.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert)
        let reminderCustomActionNameTextFieldLeading = reminderCustomActionNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        let reminderCustomActionNameTextFieldTrailing = reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        let reminderCustomActionNameTextFieldTrailingToSegmented = reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: reminderTypeSegmentedControl.trailingAnchor, constant: -2.5)

        // reminderCustomActionNameBottomConstraint (for segmented control positioning)
        reminderCustomActionNameBottom = GeneralLayoutConstraint(reminderTypeSegmentedControl.topAnchor.constraint(equalTo: reminderCustomActionNameTextField.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert))

        // reminderTypeSegmentedControl
        let reminderTypeSegmentedControlLeading = reminderTypeSegmentedControl.leadingAnchor.constraint(equalTo: reminderCustomActionNameTextField.leadingAnchor, constant: -2.5)
        let reminderTypeSegmentedControlHeight = reminderTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 40)

        // weeklyView
        let weeklyViewTop = weeklyView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor)
        let weeklyViewBottom = weeklyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let weeklyViewLeading = weeklyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let weeklyViewTrailing = weeklyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // countdownView
        let countdownViewTop = countdownView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor)
        let countdownViewBottom = countdownView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let countdownViewLeading = countdownView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let countdownViewTrailing = countdownView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // monthlyView
        let monthlyViewTop = monthlyView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor)
        let monthlyViewBottom = monthlyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let monthlyViewLeading = monthlyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let monthlyViewTrailing = monthlyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // onceView
        let onceViewTop = onceView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor)
        let onceViewBottom = onceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let onceViewLeading = onceView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let onceViewTrailing = onceView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // reminderIsEnabledSwitch
        let reminderIsEnabledSwitchLeading = reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: 15)
        let reminderIsEnabledSwitchTrailing = reminderIsEnabledSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40)
        let reminderIsEnabledSwitchCenterY = reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: reminderActionLabel.centerYAnchor)

        // reminderActionLabel
        let reminderActionLabelTop = reminderActionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15)
        let reminderActionLabelLeading = reminderActionLabel.leadingAnchor.constraint(equalTo: reminderCustomActionNameTextField.leadingAnchor)
        let reminderActionLabelHeight = reminderActionLabel.heightAnchor.constraint(equalToConstant: 45)

        // containerView (to safeArea)
        let containerViewTop = safeAreaLayoutGuide.topAnchor.constraint(equalTo: containerView.topAnchor)
        let containerViewLeading = safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let containerViewBottom = containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        let containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)

        NSLayoutConstraint.activate([
            // reminderCustomActionNameTextField
            reminderCustomActionNameTextFieldTop,
            reminderCustomActionNameTextFieldLeading,
            reminderCustomActionNameTextFieldTrailing,
            reminderCustomActionNameTextFieldTrailingToSegmented,
            reminderCustomActionNameHeightMultiplier.constraint,
            reminderCustomActionNameMaxHeight.constraint,
            // reminderTypeSegmentedControl
            reminderCustomActionNameBottom.constraint,
            reminderTypeSegmentedControlLeading,
            reminderTypeSegmentedControlHeight,
            // weeklyView
            weeklyViewTop,
            weeklyViewBottom,
            weeklyViewLeading,
            weeklyViewTrailing,
            // countdownView
            countdownViewTop,
            countdownViewBottom,
            countdownViewLeading,
            countdownViewTrailing,
            // monthlyView
            monthlyViewTop,
            monthlyViewBottom,
            monthlyViewLeading,
            monthlyViewTrailing,
            // onceView
            onceViewTop,
            onceViewBottom,
            onceViewLeading,
            onceViewTrailing,
            // reminderIsEnabledSwitch
            reminderIsEnabledSwitchLeading,
            reminderIsEnabledSwitchTrailing,
            reminderIsEnabledSwitchCenterY,
            // reminderActionLabel
            reminderActionLabelTop,
            reminderActionLabelLeading,
            reminderActionLabelHeight,
            // containerView (safeArea)
            containerViewTop,
            containerViewLeading,
            containerViewBottom,
            containerViewTrailing
        ])
    }

}
