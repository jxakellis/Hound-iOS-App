//
//  ShowBonusInformationManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import CallKit
import StoreKit

enum ShowBonusInformationManager {
    
    /// Displays release notes about a new version to the user if they have that setting enabled and the app was updated to that new version
    static func showReleaseNotesBannerIfNeeded() {
        // Check that the app was opened before, as we don't want to show the user release notes on their first launch
        // Then, check that the current version doesn't match the previous version, meaning an upgrade or downgrade. The latter shouldnt be possible
        guard let previousAppVersion = UIApplication.previousAppVersion, previousAppVersion != UIApplication.appVersion else {
            return
        }
        
        // make sure we haven't shown the release notes for this version before. To do this, we check to see if our array of app versions that we showed release notes for contains the app version of the current version. If the array does not contain the current app version, then we haven't shown release notes for this new version and we are ok to proceed.
        guard LocalConfiguration.localAppVersionsWithReleaseNotesShown.contains(UIApplication.appVersion) == false else {
            return
        }
        
        guard UIApplication.appVersion == "0.0.0" else {
            return
        }
        
        AppDelegate.generalLogger.notice("Showing Release Notes")
        
        let message: String? = "- Offline Mode! Venturing into the woods with Bella? Fear not. Now, Hound lets you add or update Bella's data, even off the grid.\n\n- Banner Messages Reimagined! We've given our banner messages a splash of fun and friendliness, ensuring every notification brings a wag to your day."
        
        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.houndUpdatedTitle, forSubtitle: message != nil ? VisualConstant.BannerTextConstant.houndUpdatedSubtitle : nil, forStyle: .info) {
            guard let message = message else {
                return
            }
            // If the user taps on the banner, then we show them the release notes
            
            let updateAlertController = UIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion)", message: message, preferredStyle: .alert)
            let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            updateAlertController.addAction(understandAlertAction)
            PresentationManager.enqueueAlert(updateAlertController)
        }
        
        // we successfully showed the banner, so store the version we showed it for
        LocalConfiguration.localAppVersionsWithReleaseNotesShown.append(UIApplication.appVersion)
    }
    
    /// This is the number of seconds in a day
    private static let dayDurationInSeconds: Double = 24.0 * 60.0 * 60.0
    
    /// We want to user to review Hound every increasingDaysBetween * numberOfTimesAskedToAppReviewReview days. Additionally, we offset this value by 0.2 day (4.8 hour) to ask during different times of day.
    private static let increasingDaysBetweenAppStoreReview: Double = 5.0 + 0.2
    /// We can only ask a user three time a year to review Hound, therefore, cap the interval to a value slightly over year / 3.
    private static let maximumDaysBetweenAppStoreReview: Double = 122.0 + 0.2
    
    /// We want to user to share Hound every increasingDaysBetween * numberOfTimesAskedToSurveyAppExperience days. Additionally, we offset this value by 0.2 day (4.8 hour) to ask during different times of day.
    private static let increasingDaysBetweenSurveyAppExperience = 3.0 + 0.2
    /// We begin by asking the user to review Hound with at a minimum frequency. This interval progressively grows, but we don't want the interval to grow too large where we ask too infrequently. This variable caps the interval to ensure a certain frequency.
    private static let maximumDaysBetweenSurveyAppExperience: Double = 40.0 + 0.2
    
    /// Checks to see if the user is eligible for a notification to asking them to review Hound and if so presents the notification
    static func requestAppStoreReviewIfNeeded() {
        // We don't want to request an app store star rating if we recently requested a survey app experience
        if let lastDateSurveyAppExperienceRequested = LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.last {
            if lastDateSurveyAppExperienceRequested.distance(to: Date()) <= 1.2 * dayDurationInSeconds {
                return
            }
        }
        
        guard let lastDateUserReviewRequested = LocalConfiguration.localPreviousDatesUserReviewRequested.last else {
            LocalConfiguration.localPreviousDatesUserReviewRequested.append(Date())
            PersistenceManager.persistRateReviewRequestedDates()
            return
        }
        
        // Check if we WANT to show the user a pop-up to review Hound.
        let isDueForReviewRequest: Bool = {
            // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 9.2 days after the initial install.
            // count == 2: asked one time; 18.4 days since last ask
            // count == 3: asked two times; 27.6 days since last ask
            // count == 4: asked three times; 36.8 days since last ask
            
            let numberOfDaysToWaitForNextReview: Double = min(
                Double(LocalConfiguration.localPreviousDatesUserReviewRequested.count) * increasingDaysBetweenAppStoreReview,
                maximumDaysBetweenAppStoreReview
            )
            
            let timeWaitedSinceLastAsk = lastDateUserReviewRequested.distance(to: Date())
            let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextReview * dayDurationInSeconds
            
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
            
            let thirdToLastUserReviewRequestedDate = LocalConfiguration.localPreviousDatesUserReviewRequested.safeIndex(
                LocalConfiguration.localPreviousDatesUserReviewRequested.count - 3)
            let timeWaitedSinceOldestReviewRequest = thirdToLastUserReviewRequestedDate?.distance(to: Date())
            
            guard let timeWaitedSinceOldestReviewRequest = timeWaitedSinceOldestReviewRequest else {
                return false
            }
            let timeNeededToWaitForNextReviewRequest = 367.0 * dayDurationInSeconds
            
            return timeWaitedSinceOldestReviewRequest > timeNeededToWaitForNextReviewRequest
        }()
        
        guard isEligibleForReviewRequest == true else {
            return
        }
        
        /*
         Apple's built in requestReview feature will only work if the user has that setting enabled on their phone. There is no way of checking this though. Therefore, if the setting is set to false, this function turns into a NO-OP with no way for us to tell.
         
         This means we can't use a banner. We run the risk of displaying a banner that asks for a review and won't show anything if tapped. Therefore we use Apple's requestReview directly. If it works, then the user will see the pop-up. Otherwise, the user won't know anything triggered.
         */
        
        guard let window = UIApplication.keyWindow?.windowScene else {
            AppDelegate.generalLogger.error("requestAppStoreReviewIfNeeded unable to fire, window not established")
            return
        }
        
        // Delay this call slightly so that current ui elements have time to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AppDelegate.generalLogger.notice("Asking user to rate Hound")
            
            SKStoreReviewController.requestReview(in: window)
            LocalConfiguration.localPreviousDatesUserReviewRequested.append(Date())
            PersistenceManager.persistRateReviewRequestedDates()
        }
        
    }
    
    /// Displays a view controller that asks for user's rating of hound
    static func requestSurveyAppExperienceIfNeeded() {
        // We don't want to request a survey for the app experience if we recently requested an app store star rating
        if let lastDateAppStoreViewRequested = LocalConfiguration.localPreviousDatesUserReviewRequested.last {
            if lastDateAppStoreViewRequested.distance(to: Date()) <= 1.2 * dayDurationInSeconds {
                return
            }
        }
        
        // This is the duration, in seconds, that Hound should wait before repeating showing the user the pop up to review the app. Currently, we wait 6 months before asking a user for a survey again
        let durationToWaitBeforeRepeatingSurvey = 180.0 * dayDurationInSeconds
        
        guard let lastDateSurveyAppExperienceRequested = LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.last else {
            LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
            return
        }
        
        if let lastDateUserSurveyFeedbackAppExperienceSubmitted = LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.last {
            if lastDateUserSurveyFeedbackAppExperienceSubmitted.distance(to: Date()) < durationToWaitBeforeRepeatingSurvey {
                return
            }
        }
        
        // Check if we WANT to show the user a pop-up to share Hound.
        let isDueForSurveyAppExperienceRequest: Bool = {
            // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 5.2 days after the initial install.
            // count == 2: asked one time; 10.4 days since last ask
            // count == 3: asked two times; 15.6 days since last ask
            // count == 4: asked three times; 20.8 days since last ask
            
            let numberOfDaysToWaitForNextSurveyAppExperience: Double = min(
                Double(LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.count) * increasingDaysBetweenSurveyAppExperience,
                maximumDaysBetweenSurveyAppExperience
            )
            
            let timeWaitedSinceLastAsk = lastDateSurveyAppExperienceRequested.distance(to: Date())
            let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextSurveyAppExperience * dayDurationInSeconds
            
            return timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk
        }()
        
        guard isDueForSurveyAppExperienceRequest == true else {
            return
        }
        
       // Delay this call slightly so that current ui elements have time to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
            
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.getSurveyFeedbackAppExperienceViewController())
        }
    }
    
}
