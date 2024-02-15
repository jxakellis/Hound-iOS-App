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
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        return RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    OfflineModeManager.shared.didGetNoResponse(forType: .familyRequestGet)
                }
                else if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any?] {
                    FamilyInformation.setup(fromBody: result)
                }
                
                completionHandler(responseStatus, error)
        }
    }

    /**
     Sends a request for the user to create their own family.
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: [:]) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToRejoinFamily()
                completionHandler(responseStatus, error)
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }

    /**
     Update specific piece(s) of the family
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forBody: [String: CompatibleDataTypeForJSON?],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let attemptingToJoinFamily = forBody[KeyConstant.familyCode.rawValue] != nil
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: forBody) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if attemptingToJoinFamily {
                    // User successfully joined a new family
                    PersistenceManager.clearStorageToRejoinFamily()
                }
                completionHandler(responseStatus, error)
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }

    /**
     If the user is a familyMember, lets the user leave the family.
     If the user is a familyHead and are the only member, deletes the family.
     If query is successful, automatically invokes PersistenceManager.clearStorageToRejoinFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forBody: [String: CompatibleDataTypeForJSON?] = [:],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericDeleteRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: forBody) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToRejoinFamily()
                completionHandler(responseStatus, error)
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }
}
