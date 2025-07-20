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
        guard let previousAppVersion = UIApplication.previousAppVersion, previousAppVersion != UIApplication.appVersion else { return }
        
        // make sure we haven't shown the release notes for this version before. To do this, we check to see if our array of app versions that we showed release notes for contains the app version of the current version. If the array does not contain the current app version, then we haven't shown release notes for this new version and we are ok to proceed.
        guard LocalConfiguration.localAppVersionsWithReleaseNotesShown.contains(UIApplication.appVersion) == false else { return }
        
        // TODO PRODUCTION run these scripts below
        // sudo apt-get update
        // sudo apt-get install --only-upgrade ca-certificates
        // sudo update-ca-certificates
        
        PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.houndUpdatedTitle, forSubtitle: Constant.Visual.BannerText.houndUpdatedSubtitle, forStyle: .info) {
            let releaseNotesVC = ReleaseNotesVC()
            PresentationManager.enqueueViewController(releaseNotesVC)
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
    
    /// Displays a view controller that asks for user's rating of hound
    static func requestSurveyAppExperienceIfNeeded() {
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
        
        guard isDueForSurveyAppExperienceRequest == true else { return }
        
        // Delay this call slightly so that current ui elements have time to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let vc = SurveyAppExperienceVC()
            PresentationManager.enqueueViewController(vc)
        }
    }
    
}
