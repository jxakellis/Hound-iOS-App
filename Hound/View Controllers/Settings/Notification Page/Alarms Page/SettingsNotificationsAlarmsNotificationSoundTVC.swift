//
//  SettingsNotificationsAlarmsNotificationSoundTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsAlarmsNotificationSoundTableViewCell: UITableViewCell {

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
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
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
    
    // TO DO NOW transform from dropdown inside cell to tableview inside cell
    // MARK: - Functions
    
    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        notificationSoundLabel.text = UserConfiguration.notificationSound.rawValue
        
    }

}
