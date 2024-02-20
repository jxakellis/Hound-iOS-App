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
    static func getSettingsSubscriptionViewController(completionHandler: @escaping ((SettingsSubscriptionViewController?) -> Void)) {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsSubscriptionViewController.self)) as! SettingsSubscriptionViewController // swiftlint:disable:this force_cast
        
        viewController.modalPresentationStyle = .fullScreen
        
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
                TransactionsRequest.get(forErrorAlert: .automaticallyAlertForAll) { responseStatus, houndError in
                    PresentationManager.endFetchingInformationIndictator {
                        guard responseStatus == .successResponse else {
                            (error ?? houndError)?.alert()
                            completionHandler(nil)
                            return
                        }
                        
                        completionHandler(viewController)
                    }

                }
            }
    }
    
    static func getAppVersionOutdatedViewController() -> AppVersionOutdatedViewController {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: AppVersionOutdatedViewController.self)) as! AppVersionOutdatedViewController // swiftlint:disable:this force_cast
        
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
    
    static func getSurveyFeedbackAppExperienceViewController() -> SurveyFeedbackAppExperienceViewController {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SurveyFeedbackAppExperienceViewController.self)) as! SurveyFeedbackAppExperienceViewController // swiftlint:disable:this force_cast
        
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
    
    static func getFamilyLimitExceededViewController() -> FamilyLimitExceededViewController {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: FamilyLimitExceededViewController.self)) as! FamilyLimitExceededViewController // swiftlint:disable:this force_cast
        
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
    
    static func getRemindersIntroductionViewController(forDelegate: RemindersIntroductionViewControllerDelegate, forDogManager: DogManager) -> RemindersIntroductionViewController {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: RemindersIntroductionViewController.self)) as! RemindersIntroductionViewController // swiftlint:disable:this force_cast
        
        viewController.setup(forDelegate: forDelegate, forDogManager: forDogManager)
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
}
