//
//  DogsAddDogReminderManagerViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsAddDogReminderManagerViewController: GeneralUIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsAddReminderCountdownViewControllerDelegate, DogsAddReminderWeeklyViewControllerDelegate, DropDownUIViewDataSource, DogsAddReminderMonthlyViewControllerDelegate, DogsAddReminderOneTimeViewControllerDelegate {
    
    // MARK: - DogsAddReminderCountdownViewControllerDelegate and DogsAddReminderWeeklyViewControllerDelegate
    
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
    
    private let containerForAll: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let onceContainerView: GeneralUIView = GeneralUIView()
    private let countdownContainerView: GeneralUIView = GeneralUIView()
    private let weeklyContainerView: GeneralUIView = GeneralUIView()
    private let monthlyContainerView: GeneralUIView = GeneralUIView()
    
    private let reminderActionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.font = .systemFont(ofSize: 17.5)
        label.borderWidth = 0.5
        label.borderColor = .systemGray2
        label.shouldRoundCorners = true
        return label
    }()
    
    private let reminderCustomActionNameHeightConstraintConstaint: CGFloat = 45
    private weak var reminderCustomActionNameHeightConstraint: NSLayoutConstraint!
    private let reminderCustomActionNameBottomConstraintConstant: CGFloat = 15
    private weak var reminderCustomActionNameBottomConstraint: NSLayoutConstraint!
    private let reminderCustomActionNameTextField: GeneralUITextField = {
        let textField = GeneralUITextField()
        
        textField.borderWidth = 0.5
        textField.borderColor = .systemGray2
        textField.shouldRoundCorners = true
        
        return textField
    }()
    
    private let reminderIsEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch()
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
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countdownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }
    
    // MARK: - Properties
    
    private var dogsReminderOneTimeViewController: DogsAddReminderOneTimeViewController?
    private var dogsAddReminderCountdownViewController: DogsAddReminderCountdownViewController?
    private var dogsAddReminderWeeklyViewController: DogsAddReminderWeeklyViewController?
    private var dogsAddReminderMonthlyViewController: DogsAddReminderMonthlyViewController?
    
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
                reminder.oneTimeComponents.oneTimeDate = dogsReminderOneTimeViewController?.oneTimeDate ?? reminder.oneTimeComponents.oneTimeDate
            case 1:
                reminder.changeReminderType(forReminderType: .countdown)
                reminder.countdownComponents.executionInterval = dogsAddReminderCountdownViewController?.currentCountdownDuration ?? reminder.countdownComponents.executionInterval
            case 2:
                guard let weekdays = dogsAddReminderWeeklyViewController?.currentWeekdays else {
                    throw ErrorConstant.WeeklyComponentsError.weekdayArrayInvalid()
                }
                
                reminder.changeReminderType(forReminderType: .weekly)
                
                try reminder.weeklyComponents.changeWeekdays(forWeekdays: weekdays)
                guard let date = dogsAddReminderWeeklyViewController?.currentTimeOfDay else {
                    break
                }
                reminder.weeklyComponents.changeUTCHour(forDate: date)
                reminder.weeklyComponents.changeUTCMinute(forDate: date)
            case 3:
                reminder.changeReminderType(forReminderType: .monthly)
                guard let date = dogsAddReminderMonthlyViewController?.currentTimeOfDay else {
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
            return dogsReminderOneTimeViewController?.didUpdateInitialValues ?? false
        case 1:
            return dogsAddReminderCountdownViewController?.didUpdateInitialValues ?? false
        case 2:
            return dogsAddReminderWeeklyViewController?.didUpdateInitialValues ?? false
        case 3:
            return dogsAddReminderMonthlyViewController?.didUpdateInitialValues ?? false
        default:
            return false
        }
    }
    private(set) var reminderActionTypeSelected: ReminderActionType?
    
    private var reminderActionDropDown: DropDownUIView?
    private var dropDownSelectedIndexPath: IndexPath?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Values
        if let reminderToUpdate = reminderToUpdate, let reminderActionIndex = GlobalTypes.shared.reminderActionTypes.firstIndex(of: reminderToUpdate.reminderActionType) {
            dropDownSelectedIndexPath = IndexPath(row: reminderActionIndex, section: 0)
            // this is for the label for the reminderActionType dropdown, so we only want the names to be the defaults. I.e. if our reminder is "Custom" with "someCustomActionName", the reminderActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            reminderActionLabel.text = reminderToUpdate.reminderActionType.convertToReadableName(customActionName: nil)
        }
        else {
            reminderActionLabel.text = ""
        }
        
        reminderActionLabel.placeholder = "Select an action..."
        reminderActionTypeSelected = reminderToUpdate?.reminderActionType
        initialReminderActionType = reminderActionTypeSelected
        
        reminderCustomActionNameTextField.text = reminderToUpdate?.reminderCustomActionName
        initialReminderCustomActionName = reminderCustomActionNameTextField.text
        // This placeholder is dynamic, so its set elsewhere
        reminderCustomActionNameTextField.delegate = self
        
        reminderIsEnabledSwitch.isOn = reminderToUpdate?.reminderIsEnabled ?? ClassConstant.ReminderConstant.defaultReminderIsEnabled
        initialReminderIsEnabled = reminderIsEnabledSwitch.isOn
        
        // This should be called after all values are setup
        updateDynamicUIElements()
        
        // Gestures
        let dismissKeyboardAndDropDownTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndDropDown))
        dismissKeyboardAndDropDownTapGesture.delegate = self
        dismissKeyboardAndDropDownTapGesture.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(dismissKeyboardAndDropDownTapGesture)
        
        reminderActionLabel.isUserInteractionEnabled = true
        let reminderActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderActionTapped))
        reminderActionTapGesture.delegate = self
        reminderActionTapGesture.cancelsTouchesInView = false
        reminderActionLabel.addGestureRecognizer(reminderActionTapGesture)
        
        // Segmented Control
        reminderTypeSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.systemBackground], for: .normal)
        reminderTypeSegmentedControl.backgroundColor = .systemGray4
        
        onceContainerView.isHidden = true
        countdownContainerView.isHidden = true
        weeklyContainerView.isHidden = true
        monthlyContainerView.isHidden = true
        
        // editing current
        if let reminderToUpdate = reminderToUpdate {
            switch reminderToUpdate.reminderType {
            case .oneTime:
                reminderTypeSegmentedControl.selectedSegmentIndex = 0
                onceContainerView.isHidden = false
            case .countdown:
                reminderTypeSegmentedControl.selectedSegmentIndex = 1
                countdownContainerView.isHidden = false
            case .weekly:
                reminderTypeSegmentedControl.selectedSegmentIndex = 2
                weeklyContainerView.isHidden = false
            case .monthly:
                reminderTypeSegmentedControl.selectedSegmentIndex = 3
                monthlyContainerView.isHidden = false
            }
        }
        else {
            reminderTypeSegmentedControl.selectedSegmentIndex = 1
            countdownContainerView.isHidden = false
        }
        initialReminderTypeSegmentedControlIndex = reminderTypeSegmentedControl.selectedSegmentIndex
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reminderActionDropDown?.hideDropDown(animated: false)
    }
    
    // MARK: - Functions
    
    func setup(forReminderToUpdate: Reminder?) {
        reminderToUpdate = forReminderToUpdate
    }
    
    private func updateDynamicUIElements() {
        let reminderCustomActionNameIsHidden = reminderActionTypeSelected?.allowsCustom != true
        
        reminderCustomActionNameHeightConstraint.constant = reminderCustomActionNameIsHidden ? 0.0 : reminderCustomActionNameHeightConstraintConstaint
        reminderCustomActionNameBottomConstraint.constant = reminderCustomActionNameIsHidden ? 0.0 : reminderCustomActionNameBottomConstraintConstant
        reminderCustomActionNameTextField.isHidden = reminderCustomActionNameIsHidden
        
        reminderCustomActionNameTextField.placeholder = " Add a custom action name..."
        
        containerForAll.setNeedsLayout()
        containerForAll.layoutIfNeeded()
    }
    
    @objc private func reminderActionTapped() {
        dismissKeyboard()
        
        if reminderActionDropDown == nil {
            let dropDown = DropDownUIView()
            dropDown.setupDropDown(
                forDataSource: self,
                forViewPositionReference: reminderActionLabel.frame,
                forOffset: 2.5,
                forRowHeight: DropDownUIView.rowHeightForGeneralUILabel
            )
            view.addSubview(dropDown)
            reminderActionDropDown = dropDown
        }
        
        reminderActionDropDown?.showDropDown(numberOfRowsToShow: 6.5, animated: true)
    }
    
    @objc override func dismissKeyboard() {
        super.dismissKeyboard()
        
        // DogsDogReminderManagerVC is embedded in DogsNestedReminderViewController which is embedded in UINavigationController which is embedded in DogsAddDogViewController.
        (self.parent?.parent?.parent as? DogsAddDogViewController)?.dismissKeyboard()
    }
    
    @objc private func dismissKeyboardAndDropDown() {
        dismissKeyboard()
        reminderActionDropDown?.hideDropDown(animated: true)
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? DropDownTVC else {
            return
        }
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)
        
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
        if let selectedCell = reminderActionDropDown?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTVC {
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
        if let dogsAddReminderCountdownViewController = segue.destination as?  DogsAddReminderCountdownViewController {
            self.dogsAddReminderCountdownViewController = dogsAddReminderCountdownViewController
            dogsAddReminderCountdownViewController.setup(forDelegate: self, forCountdownDuration: reminderToUpdate?.reminderType == .countdown ? reminderToUpdate?.countdownComponents.executionInterval : nil)
        }
        else if let dogsAddReminderWeeklyViewController = segue.destination as? DogsAddReminderWeeklyViewController {
            self.dogsAddReminderWeeklyViewController = dogsAddReminderWeeklyViewController
            let timeOfDay = reminderToUpdate?.reminderType == .weekly
            ? reminderToUpdate?.weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date())
            : nil
            let weekdays = reminderToUpdate?.reminderType == .weekly
            ? reminderToUpdate?.weeklyComponents.weekdays
            : nil
            
            dogsAddReminderWeeklyViewController.setup(forDelegate: self, forTimeOfDay: timeOfDay, forWeekdays: weekdays)
        }
        else if let dogsAddReminderMonthlyViewController = segue.destination as? DogsAddReminderMonthlyViewController {
            self.dogsAddReminderMonthlyViewController = dogsAddReminderMonthlyViewController
            let timeOfDay = reminderToUpdate?.reminderType == .monthly
            ? reminderToUpdate?.monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderToUpdate?.reminderExecutionBasis ?? Date())
            : nil
            
            dogsAddReminderMonthlyViewController.setup(forDelegate: self, forTimeOfDay: timeOfDay)
        }
        else if let dogsReminderOneTimeViewController = segue.destination as? DogsAddReminderOneTimeViewController {
            self.dogsReminderOneTimeViewController = dogsReminderOneTimeViewController
            let oneTimeDate = reminderToUpdate?.reminderType == .oneTime && Date().distance(to: reminderToUpdate?.oneTimeComponents.oneTimeDate ?? Date()) > 0
            ? reminderToUpdate?.oneTimeComponents.oneTimeDate
            : nil
            
            dogsReminderOneTimeViewController.setup(forDelegate: self, forOneTimeDate: oneTimeDate)
        }
        
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(containerForAll)
        view.addSubview(reminderActionLabel)
        containerForAll.addSubview(onceContainerView)
        containerForAll.addSubview(reminderIsEnabledSwitch)
        containerForAll.addSubview(reminderTypeSegmentedControl)
        reminderTypeSegmentedControl.addTarget(self, action: #selector(didUpdateReminderType), for: .valueChanged)
        containerForAll.addSubview(countdownContainerView)
        containerForAll.addSubview(weeklyContainerView)
        containerForAll.addSubview(monthlyContainerView)
        containerForAll.addSubview(reminderCustomActionNameTextField)
        
    }
    
    override func setupConstraints() {
        reminderCustomActionNameHeightConstraint = reminderCustomActionNameTextField.heightAnchor.constraint(equalToConstant: reminderCustomActionNameHeightConstraintConstaint)
        reminderCustomActionNameBottomConstraint = reminderTypeSegmentedControl.topAnchor.constraint(equalTo: reminderCustomActionNameTextField.bottomAnchor, constant: reminderCustomActionNameBottomConstraintConstant)
        
        NSLayoutConstraint.activate([
            reminderCustomActionNameBottomConstraint,
            reminderTypeSegmentedControl.leadingAnchor.constraint(equalTo: reminderCustomActionNameTextField.leadingAnchor, constant: -2.5),
            reminderTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            reminderCustomActionNameTextField.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: 15),
            reminderCustomActionNameTextField.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor, constant: 10),
            reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor, constant: -10),
            reminderCustomActionNameTextField.trailingAnchor.constraint(equalTo: reminderTypeSegmentedControl.trailingAnchor, constant: -2.5),
            reminderCustomActionNameHeightConstraint,
            
            weeklyContainerView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor),
            weeklyContainerView.bottomAnchor.constraint(equalTo: containerForAll.bottomAnchor),
            weeklyContainerView.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor),
            weeklyContainerView.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor),
            
            countdownContainerView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor),
            countdownContainerView.bottomAnchor.constraint(equalTo: containerForAll.bottomAnchor),
            countdownContainerView.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor),
            countdownContainerView.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor),
            
            monthlyContainerView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor),
            monthlyContainerView.bottomAnchor.constraint(equalTo: containerForAll.bottomAnchor),
            monthlyContainerView.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor),
            monthlyContainerView.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor),
            
            onceContainerView.topAnchor.constraint(equalTo: reminderTypeSegmentedControl.bottomAnchor),
            onceContainerView.bottomAnchor.constraint(equalTo: containerForAll.bottomAnchor),
            onceContainerView.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor),
            onceContainerView.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor),
            
            reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: 15),
            reminderIsEnabledSwitch.trailingAnchor.constraint(equalTo: containerForAll.trailingAnchor, constant: -40),
            reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: reminderActionLabel.centerYAnchor),
            
            reminderActionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            reminderActionLabel.leadingAnchor.constraint(equalTo: reminderCustomActionNameTextField.leadingAnchor),
            reminderActionLabel.heightAnchor.constraint(equalToConstant: 45),
            
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: containerForAll.topAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: containerForAll.leadingAnchor),
            
            containerForAll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerForAll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ])
        
    }
}
