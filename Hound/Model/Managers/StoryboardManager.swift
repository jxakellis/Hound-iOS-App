//
//  StoryboardViewControllerManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/29/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum StoryboardViewControllerManager {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    /// In order to present SettingsSubscriptionViewController, starts a fetching indicator. Then, performs a both a product and transactions request, to ensure those are both updated. If all of that completes successfully, returns the subscription view controller. Otherwise, automatically displays an error message and returns nil
    static func getSettingsSubscriptionViewController(completionHandler: @escaping ((UIViewController?) -> Void)) {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsSubscriptionViewController.self))
        viewController.modalPresentationStyle = .pageSheet
        
            PresentationManager.beginFetchingInformationIndictator()

            InAppPurchaseManager.fetchProducts { products, error  in
                guard products != nil else {
                    // If the product request returned nil, meaning there was an error, then end the request indicator early and exit
                    PresentationManager.endFetchingInformationIndictator(completionHandler: nil)
                    error?.alert()
                    completionHandler(nil)
                    return
                }

                // request indictator is still active
                TransactionsRequest.get(invokeErrorManager: true) { requestWasSuccessful, _, _ in
                    PresentationManager.endFetchingInformationIndictator {
                        guard requestWasSuccessful else {
                            error?.alert()
                            completionHandler(nil)
                            return
                        }
                        
                        completionHandler(viewController)
                    }

                }
            }
    }
}
