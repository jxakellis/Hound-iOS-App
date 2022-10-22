//
//  CheckManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import CallKit
import StoreKit

enum CheckManager {
    
    /// Checks to see if the user is eligible for a notification to asking them to review Hound and if so presents the notification
    static func checkForReview() {
        // slight delay so it pops once some things are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
            guard let lastUserAskedToReviewHoundDate = LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound.last else {
                LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound.append(Date())
                return
            }
            
            let isEligibleForBannerToReviewHound: Bool = {
                // We want to ask the user in increasing intervals of time for a review on Hound. The function below increases the number of days between reviews and help ensure that reviews get asked at different times of day.
                let numberOfDaysToWaitForNextReview: Double = {
                    let count = LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound.count
                    guard count >= 5 else {
                        // Count == 1: Been asked zero times before (first Date() is a placeholder). We ask 9.2 days after the inital install.
                        // Count == 2: asked one time; 18.4 days since last ask; 27.6 days since beginning
                        // Count == 3: asked two times; 27.6 days since last ask; 55.2 since beginning
                        // Count == 4: asked three times; 36.8 days since last ask; 92.0 since beginning
                        return Double(count) * 9.2
                    }
                    
                    // Count == 5: asked four times; 45.0 days since last ask; 137.0 since beginning
                    // Count == 6: asked five times; 45.2 days; 182.2
                    // Count == 7: asked six times; 45.4 days; 227.6
                    // Count == 8: asked seven times; 45.6 days; 273.2
                    // Count == 9: asked eight times; 45.8 days; 319.0
                    // Count == 10: asked nine times; 45.0 days; 364.0
                    return Double(45.0 + Double(count % 5) * 0.2)
                }()
                
                let timeWaitedSinceLastAsk = lastUserAskedToReviewHoundDate.distance(to: Date())
                let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextReview * 24 * 60 * 60
                
                return timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk
            }()
            
            guard isEligibleForBannerToReviewHound == true else {
                return
            }
            
            let isEligibleForReviewRequest: Bool = {
                // You can request a maximum of three reviews through StoreKit a year. If < 3, then the user is eligible to be asked.
                guard LocalConfiguration.localPreviousDatesUserReviewRequested.count >= 3 else {
                    return true
                }
                
                // User has been asked >= 3 times through StoreKit for review
                // Must cast array slice to array. Doesn't give compile error if you don't but [0] will crash below if slicing an array that isn't equal to suffix value
                let lastThreeDates = Array(LocalConfiguration.localPreviousDatesUserReviewRequested.suffix(3))
                
                // If the first element in this array (of the last three items) is > 1 year ago, then we can give the option to use the built in app review method. This is because we aren't exceeding our 3 a year limit anymore
                let timeWaitedSinceLastRate = lastThreeDates[0].distance(to: Date())
                let timeNeededToWaitForNextRate = 367.0 * 24 * 60 * 60
                
                if  timeWaitedSinceLastRate > timeNeededToWaitForNextRate {
                    return true
                }
                else {
                    return false
                }
            }()
            
            guard isEligibleForReviewRequest == true else {
                return
            }
            
            AlertManager.enqueueBannerForPresentation(forTitle: "Are you enjoying Hound?", forSubtitle: "Tap this banner to rate Hound. Your feedback helps support future development and improvements!", forStyle: .info) {
                // Open Apple's built in review page. Simple a pop-up that allows user to select number of starts and submit
                guard let window = UIApplication.keyWindow?.windowScene else {
                    AppDelegate.generalLogger.error("checkForReview unable to fire, window not established")
                    return
                }
                
                AppDelegate.generalLogger.notice("Asking user to rate Hound")
                SKStoreReviewController.requestReview(in: window)
                LocalConfiguration.localPreviousDatesUserReviewRequested.append(Date())
                PersistenceManager.persistRateReviewRequestedDates()
            }
            
            LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound.append(Date())
            
        })
        
    }
    
    /// Displays release notes about a new version to the user if they have that setting enabled and the app was updated to that new version
    static func checkForReleaseNotes() {
        // Check that the app was opened before, as we don't want to show the user release notes on their first launch
        // Then, check that the current version doesn't match the previous version, meaning an upgrade or downgrade. The latter shouldnt be possible
        guard let previousAppVersion = UIApplication.previousAppVersion, previousAppVersion != UIApplication.appVersion else {
            return
        }
        
        // make sure we haven't shown the release notes for this version before. To do this, we check to see if our array of app versions that we showed release notes for contains the app version of the current version. If the array does not contain the current app version, then we haven't shown release notes for this new version and we are ok to proceed.
        guard LocalConfiguration.localAppVersionsWithReleaseNotesShown.contains(UIApplication.appVersion) == false else {
            return
        }
        
        guard UIApplication.appVersion == "2.0.0" else {
            return
        }
        
        AppDelegate.generalLogger.notice("Showing Release Notes")
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.houndUpdatedTitle, forSubtitle: VisualConstant.BannerTextConstant.houndUpdatedSubtitle, forStyle: .info) {
            
            // If the user taps on the banner, then we show them the release notes
            
            let message = "-- Cloud storage! Create your Hound account with the 'Sign In with Apple' feature and have all of your information saved to the Hound server.\n-- Family sharing! Create your own Hound family and have other users join it, allowing your logs, reminders, and notifications to all sync.\n-- Refined UI. Enjoy a smoother, more fleshed out UI experience with quality of life tweaks.\n-- Settings Revamp. Utilize the redesigned settings page to view more options in a cleaner way."
            
            let updateAlertController = GeneralUIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion)", message: message, preferredStyle: .alert)
            let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            updateAlertController.addAction(understandAlertAction)
            AlertManager.enqueueAlertForPresentation(updateAlertController)
        }
        
        // we successfully showed the banner, so store the version we showed it for
        LocalConfiguration.localAppVersionsWithReleaseNotesShown.append(UIApplication.appVersion)
    }
    
}
