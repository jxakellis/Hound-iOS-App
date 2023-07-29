//
//  SettingsNotificationsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsViewController: UIViewController {
    
    // MARK: - Properties
    
    private(set) var settingsNotificationsTableViewController: SettingsNotificationsTableViewController?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsNotificationsTableViewController = segue.destination as? SettingsNotificationsTableViewController {
            self.settingsNotificationsTableViewController = settingsNotificationsTableViewController
        }
    }

}
