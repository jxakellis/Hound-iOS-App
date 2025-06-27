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
        let userId = UserInformation.userId

        /// If onTap isn't specified, this is the default action to take.
        let defaultOnTap: (() -> Void) = {
            var message = "Name: \(forName)\nDescription: \(forDescription)"
            if let userId = userId {
                message.append("\nSupport ID: \(userId)")
            }

            let errorInformationAlertController = UIAlertController(title: "Error Information", message: message, preferredStyle: .alert)
            let copyAlertAction = UIAlertAction(title: "Copy to Clipboard", style: .default) { _ in
                UIPasteboard.general.setPasteboard(forString: message)
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            errorInformationAlertController.addAction(copyAlertAction)
            errorInformationAlertController.addAction(cancelAlertAction)
            PresentationManager.enqueueAlert(errorInformationAlertController)
        }

        self.onTap = forOnTap ?? defaultOnTap
    }

    // MARK: - Functions

    /// Alerts the user to this error. If the error is an appVersionOutdated error, presents a undismissable alert to update the app (bricking Hound until they update). Otherwise, presents a banner about the error
    func alert() {
        AppDelegate.generalLogger.error("Alerting user for error: \(self.description)")

        guard name != ErrorConstant.GeneralResponseError.appVersionOutdated(forRequestId: -1, forResponseId: -1).name else {
            let vc = AppVersionOutdatedVC()
            PresentationManager.enqueueViewController(vc)
            return
        }
        
        guard name != ErrorConstant.FamilyResponseError.limitFamilyMemberExceeded(forRequestId: -1, forResponseId: -1).name else {
            let vc = LimitExceededViewController()
            PresentationManager.enqueueViewController(vc)
            return
        }

        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.errorAlertTitle, forSubtitle: description, forStyle: .danger) {
            self.onTap()
        }
    }
}

final class HoundServerError: HoundError {

    // MARK: - Properties

    /// The requestId of a request to the Hound server that failed and generated an error
    private(set) var requestId: Int

    /// The responseId of a response from the Hound server due to a request that failed and generated an error
    private(set) var responseId: Int

    // MARK: - Main
    
    init(forName: String, forDescription: String, forOnTap: (() -> Void)?, forRequestId: Int, forResponseId: Int) {
        self.requestId = forRequestId
        self.responseId = forResponseId
        let userId = UserInformation.userId

        /// If onTap isn't specified, this is the default action to take.
        let defaultOnTap: (() -> Void) = {
            var message = "Name: \(forName)\nDescription: \(forDescription)\nRequest ID: \(forRequestId)\nResponse ID: \(forResponseId)"
            if let userId = userId {
                message.append("\nSupport ID: \(userId)")
            }

            let errorInformationAlertController = UIAlertController(title: "Error Information", message: message, preferredStyle: .alert)
            let copyAlertAction = UIAlertAction(title: "Copy to Clipboard", style: .default) { _ in
                UIPasteboard.general.setPasteboard(forString: message)
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            errorInformationAlertController.addAction(copyAlertAction)
            errorInformationAlertController.addAction(cancelAlertAction)
            PresentationManager.enqueueAlert(errorInformationAlertController)
        }

        super.init(forName: forName, forDescription: forDescription, forOnTap: forOnTap ?? defaultOnTap)
    }
}
