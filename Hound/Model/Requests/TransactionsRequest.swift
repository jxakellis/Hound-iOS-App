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

    static var baseURLWithoutParams: URL { FamilyRequest.baseURL.appendingPathComponent("/transactions") }

    /**
     If query is successful, automatically manages FamilyInformation.familySubscriptions and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
    */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {

        RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURLWithoutParams,
            forBody: [:]) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [JSONResponseBody] {

                    FamilyInformation.clearAllFamilySubscriptions()
                    for subscription in result {
                        FamilyInformation.addFamilySubscription(forSubscription: Subscription(fromBody: subscription))
                    }

                    completionHandler(.successResponse, error)
                }
                else {
                    completionHandler(.failureResponse, error)
                }
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }

    /**
     Sends a request with the user's base64 encoded appStoreRecieptURL for the user to create a subscription.
     If query is successful, automatically manages FamilyInformation.familySubscriptions and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
    */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // Get the receipt if it's available. If the receipt isn't available, we sent through an invalid base64EncodedString, then the server will return us an error
        let base64EncodedReceiptString: String? = {
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                // Experienced an error, so no base64 encoded string
                return nil
            }

            return receiptData.base64EncodedString(options: [])
        }()

        guard let base64EncodedReceiptString = base64EncodedReceiptString else {
            completionHandler(.failureResponse, nil)
            return nil
        }

        let body: JSONRequestBody = [KeyConstant.appStoreReceiptURL.rawValue: .string(base64EncodedReceiptString)]

        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURLWithoutParams,
            forBody: body) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? JSONResponseBody {
                    let familyActiveSubscription = Subscription(fromBody: result)
                    FamilyInformation.addFamilySubscription(forSubscription: familyActiveSubscription)

                    completionHandler(.successResponse, error)
                }
                else {
                    completionHandler(.failureResponse, error)
                }
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }
}
