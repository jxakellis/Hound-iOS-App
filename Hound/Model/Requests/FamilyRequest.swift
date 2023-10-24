//
//  FamilyRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum FamilyRequest {
    
    static var baseURL: URL { UserRequest.baseURL.appendingPathComponent("/family") }

    /**
     If query is successful, automatically sets up FamilyInformation and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    // set up family configuration
                    FamilyInformation.setup(fromBody: result)

                    completionHandler(true, responseStatus, error)
                }
                else {
                    completionHandler(false, responseStatus, error)
                }
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }

    /**
     Sends a request for the user to create their own family.
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: [: ]) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToRejoinFamily()
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }

    /**
     Update specific piece(s) of the family
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let attemptingToJoinFamily = body[KeyConstant.familyCode.rawValue] != nil
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if attemptingToJoinFamily {
                    // User successfully joined a new family
                    PersistenceManager.clearStorageToRejoinFamily()
                }
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }

    /**
     If the user is a familyMember, lets the user leave the family.
     If the user is a familyHead and are the only member, deletes the family.
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToRejoinFamily()
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }
}
