//
//  SettingsNotificationsCatagoriesViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsCatagoriesViewController: UIViewController {

    // MARK: - Properties
    
    private(set) var settingsNotificationsCatagoriesTableViewController: SettingsNotificationsCatagoriesTableViewController?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsNotificationsCatagoriesTableViewController = segue.destination as? SettingsNotificationsCatagoriesTableViewController {
            self.settingsNotificationsCatagoriesTableViewController = settingsNotificationsCatagoriesTableViewController
        }
    }

}
