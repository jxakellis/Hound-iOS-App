//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ErrorConstant {
    
    static func serverError(forErrorCode errorCode: String) -> HoundError? {
        // MARK: - GENERAL
        if errorCode == "ER_GENERAL_APP_VERSION_OUTDATED" {
            return GeneralResponseError.appVersionOutdated
        }
        // ER_GENERAL_ENVIRONMENT_INVALID
        // ER_GENERAL_PARSE_FORM_DATA_FAILED
        // ER_GENERAL_PARSE_JSON_FAILED
        // ER_GENERAL_POOL_CONNECTION_FAILED
        // ER_GENERAL_POOL_TRANSACTION_FAILED
        else if errorCode == "ER_GENERAL_APPLE_SERVER_FAILED" {
            return GeneralResponseError.appleServerFailed
        }
        // MARK: - VALUE
        // ER_VALUE_MISSING
        // ER_VALUE_INVALID
        // MARK: - PERMISSION
        // MARK: NO
        else if errorCode == "ER_PERMISSION_NO_USER" {
            return PermissionResponseError.noUser
        }
        else if errorCode == "ER_PERMISSION_NO_FAMILY" {
            return PermissionResponseError.noFamily
        }
        else if errorCode == "ER_PERMISSION_NO_DOG" {
            return PermissionResponseError.noDog
        }
        else if errorCode == "ER_PERMISSION_NO_LOG" {
            return PermissionResponseError.noLog
        }
        else if errorCode == "ER_PERMISSION_NO_REMINDER" {
            return PermissionResponseError.noReminder
        }
        // MARK: INVALID
        else if errorCode == "ER_PERMISSION_INVALID_FAMILY" {
            return PermissionResponseError.invalidFamily
        }
        // MARK: - FAMILY
        // MARK: LIMIT
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW" {
            return FamilyResponseError.limitFamilyMemberTooLow
        }
        else if errorCode == "ER_FAMILY_LIMIT_DOG_TOO_LOW" {
            return FamilyResponseError.limitDogTooLow
        }
        else if errorCode == "ER_FAMILY_LIMIT_LOG_TOO_LOW" {
            return FamilyResponseError.limitLogTooLow
        }
        else if errorCode == "ER_FAMILY_LIMIT_REMINDER_TOO_LOW" {
            return FamilyResponseError.limitReminderTooLow
        }
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED" {
            return FamilyResponseError.limitFamilyMemberExceeded
        }
        else if errorCode == "ER_FAMILY_LIMIT_DOG_EXCEEDED" {
            return FamilyResponseError.limitDogExceeded
        }
        // MARK: DELETED
        else if errorCode == "ER_FAMILY_DELETED_DOG" {
            return FamilyResponseError.deletedDog
        }
        else if errorCode == "ER_FAMILY_DELETED_LOG" {
            return FamilyResponseError.deletedLog
        }
        else if errorCode == "ER_FAMILY_DELETED_REMINDER" {
            return FamilyResponseError.deletedReminder
        }
        // MARK: JOIN
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_CODE_INVALID" {
            return FamilyResponseError.joinFamilyCodeInvalid
        }
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_LOCKED" {
            return FamilyResponseError.joinFamilyLocked
        }
        else if errorCode == "ER_FAMILY_JOIN_IN_FAMILY_ALREADY" {
            return FamilyResponseError.joinInFamilyAlready
        }
        // MARK: Leave
        else if errorCode == "ER_FAMILY_LEAVE_SUBSCRIPTION_ACTIVE" {
            return FamilyResponseError.leaveSubscriptionActive
        }
        else if errorCode == "ER_FAMILY_LEAVE_STILL_FAMILY_MEMBERS" {
            return FamilyResponseError.leaveStillFamilyMembers
        }
        // MARK: - NONE
        else {
            return nil
        }
    }
    
    // MARK: - Text Constants
    
    private static let contactHoundSupport: String = "If the issue persists, please contact Hound support."
    private static let restartHoundAndRetry: String = "If the issue persists, please restart and retry."
    private static let potentialHoundServerOutage: String = "If the issue persists, Hound's server may be experiencing an outage."
    private static let verifyInternetConnection: String = "Please verify that you are connected to the internet and retry."
    private static let tryShorterOne: String = "Please try a shorter one."
    private static let enterValidCode: String = "Please enter in a valid code and retry."
    
    // MARK: - API Request
    
    enum GeneralRequestError {
        static var noInternetConnection: HoundError {
            return HoundError(
                forName: "GeneralRequestError.noInternetConnection",
                forDescription: "Your device doesn't appear to be connected to the internet. \(ErrorConstant.verifyInternetConnection)",
                forOnTap: nil)
        }
    }
    
    enum FamilyRequestError {
        static var familyCodeBlank: HoundError {
            return HoundError(
                forName: "FamilyRequestError.familyCodeBlank",
                forDescription: "Your family code is blank! \(ErrorConstant.enterValidCode)",
                forOnTap: nil)
        }
        static var familyCodeInvalid: HoundError {
            return HoundError(
                forName: "FamilyRequestError.familyCodeInvalid",
                forDescription: "Your family code's format is invalid! \(ErrorConstant.enterValidCode)",
                forOnTap: nil)
        }
    }
    
    // MARK: - API Response
    
    enum GeneralResponseError {
        
        /// The app version that the user is using is out dated
        static var appVersionOutdated: HoundError {
            return HoundError(
                forName: "GeneralResponseError.appVersionOutdated",
                forDescription: "Version \(UIApplication.appVersion) of Hound is outdated. Please update to the latest version to continue.",
                forOnTap: nil)
        }
        static var appleServerFailed: HoundError {
            return HoundError(
                forName: "GeneralResponseError.appleServerFailed",
                forDescription: "Hound was unable to contact Apple's iTunes server and complete your request. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        /// GET: != 200...299, e.g. 400, 404, 500
        static var getFailureResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.getFailureResponse",
                forDescription: "We experienced an issue while retrieving your data Hound's server. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var getNoResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.getNoResponse",
                forDescription: "We were unable to reach Hound's server and retrieve your data. \(ErrorConstant.verifyInternetConnection) \(ErrorConstant.potentialHoundServerOutage)",
                forOnTap: nil)
        }
        
        /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
        static var postFailureResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.postFailureResponse",
                forDescription: "Hound's server experienced an issue in saving your new data. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var postNoResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.postNoResponse",
                forDescription: "We were unable to reach Hound's server and save your new data. \(ErrorConstant.verifyInternetConnection) \(ErrorConstant.potentialHoundServerOutage)",
                forOnTap: nil)
        }
        
        /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
        static var putFailureResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.putFailureResponse",
                forDescription: "Hound's server experienced an issue in updating your data. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var putNoResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.putNoResponse",
                forDescription: "We were unable to reach Hound's server and update your data. \(ErrorConstant.verifyInternetConnection) \(ErrorConstant.potentialHoundServerOutage)",
                forOnTap: nil)
        }
        
        /// DELETE:  != 200...299, e.g. 400, 404, 500
        static var deleteFailureResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.deleteFailureResponse",
                forDescription: "Hound's server experienced an issue in deleting your data. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var deleteNoResponse: HoundError {
            return HoundError(
                forName: "GeneralResponseError.deleteNoResponse",
                forDescription: "We were unable to reach Hound's server to delete your data. \(ErrorConstant.verifyInternetConnection) \(ErrorConstant.potentialHoundServerOutage)",
                forOnTap: nil)
        }
    }
    
    enum PermissionResponseError {
        static var noUser: HoundError {
            return HoundError(
                forName: "PermissionResponseError.noUser",
                forDescription: "You are attempting to access a user that doesn't exist or you don't have permission to. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static var noFamily: HoundError {
            return HoundError(
                forName: "PermissionResponseError.noFamily",
                forDescription: "You are attempting to access a family that doesn't exist or you don't have permission to. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static var noDog: HoundError {
            return HoundError(
                forName: "PermissionResponseError.noDog",
                forDescription: "You are attempting to access a dog that doesn't exist or you don't have permission to. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static var noLog: HoundError {
            return HoundError(
                forName: "PermissionResponseError.noLog",
                forDescription: "You are attempting to access a log that doesn't exist or you don't have permission to. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static var noReminder: HoundError {
            return HoundError(
                forName: "PermissionResponseError.noReminder",
                forDescription: "You are attempting to access a reminder that doesn't exist or you don't have permission to. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        static var invalidFamily: HoundError {
            return HoundError(
                forName: "PermissionResponseError.invalidFamily",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(ErrorConstant.contactHoundSupport)",
                forOnTap: nil)
        }
    }
    
    enum FamilyResponseError {
        
        // TO DO FUTURE check to see if family subscription is at maximum possible value. if it is, then dont tell them to upgrade as they simply can't upgrade
        
        // MARK: Limit
        // Too Low
        static var limitFamilyMemberTooLow: HoundError {
            // user can't be family head in this situation as they are attempting to join a family
            // additionally, since the user wasn't able to join the family, they can't know the family member limit.
            return HoundError(
                forName: "FamilyResponseError.limitFamilyMemberTooLow",
                forDescription: "This family can only have a limited number of family members! Please have the family head upgrade their subscription before attempting to join this family.",
                forOnTap: nil)
        }
        static var  limitDogTooLow: HoundError {
            // spell out the number of dogs the family can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let dogLimit = formatter.string(from: FamilyInformation.activeFamilySubscription.numberOfDogs as NSNumber) ?? "negative one"
            
            // user could be family head or they could be a family member
            var description = "Your family can only have \(dogLimit) dogs! "
            if FamilyInformation.isUserFamilyHead {
                description.append("Please upgrade your family's subscription before attempting to add a new dog.")
            }
            else {
                description.append("Please have the family head upgrade your family's subscription before attempting to add a new dog.")
            }
            
            return HoundError(
                forName: "FamilyResponseError.limitDogTooLow",
                forDescription: description,
                forOnTap: nil)
        }
        static var  limitLogTooLow: HoundError {
            return HoundError(
                forName: "FamilyResponseError.limitLogTooLow",
                forDescription: "Your dog can only have a limited number of logs! Please remove an existing log before trying to add a new one. If you are having difficulty with this limit, please contact Hound support.",
                forOnTap: nil)
        }
        static var  limitReminderTooLow: HoundError {
            return HoundError(
                forName: "FamilyResponseError.limitReminderTooLow",
                forDescription: "Your dog can only have a limited number of reminders! Please remove an existing reminder before trying to add a new one.",
                forOnTap: nil)
        }
        
        // Exceeded
        static var  limitFamilyMemberExceeded: HoundError {
            // find out how many family members can be in the family
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let familyMemberLimit = formatter.string(from: FamilyInformation.activeFamilySubscription.numberOfFamilyMembers as NSNumber) ?? "negative one"
            
            // user could be family head or they could be a family member
            var description = "Your family is exceeding it's \(familyMemberLimit) family member limit and is unable to have data added or updated. This is likely due to your family's subscription expiring or being downgraded. "
            if FamilyInformation.isUserFamilyHead {
                description.append("To restore functionality, please remove family members or upgrade your subscription.")
            }
            else {
                description.append("To restore functionality, please have the family head remove family members or upgrade your subscription.")
            }
            
            return HoundError(
                forName: "FamilyResponseError.limitFamilyMemberExceeded",
                forDescription: description,
                forOnTap: nil)
        }
        static var  limitDogExceeded: HoundError {
            // find out how many family members can be in the family
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let dogLimit = formatter.string(from: FamilyInformation.activeFamilySubscription.numberOfDogs as NSNumber) ?? "negative one"
            
            // user could be family head or they could be a family member
            var description = "Your family has exceeded it's \(dogLimit) dog limit and is unable to have data added or updated. This is likely due to your family's subscription being downgraded or expiring. "
            if FamilyInformation.isUserFamilyHead {
                description.append("To restore functionality, please remove dogs or upgrade your subscription.")
            }
            else {
                description.append("To restore functionality, please have remove  the family head remove family members or upgrade your subscription.")
            }
            
            return HoundError(
                forName: "FamilyResponseError.limitDogExceeded",
                forDescription: description,
                forOnTap: nil)
        }
        
        // MARK: Deleted
        /// The dog that the user is trying to access has been marked as deleted
        static var deletedDog: HoundError {
            return HoundError(
                forName: "FamilyResponseError.deletedDog",
                forDescription: "The dog you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil)
        }
        /// The log that the user is trying to access has been marked as deleted
        static var deletedLog: HoundError {
            return HoundError(
                forName: "FamilyResponseError.deletedLog",
                forDescription: "The log you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil)
        }
        /// The reminder that the user is trying to access has been marked as deleted
        static var deletedReminder: HoundError {
            return HoundError(
                forName: "FamilyResponseError.deletedReminder",
                forDescription: "The reminder you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil)
        }
        
        // MARK: Join
        /// Family code was valid but was not linked to any family
        static var joinFamilyCodeInvalid: HoundError {
            return HoundError(
                forName: "FamilyResponseError.joinFamilyCodeInvalid",
                forDescription: "The family code you input isn't linked to any family. \(ErrorConstant.enterValidCode)",
                forOnTap: nil)
        }
        /// Family code was valid and linked to a family but the family was locked
        static var  joinFamilyLocked: HoundError {
            return HoundError(
                forName: "FamilyResponseError.joinFamilyLocked",
                forDescription: "The family you are trying to join is locked, preventing any new family members from joining. Please have an existing family member unlock it and retry.",
                forOnTap: nil)
        }
        /// User is already in a family and therefore can't join a new one
        static var  joinInFamilyAlready: HoundError {
            return HoundError(
                forName: "FamilyResponseError.joinInFamilyAlready",
                forDescription: "You are already in a family. Please leave your existing family before attempting to join a new one. \(ErrorConstant.contactHoundSupport)",
                forOnTap: nil)
        }
        
        // MARK: Leave
        static var  leaveSubscriptionActive: HoundError {
            return HoundError(
                forName: "FamilyResponseError.leaveSubscriptionActive",
                forDescription: "You are unable to delete your current family due having an active, auto-renewing subscription. To continue, tap this banner to cancel your subscription. \(ErrorConstant.contactHoundSupport)") {
                    // If the user taps the banner, that means they want to cancel their Hound subscription. The only way to cancel a subscription is with Apple's manage subscriptions page.
                    InAppPurchaseManager.showManageSubscriptions()
                }
        }
        static var  leaveStillFamilyMembers: HoundError {
            // if user is family head, then add piece about removing other family members. this error shouldn't happen if the user isn't the family head, and therefore we direct them more toward hound support
            var description = "You are unable to leave your current family. "
            if FamilyInformation.isUserFamilyHead {
                description.append("Please remove all existing family members before attempting to leave. ")
            }
            description.append("\(ErrorConstant.contactHoundSupport)")
            
            return HoundError(
                forName: "FamilyResponseError.leaveStillFamilyMembers",
                forDescription: description,
                forOnTap: nil)
        }
    }
    
    // MARK: - Class
    
    enum InAppPurchaseError {
        // MARK: Product Request Of Available In-App Purchases
        static var productRequestInProgress: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.productRequestInProgress",
                forDescription: "There is a in-app purchase product request currently in progress. You are unable to initiate another in-app purchase product request until the first one has finished processing. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// The app cannot request App Store about available IAP products for some reason.
        static var productRequestFailed: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.productRequestFailed",
                forDescription: "Your in-app purchase product request has failed. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// No in-app purchase products were returned by the App Store because none was found.
        static var productRequestNotFound: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.productRequestNotFound",
                forDescription: "Your in-app purchase product request did not return any results. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        // MARK: User Attempting To Make An In-App Purchase
        /// User can't make any in-app purchase because SKPaymentQueue.canMakePayment() == false
        static var purchaseRestricted: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchaseRestricted",
                forDescription: "Your device is restricted from accessing the Apple App Store and is unable to make in-app purchases. Please remove this restriction before attempting to make another in-app purchase.",
                forOnTap: nil)
        }
        
        /// User can't make any in-app purchase because they are not the family head
        static var purchasePermission: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchasePermission",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(ErrorConstant.contactHoundSupport)",
                forOnTap: nil)
        }
        
        /// There is a in-app purchases in progress, so a new one cannot be initiated currentProductPurchase != nil || productPurchaseCompletionHandler != nil
        static var purchaseInProgress: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchaseInProgress",
                forDescription: "There is an in-app purchase currently in progress. You are unable to initiate another in-app purchase until the first one has finished processing. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        /// Deferred. Most likely due to pending parent approval from Ask to Buy
        static var purchaseDeferred: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchaseDeferred",
                forDescription: "Your in-app purchase is pending an approval from your parent. To complete your purchase, please have your parent approve the request within 24 hours.",
                forOnTap: nil)
        }
        
        /// The in app purchase failed and was not completed
        static var purchaseFailed: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchaseFailed",
                forDescription: "Your in-app purchase has failed. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        /// Unknown error
        static var purchaseUnknown: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.purchaseUnknown",
                forDescription: "Your in-app purchase has experienced an unknown error. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        // MARK: User Attempting To Restore An In-App Purchase
        
        /// User can't make any in-app purchase restoration because they are not the family head
        static var restorePermission: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.restorePermission",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(ErrorConstant.contactHoundSupport)",
                forOnTap: nil)
        }
        
        /// There is a in-app purchases restoration in progress, so a new one cannot be initiated
        static var restoreInProgress: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.restoreInProgress",
                forDescription: "There is an in-app purchase restoration currently in progress. You are unable to initiate another in-app purchase restoration until the first one has finished processing. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        static var restoreFailed: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.restoreFailed",
                forDescription: "Your in-app purchase restoration has failed. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        
        // MARK: System Is Processing Transaction In The Background
        static var backgroundPurchaseInProgress: HoundError {
            return HoundError(
                forName: "InAppPurchaseError.backgroundPurchaseInProgress",
                forDescription: "There is a transaction currently being processed in the background. This is likely due to a subscription renewal. Please wait a moment for this to finish processing. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
    }
    
    enum DogError {
        static var dogNameNil: HoundError {
            return HoundError(
                forName: "DogError.dogNameNil",
                forDescription: "Your dog's name is invalid! Please try a different one.",
                forOnTap: nil)
        }
        static var dogNameBlank: HoundError {
            return HoundError(
                forName: "DogError.dogNameBlank",
                forDescription: "Your dog's name is blank! Try typing something in.",
                forOnTap: nil)
        }
        static var dogNameCharacterLimitExceeded: HoundError {
            return HoundError(
                forName: "DogError.dogNameCharacterLimitExceeded",
                forDescription: "Your dog's name is too long! \(ErrorConstant.tryShorterOne)",
                forOnTap: nil)
        }
    }
    
    enum LogError {
        static var parentDogNotSelected: HoundError {
            return HoundError(
                forName: "LogError.parentDogNotSelected",
                forDescription: "Your log needs a corresponding dog! Please try selecting at least one.",
                forOnTap: nil)
        }
        static var logActionBlank: HoundError {
            return HoundError(
                forName: "LogError.logActionBlank",
                forDescription: "Your log has no action! Please try selecting one.",
                forOnTap: nil)
        }
        static var logCustomActionNameCharacterLimitExceeded: HoundError {
            return HoundError(
                forName: "LogError.logCustomActionNameCharacterLimitExceeded",
                forDescription: "Your log's custom name is too long! \(ErrorConstant.tryShorterOne)",
                forOnTap: nil)
        }
        static var logNoteCharacterLimitExceeded: HoundError {
            return HoundError(
                forName: "LogError.logNoteCharacterLimitExceeded",
                forDescription: "Your log's note is too long! \(ErrorConstant.tryShorterOne)",
                forOnTap: nil)
        }
    }
    
    enum ReminderError {
        static var reminderActionBlank: HoundError {
            return HoundError(
                forName: "ReminderError.reminderActionBlank",
                forDescription: "Your reminder has no action! Please try selecting one.",
                forOnTap: nil)
        }
        static var reminderCustomActionNameCharacterLimitExceeded: HoundError {
            return HoundError(
                forName: "ReminderError.reminderCustomActionNameCharacterLimitExceeded",
                forDescription: "Your reminders's custom name is too long! \(ErrorConstant.tryShorterOne)",
                forOnTap: nil)
        }
    }
    
    enum SignInWithAppleError {
        static var canceled: HoundError {
            return HoundError(
                forName: "SignInWithAppleError.canceled",
                forDescription: "The 'Sign In With Apple' page was prematurely canceled. \(ErrorConstant.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static var notSignedIn: HoundError {
            return HoundError(
                forName: "SignInWithAppleError.notSignedIn",
                forDescription: "The 'Sign In With Apple' page failed as you have no Apple ID. Please create an Apple ID with two-factor authentication enabled and retry.",
                forOnTap: nil)
        }
        static var other: HoundError {
            return HoundError(
                forName: "SignInWithAppleError.other",
                forDescription: "The 'Sign In With Apple' page failed. Please make sure you have an Apple ID with two-factor authentication enabled and retry.",
                forOnTap: nil)
        }
    }
    
    enum UnknownError {
        static var unknown: HoundError {
            return HoundError(
                forName: "UnknownError.unknown",
                forDescription: "Hound has experienced an unknown error. \(ErrorConstant.contactHoundSupport)",
                forOnTap: nil)
        }
    }
    
    enum WeeklyComponentsError {
        static var weekdayArrayInvalid: HoundError {
            return HoundError(
                forName: "WeeklyComponentsError.weekdayArrayInvalid",
                forDescription: "Please select at least one day of the week for your reminder. You can do this by tapping on the S, M, T, W, T, F, or S. A blue letter means that your reminder's alarm will sound that day and grey means it won't.",
                forOnTap: nil)
        }
    }
    
}
