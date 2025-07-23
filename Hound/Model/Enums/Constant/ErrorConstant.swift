//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

public enum ErrorConstant {

    static func serverError(forErrorCode errorCode: String, forRequestId requestId: Int, forResponseId responseId: Int) -> HoundServerError? {
        // MARK: - GENERAL
        if errorCode == "ER_GENERAL_APP_VERSION_OUTDATED" {
            return GeneralResponseError.appVersionOutdated(forRequestId: requestId, forResponseId: responseId)
        }
        // ER_GENERAL_ENVIRONMENT_INVALID
        // ER_GENERAL_PARSE_FORM_DATA_FAILED
        // ER_GENERAL_PARSE_JSON_FAILED
        // ER_GENERAL_POOL_CONNECTION_FAILED
        // ER_GENERAL_POOL_TRANSACTION_FAILED
        else if errorCode == "ER_GENERAL_APPLE_SERVER_FAILED" {
            return GeneralResponseError.appleServerFailed(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_RATE_LIMIT_EXCEEDED" {
            return GeneralResponseError.rateLimitExceeded(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: - VALUE
        // ER_VALUE_MISSING
        // ER_VALUE_INVALID
        // MARK: - PERMISSION
        // MARK: NO
        else if errorCode == "ER_PERMISSION_NO_USER" {
            return PermissionResponseError.noUser(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_FAMILY" {
            return PermissionResponseError.noFamily(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_DOG" {
            return PermissionResponseError.noDog(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_LOG" {
            return PermissionResponseError.noLog(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_REMINDER" {
            return PermissionResponseError.noReminder(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_PERMISSION_NO_TRIGGER" {
            return PermissionResponseError.noTrigger(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: INVALID
        else if errorCode == "ER_PERMISSION_INVALID_FAMILY" {
            return PermissionResponseError.invalidFamily(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: - FAMILY
        // MARK: LIMIT
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW" {
            return FamilyResponseError.limitFamilyMemberTooLow(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_DOG_TOO_LOW" {
            return FamilyResponseError.limitDogTooLow(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_LOG_TOO_LOW" {
            return FamilyResponseError.limitLogTooLow(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_REMINDER_TOO_LOW" {
            return FamilyResponseError.limitReminderTooLow(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_TRIGGER_TOO_LOW" {
            return FamilyResponseError.limitTriggerTooLow(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED" {
            return FamilyResponseError.limitFamilyMemberExceeded(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: DELETED
        else if errorCode == "ER_FAMILY_DELETED_DOG" {
            return FamilyResponseError.deletedDog(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_LOG" {
            return FamilyResponseError.deletedLog(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_REMINDER" {
            return FamilyResponseError.deletedReminder(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_DELETED_TRIGGER" {
            return FamilyResponseError.deletedTrigger(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: JOIN
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_CODE_INVALID" {
            return FamilyResponseError.joinFamilyCodeInvalid(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_JOIN_FAMILY_LOCKED" {
            return FamilyResponseError.joinFamilyLocked(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_JOIN_IN_FAMILY_ALREADY" {
            return FamilyResponseError.joinInFamilyAlready(forRequestId: requestId, forResponseId: responseId)
        }
        // MARK: Leave
        else if errorCode == "ER_FAMILY_LEAVE_SUBSCRIPTION_ACTIVE" {
            return FamilyResponseError.leaveSubscriptionActive(forRequestId: requestId, forResponseId: responseId)
        }
        else if errorCode == "ER_FAMILY_LEAVE_STILL_FAMILY_MEMBERS" {
            return FamilyResponseError.leaveStillFamilyMembers(forRequestId: requestId, forResponseId: responseId)
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
                forName: "GeneralRequestError.noInternetConnection",
                forDescription: "Your device doesn't appear to be connected to the internet. \(Constant.Error.verifyInternetConnection)",
                forOnTap: nil)
        }
    }

    enum FamilyRequestError {
        static func familyCodeBlank() -> HoundError {
            HoundError(
                forName: "FamilyRequestError.familyCodeBlank",
                forDescription: "Your family code is blank! \(Constant.Error.enterValidCode)",
                forOnTap: nil)
        }
        static func familyCodeInvalid() -> HoundError {
            HoundError(
                forName: "FamilyRequestError.familyCodeInvalid",
                forDescription: "Your family code's format is invalid! \(Constant.Error.enterValidCode)",
                forOnTap: nil)
        }
    }

    // MARK: - API Response

    enum GeneralResponseError {
        /// The app version that the user is using is out dated
        static func appVersionOutdated(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.appVersionOutdated",
                forDescription: "It looks like you're using an outdated version of Hound. Update now for the latest features and improvements!",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func appleServerFailed(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.appleServerFailed",
                forDescription: "Hound was unable to contact Apple's iTunes server and complete your request. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func rateLimitExceeded(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.rateLimitExceeded",
                forDescription: "You have exceeded Hound's rate limit. Please wait 10 seconds before retrying your request.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        
        /// GET: != 200...299, e.g. 400, 404, 500
        static func getFailureResponse(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.getFailureResponse",
                forDescription: "We experienced an issue while retrieving your data Hound's server. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func getNoResponse() -> HoundError {
            HoundError(
                forName: "GeneralResponseError.getNoResponse",
                forDescription: "We were unable to reach Hound's server and retrieve your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                forOnTap: nil)
        }

        /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
        static func postFailureResponse(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.postFailureResponse",
                forDescription: "Hound's server experienced an issue in saving your new data. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func postNoResponse() -> HoundError {
            HoundError(
                forName: "GeneralResponseError.postNoResponse",
                forDescription: "We were unable to reach Hound's server and save your new data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                forOnTap: nil)
        }

        /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
        static func putFailureResponse(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.putFailureResponse",
                forDescription: "Hound's server experienced an issue in updating your data. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func putNoResponse() -> HoundError {
            HoundError(
                forName: "GeneralResponseError.putNoResponse",
                forDescription: "We were unable to reach Hound's server and update your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                forOnTap: nil)
        }

        /// DELETE:  != 200...299, e.g. 400, 404, 500
        static func deleteFailureResponse(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "GeneralResponseError.deleteFailureResponse",
                forDescription: "Hound's server experienced an issue in deleting your data. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
        static func deleteNoResponse() -> HoundError {
            HoundError(
                forName: "GeneralResponseError.deleteNoResponse",
                forDescription: "We were unable to reach Hound's server to delete your data. \(Constant.Error.verifyInternetConnection) \(Constant.Error.potentialHoundServerOutage)",
                forOnTap: nil)
        }
    }

    enum PermissionResponseError {
        static func noUser(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noUser",
                forDescription: "You are attempting to access a user that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func noFamily(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noFamily",
                forDescription: "You are attempting to access a family that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func noDog(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noDog",
                forDescription: "You are attempting to access a dog that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func noLog(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noLog",
                forDescription: "You are attempting to access a log that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func noReminder(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noReminder",
                forDescription: "You are attempting to access a reminder that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func noTrigger(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.noTrigger",
                forDescription: "You are attempting to access a trigger that doesn't exist or you don't have permission to. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        static func invalidFamily(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "PermissionResponseError.invalidFamily",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
    }

    enum FamilyResponseError {
        // MARK: Limit
        // Too Low
        static func  limitFamilyMemberTooLow(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.limitFamilyMemberTooLow",
                // DON'T MAKE THIS MESSAGE DYNAMIC. User is attempting to join a family but failed, therefore familyActiveSubscription will be inaccurate as user currently has no family.
                forDescription: "This family can only have a limited number of family members! Please have the family head upgrade their subscription before attempting to join this family.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func  limitDogTooLow(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            // spell out the number of dogs the family can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let dogLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfDogs as NSNumber) ?? "negative one"

            return HoundServerError(
                forName: "FamilyResponseError.limitDogTooLow",
                forDescription: "Your family can only have \(dogLimitSpelledOut) dog\(Constant.Class.Dog.maximumNumberOfDogs == 1 ? "" : "s")! Please remove an existing dog before trying to add a new one.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func  limitLogTooLow(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let logLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfLogs as NSNumber) ?? "negative one"

            return HoundServerError(
                forName: "FamilyResponseError.limitLogTooLow",
                forDescription: "Your dog can only have \(logLimitSpelledOut) log\(Constant.Class.Dog.maximumNumberOfLogs == 1 ? "" : "s")! Please remove an existing log before trying to add a new one.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func  limitReminderTooLow(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let reminderLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfReminders as NSNumber) ?? "negative one"

            return HoundServerError(
                forName: "FamilyResponseError.limitReminderTooLow",
                forDescription: "Your dog can only have \(reminderLimitSpelledOut) reminder\(Constant.Class.Dog.maximumNumberOfReminders == 1 ? "" : "s")! Please remove an existing reminder before trying to add a new one.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func  limitTriggerTooLow(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            // spell out the number of logs a dog can have
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let triggerLimitSpelledOut = formatter.string(from: Constant.Class.Dog.maximumNumberOfTriggers as NSNumber) ?? "negative one"

            return HoundServerError(
                forName: "FamilyResponseError.limitTriggerTooLow",
                forDescription: "Your dog can only have \(triggerLimitSpelledOut) trigger\(Constant.Class.Dog.maximumNumberOfTriggers == 1 ? "" : "s")! Please remove an existing trigger before trying to add a new one.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        // Exceeded
        static func limitFamilyMemberExceeded(forRequestId: Int, forResponseId: Int) -> HoundServerError {
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
                forName: "FamilyResponseError.limitFamilyMemberExceeded",
                forDescription: description,
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        // MARK: Deleted
        /// The dog that the user is trying to access has been marked as deleted
        static func deletedDog(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.deletedDog",
                forDescription: "The dog you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// The log that the user is trying to access has been marked as deleted
        static func deletedLog(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.deletedLog",
                forDescription: "The log you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// The reminder that the user is trying to access has been marked as deleted
        static func deletedReminder(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.deletedReminder",
                forDescription: "The reminder you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// The trigger that the user is trying to access has been marked as deleted
        static func deletedTrigger(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.deletedTrigger",
                forDescription: "The trigger you are attempting to access has been deleted! Hold on while we refresh your data...",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        // MARK: Join
        /// Family code was valid but was not linked to any family
        static func joinFamilyCodeInvalid(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.joinFamilyCodeInvalid",
                forDescription: "The family code you input isn't linked to any family. \(Constant.Error.enterValidCode)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// Family code was valid and linked to a family but the family was locked
        static func  joinFamilyLocked(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.joinFamilyLocked",
                forDescription: "The family you are trying to join is locked, preventing any new family members from joining. Please have an existing family member unlock it and retry.",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        /// User is already in a family and therefore can't join a new one
        static func  joinInFamilyAlready(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.joinInFamilyAlready",
                forDescription: "You are already in a family. Please leave your existing family before attempting to join a new one. \(Constant.Error.contactHoundSupport)",
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }

        // MARK: Leave
        static func  leaveSubscriptionActive(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            HoundServerError(
                forName: "FamilyResponseError.leaveSubscriptionActive",
                forDescription: "You are unable to delete your current family due having an active, auto-renewing subscription. To continue, tap this banner to cancel your subscription. \(Constant.Error.contactHoundSupport)",
                forOnTap: {
                    // If the user taps the banner, that means they want to cancel their Hound subscription. The only way to cancel a subscription is with Apple's manage subscriptions page.
                    InAppPurchaseManager.showManageSubscriptions()
                },
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
        static func  leaveStillFamilyMembers(forRequestId: Int, forResponseId: Int) -> HoundServerError {
            // if user is family head, then add piece about removing other family members. this error shouldn't happen if the user isn't the family head, and therefore we direct them more toward hound support
            var description = "You are unable to leave your current family. "
            if UserInformation.isUserFamilyHead {
                description.append("Please remove all existing family members before attempting to leave. ")
            }
            description.append("\(Constant.Error.contactHoundSupport)")

            return HoundServerError(
                forName: "FamilyResponseError.leaveStillFamilyMembers",
                forDescription: description,
                forOnTap: nil,
                forRequestId: forRequestId,
                forResponseId: forResponseId
            )
        }
    }

    // MARK: - Class

    enum InAppPurchaseError {
        // MARK: Product Request Of Available In-App Purchases
        static func productRequestInProgress() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.productRequestInProgress",
                forDescription: "There is a in-app purchase product request currently in progress. You are unable to initiate another in-app purchase product request until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// The app cannot request App Store about available IAP products for some reason.
        static func productRequestFailed() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.productRequestFailed",
                forDescription: "Your in-app purchase product request has failed. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }
        /// No in-app purchase products were returned by the App Store because none was found.
        static func productRequestNotFound() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.productRequestNotFound",
                forDescription: "Your in-app purchase product request did not return any results. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        // MARK: User Attempting To Make An In-App Purchase
        /// User can't make any in-app purchase because SKPaymentQueue.canMakePayment() == false
        static func purchaseRestricted() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchaseRestricted",
                forDescription: "Your device is restricted from accessing the Apple App Store and is unable to make in-app purchases. Please remove this restriction before attempting to make another in-app purchase.",
                forOnTap: nil)
        }

        /// User can't make any in-app purchase because they are not the family head
        static func purchasePermission() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchasePermission",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                forOnTap: nil)
        }

        /// There is a in-app purchases in progress, so a new one cannot be initiated currentProductPurchase != nil || productPurchaseCompletionHandler != nil
        static func purchaseInProgress() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchaseInProgress",
                forDescription: "There is an in-app purchase currently in progress. You are unable to initiate another in-app purchase until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        /// Deferred. Most likely due to pending parent approval from Ask to Buy
        static func purchaseDeferred() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchaseDeferred",
                forDescription: "Your in-app purchase is pending an approval from your parent. To complete your purchase, please have your parent approve the request within 24 hours.",
                forOnTap: nil)
        }

        /// The in app purchase failed and was not completed
        static func purchaseFailed() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchaseFailed",
                forDescription: "Your in-app purchase has failed. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        /// Unknown error
        static func purchaseUnknown() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.purchaseUnknown",
                forDescription: "Your in-app purchase has experienced an unknown error. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        // MARK: User Attempting To Restore An In-App Purchase

        /// User can't make any in-app purchase restoration because they are not the family head
        static func restorePermission() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.restorePermission",
                forDescription: "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. \(Constant.Error.contactHoundSupport)",
                forOnTap: nil)
        }

        /// There is a in-app purchases restoration in progress, so a new one cannot be initiated
        static func restoreInProgress() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.restoreInProgress",
                forDescription: "There is an in-app purchase restoration currently in progress. You are unable to initiate another in-app purchase restoration until the first one has finished processing. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        static func restoreFailed() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.restoreFailed",
                forDescription: "Your in-app purchase restoration has failed. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }

        // MARK: System Is Processing Transaction In The Background
        static func backgroundPurchaseInProgress() -> HoundError {
            HoundError(
                forName: "InAppPurchaseError.backgroundPurchaseInProgress",
                forDescription: "There is a transaction currently being processed in the background. This is likely due to a subscription renewal. Please wait a moment for this to finish processing. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
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
                forName: "SignInWithAppleError.canceled",
                forDescription: "The 'Sign In With Apple' page was prematurely canceled. \(Constant.Error.restartHoundAndRetry)",
                forOnTap: nil)
        }
        static func notSignedIn() -> HoundError {
            HoundError(
                forName: "SignInWithAppleError.notSignedIn",
                forDescription: "The 'Sign In With Apple' page failed as you have no Apple ID. Please create an Apple ID with two-factor authentication enabled and retry.",
                forOnTap: nil)
        }
        static func other() -> HoundError {
            HoundError(
                forName: "SignInWithAppleError.other",
                forDescription: "The 'Sign In With Apple' page failed. Please make sure you have an Apple ID with two-factor authentication enabled and retry.",
                forOnTap: nil)
        }
    }

    enum UnknownError {
        static func unknown() -> HoundError {
            HoundError(
                forName: "UnknownError.unknown",
                forDescription: "Hound has experienced an unknown error. \(Constant.Error.contactHoundSupport)",
                forOnTap: nil)
        }
    }

    enum WeeklyComponentsError {
        static let weekdaysInvalid = "Choose at least one day of week"
    }

    enum ExportError {
        static func shareHound() -> HoundError {
            HoundError(
                forName: "ExportError.shareHound",
                forDescription: "Unable to present menu to share Hound",
                forOnTap: nil)
        }

        static func shareFamilyCode() -> HoundError {
            HoundError(
                forName: "ExportError.shareHound",
                forDescription: "Unable to present menu to share family code",
                forOnTap: nil)
        }

        static func exportLogs() -> HoundError {
            HoundError(
                forName: "ExportError.shareHound",
                forDescription: "Unable to present menu to export logs",
                forOnTap: nil)
        }
    }
}
