//
//  CheckManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import CallKit
import StoreKit

enum CheckManager {
    
    /// Checks to see if the user is eligible for a notification to asking them to review Hound and if so presents the notification
    static func checkForReview() {
        // slight delay so it pops once some things are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let lastDateUserReviewRequested = LocalConfiguration.localPreviousDatesUserReviewRequested.last else {
                LocalConfiguration.localPreviousDatesUserReviewRequested.append(Date())
                PersistenceManager.persistRateReviewRequestedDates()
                return
            }
            
            // Check if we WANT to show the user a pop-up to review Hound.
            let isDueForReviewRequest: Bool = {
                // We want to user to review Hound every increasingDayInterval * numberOfTimesAskedToReviewBefore days. Additionally, we offset this value by 0.2 day (4.8 hour) to ask during different times of day.
                let increasingDayInterval = (7 * 3) + 2 + 0.2 // 23.2
                // We can only ask a user three time a year to review Hound, therefore, cap the interval to a value slightly under year/3 that asks them during different days of week / hours of day.
                let maximumDayInterval = (7 * 15) + 2 + 0.2 // 107.2
                
                let numberOfDaysToWaitForNextReview: Double = {
                    // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 23.2 days after the inital install.
                    // count == 2: asked one time; 46.4 days since last ask
                    // count == 3: asked two times; 69.6 days since last ask
                    // count == 4: asked three times; 92.8 days since last ask
                    
                    let dayInterval = Double(LocalConfiguration.localPreviousDatesUserReviewRequested.count) * increasingDayInterval
                    
                    return dayInterval <= maximumDayInterval ? dayInterval : maximumDayInterval
                }()
                
                let timeWaitedSinceLastAsk = lastDateUserReviewRequested.distance(to: Date())
                let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextReview * 24 * 60 * 60
                
                return timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk
            }()
            
            guard isDueForReviewRequest == true else {
                return
            }
            
            // Check if we CAN show the user a pop-up to review Hound.
            let isEligibleForReviewRequest: Bool = {
                // You can request a maximum of three reviews through StoreKit a year. If < 3, then the user is eligible to be asked.
                guard LocalConfiguration.localPreviousDatesUserReviewRequested.count >= 3 else {
                    return true
                }
                
                // User has been asked >= 3 times through StoreKit for review
                // Must cast array slice to array. Not castingDoesn't give compile error if you don't but [0] will crash below if slicing an array that isn't equal to suffix value
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
            
            /*
             Apple's built in requestReview feature will only work if the user has that setting enabled on their phone. There is no way of checking this though. Therefore, if the setting is set to false, this function turns into a NO-OP with no way for us to tell.
             
             This means we can't use a banner. We run the risk of displaying a banner that asks for a review and won't show anything if tapped. Therefore we use Apple's requestReview directly. If it works, then the user will see the pop-up. Otherwise, the user won't know anything triggered.
             */
            
            guard let window = UIApplication.keyWindow?.windowScene else {
                AppDelegate.generalLogger.error("checkForReview unable to fire, window not established")
                return
            }
            
            AppDelegate.generalLogger.notice("Asking user to rate Hound")
            
            SKStoreReviewController.requestReview(in: window)
            LocalConfiguration.localPreviousDatesUserReviewRequested.append(Date())
            PersistenceManager.persistRateReviewRequestedDates()
        }
        
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
        
        guard UIApplication.appVersion == "2.2.0" else {
            return
        }
        
        AppDelegate.generalLogger.notice("Showing Release Notes")
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.houndUpdatedTitle, forSubtitle: VisualConstant.BannerTextConstant.houndUpdatedSubtitle, forStyle: .info) {
            
            // If the user taps on the banner, then we show them the release notes
            
            let message = "-- Logs of Care exporting! Tap the new share button on the top right of the Logs of Care page to get a CSV file of your currently viewed logs.\n\n-- Personal information copying. Need to verify yourself with Hound support? Use the new copy buttons to the email and user id fields to quickly extract those details.\n\n-- Dynamic limit and exceeding limit error messages. If you encounter Hound's family member, dog, or reminder limits, you'll recieve a helpful, quantitative message guiding you through it."
            
            let updateAlertController = GeneralUIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion)", message: message, preferredStyle: .alert)
            let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            updateAlertController.addAction(understandAlertAction)
            AlertManager.enqueueAlertForPresentation(updateAlertController)
        }
        
        // we successfully showed the banner, so store the version we showed it for
        LocalConfiguration.localAppVersionsWithReleaseNotesShown.append(UIApplication.appVersion)
    }
    
    /// Displays message that the user should share Hound with a friend
    static func checkForShareHound() {
        
        guard let lastDateUserShareHoundRequested = LocalConfiguration.localPreviousDatesUserShareHoundRequested.last else {
            LocalConfiguration.localPreviousDatesUserShareHoundRequested.append(Date())
            return
        }
        
        // Check if we WANT to show the user a pop-up to share Hound.
        let isDueForShareRequest: Bool = {
            // We want to user to share Hound every increasingDayInterval * numberOfTimesAskedToShareBefore days. Additionally, we offset this value by 0.2 day (4.8 hour) to ask during different times of day.
            let increasingDayInterval = (7 * 2) + 5 + 0.2 // 19.2
            // We want to ask the user to share Hound at a minimum frequency. We don't want the interval to grow too large where we ask too infrequently. This variable caps the interval to ensure a certain frequency.
            let maximumDayInterval = (7 * 5) + 5 + 0.2 // 40.2
            
            let numberOfDaysToWaitForNextShare: Double = {
                // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 23.2 days after the inital install.
                // count == 2: asked one time; 46.4 days since last ask
                // count == 3: asked two times; 69.6 days since last ask
                // count == 4: asked three times; 92.8 days since last ask
                
                let dayInterval = Double(LocalConfiguration.localPreviousDatesUserShareHoundRequested.count) * increasingDayInterval
                
                return dayInterval <= maximumDayInterval ? dayInterval : maximumDayInterval
            }()
            
            let timeWaitedSinceLastAsk = lastDateUserShareHoundRequested.distance(to: Date())
            let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextShare * 24 * 60 * 60
            
            return timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk
        }()
        
        guard isDueForShareRequest == true else {
            return
        }
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.shareHoundTitle, forSubtitle: VisualConstant.BannerTextConstant.shareHoundSubtitle, forStyle: .info) {
            ExportManager.shareHound()
        }
        
        LocalConfiguration.localPreviousDatesUserShareHoundRequested.append(Date())
    }
    
}
