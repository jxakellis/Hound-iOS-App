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
                let increasingDayInterval = 9 + 0.2 // 9.2
                // We can only ask a user three time a year to review Hound, therefore, cap the interval to a value slightly under year/3 that asks them during different days of week / hours of day.
                let maximumDayInterval = (7 * 15) + 2 + 0.2 // 107.2

                let numberOfDaysToWaitForNextReview: Double = {
                    // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 9.2 days after the initial install.
                    // count == 2: asked one time; 18.4 days since last ask
                    // count == 3: asked two times; 27.6 days since last ask
                    // count == 4: asked three times; 36.8 days since last ask

                    let dayInterval = Double(LocalConfiguration.localPreviousDatesUserReviewRequested.count) * increasingDayInterval

                    return min(dayInterval, maximumDayInterval)
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

                let thirdToLastUserReviewRequestedDate = LocalConfiguration.localPreviousDatesUserReviewRequested.safeIndex(
                    LocalConfiguration.localPreviousDatesUserReviewRequested.count - 3)
                let timeWaitedSinceOldestReviewRequest = thirdToLastUserReviewRequestedDate?.distance(to: Date())

                guard let timeWaitedSinceOldestReviewRequest = timeWaitedSinceOldestReviewRequest else {
                    return false
                }
                let timeNeededToWaitForNextReviewRequest = 367.0 * 24 * 60 * 60

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

        // TODO Write this message before publishing. Added calories for log unit, added Vaccine type, added custom names for medicine and vaccines, in-app surveys, improved error pages (limit too low, limit exceeded),
        guard UIApplication.appVersion == "3.2.0" else {
            return
        }

        AppDelegate.generalLogger.notice("Showing Release Notes")
        
        let message: String? = "-- Logs Filtering! Quickly sift through your logs, focusing on specific dogs, log types, or family members. Finding that one special log just got a whole lot easier!\n\n-- Log End Dates! Never have any more ambiguity on how long your log lasted by adding a log end date.\n\n-- Revamped Add Logs Page! Adding logs is now faster and smoother. Our reworked Add Log page not only speeds up your log entries but also integrates seamlessly with our new data fields.\n\n-- Revamped Logs Page! We've given our Logs page a makeover for a more seamless viewing experience that focuses on the data you most care about."

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

    /// Displays a view controller that asks for user's rating of hound
    static func checkForSurveyFeedbackAppExperience() {
        guard let lastDateUserShareHoundRequested = LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.last else {
            LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
            return
        }
        
        if let lastDateUserSurveyFeedbackAppExperienceSubmitted = LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.last {
            // Don't ask for this survey more than every 6 months
            if lastDateUserSurveyFeedbackAppExperienceSubmitted.distance(to: Date()) < 180.0 * 24.0 * 60.0 * 60.0 {
                return
            }
        }

        // Check if we WANT to show the user a pop-up to share Hound.
        let isDueForShareRequest: Bool = {
            // We want to user to share Hound every increasingDayInterval * numberOfTimesAskedToShareBefore days. Additionally, we offset this value by 0.2 day (4.8 hour) to ask during different times of day.
            let increasingDayInterval = 5 + 0.2 // 5.2
            // We want to ask the user to share Hound at a minimum frequency. We don't want the interval to grow too large where we ask too infrequently. This variable caps the interval to ensure a certain frequency.
            let maximumDayInterval = 40 + 0.2 // 40.2

            let numberOfDaysToWaitForNextShare: Double = {
                // count == 1: Been asked zero times before (first Date() is a placeholder). We ask 5.2 days after the initial install.
                // count == 2: asked one time; 10.4 days since last ask
                // count == 3: asked two times; 15.6 days since last ask
                // count == 4: asked three times; 20.8 days since last ask

                let dayInterval = Double(LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.count) * increasingDayInterval

                return min(dayInterval, maximumDayInterval)
            }()

            let timeWaitedSinceLastAsk = lastDateUserShareHoundRequested.distance(to: Date())
            let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextShare * 24 * 60 * 60

            return timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk
        }()

        guard isDueForShareRequest == true else {
            return
        }
        
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
        
        PresentationManager.enqueueViewController(StoryboardViewControllerManager.getSurveyFeedbackAppExperienceViewController())
    }

}
