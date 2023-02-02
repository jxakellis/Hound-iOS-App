//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundError: Error {
    // MARK: - Properties
    
    /// Constant name of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var name: String
    /// Dynamic descripton of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var description: String
    
    /// If a HoundError is generated, a banner is shown for it, and the user taps the banner, this is the action that will be taken (after the banner is tapped).
    private(set) var onTap: (() -> Void)
    
    // MARK: - Main
    init(forName: String, forDescription: String, forOnTap: (() -> Void)?) {
        self.name = forName
        self.description = forDescription
        
        /// If onTap isn't specified, this is the default action to take.
        let defaultOnTap: (() -> Void) = {
            let errorInformationAlertController = GeneralUIAlertController(title: "Error Information", message: "Name: \(forName)\nDescription: \(forDescription)", preferredStyle: .alert)
            let OKAlertAction = UIAlertAction(title: "OK", style: .default)
            errorInformationAlertController.addAction(OKAlertAction)
            AlertManager.enqueueAlertForPresentation(errorInformationAlertController)
        }
        
        self.onTap = forOnTap ?? defaultOnTap
    }
    
    // MARK: - Functions
    
    /// Alerts the user to this error. If the error is an appVersionOutdated error, presents a undismissable alert to update the app (bricking Hound until they update). Otherwise, presents a banner about the error
    func alert() {
        AppDelegate.generalLogger.error("Alerting user for error: \(self.description)")
        
        guard name != ErrorConstant.GeneralResponseError.appVersionOutdated(forRequestId: -1, forResponseId: -1).name else {
            // Create an alert controller that blocks everything, as it has no alert actions to dismiss
            let outdatedAppVersionAlertController = GeneralUIAlertController(title: VisualConstant.BannerTextConstant.alertForErrorTitle, message: description, preferredStyle: .alert)
            AlertManager.enqueueAlertForPresentation(outdatedAppVersionAlertController)
            return
        }
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.alertForErrorTitle, forSubtitle: description, forStyle: .danger) {
            self.onTap()
        }
    }
}

class HoundServerError: HoundError {
    
    // MARK: - Properties
    
    /// The requestId of a request to the Hound server that failed and generated an error
    private(set) var requestId: Int
    
    /// The responseId of a response from the Hound server due to a request that failed and generated an error
    private(set) var responseId: Int
    
    // MARK: - Main
    init(forName: String, forDescription: String, forOnTap: (() -> Void)?, forRequestId: Int, forResponseId: Int) {
        self.requestId = forRequestId
        self.responseId = forResponseId
        
        /// If onTap isn't specified, this is the default action to take.
        let defaultOnTap: (() -> Void) = {
            let errorInformationAlertController = GeneralUIAlertController(title: "Error Information", message: "Name: \(forName)\nDescription: \(forDescription)\nRequest ID: \(forRequestId)\nResponse ID: \(forResponseId)", preferredStyle: .alert)
            let OKAlertAction = UIAlertAction(title: "OK", style: .default)
            errorInformationAlertController.addAction(OKAlertAction)
            AlertManager.enqueueAlertForPresentation(errorInformationAlertController)
        }
        
        super.init(forName: forName, forDescription: forDescription, forOnTap: forOnTap ?? defaultOnTap)
    }
}
