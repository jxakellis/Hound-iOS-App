//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ErrorConstant {
    
    static func serverError(forErrorCode errorCode: String) -> HoundError? {
        // MARK: - FamilyResponseError
        // MARK: Limit
        if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW" {
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
        // MARK: Join
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
        else if errorCode == "ER_FAMILY_LEAVE_INVALID" {
            return FamilyResponseError.leaveInvalid
        }
        else if errorCode == "ER_FAMILY_LEAVE_SUBSCRIPTION_ACTIVE" {
            return FamilyResponseError.leaveSubscriptionActive
        }
        // MARK: Permission
        else if errorCode == "ER_FAMILY_PERMISSION_INVALID" {
            return FamilyResponseError.permissionInvalid
        }
        // MARK: - GeneralResponseError
        else if errorCode == "ER_GENERAL_APP_VERSION_OUTDATED" {
            return GeneralResponseError.appVersionOutdated
        }
        else if errorCode == "ER_GENERAL_APPLE_SERVER_FAILED" {
            return GeneralResponseError.appleServerFailed
        }
        else {
            return nil
        }
    }
    
    // MARK: - API Request
    
    enum FamilyRequestError {
        static var familyCodeBlank: HoundError {
            return HoundError(forName: "FamilyRequestError.familyCodeBlank", forDescription: "Your family code is blank! Please enter in a valid code and retry.")
        }
        static var familyCodeInvalid: HoundError {
            return HoundError(forName: "FamilyRequestError.familyCodeInvalid", forDescription: "Your family code's format is invalid! Please enter in a valid code and retry.")
        }
    }
    
    enum GeneralRequestError {
        static var noInternetConnection: HoundError {
            return HoundError(forName: "GeneralRequestError.noInternetConnection", forDescription: "Your device doesn't appear to be connected to the internet. Please verify that you are connected to the internet and retry.")
        }
    }
    
    // MARK: - API Response
    
    enum FamilyResponseError {
        
        // MARK: Limit
        // Too Low
        static var limitFamilyMemberTooLow: HoundError {
            return HoundError(forName: "FamilyResponseError.limitFamilyMemberTooLow", forDescription: "This family can only have a limited number of family members! Please have the family head upgrade their subscription before attempting to join this family.")
        }
        static var  limitDogTooLow: HoundError {
            return HoundError(forName: "FamilyResponseError.limitDogTooLow", forDescription: "Your family can only have a limited number of dogs! Please have the family head upgrade your family's subscription before attempting to add a new dog.")
        }
        static var  limitLogTooLow: HoundError {
            return HoundError(forName: "FamilyResponseError.limitLogTooLow", forDescription: "Your dog can only have a limited number of logs! Please remove an existing log before trying to add a new one. If you are having difficulty with this limit, please contact Hound support.")
        }
        static var  limitReminderTooLow: HoundError {
            return HoundError(forName: "FamilyResponseError.limitReminderTooLow", forDescription: "Your dog can only have a limited number of reminders! Please remove an existing reminder before trying to add a new one.")
        }
        
        // Exceeded
        static var  limitFamilyMemberExceeded: HoundError {
            return HoundError(forName: "FamilyResponseError.limitFamilyMemberExceeded", forDescription: "Your family has exceeded it's family member limit and is unable to have data added or updated. This is likely due to your family's subscription being downgraded or expiring. Please remove existing family members or have the family head upgrade your family's subscription to restore functionality.")
        }
        static var  limitDogExceeded: HoundError {
            return HoundError(forName: "FamilyResponseError.limitDogExceeded", forDescription: "Your family has exceeded it's dog limit and is unable to have data added or updated. This is likely due to your family's subscription being downgraded or expiring. Please remove existing dogs or have the family head upgrade your family's subscription to restore functionality.")
        }
        
        // MARK: Join
        /// Family code was valid but was not linked to any family
        static var  joinFamilyCodeInvalid: HoundError {
            return HoundError(forName: "FamilyResponseError.joinFamilyCodeInvalid", forDescription: "Your family code isn't linked to any family. Please enter a valid code and retry.")
        }
        /// Family code was valid and linked to a family but the family was locked
        static var  joinFamilyLocked: HoundError {
            return HoundError(forName: "FamilyResponseError.joinFamilyLocked", forDescription: "The family you are trying to join is locked, preventing any new family members from joining. Please have an existing family member unlock it and retry.")
        }
        /// User is already in a family and therefore can't join a new one
        static var  joinInFamilyAlready: HoundError {
            return HoundError(forName: "FamilyResponseError.joinInFamilyAlready", forDescription: "You are already in a family. Please leave your existing family before attempting to join a new one. If this issue persists, please contact Hound support.")
        }
        
        // MARK: Leave
        static var  leaveInvalid: HoundError {
            return HoundError(forName: "FamilyResponseError.leaveInvalid", forDescription: "You are unable to leave your current family. This is likely due to you being the family head and your family containing multiple family members. Please remove all existing family members before attempting to leave. If this issue persists, please contact Hound support.")
        }
        static var  leaveSubscriptionActive: HoundError {
            return HoundError(forName: "FamilyResponseError.leaveSubscriptionActive", forDescription: "You are unable to delete your current family due having an active, auto-renewing subscription. Please cancel your subscription before attempting to leave. If this issue persists, please contact Hound support.")
        }
        
        // MARK: Permission
        static var  permissionInvalid: HoundError {
            return HoundError(forName: "FamilyResponseError.permissionInvalid", forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. If this issue persists, please contact Hound support.")
        }
        
    }
    
    enum GeneralResponseError {
        
        static let appVersionOutdatedName = "GeneralResponseError.appVersionOutdated"
        /// The app version that the user is using is out dated
        static var appVersionOutdated: HoundError {
            return HoundError(forName: appVersionOutdatedName, forDescription: "Your version of Hound is outdated. Please update to the latest version to continue.")
        }
        static var appleServerFailed: HoundError {
            return HoundError(forName: "GeneralResponseError.appleServerFailed", forDescription: "Hound was unable to contact Apple's iTunes server and complete your request. Please restart and retry. If this issue persists, please contact Hound support.")
        }
        
        /// GET: != 200...299, e.g. 400, 404, 500
        static var getFailureResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.getFailureResponse", forDescription: "We experienced an issue while retrieving your data Hound's server. Please restart and re-login to Hound if the issue persists.")
        }
        
        /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var getNoResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.getNoResponse", forDescription: "We were unable to reach Hound's server and retrieve your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage.")
        }
        
        /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
        static var postFailureResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.postFailureResponse", forDescription: "Hound's server experienced an issue in saving your new data. Please restart and re-login to Hound if the issue persists.")
        }
        /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var postNoResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.postNoResponse", forDescription: "We were unable to reach Hound's server and save your new data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage.")
        }
        
        /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
        static var putFailureResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.putFailureResponse", forDescription: "Hound's server experienced an issue in updating your data. Please restart and re-login to Hound if the issue persists.")
        }
        /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var putNoResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.putNoResponse", forDescription: "We were unable to reach Hound's server and update your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage.")
        }
        
        /// DELETE:  != 200...299, e.g. 400, 404, 500
        static var deleteFailureResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.deleteFailureResponse", forDescription: "Hound's server experienced an issue in deleting your data. Please restart and re-login to Hound if the issue persists.")
        }
        /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static var deleteNoResponse: HoundError {
            return HoundError(forName: "GeneralResponseError.deleteNoResponse", forDescription: "We were unable to reach Hound's server to delete your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage.")
        }
    }
    
    // MARK: - Class
    
    enum DogError {
        static var dogNameNil: HoundError {
            return HoundError(forName: "DogError.dogNameNil", forDescription: "Your dog's name is invalid, please try a different one.")
        }
        static var dogNameBlank: HoundError {
            return HoundError(forName: "DogError.dogNameBlank", forDescription: "Your dog's name is blank, try typing something in.")
        }
        static var dogNameCharacterLimitExceeded: HoundError {
            return HoundError(forName: "DogError.dogNameCharacterLimitExceeded", forDescription: "Your dog's name is too long, please try a shorter one.")
        }
    }
    
    enum InAppPurchaseError {
        // MARK: Product Request Of Available In-App Purchases
        static var productRequestInProgress: HoundError {
            return HoundError(forName: "InAppPurchaseError.productRequestInProgress", forDescription: "There is a In-App Purchase product request currently in progress. You are unable to initiate another In-App Purchase product request until the first one has finished processing. If the issue persists, please restart and retry.")
        }
        /// The app cannot request App Store about available IAP products for some reason.
        static var productRequestFailed: HoundError {
            return HoundError(forName: "InAppPurchaseError.productRequestFailed", forDescription: "Your In-App Purchase product request has failed. If the issue persists, please restart and retry.")
        }
        /// No In-App Purchase products were returned by the App Store because none was found.
        static var productRequestNotFound: HoundError {
            return HoundError(forName: "InAppPurchaseError.productRequestNotFound", forDescription: "Your In-App Purchase product request did not return any results. If the issue persists, please restart and retry.")
        }
        
        // MARK: User Attempting To Make An In-App Purchase
        /// User can't make any In-App purchase because SKPaymentQueue.canMakePayment() == false
        static var purchaseRestricted: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchaseRestricted", forDescription: "Your device is restricted from accessing the Apple App Store and is unable to make In-App Purchases. Please remove this restriction before attempting to make another In-App Purchase.")
        }
        
        /// User can't make any in-app purchase because they are not the family head
        static var purchasePermission: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchasePermission", forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. If this issue persists, please contact Hound support.")
        }
        
        /// There is a In-App Purchases in progress, so a new one cannot be initiated currentProductPurchase != nil || productPurchaseCompletionHandler != nil
        static var purchaseInProgress: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchaseInProgress", forDescription: "There is an In-App Purchase currently in progress. You are unable to initiate another In-App Purchase until the first one has finished processing. If the issue persists, please restart and retry.")
        }
        
        /// Deferred. Most likely due to pending parent approval from Ask to Buy
        static var purchaseDeferred: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchaseDeferred", forDescription: "Your In-App Purchase is pending an approval from your parent. To complete your purchase, please have your parent approve the request within 24 hours.")
        }
        
        /// The in app purchase failed and was not completed
        static var purchaseFailed: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchaseFailed", forDescription: "Your In-App Purchase has failed. If the issue persists, please restart and retry.")
        }
        
        /// Unknown error
        static var purchaseUnknown: HoundError {
            return HoundError(forName: "InAppPurchaseError.purchaseUnknown", forDescription: "Your In-App Purchase has experienced an unknown error. If the issue persists, please restart and retry.")
        }
        
        // MARK: User Attempting To Restore An In-App Purchase
        
        /// User can't make any in-app purchase restoration because they are not the family head
        static var restorePermission: HoundError {
            return HoundError(forName: "InAppPurchaseError.restorePermission", forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. If this issue persists, please contact Hound support. ")
        }
        
        /// There is a In-App Purchases restoration in progress, so a new one cannot be initiated
        static var restoreInProgress: HoundError {
            return HoundError(forName: "InAppPurchaseError.restoreInProgress", forDescription: "There is an In-App Purchase restoration currently in progress. You are unable to initiate another In-App Purchase restoration until the first one has finished processing. If the issue persists, please restart and retry.")
        }
        
        static var restoreFailed: HoundError {
            return HoundError(forName: "InAppPurchaseError.restoreFailed", forDescription: "Your In-App Purchase restoration has failed. If the issue persists, please restart and retry.")
        }
        
        // MARK: System Is Processing Transaction In The Background
        static var backgroundPurchaseInProgress: HoundError {
            return HoundError(forName: "", forDescription: "There is a transaction currently being processed in the background. This is likely due to a subscription renewal. Please wait a moment for this to finish processing. If the issue persists, please restart and retry.")
        }
    }
    
    enum LogError {
        static var parentDogNotSelected: HoundError {
            return HoundError(forName: "LogError.parentDogNotSelected", forDescription: "Your log needs a corresponding dog, please try selecting at least one!")
        }
        static var logActionBlank: HoundError {
            return HoundError(forName: "LogError.logActionBlank", forDescription: "Your log has no action, please try selecting one!")
        }
        static var logCustomActionNameCharacterLimitExceeded: HoundError {
            return HoundError(forName: "LogError.logCustomActionNameCharacterLimitExceeded", forDescription: "Your log's custom name is too long, please try a shorter one.")
        }
        static var logNoteCharacterLimitExceeded: HoundError {
            return HoundError(forName: "LogError.logNoteCharacterLimitExceeded", forDescription: "Your log's note name is too long, please try a shorter one.")
        }
    }
    
    enum ReminderError {
        static var reminderActionBlank: HoundError {
            return HoundError(forName: "ReminderError.reminderActionBlank", forDescription: "Your reminder has no action, try selecting one!")
        }
        static var reminderCustomActionNameCharacterLimitExceeded: HoundError {
            return HoundError(forName: "ReminderError.reminderCustomActionNameCharacterLimitExceeded", forDescription: "Your reminders's custom name is too long, please try a shorter one.")
        }
    }
    
    enum SignInWithAppleError {
        static var canceled: HoundError {
            return HoundError(forName: "SignInWithAppleError.canceled", forDescription: "The 'Sign In With Apple' page was prematurely canceled. Please retry and follow the prompts.")
        }
        static var notSignedIn: HoundError {
            return HoundError(forName: "SignInWithAppleError.notSignedIn", forDescription: "The 'Sign In With Apple' page failed as you have no Apple ID. Please create an Apple ID with two-factor authentication enabled and retry.")
        }
        static var other: HoundError {
            return HoundError(forName: "SignInWithAppleError.other", forDescription: "The 'Sign In With Apple' page failed. Please make sure you have an Apple ID with two-factor authentication enabled and retry.")
        }
    }
    
    enum UnknownError {
        static var unknown: HoundError {
            return HoundError(forName: "UnknownError.unknown", forDescription: "Hound has experienced an unknown error. Please restart and retry. If this issue persists, please contact Hound support.")
        }
    }
    
    enum WeeklyComponentsError {
        static var weekdayArrayInvalid: HoundError {
            return HoundError(forName: "WeeklyComponentsError.weekdayArrayInvalid", forDescription: "Please select at least one day of the week for your reminder. You can do this by clicking on the S, M, T, W, T, F, or S. A blue letter means that your reminder's alarm will sound that day and grey means it won't.")
        }
    }
    
}
