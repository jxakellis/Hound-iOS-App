//
//  SettingsAppearanceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsAppearanceViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var interfaceStyleSegmentedControl: UISegmentedControl!
    
    @IBAction private func didUpdateInterfaceStyle(_ sender: Any) {
        if let sender = sender as? UISegmentedControl {
            sender.updateInterfaceStyle(forViewController: self)
        }
    }
    
    @IBOutlet private weak var logsInterfaceScaleSegmentedControl: UISegmentedControl!
    
    @IBAction private func didUpdateLogsInterfaceScale(_ sender: Any) {
        
        let beforeUpdateLogsInterfaceScale = UserConfiguration.logsInterfaceScale
        
        // selected segement index is in the same order as all cases
        UserConfiguration.logsInterfaceScale = LogsInterfaceScale.allCases[logsInterfaceScaleSegmentedControl.selectedSegmentIndex]
        
        let body = [KeyConstant.userConfigurationLogsInterfaceScale.rawValue: UserConfiguration.logsInterfaceScale.rawValue]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.logsInterfaceScale = beforeUpdateLogsInterfaceScale
                self.logsInterfaceScaleSegmentedControl.selectedSegmentIndex = LogsInterfaceScale.allCases.firstIndex(of: UserConfiguration.logsInterfaceScale) ?? self.logsInterfaceScaleSegmentedControl.selectedSegmentIndex
            }
        }
    }
    
    @IBOutlet private weak var remindersInterfaceScaleSegmentedControl: UISegmentedControl!
    
    @IBAction private func didUpdateRemindersInterfaceScale(_ sender: Any) {
        
        let beforeUpdateRemindersInterfaceScale = UserConfiguration.remindersInterfaceScale
        
        // selected segement index is in the same order as all cases
        UserConfiguration.remindersInterfaceScale = RemindersInterfaceScale.allCases[remindersInterfaceScaleSegmentedControl.selectedSegmentIndex]
        
        let body = [KeyConstant.userConfigurationRemindersInterfaceScale.rawValue: UserConfiguration.remindersInterfaceScale.rawValue]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.remindersInterfaceScale = beforeUpdateRemindersInterfaceScale
                self.remindersInterfaceScaleSegmentedControl.selectedSegmentIndex = RemindersInterfaceScale.allCases.firstIndex(of: UserConfiguration.remindersInterfaceScale) ?? self.remindersInterfaceScaleSegmentedControl.selectedSegmentIndex
            }
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dark Mode
        interfaceStyleSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.white], for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = .systemGray4
        
        // Logs Interface Scale
        logsInterfaceScaleSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.white], for: .normal)
        logsInterfaceScaleSegmentedControl.backgroundColor = .systemGray4
        
        logsInterfaceScaleSegmentedControl.selectedSegmentIndex = LogsInterfaceScale.allCases.firstIndex(of: UserConfiguration.logsInterfaceScale) ?? logsInterfaceScaleSegmentedControl.selectedSegmentIndex
        
        // Reminders Interface Scale
        remindersInterfaceScaleSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.white], for: .normal)
        remindersInterfaceScaleSegmentedControl.backgroundColor = .systemGray4
        
        remindersInterfaceScaleSegmentedControl.selectedSegmentIndex = RemindersInterfaceScale.allCases.firstIndex(of: UserConfiguration.remindersInterfaceScale) ?? remindersInterfaceScaleSegmentedControl.selectedSegmentIndex
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // DARK MODE
        switch UserConfiguration.interfaceStyle.rawValue {
            // system/unspecified
        case 0:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 2
            // light
        case 1:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 0
            // dark
        case 2:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 1
        default:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .didDismissForSettingsPageViewController, object: self)
    }
    
}