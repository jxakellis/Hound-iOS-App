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
        // MARK: Header Labels
        static let primaryHeaderLabel = UIFont.systemFont(ofSize: 35.0, weight: .bold)
        
        static let secondaryHeaderLabel = UIFont.systemFont(ofSize: 25.0, weight: .medium)
        static let emphasizedSecondaryHeaderLabel = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
        
        static let tertiaryHeaderLabel = UIFont.systemFont(ofSize: 21.5, weight: .regular)
        
        // MARK: Regular Labels
        
        static let primaryRegularLabel = UIFont.systemFont(ofSize: 19.0, weight: .regular)
        static let emphasizedPrimaryRegularLabel = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
        
        static let weakSecondaryRegularLabel = UIFont.systemFont(ofSize: 17.0, weight: .light)
        static let secondaryRegularLabel = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        static let emphasizedSecondaryRegularLabel = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        
        static let tertiaryRegularLabel = UIFont.systemFont(ofSize: 15.5, weight: .regular)
        static let emphasizedTertiaryRegularLabel = UIFont.systemFont(ofSize: 15.5, weight: .semibold)

        // MARK: Description Labels
        static let secondaryColorDescLabel = UIFont.systemFont(ofSize: 15.5, weight: .light)
        static let emphasizedSecondaryColorDescLabel = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        
        static let tertiaryColorDescLabel = UIFont.systemFont(ofSize: 15.5, weight: .regular)
        static let emphasizedTertiaryColorDescLabel = UIFont.systemFont(ofSize: 15.5, weight: .semibold)

        // MARK: Buttons
        static let wideButton = UIFont.systemFont(ofSize: 27.5, weight: .semibold)
        static let circleButton = UIFont.systemFont(ofSize: 22.5, weight: .medium)
        
        // MARK: Badge
        static let badgeLabel = UIFont.systemFont(ofSize: 12.5, weight: .bold)
    }

    enum LayerConstant {
        static let defaultCornerRadius = 10.0
        static let imageCoveringViewCornerRadius = 27.5
    }

    enum BannerTextConstant {
        // MARK: - .success (banner style)
        
        static let successPurchasedSubscriptionTitle = "Welcome to Hound+"
        static let successPurchasedSubscriptionSubtitle = "Dive into the full Hound experience with your family. Enjoy!"

        static let successRestoreTransactionsTitle = "Transactions Back on Track"
        static let successRestoreTransactionsSubtitle = "We've retrieved all your past Hound purchases. Enjoy!"

        static let successRedownloadDataTitle = "Data Re-barked and Ready"
        static let successRedownloadDataSubtitle = "Your dogs, reminders, and logs have been redownloaded from the Hound server and are up-to-date"

        static let successRefreshRemindersTitle = successRedownloadDataTitle
        static let successRefreshRemindersSubtitle = "Your dogs, reminders, and logs are now up-to-date"

        static let successRefreshLogsTitle = successRedownloadDataTitle
        static let successRefreshLogsSubtitle = successRefreshRemindersSubtitle

        static let successRefreshFamilyTitle = "Family Fur-ever Refreshed"
        static let successRefreshFamilySubtitle = "Your family is now up-to-date"

        static let copiedToClipboardTitle = "Copied to Clipboard ✂️"
        static var copiedToClipboardSubtitle: String {
            UIPasteboard.general.string ?? ""
        }
        
        static let surveyFeedbackAppExperienceTitle = "Your Bark, Our Command! 📣"
        static let surveyFeedbackAppExperienceSubtitle = "Thanks for sharing! We're listening and committed to enhancing your Hound experience"

        // MARK: - .info (banner style)

        static let houndUpdatedTitle: String = "Fresh Paws on the Block! 🐾"
        static var houndUpdatedSubtitle: String {
            return "Tap here to check out what version \(UIApplication.appVersion) has in store for you!"
        }
        
        static let infoEnteredOfflineModeTitle = "Switched to Offline Mode"
        static let infoEnteredOfflineModeSubtitle = "Hang tight! We'll sync your data as soon as we reconnect to the Hound servers"
        
        static let infoRedownloadOnHoldTitle = "Your Updates, Coming Up!"
        static let infoRedownloadOnHoldSubtitle = "Hang tight! We'll redownload the latest on your pups as soon as we reconnect to the Hound servers"

        static let infoRefreshOnHoldTitle = "Your Updates, Coming Up!"
        static let infoRefreshOnHoldSubtitle = "Hang tight! We'll fetch the latest on your pups as soon as we reconnect to the Hound servers"

        // MARK: - .danger (banner style)
        
        static let noCameraTitle = "Camera Needed for Snaps 📷"
        static let noCameraSubtitle = "Enable camera access to capture moments with your pup"

        static let errorAlertTitle = "Uh-oh! We sniffed out an issue 🐾"

        static let notificationsDisabledTitle = "Heads Up! Notifications Disabled 🔕"
        static let notificationsDisabledSubtitle = "To enable notifications go to Settings -> Notifications -> Hound and enable \"Allow Notifications\""

        static let invalidLockedFamilyShareTitle = "Family Sharing Gate Locked 🔒"
        static let invalidLockedFamilyShareSubtitle = "Currently, your Hound family is locked, preventing new users from joining. In order to share your family, please unlock it and retry"

        static let notFamilyHeadInvalidPermissionTitle = "Paws Off! Permission Needed 🚫"
        static let notFamilyHeadInvalidPermissionSubtitle = "Only the family head can modify your family's subscription. Please contact them to complete this action"

    }

    enum TextConstant {
        static let unknownText = "Unknown ⚠️"
        static let unknownName = "Missing Name"
        static let unknownEmail = "Missing Email"
        static let unknownUserId = "Missing User ID"
        static let unknownHash = "0123456789012345678901234567890123456789012345678901234567890123"
        static let unknownUUID: UUID = UUID(uuidString: "00000000-0000-4000-8000-000000000000")! // swiftlint:disable:this force_unwrapping
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
