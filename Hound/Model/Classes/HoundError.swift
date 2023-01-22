//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class HoundError: Error {
    init(forName: String, forDescription: String) {
        self.name = forName
        self.description = forDescription
    }
    
    /// Constant name of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var name: String
    /// Dynamic descripton of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var description: String
    
    /// Alerts the user to this error. If the error is an appVersionOutdated error, presents a undismissable alert to update the app (bricking Hound until they update). Otherwise, presents a banner about the error
    func alert(onTap: (() -> Void)? = nil) {
        AppDelegate.generalLogger.error("Alerting user for error: \(self.description)")
        
        guard name != ErrorConstant.GeneralResponseError.appVersionOutdated.name else {
            // Create an alert controller that blocks everything, as it has no alert actions to dismiss
            let outdatedAppVersionAlertController = GeneralUIAlertController(title: VisualConstant.BannerTextConstant.alertForErrorTitle, message: description, preferredStyle: .alert)
            AlertManager.enqueueAlertForPresentation(outdatedAppVersionAlertController)
            return
        }
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.alertForErrorTitle, forSubtitle: description, forStyle: .danger) {
            onTap?()
        }
    }
}
