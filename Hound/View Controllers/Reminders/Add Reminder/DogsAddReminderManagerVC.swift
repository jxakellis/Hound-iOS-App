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

    // MARK: - IB

    @IBOutlet private weak var containerForAll: UIView!

    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countdownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!

    @IBOutlet private weak var reminderActionLabel: GeneralUILabel!

    @IBOutlet private weak var reminderCustomActionNameTextField: GeneralUITextField!
    @IBOutlet private weak var reminderCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderCustomActionNameBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!

    @IBOutlet private weak var reminderTypeSegmentedControl: UISegmentedControl!

    @IBAction private func didUpdateReminderType(_ sender: UISegmentedControl) {
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
    private var initialReminderAction: ReminderAction!
    private var initialReminderCustomActionName: String?
    private var initialReminderIsEnabled: Bool!
    private var initialReminderTypeSegmentedControlIndex: Int!

    /// Given the reminderToUpdate provided, construct a new reminder or updates the one provided with the settings selected inside this view and its subviews. If there are invalid settings (e.g. no weekdays), an error message is sent to the user and nil is returned. If the reminder is valid, a reminder is returned that is ready to be sent to the server.
    var currentReminder: Reminder? {
        do {
            guard let reminderActionSelected = reminderActionSelected else {
                throw ErrorConstant.ReminderError.reminderActionMissing()
            }

            guard let reminder: Reminder = reminderToUpdate != nil ? reminderToUpdate?.copy() as? Reminder : Reminder() else {
                return nil
            }

            reminder.reminderAction = reminderActionSelected

            if reminderActionSelected == ReminderAction.medicine || reminderActionSelected == ReminderAction.custom {
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
        if initialReminderAction != reminderActionSelected {
            return true
        }
        if (reminderActionSelected == ReminderAction.medicine || reminderActionSelected == ReminderAction.custom) && initialReminderCustomActionName != reminderCustomActionNameTextField.text {
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
    private(set) var reminderActionSelected: ReminderAction?

    private var reminderActionDropDown: DropDownUIView?
    private var dropDownSelectedIndexPath: IndexPath?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // Values
        if let reminderToUpdate = reminderToUpdate, let reminderActionIndex = ReminderAction.allCases.firstIndex(of: reminderToUpdate.reminderAction) {
            dropDownSelectedIndexPath = IndexPath(row: reminderActionIndex, section: 0)
            // this is for the label for the reminderAction dropdown, so we only want the names to be the defaults. I.e. if our reminder is "Custom" with "someCustomActionName", the reminderActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            reminderActionLabel.text = reminderToUpdate.reminderAction.fullReadableName(reminderCustomActionName: nil)
        }
        else {
            reminderActionLabel.text = ""
        }

        reminderActionLabel.placeholder = "Select an action..."
        reminderActionSelected = reminderToUpdate?.reminderAction
        initialReminderAction = reminderActionSelected

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
        let reminderCustomActionNameIsHidden = !(reminderActionSelected == .medicine || reminderActionSelected == .custom)
        
        reminderCustomActionNameHeightConstraint.constant = reminderCustomActionNameIsHidden ? 0.0 : 45.0
        reminderCustomActionNameBottomConstraint.constant = reminderCustomActionNameIsHidden ? 0.0 : 15.0
        reminderCustomActionNameTextField.isHidden = reminderCustomActionNameIsHidden
        
        reminderCustomActionNameTextField.placeholder = {
            // Dynamic placeholder depending upon which reminder action is selected
            if reminderActionSelected == .medicine {
                return " Add a custom medicine..."
            }
            return " Add a custom action..."
        }()

        containerForAll.setNeedsLayout()
        containerForAll.layoutIfNeeded()
    }

    @objc private func reminderActionTapped() {
        dismissKeyboard()
        
        if reminderActionDropDown == nil {
            let dropDown = DropDownUIView()
            dropDown.setupDropDown(
                forDataSource: self,
                forNibName: "DropDownTableViewCell",
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
        guard let customCell = cell as? DropDownTableViewCell else {
            return
        }
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForGeneralUILabel)

        if dropDownSelectedIndexPath == indexPath {
            customCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        else {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
        }

        // inside of the predefined ReminderAction
        if indexPath.row < ReminderAction.allCases.count {
            customCell.label.text = ReminderAction.allCases[indexPath.row].fullReadableName(reminderCustomActionName: nil)
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - ReminderAction.allCases.count]
            customCell.label.text = previousReminderCustomActionName.reminderAction.fullReadableName(reminderCustomActionName: previousReminderCustomActionName.reminderCustomActionName)
        }
    }

    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        ReminderAction.allCases.count + LocalConfiguration.localPreviousReminderCustomActionNames.count
    }

    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        1
    }

    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if let selectedCell = reminderActionDropDown?.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true)
        }
        dropDownSelectedIndexPath = indexPath

        // inside of the predefined LogAction
        if indexPath.row < ReminderAction.allCases.count {
            reminderActionLabel.text = ReminderAction.allCases[indexPath.row].fullReadableName(reminderCustomActionName: nil)
            reminderActionSelected = ReminderAction.allCases[indexPath.row]
        }
        // a user generated custom name
        else {
            let previousReminderCustomActionName = LocalConfiguration.localPreviousReminderCustomActionNames[indexPath.row - ReminderAction.allCases.count]
            
            reminderActionLabel.text = previousReminderCustomActionName.reminderAction.fullReadableName(reminderCustomActionName: previousReminderCustomActionName.reminderCustomActionName)
            reminderActionSelected = previousReminderCustomActionName.reminderAction
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

}
