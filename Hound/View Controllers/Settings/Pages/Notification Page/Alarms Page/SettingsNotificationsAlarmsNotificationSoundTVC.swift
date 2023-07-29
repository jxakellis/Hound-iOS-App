//
//  SettingsNotificationsAlarmsNotificationSoundsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsAlarmsNotificationSoundsTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet private weak var notificationSoundsTableView: GeneralUITableView!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationSoundsTableView.delegate = self
        notificationSoundsTableView.dataSource = self
        
        notificationSoundsTableView.isScrollEnabled = false
        
        // notificationSoundsTableView won't automatically size itself inside a cell. If you set rowHeight to automaticDimension and estimatedRowHeight to 42.0, the cell will always resize to 42.0, not adapting at all. translatesAutoresizingMaskIntoConstraints doesn't do anything either. Hard coding the cell's size in storyboard (top, bottom, height, and row height set) doesn't resolve this either.
        notificationSoundsTableView.rowHeight = SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell.cellHeight
        
        synchronizeValues(animated: false)
    }
    
    // MARK: - Functions
    
    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        notificationSoundsTableView.isUserInteractionEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        // set all cells to unselected
        for cellRow in 0..<NotificationSound.allCases.count {
            let cellIndexPath = IndexPath(row: cellRow, section: 0)
            let cell = notificationSoundsTableView.cellForRow(at: cellIndexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell
            cell?.setCustomSelectedTableViewCell(false, animated: true)
        }
        
        // set user configuration notification sound cell to selected
        guard let currentNotificationSoundCellRow = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            return
        }
        let currentNotificationSoundCellIndexPath = IndexPath(row: currentNotificationSoundCellRow, section: 0)
        let currentNotificationSoundCell = notificationSoundsTableView.cellForRow(at: currentNotificationSoundCellIndexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(true, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationSound.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = notificationSoundsTableView.dequeueReusableCell(withIdentifier: "SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell", for: indexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell else {
            return UITableViewCell()
        }
        
        let notificationSound = NotificationSound.allCases[indexPath.row]
        
        cell.setup(forNotificationSound: notificationSound == NotificationSound.radar ? "Radar (Default)" : notificationSound.rawValue)
        cell.setCustomSelectedTableViewCell(notificationSound == UserConfiguration.notificationSound, animated: false)
        
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = notificationSoundsTableView.cellForRow(at: indexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell,
              let currentNotificationSoundIndex = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            // we need the selected cell and current notification sound index before we proceed
            AudioManager.stopAudio()
            return
        }
        
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        guard selectedNotificationSound != UserConfiguration.notificationSound else {
            // cell selected is the same as the current sound saved, toggle the audio
            if AudioManager.isPlaying {
                AudioManager.stopAudio()
            }
            else {
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
            }
            
            return
        }
        
        // the new cell selected is different that the current sound saved
        
        // find the current notification sound cell and unselect it, as the user just selected a new one
        let currentNotificationSoundIndexPath = IndexPath(row: currentNotificationSoundIndex, section: 0)
        let currentNotificationSoundCell = notificationSoundsTableView.cellForRow(at: currentNotificationSoundIndexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(false, animated: true)
        
        // highlight the new selected cell
        selectedCell.setCustomSelectedTableViewCell(true, animated: true)
        
        // leave this code right here, don't move below or its value will be incorrect
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        
        // assign user configuration to new value and play its audio
        UserConfiguration.notificationSound = selectedNotificationSound
        AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
        
        // contact server to attempt to persist change
        let body = [KeyConstant.userConfigurationNotificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            guard requestWasSuccessful else {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.notificationSound = beforeUpdateNotificationSound
                self.synchronizeValues(animated: true)
                return
            }
        }
    }

}
