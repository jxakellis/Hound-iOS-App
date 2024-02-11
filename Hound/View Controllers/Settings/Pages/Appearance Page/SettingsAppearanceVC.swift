//
//  SettingsAppearanceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsAppearanceViewController: GeneralUIViewController {

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
        UserRequest.update(errorAlert: .automaticallyAlertForAll, forBody: body) { responseStatus, _ in
            guard responseStatus == .successResponse else {
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
                return
            }
        }
    }
    
    @IBOutlet private weak var measurementSystemSegmentedControl: UISegmentedControl!
    @IBAction private func didUpdateMeasurementSystem(_ sender: Any) {
        guard let sender = sender as? UISegmentedControl else {
            return
        }

        /// Assumes the segmented control is configured for measurementSystem selection (0: imperial, 1: metric, 2: both).

        let beforeUpdateMeasurementSystem = UserConfiguration.measurementSystem

        UserConfiguration.measurementSystem = MeasurementSystem(rawValue: sender.selectedSegmentIndex) ?? UserConfiguration.measurementSystem

        let body = [KeyConstant.userConfigurationMeasurementSystem.rawValue: sender.selectedSegmentIndex]
        UserRequest.update(errorAlert: .automaticallyAlertForAll, forBody: body) { responseStatus, _ in
            guard responseStatus == .successResponse else {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.measurementSystem = beforeUpdateMeasurementSystem
                sender.selectedSegmentIndex = beforeUpdateMeasurementSystem.rawValue
                return
            }
        }
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

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
        
        measurementSystemSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        measurementSystemSegmentedControl.backgroundColor = backgroundColor
        measurementSystemSegmentedControl.selectedSegmentIndex = UserConfiguration.measurementSystem.rawValue
    }

}
