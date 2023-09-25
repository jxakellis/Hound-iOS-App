//
//  TransactionsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/23/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum TransactionsRequest {

    static var baseURLWithoutParams: URL { FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/transactions") }

    /**
     If query is successful, automatically manages FamilyInformation.familySubscriptions and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
    */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {

        RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {

                    FamilyInformation.clearAllFamilySubscriptions()
                    for subscription in result {
                        FamilyInformation.addFamilySubscription(forSubscription: Subscription(fromBody: subscription))
                    }

                    completionHandler(true, responseStatus)
                }
                else {
                    completionHandler(false, responseStatus)
                }
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }

    /**
     Sends a request with the user's base64 encoded appStoreRecieptURL for the user to create a subscription.
     If query is successful, automatically manages FamilyInformation.familySubscriptions and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
    */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        // Get the receipt if it's available. If the receipt isn't available, we sent through an invalid base64EncodedString, then the server will return us an error
        let base64EncodedReceiptString: String? = {
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                // Experienced an error, so no base64 encoded string
                return nil
            }

            return receiptData.base64EncodedString(options: [])
        }()

        guard let base64EncodedReceiptString = base64EncodedReceiptString else {
            completionHandler(false, .noResponse)
            return nil
        }

        let body: [String: Any] = [KeyConstant.appStoreReceiptURL.rawValue: base64EncodedReceiptString]

        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams,
            forBody: body) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    let familyActiveSubscription = Subscription(fromBody: result)
                    FamilyInformation.addFamilySubscription(forSubscription: familyActiveSubscription)

                    completionHandler(true, responseStatus)
                }
                else {
                    completionHandler(false, responseStatus)
                }
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
