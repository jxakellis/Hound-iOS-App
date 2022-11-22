//
//  SubscriptionRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/23/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum SubscriptionRequest {
    
    static var baseURLWithoutParams: URL { return FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/subscriptions") }
    
    // MARK: - Private Functions
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        // Get the receipt if it's available. If the receipt isn't available, we sent through an invalid base64EncodedString, then the server will return us an error
        var base64EncodedReceiptString: String? {
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                // Experienced an error, so no base64 encoded string
                return nil
            }
            
            return receiptData.base64EncodedString(options: [])
        }
        
        let body: [String: Any] = [KeyConstant.appStoreReceiptURL.rawValue: base64EncodedReceiptString ?? VisualConstant.TextConstant.unknownText]
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
}

extension SubscriptionRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a bool and response status. If the query is successful, automatically sets up familyInformation and returns true. Otherwise, false is returned.
    */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return SubscriptionRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                    
                    FamilyInformation.clearAllFamilySubscriptions()
                    for subscription in result {
                        FamilyInformation.addFamilySubscription(forSubscription: Subscription(fromBody: subscription))
                    }
                    
                    completionHandler(true, responseStatus, responseError)
                }
                else {
                    completionHandler(false, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
    
    /**
     Sends a request for the user to create a subscription
     Hound uses the provided base64 encoded appStoreReceiptURL to retrieving all transactions for the user, parsing through them and updating its records
    completionHandler returns a Bool  and the ResponseStatus, indicating whether or not the transaction was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return SubscriptionRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    let familyActiveSubscription = Subscription(fromBody: result)
                    FamilyInformation.addFamilySubscription(forSubscription: familyActiveSubscription)
                    
                    // purchaseDate
                    completionHandler(true, responseStatus, responseError)
                }
                else {
                    completionHandler(false, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
}
