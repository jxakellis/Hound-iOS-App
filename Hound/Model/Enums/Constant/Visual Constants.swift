//
//  View Tag ClassConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum VisualConstant {
    // MARK: - Visual

    enum ViewTagConstant {
        // reserve lower bound of tag for potential use within app. tags will never reach anywhere near the upper bound of this reserved range but it costs nothing to reserve some tags.

        static let weekdayEnabled = 1000000004
        static let weekdayDisabled = 1000000005
        static let serverSyncViewControllerRetryLogin = 1000000006
        static let serverSyncViewControllerGoToLoginPage = 1000000007
    }

    enum FontConstant {
        static let unweightedSettingsPageLabel = UIFont.systemFont(ofSize: 20.0)

        static let secondaryLabelColorFeaturePromotionLabel = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        static let emphasizedSecondaryLabelColorFeaturePromotionLabel = UIFont.systemFont(ofSize: 15.0, weight: .bold)

        static let secondaryLabelColorFeatureDescriptionLabel = UIFont.systemFont(ofSize: 12.5, weight: .light)
        static let emphasizedSecondaryLabelColorFeatureDescriptionLabel = UIFont.systemFont(ofSize: 12.5, weight: .semibold)

        static let tertiaryLabelColorButtonDescriptionLabel = UIFont.systemFont(ofSize: 12.5, weight: .regular)

        static let underlinedClickableLabel = UIFont.systemFont(ofSize: 17.5, weight: .regular)
    }

    enum LayerConstant {
        /// 10.0
        static let defaultCornerRadius = 10.0
        /// 27.5
        static let imageCoveringViewCornerRadius = 27.5
    }

    enum BannerTextConstant {
        // MARK: - .success (banner style)
        static let purchasedSubscriptionTitle = "Sucessfully purchased subscription"
        static let purchasedSubscriptionSubtitle = "Enjoy your Hound family experience"

        static let restoreTransactionsTitle = "Sucessfully restored transactions"
        static let restoreTransactionsSubtitle = "Any Hound purchase you have previously made with your Apple ID is recovered"

        static let redownloadDataTitle = "Successfully redownloaded data"
        static let redownloadDataSubtitle = "Your dogs, reminders, and logs have been redownloaded from the Hound server and are up-to-date"

        static let refreshRemindersTitle = "Successfully refreshed reminders"
        static let refreshRemindersSubtitle = "Your dogs, reminders, and logs are now up-to-date"

        static let refreshLogsTitle = "Successfully refreshed logs of care"
        static let refreshLogsSubtitle = refreshRemindersSubtitle

        static let refreshFamilyTitle = "Successfully refreshed family"
        static let refreshFamilySubtitle = "Your family is now up-to-date"

        static let refreshSubscriptionTitle = "Successfully refreshed subscriptions"
        static let refreshSubscriptionSubtitle = "Your subscriptions are now up-to-date"

        static let copiedToClipboardTitle = "Copied to clipboard"
        static var copiedToClipboardSubtitle: String {
            UIPasteboard.general.string ?? ""
        }
        
        static let surveyFeedbackAppExperienceTitle = "Feedback Received!"
        static let surveyFeedbackAppExperienceSubtitle = "We're listening and committed to enhancing your Hound experience. Thank you!"

        // MARK: - .info (banner style)

        static var houndUpdatedTitle: String {
            "Hound updated to version \(UIApplication.appVersion)"
        }
        static var houndUpdatedSubtitle = "Tap to show release notes"

        // MARK: - .danger (banner style)
        static let noCameraTitle = "You don't have a camera"

        static let errorAlertTitle = "Uh oh! There seems to be an issue"

        static let notificationsDisabledTitle = "Notifications disabled"
        static let notificationsDisabledSubtitle = "To enable notifications go to Settings -> Notifications -> Hound and enable \"Allow Notifications\""

        static let invalidLockedFamilyShareTitle = "Unable to share your Hound family"
        static let invalidLockedFamilyShareSubtitle = "Currently, your Hound family is locked, preventing new users from joining. In order to share your family, please unlock it and retry"

        static let invalidFamilyPermissionTitle = "You don't have permission to perform this action"
        static let invalidFamilyPermissionSubtitle = "Only the family head can modify your family's subscription. Please contact the family head and have them complete this action"

    }

    enum TextConstant {
        static let unknownText = "Unknown ⚠️"
        static let unknownName = "Missing Name"
        static let unknownEmail = "Missing Email"
        static let unknownUserId = "Missing User ID"
        static let unknownHash = "0123456789012345678901234567890123456789012345678901234567890123"
    }

    enum AnimationConstant {
        static let openOrCloseCreateNewDogOrReminder = 0.3
        static let removeFromViewCreateNewDogOrReminderDelay = openOrCloseCreateNewDogOrReminder / 2.0
        /// Duration after selecting a ui element. For example: toggling weekday(s) for a weekly reminder or setCustomSelected for a drop down table view cell
        static let toggleSelectUIElement = 0.125
        static let spinUIElement = 0.4
        
        static let showOrHideUIElement = 0.15
    }
}
