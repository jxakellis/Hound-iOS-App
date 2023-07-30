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
        guard let sender = sender as? UISegmentedControl else {
            return
        }
        
        
        /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
        
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        let unconvertedNewInterfaceStyle = sender.selectedSegmentIndex
        let convertedNewInterfaceStyle = {
            switch unconvertedNewInterfaceStyle {
            case 0:
                return 1
            case 1:
                return 2
            default:
                return 0
            }
        }()
        
        UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: convertedNewInterfaceStyle) ?? UserConfiguration.interfaceStyle
        
        
        let body = [KeyConstant.userConfigurationInterfaceStyle.rawValue: convertedNewInterfaceStyle]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                
                sender.selectedSegmentIndex = {
                    switch UserConfiguration.interfaceStyle.rawValue {
                        // system/unspecified
                    case 0:
                        return 2
                        // light
                    case 1:
                        return 0
                        // dark
                    case 2:
                        return 1
                    default:
                        return 2
                    }
                }()
            }
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
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.systemBackground]
        let backgroundColor = UIColor.systemGray4
        
        // Dark Mode
        interfaceStyleSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = backgroundColor
        interfaceStyleSegmentedControl.selectedSegmentIndex = {
            switch UserConfiguration.interfaceStyle.rawValue {
                // system/unspecified
            case 0:
                return 2
                // light
            case 1:
                return 0
                // dark
            case 2:
                return 1
            default:
                return 2
            }
        }()
        
        // Logs Interface Scale
        logsInterfaceScaleSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        logsInterfaceScaleSegmentedControl.backgroundColor = backgroundColor
        logsInterfaceScaleSegmentedControl.selectedSegmentIndex = LogsInterfaceScale.allCases.firstIndex(of: UserConfiguration.logsInterfaceScale) ?? logsInterfaceScaleSegmentedControl.selectedSegmentIndex
        
        // Reminders Interface Scale
        remindersInterfaceScaleSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        remindersInterfaceScaleSegmentedControl.backgroundColor = backgroundColor
        remindersInterfaceScaleSegmentedControl.selectedSegmentIndex = RemindersInterfaceScale.allCases.firstIndex(of: UserConfiguration.remindersInterfaceScale) ?? remindersInterfaceScaleSegmentedControl.selectedSegmentIndex
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
