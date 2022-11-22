//
//  SettingsNotificationsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsViewController: UIViewController, UIGestureRecognizerDelegate, DropDownUIViewDataSource {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Properties
    
    /// holds all the views inside except for the notification sound label. Alls for hiding of the dropDown when anywhere else is clocked
    @IBOutlet private weak var containerViewForAll: UIView!
    
    /// Holds containerViewForAll, notificationSound label, and notificationSound drop down
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TO DO NOW add notification catagories for the users to opt out of. The catagories should be the same as defined by globalConstant category field (reminder, log, family, user, and general)
        
        // Notification Sound
        notificationSoundLabel.text = UserConfiguration.notificationSound.rawValue
        
        self.notificationSoundLabel.isUserInteractionEnabled = true
        notificationSoundLabel.isEnabled = true
        let notificationSoundLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(willShowNotificationSoundDropDown))
        self.notificationSoundLabel.addGestureRecognizer(notificationSoundLabelTapGesture)
        // hide drop down when other things touched
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerViewForAll.addGestureRecognizer(tap)
        
        // Snooze Length
        
        snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        synchronizeNotificationsValues(animated: false)
    }
    
    /// viewDidLayoutSubviews is called repeatedly whenever views inside the viewcontroller are added or shifted. This causes the code inside viewDidLayoutSubviews to be repeatedly called. However, we use viewDidLayoutSubviews instead of viewDidAppear. Both of these functions are called when the view is already layed out, meaning we can perform accurate changes to the view (like adding and showing a drop down), though viewDidAppear has the downside of performing these changes once the user can see the view, meaning they will see views shift in front of them. Therefore, viewDidLayoutSubviews is the superior choice and we just need to limit it calling the code below once.
    private var didLayoutSubviews: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
        
        guard didLayoutSubviews == false else {
            return
        }
        
        didLayoutSubviews = true
        
        /// only one dropdown used on the dropdown instance so no identifier needed
        dropDown.dropDownUIViewIdentifier = ""
        dropDown.cellReusableIdentifier = "DropDownCell"
        dropDown.dataSource = self
        dropDown.setupDropDown(viewPositionReference: notificationSoundLabel.frame, offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
        scrollView.addSubview(dropDown)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cant use self.hideDropDown
        AudioManager.stopAudio()
        dropDown.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Individual Settings
    
    // MARK: Use Notifications
    
    @IBOutlet private weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        
        synchronizeNotificationsIsEnabled()
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                // needed as  UNUserNotificationCenter.current().getNotificationSettings on other thread
                DispatchQueue.main.async {
                    
                    // notications enabled, going from on to off
                    if UserConfiguration.isNotificationEnabled == true {
                        UserConfiguration.isNotificationEnabled = false
                    }
                    // notifications disabled, going from off to on
                    else {
                        UserConfiguration.isNotificationEnabled = true
                    }
                    
                    self.synchronizeNotificationsValues(animated: true)
                    
                    let body = [KeyConstant.userConfigurationIsNotificationEnabled.rawValue: UserConfiguration.isNotificationEnabled]
                    
                    UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
                        if requestWasSuccessful == false {
                            UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                            self.synchronizeNotificationsValues(animated: true)
                        }
                    }
                }
            case .denied:
                // needed as  UNUserNotificationCenter.current().getNotificationSettings on other thread
                DispatchQueue.main.async {
                    // nothing to update (as permissions denied) so we don't tell the server anything
                    
                    // Permission is denied, so we want to flip the switch back to its proper off position
                    let switchDisableTimer = Timer(fire: Date().addingTimeInterval(0.25), interval: -1, repeats: false) { _ in
                        self.synchronizeNotificationsValues(animated: true)
                    }
                    
                    RunLoop.main.add(switchDisableTimer, forMode: .common)
                    
                    // Attempt to re-direct the user to their iPhone's settings for Hound, so they can enable notifications
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    // If we can't redirect the user, then just user a generic pop-up
                    else {
                        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.notificationsDisabledTitle, forSubtitle: VisualConstant.BannerTextConstant.notificationsDisabledSubtitle, forStyle: .danger)
                    }
                }
            case .notDetermined:
                // don't advise the user if they want to turn on notifications. we already know that the user wants to turn on notification because they just toggle a switch to do so
                NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: false) {
                    self.synchronizeNotificationsValues(animated: true)
                }
            case .provisional:
                AppDelegate.generalLogger.fault(".provisional")
            case .ephemeral:
                AppDelegate.generalLogger.fault(".ephemeral")
            @unknown default:
                AppDelegate.generalLogger.fault("\(VisualConstant.TextConstant.unknownText) notification authorization status")
            }
        }
        
    }
    
    /// Updates the UI's values and isEnabled states to reflect the values stored.
    func synchronizeNotificationsValues(animated: Bool) {
        synchronizeNotificationsIsEnabled()
        
        isNotificationEnabledSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        
        silentModeIsEnabledSwitch.setOn(UserConfiguration.silentModeIsEnabled, animated: animated)
        
        silentModeStartHoursDatePicker.setDate(
            Calendar.UTCCalendar.date(bySettingHour: UserConfiguration.silentModeStartUTCHour, minute: UserConfiguration.silentModeStartUTCMinute, second: 0, of: Date()) ?? Date(),
            animated: animated)
        
        silentModeEndHoursDatePicker.setDate(
            Calendar.UTCCalendar.date(bySettingHour: UserConfiguration.silentModeEndUTCHour, minute: UserConfiguration.silentModeEndUTCMinute, second: 0, of: Date()) ?? Date(),
            animated: animated)
        
        isLoudNotificationSwitch.setOn(UserConfiguration.isLoudNotification, animated: animated)
    }
    
    /// Updates the UI's isEnabled states to reflect the values stored
    private func synchronizeNotificationsIsEnabled() {
        hideDropDown()
        
        silentModeIsEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
        silentModeStartHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled && UserConfiguration.silentModeIsEnabled
        
        silentModeEndHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled && UserConfiguration.silentModeIsEnabled
        
        notificationSoundLabel.isEnabled = UserConfiguration.isNotificationEnabled
        
        isLoudNotificationSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    // MARK: Silent Hours
    
    @IBOutlet private weak var silentModeIsEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleSilentModeIsEnabled(_ sender: Any) {
        let beforeUpdateSilentModeIsEnabled = UserConfiguration.silentModeIsEnabled
        
        UserConfiguration.silentModeIsEnabled = silentModeIsEnabledSwitch.isOn
        
        synchronizeNotificationsIsEnabled()
        
        let body = [KeyConstant.userConfigurationSilentModeIsEnabled.rawValue: UserConfiguration.silentModeIsEnabled]
        
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.silentModeIsEnabled = beforeUpdateSilentModeIsEnabled
                self.synchronizeNotificationsValues(animated: true)
            }
        }
    }
    
    @IBOutlet private weak var silentModeStartHoursDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateSilentModeStartHours(_ sender: Any) {
        let beforeUpdateSilentModeStartUTCHour = UserConfiguration.silentModeStartUTCHour
        let beforeUpdateSilentModeStartUTCMinute = UserConfiguration.silentModeStartUTCMinute
        
        UserConfiguration.silentModeStartUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeStartHoursDatePicker.date)
        UserConfiguration.silentModeStartUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeStartHoursDatePicker.date)
        
        let body = [KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue: UserConfiguration.silentModeStartUTCHour,
                    KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue: UserConfiguration.silentModeStartUTCMinute]
        
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.silentModeStartUTCHour = beforeUpdateSilentModeStartUTCHour
                UserConfiguration.silentModeStartUTCMinute = beforeUpdateSilentModeStartUTCMinute
                self.synchronizeNotificationsValues(animated: true)
            }
        }
    }
    
    @IBOutlet private weak var silentModeEndHoursDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateSilentModeEndHours(_ sender: Any) {
        let beforeUpdateSilentModeEndUTCHour = UserConfiguration.silentModeEndUTCHour
        let beforeUpdateSilentModeEndUTCMinute = UserConfiguration.silentModeEndUTCMinute
        
        UserConfiguration.silentModeEndUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeEndHoursDatePicker.date)
        UserConfiguration.silentModeEndUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeEndHoursDatePicker.date)
        
        let body = [KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue: UserConfiguration.silentModeEndUTCHour,
                    KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue: UserConfiguration.silentModeEndUTCMinute]
        
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.silentModeEndUTCHour = beforeUpdateSilentModeEndUTCHour
                UserConfiguration.silentModeEndUTCMinute = beforeUpdateSilentModeEndUTCMinute
                self.synchronizeNotificationsValues(animated: true)
            }
        }
    }
    
    // MARK: Notification Sound
    
    @IBOutlet private weak var notificationSoundLabel: BorderedUILabel!
    
    @objc private func willShowNotificationSoundDropDown(_ sender: Any) {
        self.dropDown.showDropDown(numberOfRowsToShow: 6.5, animated: true)
    }
    
    // MARK: Notification Sound Drop Down
    
    private let dropDown = DropDownUIView()
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let customCell = cell as? DropDownTableViewCell else {
            return
        }
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
        
        customCell.label.text = NotificationSound.allCases[indexPath.row].rawValue
        
        if NotificationSound.allCases[indexPath.row] == UserConfiguration.notificationSound {
            customCell.willToggleDropDownSelection(forSelected: true)
        }
        else {
            customCell.willToggleDropDownSelection(forSelected: false)
        }
        
        if NotificationSound.allCases[indexPath.row] == NotificationSound.radar {
            customCell.label.text = "Radar (Default)"
        }
        
        // adjust customCell based on indexPath
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        return NotificationSound.allCases.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        
        // do actions based on a cell selected at a indexPath given a dropDownUIViewIdentifier
        // want to hide the drop down after something is selected
        
        guard let dropDownTableView = dropDown.dropDownTableView else {
            return
        }
        
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        guard selectedNotificationSound != UserConfiguration.notificationSound,
              let selectedCell = dropDownTableView.cellForRow(at: indexPath) as? DropDownTableViewCell,
              let notificationSound = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound)
        else {
            // cell selected is the same as the current sound saved
            AudioManager.stopAudio()
            self.dropDown.hideDropDown()
            return
        }
        
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        
        // the new cell selected is different that the current sound saved
        let unselectedCellIndexPath = IndexPath(row: notificationSound, section: 0)
        let unselectedCell = dropDownTableView.cellForRow(at: unselectedCellIndexPath) as? DropDownTableViewCell
        unselectedCell?.willToggleDropDownSelection(forSelected: false)
        
        selectedCell.willToggleDropDownSelection(forSelected: true)
        UserConfiguration.notificationSound = selectedNotificationSound
        self.notificationSoundLabel.text = selectedNotificationSound.rawValue
        
        AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
        
        let body = [KeyConstant.userConfigurationNotificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.notificationSound = beforeUpdateNotificationSound
                self.notificationSoundLabel.text = beforeUpdateNotificationSound.rawValue
            }
        }
        
    }
    
    // MARK: Notification Sound Drop Down Functions
    
    @objc private func hideDropDown() {
        AudioManager.stopAudio()
        dropDown.hideDropDown()
    }
    
    // MARK: Loud Notifications
    
    @IBOutlet private weak var isLoudNotificationSwitch: UISwitch!
    
    @IBAction private func didToggleIsLoudNotification(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        UserConfiguration.isLoudNotification = isLoudNotificationSwitch.isOn
        let body = [KeyConstant.userConfigurationIsLoudNotification.rawValue: UserConfiguration.isLoudNotification]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                self.isLoudNotificationSwitch.setOn(UserConfiguration.isLoudNotification, animated: true)
            }
        }
    }
    
    // MARK: Snooze Length
    
    @IBOutlet private weak var snoozeLengthDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeLength(_ sender: Any) {
        let beforeUpdateSnoozeLength = UserConfiguration.snoozeLength
        UserConfiguration.snoozeLength = snoozeLengthDatePicker.countDownDuration
        let body = [KeyConstant.userConfigurationSnoozeLength.rawValue: UserConfiguration.snoozeLength]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.snoozeLength = beforeUpdateSnoozeLength
                self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
            }
        }
    }
    
}
