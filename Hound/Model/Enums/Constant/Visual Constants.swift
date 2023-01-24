//
//  View Tag ClassConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum VisualConstant {
    // MARK: - Visual
    
    enum ViewTagConstant {
        // reserve 0 through 9999 for use within app. it will never reach anywhere near that level but it costs nothing to reserver some tags.
        
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
        
        static let semiboldAddDogAddReminderUILabel = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        
        static let lightDescriptionUILabel = UIFont.systemFont(ofSize: 12.5, weight: .light)
        static let semiboldEmphasizedDescriptionUILabel = UIFont.systemFont(ofSize: 12.5, weight: .semibold)
        static let regularUILabel = UIFont.systemFont(ofSize: 20, weight: .regular)
        static let boldEmphasizedUILabel = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        static let semiboldScreenWidthUIButton = UIFont.systemFont(ofSize: 30.0, weight: .semibold)
    }
    
    enum LayerConstant {
        static let defaultMasksToBounds = true
        static let defaultBorderWidth = 0.2
        static let defaultBorderColor = UIColor.systemGray2.cgColor
        static let defaultCornerRadius = 5.0
        
        static let screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderWidth = 2.0
        static let screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderColor = UIColor.black.cgColor
        
        static let screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderWidth = 0.0
        static let screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderColor = UIColor.clear.cgColor
    }
    
    enum BannerTextConstant {
        // MARK: - .success
        static let purchasedSubscriptionTitle = "Sucessfully Purchased Your Subscription!"
        static let purchasedSubscriptionSubtitle = "Enjoy your Hound family experience"
        
        static let restoreTransactionsTitle = "Sucessfully Restored Transactions!"
        static let restoreTransactionsSubtitle = "Any Hound purchase you have previously made with your Apple ID is recovered"
        
        static let redownloadDataTitle = "Redownload Data Successful!"
        static let redownloadDataSubtitle = "Your dogs, reminders, and logs have been redownloaded from the Hound server and are up-to-date"
        
        static let refreshRemindersTitle = "Reminders Refresh Successful!"
        static let refreshRemindersSubtitle = "Your dogs, reminders, and logs are now up-to-date"
        
        static let refreshLogsTitle = "Logs of Care Refresh Successful!"
        static let refreshLogsSubtitle = refreshRemindersSubtitle
        
        static let refreshFamilyTitle = "Family Refresh Successful!"
        static let refreshFamilySubtitle = "Your family is now up-to-date"
        
        static let refreshSubscriptionTitle = "Subscriptions Refresh Successful!"
        static let refreshSubscriptionSubtitle = "Your subscriptions are now up-to-date"
        
        // MARK: - .info
        
        static var houndUpdatedTitle: String {
            return "Hound updated to version \(UIApplication.appVersion)"
        }
        static var houndUpdatedSubtitle = "Tap to show release notes"
        
        // MARK: - .danger
        static let noCameraTitle = "You Don't Have a Camera!"
        
        static let alertForErrorTitle = "Uh oh! There seems to be an issue"
        
        static let notificationsDisabledTitle = "Notifications Disabled"
        static let notificationsDisabledSubtitle = "To enable notifications go to the Settings App -> Notifications -> Hound and enable \"Allow Notifications\""
        
        static let invalidLockedFamilyShareTitle = "Unable to share your Hound family!"
        static let invalidLockedFamilyShareSubtitle = "Currently, your Hound family is locked, preventing new users from joining. In order to share your family, please unlock it and retry."
        
        static let invalidSubscriptionFamilyShareTitle = "Unable to share your Hound family! "
        static var invalidSubscriptionFamilyShareSubtitle: String {
            let familyMembers = FamilyInformation.activeFamilySubscription.numberOfFamilyMembers
            return "Currently, your Hound family is limited to \(familyMembers) family member\(familyMembers == 1 ? "" : "s") and doesn't have space for more members. To increase this limit, please visit the Subscriptions page and upgrade your family."
        }
        
        static let invalidFamilyPermissionTitle = "You don't have permission to perform this action!"
        static let invalidFamilyPermissionSubtitle = "Only the family head can modify your family's subscription. Please contact the family head and have them complete this action."
    }
    
    enum TextConstant {
        static let unknownText = "Unknown ⚠️"
    }
    
    enum AnimationConstant {
        static let openCreateNewMenuDuration = 0.3
        static let closeCreateNewMenuDuration = 0.3
        static let removeCreateNewMenuDelay = 0.15
        static let weekdayButton = 0.12
        static let setCustomSelected = 0.12
    }
}
