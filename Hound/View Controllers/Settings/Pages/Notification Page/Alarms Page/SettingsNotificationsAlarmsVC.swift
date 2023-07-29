//
//  SettingsNotificationsAlarmsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsAlarmsViewController: UIViewController {

    // MARK: - Properties
    
    private(set) var settingsNotificationsAlarmsTableViewController: SettingsNotificationsAlarmsTableViewController?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsNotificationsAlarmsTableViewController = segue.destination as? SettingsNotificationsAlarmsTableViewController {
            self.settingsNotificationsAlarmsTableViewController = settingsNotificationsAlarmsTableViewController
        }
    }

}
