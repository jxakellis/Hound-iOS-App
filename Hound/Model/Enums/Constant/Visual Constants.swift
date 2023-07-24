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
        
        static let placeholderLabelForBorderedUILabel = 1000000001
        static let placeholderLabelForScaledUILabel = 1000000002
        static let placeholderLabelForUITextView = 1000000003
        static let weekdayEnabled = 1000000004
        static let weekdayDisabled = 1000000005
        static let serverSyncViewControllerRetryLogin = 1000000006
        static let serverSyncViewControllerGoToLoginPage = 1000000007
    }
    
    enum FontConstant {
        static let noWeightLogUILabel = UIFont.systemFont(ofSize: 15.0)
        
        static let regularFilterByLogUILabel = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let semiboldFilterByDogUILabel = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        static let semiboldAddDogAddReminderLabel = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        
        static let regularPrimaryLabel = UIFont.systemFont(ofSize: 20, weight: .regular)
        static let emphasizedPrimaryLabel = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        static let regularSecondaryLabel = UIFont.systemFont(ofSize: 12.5, weight: .light)
        static let emphasizedSecondaryLabel = UIFont.systemFont(ofSize: 12.5, weight: .semibold)
        
        static let regularTertiaryLabel = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        
        static let semiboldButton = UIFont.systemFont(ofSize: 25, weight: .semibold)
    }
    
    enum LayerConstant {
        /// true
        static let defaultMasksToBounds = true
        
        /// 10.0
        static let defaultCornerRadius = 10.0
        /// 27.5
        static let imageCoveringViewCornerRadius = 27.5
        
        /// 0.0
        static let noBorderWidth = 0.0
        /// 0.25
        static let defaultBorderWidth = 0.25
        /// 1.0
        static let lightBorderWidth = 1.0
        /// 2.0
        static let boldBorderWidth = 2.0
        
        /// UIColor.systemGray2.cgColor
        static let defaultBorderColor = UIColor.systemGray2.cgColor
        /// UIColor.clear.cgColor
        static let nonWhiteBackgroundBorderColor = UIColor.clear.cgColor
        /// UIColor.black.cgColor
        static let whiteBackgroundBorderColor = UIColor.black.cgColor
        
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
            return UIPasteboard.general.string ?? ""
        }
        
        // MARK: - .info (banner style)
        
        static var houndUpdatedTitle: String {
            return "Hound updated to version \(UIApplication.appVersion)"
        }
        static var houndUpdatedSubtitle = "Tap to show release notes"
        
        static let shareHoundTitle = "Do you find Hound helpful?"
        static let shareHoundSubtitle = "Get your friends' and families' lives more organized by tapping this banner to share Hound"
        
        // MARK: - .danger (banner style)
        static let noCameraTitle = "You don't have a camera"
        
        static let alertForErrorTitle = "Uh oh! There seems to be an issue"
        
        static let notificationsDisabledTitle = "Notifications disabled"
        static let notificationsDisabledSubtitle = "To enable notifications go to Settings -> Notifications -> Hound and enable \"Allow Notifications\""
        
        static let invalidLockedFamilyShareTitle = "Unable to share your Hound family"
        static let invalidLockedFamilyShareSubtitle = "Currently, your Hound family is locked, preventing new users from joining. In order to share your family, please unlock it and retry"
        
        static let invalidSubscriptionFamilyShareTitle = "Unable to share your Hound family"
        static var invalidSubscriptionFamilyShareSubtitle: String {
            let familyMembers = FamilyInformation.activeFamilySubscription.numberOfFamilyMembers
            return "Currently, your Hound family is limited to \(familyMembers) family member\(familyMembers == 1 ? "" : "s") and doesn't have space for more members. To increase this limit, please visit the Subscriptions page and upgrade your family"
        }
        
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
        static let openCreateNewMenuDuration = 0.3
        static let closeCreateNewMenuDuration = 0.3
        static let removeCreateNewMenuDelay = 0.15
        static let toggleWeekdayButton = 0.12
        static let setCustomSelectedTableViewCell = 0.12
    }
}
