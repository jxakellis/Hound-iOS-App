//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

public enum ErrorConstant {

    static func serverError(errorCode: String, requestId: Int, responseId: Int) -> HoundServerError? {
        // MARK: - GENERAL
        if errorCode == "ER_GENERAL_APP_VERSION_OUTDATED" {
            return GeneralResponseError.appVersionOutdated(requestId: requestId, responseId: responseId)
        }
        // ER_GENERAL_ENVIRONMENT_INVALID
        // ER_GENERAL_PARSE_FORM_DATA_FAILED
        // ER_GENERAL_PARSE_JSON_FAILED
        // ER_GENERAL_POOL_CONNECTION_FAILED
        // ER_GENERAL_POOL_TRANSACTION_FAILED
        else if errorCode == "ER_GENERAL_APPLE_SERVER_FAILED" {
            return GeneralResponseError.appleServerFailed(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_RATE_LIMIT_EXCEEDED" {
            return GeneralResponseError.rateLimitExceeded(requestId: requestId, responseId: responseId)
        }
        // MARK: - VALUE
        // ER_VALUE_MISSING
        // ER_VALUE_INVALID
        // MARK: - PERMISSION
        // MARK: NO
        else if errorCode == "ER_PERMISSION_NO_USER" {
            return PermissionResponseError.noUser(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_FAMILY" {
            return PermissionResponseError.noFamily(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_DOG" {
            return PermissionResponseError.noDog(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_LOG" {
            return PermissionResponseError.noLog(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_REMINDER" {
            return PermissionResponseError.noReminder(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_TRIGGER" {
            return PermissionResponseError.noTrigger(requestId: requestId, responseId: responseId)
        }
        // MARK: INVALID
        else if errorCode == "ER_PERMISSION_INVALID_FAMILY" {
            return PermissionResponseError.invalidFamily(requestId: requestId, responseId: responseId)
        }
        // MARK: - FAMILY
        // MARK: LIMIT
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW" {
            return FamilyResponseError.limitFamilyMemberTooLow(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_DOG_TOO_LOW" {
            return FamilyResponseError.limitDogTooLow(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_LOG_TOO_LOW" {
            return FamilyResponseError.limitLogTooLow(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_REMINDER_TOO_LOW" {
            return FamilyResponseError.limitReminderTooLow(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_TRIGGER_TOO_LOW" {
            return FamilyResponseError.limitTriggerTooLow(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED" {
            return FamilyResponseError.limitFamilyMemberExceeded(requestId: requestId, responseId: responseId)
        }
        // MARK: DELETED
        else if errorCode == "ER_FAMILY_DELETED_DOG" {
            return FamilyResponseError.deletedDog(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_LOG" {
            return FamilyResponseError.deletedLog(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_REMINDER" {
            return FamilyResponseError.deletedReminder(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_TRIGGER" {
            return FamilyResponseError.deletedTrigger(requestId: requestId, responseId: responseId)
        }
        // MARK: JOIN
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_CODE_INVALID" {
            return FamilyResponseError.joinFamilyCodeInvalid(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_LOCKED" {
            return FamilyResponseError.joinFamilyLocked(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_JOIN_IN_FAMILY_ALREADY" {
            return FamilyResponseError.joinInFamilyAlready(requestId: requestId, responseId: responseId)
        }
        // MARK: Leave
        else if errorCode == "ER_FAMILY_LEAVE_SUBSCRIPTION_ACTIVE" {
            return FamilyResponseError.leaveSubscriptionActive(requestId: requestId, responseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LEAVE_STILL_FAMILY_MEMBERS" {
            return FamilyResponseError.leaveStillFamilyMembers(requestId: requestId, responseId: responseId)
        }
        // MARK: - NONE
        return nil
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
        static func noInternetConnection() -> HoundError {
            HoundError(
                name: "GeneralRequestError.noInternetConnection",
                description: "Your device doesn't appear to be connected to the internet. \(Constant.Error.verifyInternetConnection)",
                onTap: nil)
        }
    }

    enum FamilyRequestError {
        static func familyCodeBlank() -> HoundError {
            HoundError(
                name: "FamilyRequestError.familyCodeBlank",
                description: "Your family code is blank! \(Constant.Error.enterValidCode)",
                onTap: nil)
        }
        static func familyCodeInvalid() -> HoundError {
            HoundError(
                name: "FamilyRequestError.familyCodeInvalid",
                description: "Your family code's format is invalid! \(Constant.Error.enterValidCode)",
                onTap: nil)
        }
    }

    // MARK: - API Response

    enum GeneralResponseError {
        /// The app version that the user is using is out dated
        static func appVersionOutdated(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.appVersionOutdated",
                description: "It looks like you're using an outdated version of Hound. Update now for the latest features and improvements!",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func appleServerFailed(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.appleServerFailed",
                description: "Hound was unable to contact Apple's iTunes server and complete your request. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func rateLimitExceeded(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.rateLimitExceeded",
                description: "You have exceeded Hound's rate limit. Please wait 10 seconds before retrying your request.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        
        /// GET: != 200...299, e.g. 400, 404, 500
        static func getFailureResponse(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.getFailureResponse",
                description: "We experienced an issue while retrieving your data Hound's server. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func getNoResponse() -> HoundError {
            HoundError(
                name: "GeneralResponseError.getNoResponse",
                description: "We were unable to reach Hound's server and retrieve your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                onTap: nil)
        }

        /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
        static func postFailureResponse(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.postFailureResponse",
                description: "Hound's server experienced an issue in saving your new data. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func postNoResponse() -> HoundError {
            HoundError(
                name: "GeneralResponseError.postNoResponse",
                description: "We were unable to reach Hound's server and save your new data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                onTap: nil)
        }

        /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
        static func putFailureResponse(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.putFailureResponse",
                description: "Hound's server experienced an issue in updating your data. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func putNoResponse() -> HoundError {
            HoundError(
                name: "GeneralResponseError.putNoResponse",
                description: "We were unable to reach Hound's server and update your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                onTap: nil)
        }

        /// DELETE:  != 200...299, e.g. 400, 404, 500
        static func deleteFailureResponse(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "GeneralResponseError.deleteFailureResponse",
                description: "Hound's server experienced an issue in deleting your data. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func deleteNoResponse() -> HoundError {
            HoundError(
                name: "GeneralResponseError.deleteNoResponse",
                description: "We were unable to reach Hound's server to delete your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                onTap: nil)
        }
    }

    enum PermissionResponseError {
        static func noUser(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noUser",
                description: "You are attempting to access a user that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func noFamily(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noFamily",
                description: "You are attempting to access a family that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func noDog(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noDog",
                description: "You are attempting to access a dog that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func noLog(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noLog",
                description: "You are attempting to access a log that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func noReminder(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noReminder",
                description: "You are attempting to access a reminder that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func noTrigger(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.noTrigger",
                description: "You are attempting to access a trigger that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        static func invalidFamily(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "PermissionResponseError.invalidFamily",
                description: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
    }

    enum FamilyResponseError {
        // MARK: Limit
        // Too Low
        static func  limitFamilyMemberTooLow(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.limitFamilyMemberTooLow",
                // DON'T MAKE THIS MESSAGE DYNAMIC. User is attempting to join a family but failed, therefore familyActiveSubscription will be inaccurate as user currently has no family.
                description: "This family can only have a limited number of family members! Please have the family head upgrade their subscription before attempting to join this family.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func  limitDogTooLow(requestId: Int, responseId: Int) -> HoundServerError {
            // spell out the number of dogs the family can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let dogLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfDogs as NSNumber) ?? "negative one"

            return HoundServerError(
                name: "FamilyResponseError.limitDogTooLow",
                description: "Your family can only have \(dogLimitSpelledOut) dog\(Constant.Class.Dog.maximumNumberOfDogs == 1 ? "" : "s")! Please remove an existing dog before trying to add a new one.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func  limitLogTooLow(requestId: Int, responseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let logLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfLogs as NSNumber) ?? "negative one"

            return HoundServerError(
                name: "FamilyResponseError.limitLogTooLow",
                description: "Your dog can only have \(logLimitSpelledOut) log\(Constant.Class.Dog.maximumNumberOfLogs == 1 ? "" : "s")! Please remove an existing log before trying to add a new one.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func  limitReminderTooLow(requestId: Int, responseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let reminderLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfReminders as NSNumber) ?? "negative one"

            return HoundServerError(
                name: "FamilyResponseError.limitReminderTooLow",
                description: "Your dog can only have \(reminderLimitSpelledOut) reminder\(Constant.Class.Dog.maximumNumberOfReminders == 1 ? "" : "s")! Please remove an existing reminder before trying to add a new one.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        static func  limitTriggerTooLow(requestId: Int, responseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let triggerLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfTriggers as NSNumber) ?? "negative one"

            return HoundServerError(
                name: "FamilyResponseError.limitTriggerTooLow",
                description: "Your dog can only have \(triggerLimitSpelledOut) trigger\(Constant.Class.Dog.maximumNumberOfTriggers == 1 ? "" : "s")! Please remove an existing trigger before trying to add a new one.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        // Exceeded
        static func limitFamilyMemberExceeded(requestId: Int, responseId: Int) -> HoundServerError {
            // find out how many family members can be in the family
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let allowedNumberOfFamilyMembers = FamilyInformation.familyActiveSubscription.numberOfFamilyMembers
            let familyMemberLimitSpelledOut = formatter.string(from: allowedNumberOfFamilyMembers as NSNumber) ?? "\(allowedNumberOfFamilyMembers)"

            let numberOfExceededFamilyMembers = FamilyInformation.familyMembers.count - allowedNumberOfFamilyMembers
            let numberOfExceededFamilyMembersSpelledOut = formatter.string(
                from: numberOfExceededFamilyMembers as NSNumber) ?? "\(numberOfExceededFamilyMembers)"

            // user could be family head or they could be a family member
            var description = "Your family is exceeding it's \(familyMemberLimitSpelledOut) family member limit and is unable to have data added or updated. "

            description.append("To restore functionality, please ")

            if UserInformation.isUserFamilyHead == false {
                description.append("have the family head ")
            }

            if numberOfExceededFamilyMembers >= 1 {
                description.append("remove \(numberOfExceededFamilyMembersSpelledOut) family member\(numberOfExceededFamilyMembers == 1 ? "" : "s") or ")
            }
            
            description.append("upgrade your subscription.")
            
            return HoundServerError(
                name: "FamilyResponseError.limitFamilyMemberExceeded",
                description: description,
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        // MARK: Deleted
        /// The dog that the user is trying to access has been marked as deleted
        static func deletedDog(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.deletedDog",
                description: "The dog you are attempting to access has been deleted! Hold on while we refresh your data...",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// The log that the user is trying to access has been marked as deleted
        static func deletedLog(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.deletedLog",
                description: "The log you are attempting to access has been deleted! Hold on while we refresh your data...",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// The reminder that the user is trying to access has been marked as deleted
        static func deletedReminder(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.deletedReminder",
                description: "The reminder you are attempting to access has been deleted! Hold on while we refresh your data...",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// The trigger that the user is trying to access has been marked as deleted
        static func deletedTrigger(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.deletedTrigger",
                description: "The trigger you are attempting to access has been deleted! Hold on while we refresh your data...",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        // MARK: Join
        /// Family code was valid but was not linked to any family
        static func joinFamilyCodeInvalid(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.joinFamilyCodeInvalid",
                description: "The family code you input isn't linked to any family. \(Constant.Error.enterValidCode)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// Family code was valid and linked to a family but the family was locked
        static func  joinFamilyLocked(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.joinFamilyLocked",
                description: "The family you are trying to join is locked, preventing any new family members from joining. Please have an existing family member unlock it and retry.",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
        /// User is already in a family and therefore can't join a new one
        static func  joinInFamilyAlready(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.joinInFamilyAlready",
                description: "You are already in a family. Please leave your existing family before attempting to join a new one. \(Constant.Error.contactHoundSupport)",
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }

        // MARK: Leave
        static func  leaveSubscriptionActive(requestId: Int, responseId: Int) -> HoundServerError {
            HoundServerError(
                name: "FamilyResponseError.leaveSubscriptionActive",
                description: "You are unable to delete your current family due having an active, auto-renewing subscription. To continue, tap this banner to cancel your subscription. \(Constant.Error.contactHoundSupport)",
                onTap: {
                    // If the user taps the banner, that means they want to cancel their Hound subscription. The only way to cancel a subscription is with Apple's manage subscriptions page.
                    InAppPurchaseManager.showManageSubscriptions()
                },
                requestId: requestId,
                responseId: responseId
            )
        }
        static func  leaveStillFamilyMembers(requestId: Int, responseId: Int) -> HoundServerError {
            // if user is family head, then add piece about removing other family members. this error shouldn't happen if the user isn't the family head, and therefore we direct them more toward hound support
            var description = "You are unable to leave your current family. "
            if UserInformation.isUserFamilyHead {
                description.append("Please remove all existing family members before attempting to leave. ")
            }
            description.append("\(Constant.Error.contactHoundSupport)")

            return HoundServerError(
                name: "FamilyResponseError.leaveStillFamilyMembers",
                description: description,
                onTap: nil,
                requestId: requestId,
                responseId: responseId
            )
        }
    }

    // MARK: - Class

    enum InAppPurchaseError {
        // MARK: Product Request Of Available In-App Purchases
        static func productRequestInProgress() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.productRequestInProgress",
                description: "There is a in-app purchase product request currently in progress. You are unable to initiate another in-app purchase product request until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }
        /// The app cannot request App Store about available IAP products for some reason.
        static func productRequestFailed() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.productRequestFailed",
                description: "Your in-app purchase product request has failed. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }
        /// No in-app purchase products were returned by the App Store because none was found.
        static func productRequestNotFound() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.productRequestNotFound",
                description: "Your in-app purchase product request did not return any results. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        // MARK: User Attempting To Make An In-App Purchase
        /// User can't make any in-app purchase because SKPaymentQueue.canMakePayment() == false
        static func purchaseRestricted() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchaseRestricted",
                description: "Your device is restricted from accessing the Apple App Store and is unable to make in-app purchases. Please remove this restriction before attempting to make another in-app purchase.",
                onTap: nil)
        }

        /// User can't make any in-app purchase because they are not the family head
        static func purchasePermission() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchasePermission",
                description: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                onTap: nil)
        }

        /// There is a in-app purchases in progress, so a new one cannot be initiated currentProductPurchase != nil || productPurchaseCompletionHandler != nil
        static func purchaseInProgress() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchaseInProgress",
                description: "There is an in-app purchase currently in progress. You are unable to initiate another in-app purchase until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        /// Deferred. Most likely due to pending parent approval from Ask to Buy
        static func purchaseDeferred() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchaseDeferred",
                description: "Your in-app purchase is pending an approval from your parent. To complete your purchase, please have your parent approve the request within 24 hours.",
                onTap: nil)
        }

        /// The in app purchase failed and was not completed
        static func purchaseFailed() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchaseFailed",
                description: "Your in-app purchase has failed. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        /// Unknown error
        static func purchaseUnknown() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.purchaseUnknown",
                description: "Your in-app purchase has experienced an unknown error. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        // MARK: User Attempting To Restore An In-App Purchase

        /// User can't make any in-app purchase restoration because they are not the family head
        static func restorePermission() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.restorePermission",
                description: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                onTap: nil)
        }

        /// There is a in-app purchases restoration in progress, so a new one cannot be initiated
        static func restoreInProgress() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.restoreInProgress",
                description: "There is an in-app purchase restoration currently in progress. You are unable to initiate another in-app purchase restoration until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        static func restoreFailed() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.restoreFailed",
                description: "Your in-app purchase restoration has failed. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }

        // MARK: System Is Processing Transaction In The Background
        static func backgroundPurchaseInProgress() -> HoundError {
            HoundError(
                name: "InAppPurchaseError.backgroundPurchaseInProgress",
                description: "There is a transaction currently being processed in the background. This is likely due to a subscription renewal. Please wait a moment for this to finish processing. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }
    }

    enum DogError {
        static let dogNameMissing = "Choose a name for your dog"
    }

    enum LogError {
        static let parentDogMissing = "Choose at least one dog"
        static let logActionMissing = "Choose an action"
        static let logStartDateMissing = "Choose a start date"
        static let logStartTooLate = "Start date can't be after end date"
        static let logEndTooEarly = "End date can't be before start date"
    }

    enum ReminderError {
        static let reminderActionMissing = "Choose an action for your reminder"
        static let reminderTimeZoneMissing = "Choose a time zone for your reminder"
    }
    
    enum TriggerError {
        static let reminderResultMissing = "Choose a reminder to create"
        static let logReactionMissing = "Choose at least one log type"
        static let conditionsInvalid = "Choose at least one condition"
        static let timeDelayInvalid = "Choose a valid time delay"
        static let fixedTimeTypeAmountInvalid = "Choose a valid amount of fixed time"
    }

    enum SignInWithAppleError {
        static func canceled() -> HoundError {
            HoundError(
                name: "SignInWithAppleError.canceled",
                description: "The 'Sign In With Apple' page was prematurely canceled. \(Constant.Error.restartHoundAndRetry)",
                onTap: nil)
        }
        static func notSignedIn() -> HoundError {
            HoundError(
                name: "SignInWithAppleError.notSignedIn",
                description: "The 'Sign In With Apple' page failed as you have no Apple ID. Please create an Apple ID with two-factor authentication enabled and retry.",
                onTap: nil)
        }
        static func other() -> HoundError {
            HoundError(
                name: "SignInWithAppleError.other",
                description: "The 'Sign In With Apple' page failed. Please make sure you have an Apple ID with two-factor authentication enabled and retry.",
                onTap: nil)
        }
    }

    enum UnknownError {
        static func unknown() -> HoundError {
            HoundError(
                name: "UnknownError.unknown",
                description: "Hound has experienced an unknown error. \(Constant.Error.contactHoundSupport)",
                onTap: nil)
        }
    }

    enum WeeklyComponentsError {
        static let weekdaysInvalid = "Choose at least one day of week"
    }

    enum ExportError {
        static func shareHound() -> HoundError {
            HoundError(
                name: "ExportError.shareHound",
                description: "Unable to present menu to share Hound",
                onTap: nil)
        }

        static func shareFamilyCode() -> HoundError {
            HoundError(
                name: "ExportError.shareHound",
                description: "Unable to present menu to share family code",
                onTap: nil)
        }

        static func exportLogs() -> HoundError {
            HoundError(
                name: "ExportError.shareHound",
                description: "Unable to present menu to export logs",
                onTap: nil)
        }
    }
}
