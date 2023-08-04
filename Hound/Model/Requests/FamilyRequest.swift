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

    static var baseURLWithoutParams: URL { UserRequest.baseURLWithUserId.appendingPathComponent("/family") }
    // UserRequest baseURL with the userId path param appended on
    static var baseURLWithFamilyId: URL { FamilyRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.familyId ?? VisualConstant.TextConstant.unknownHash)") }

    /**
     If query is successful, automatically sets up FamilyInformation and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    // set up family configuration
                    FamilyInformation.setup(fromBody: result)

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
     Sends a request for the user to create their own family.
     If query is successful, automatically invokes PersistenceManager.clearStorageForNewFamily() and sets up UserInformation.familyId and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams,
            forBody: [: ]) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let familyId = responseBody?[KeyConstant.result.rawValue] as? String {
                    // User successfully created a new family
                    PersistenceManager.clearStorageForNewFamily()
                    UserInformation.familyId = familyId
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
     Update specific piece(s) of the family
     If query is successful, automatically invokes PersistenceManager.clearStorageForNewFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        // If the body has a familyCode in it, then the user is trying to join a family, so omit familyId (as we don't have one). Otherwise, user isn't trying to join a family, so add familyId
        let attemptingToJoinFamily = body[KeyConstant.familyCode.rawValue] != nil
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: attemptingToJoinFamily ? baseURLWithoutParams : baseURLWithFamilyId,
            forBody: body) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                if attemptingToJoinFamily {
                    // User successfully joined a new family
                    PersistenceManager.clearStorageForNewFamily()
                }
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }

    /**
     If the user is a familyMember, lets the user leave the family.
     If the user is a familyHead and are the only member, deletes the family.
     If query is successful, automatically invokes PersistenceManager.clearStorageForNewFamily() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithFamilyId,
            forBody: body) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageForNewFamily()
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
