//
//  StoryboardViewControllerManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/29/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum StoryboardViewControllerManager {
    // TODO go through this once conversion is gone and set and modalPresentationStyle for all of these
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    enum SettingsViewControllers {
        static func getSettingsAccountViewController(forDelegate: SettingsAccountViewControllerDelegate) -> SettingsAccountViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsAccountViewController.self)) as! SettingsAccountViewController // swiftlint:disable:this force_cast
            
            viewController.setup(forDelegate: forDelegate)
            viewController.modalPresentationStyle = .pageSheet
            
            return viewController
        }
        
        static func getSettingsFamilyViewController() -> SettingsFamilyViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsFamilyViewController.self)) as! SettingsFamilyViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .pageSheet
            
            return viewController
        }
        
        /// In order to present SettingsSubscriptionViewController, starts a fetching indicator. Then, performs a both a product and transactions request, to ensure those are both updated. If all of that completes successfully, returns the subscription view controller. Otherwise, automatically displays an error message and returns nil
        static func getSettingsSubscriptionViewController(completionHandler: @escaping ((SettingsSubscriptionViewController?) -> Void)) {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsSubscriptionViewController.self)) as! SettingsSubscriptionViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .fullScreen
            
                PresentationManager.beginFetchingInformationIndicator()

                InAppPurchaseManager.fetchProducts { error  in
                    guard error == nil else {
                        // If the product request returned nil, meaning there was an error, then end the request indicator early and exit
                        PresentationManager.endFetchingInformationIndicator(completionHandler: nil)
                        error?.alert()
                        completionHandler(nil)
                        return
                    }

                    // request indictator is still active
                    TransactionsRequest.get(forErrorAlert: .automaticallyAlertForAll) { responseStatus, houndError in
                        PresentationManager.endFetchingInformationIndicator {
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
        
        static func getSettingsAppearanceViewController() -> SettingsAppearanceViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsAppearanceViewController.self)) as! SettingsAppearanceViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .pageSheet
            
            return viewController
        }
        
        static func getSettingsNotifsTableVC() -> SettingsNotifsTableVC {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsNotifsTableVC.self)) as! SettingsNotifsTableVC // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .pageSheet
            
            return viewController
        }
    }
    
    enum IntroductionViewControllers {
        static func getRemindersIntroductionViewController(forDelegate: RemindersIntroductionViewControllerDelegate, forDogManager: DogManager) -> RemindersIntroductionViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: RemindersIntroductionViewController.self)) as! RemindersIntroductionViewController // swiftlint:disable:this force_cast
            
            viewController.setup(forDelegate: forDelegate, forDogManager: forDogManager)
            viewController.modalPresentationStyle = .fullScreen
            
            return viewController
        }
        static func getSettingsFamilyIntroductionViewController(forDelegate: SettingsFamilyIntroductionViewControllerDelegate) -> SettingsFamilyIntroductionViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingsFamilyIntroductionViewController.self)) as! SettingsFamilyIntroductionViewController // swiftlint:disable:this force_cast
            
            viewController.setup(forDelegate: forDelegate)
            viewController.modalPresentationStyle = .fullScreen
            
            return viewController
        }
    }
    
    enum ErrorInformationViewControllers {
        static func getAppVersionOutdatedViewController() -> AppVersionOutdatedViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: AppVersionOutdatedViewController.self)) as! AppVersionOutdatedViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .fullScreen
            
            return viewController
        }
        
        static func getFamilyLimitExceededViewController() -> FamilyLimitExceededViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: FamilyLimitExceededViewController.self)) as! FamilyLimitExceededViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .fullScreen
            
            return viewController
        }
        
        static func getFamilyLimitTooLowViewController() -> FamilyLimitTooLowViewController {
            // This should never fail. And if it does, it should do catastrophically so we know it failed
            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: FamilyLimitTooLowViewController.self)) as! FamilyLimitTooLowViewController // swiftlint:disable:this force_cast
            
            viewController.modalPresentationStyle = .fullScreen
            
            return viewController
        }
    }
    
    static func getSurveyFeedbackAppExperienceViewController() -> SurveyFeedbackAppExperienceViewController {
        // This should never fail. And if it does, it should do catastrophically so we know it failed
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SurveyFeedbackAppExperienceViewController.self)) as! SurveyFeedbackAppExperienceViewController // swiftlint:disable:this force_cast
        
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
    
}
