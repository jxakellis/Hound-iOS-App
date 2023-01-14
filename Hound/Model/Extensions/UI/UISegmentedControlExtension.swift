//
//  File.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/11/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
    func updateInterfaceStyle() {
        
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        let convertedInterfaceStyleRawValue: Int = {
            switch self.selectedSegmentIndex {
            case 0:
                UserConfiguration.interfaceStyle = .light
                return 1
            case 1:
                UserConfiguration.interfaceStyle = .dark
                return 2
            default:
                UserConfiguration.interfaceStyle = .unspecified
                return 0
            }
        }()
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        let body = [KeyConstant.userConfigurationInterfaceStyle.rawValue: convertedInterfaceStyleRawValue]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UIApplication.keyWindow?.overrideUserInterfaceStyle = beforeUpdateInterfaceStyle
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                switch UserConfiguration.interfaceStyle.rawValue {
                    // system/unspecified
                case 0:
                    self.selectedSegmentIndex = 2
                    // light
                case 1:
                    self.selectedSegmentIndex = 0
                    // dark
                case 2:
                    self.selectedSegmentIndex = 1
                    // system/unspecified
                default:
                    self.selectedSegmentIndex = 2
                }
            }
        }
    }
}
