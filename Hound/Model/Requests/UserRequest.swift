//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import KeychainSwift

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest {
    
    static var baseURLWithoutParams: URL { return RequestUtils.baseURLWithoutParams.appendingPathComponent("/user")}
    // UserRequest baseURL with the userId URL param appended on
    static var baseURLWithUserId: URL { return UserRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.userId ?? VisualConstant.TextConstant.unknownHash)") }
    
    /**
     If query is successful, automatically sets up UserInformation and UserConfiguration and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)
                    
                    completionHandler(UserInformation.userId != nil, .successResponse)
                }
                else {
                    completionHandler(false, .failureResponse)
                }
            case .failureResponse:
                completionHandler(false, .failureResponse)
            case .noResponse:
                completionHandler(false, .noResponse)
            }
        }
    }
    
    /**
     Creates a user's account on the server
     If query is successful, automatically sets up UserInformation.userId and returns (true, .successResponse, requestId, responseId)
     If query isn't successful, returns (false, .failureResponse, requestId, responseId) or (false, .noResponse, requestId, responseId)
     */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, Int, Int) -> Void) -> Progress? {
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams,
            forBody: UserConfiguration.createBody(addingOntoBody: UserInformation.createBody(addingOntoBody: nil))) { responseBody, responseStatus in
            let requestId: Int = responseBody?[KeyConstant.requestId.rawValue] as? Int ?? -1
            let responseId: Int = responseBody?[KeyConstant.responseId.rawValue] as? Int ?? -1
                
            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[KeyConstant.result.rawValue] as? String {
                    UserInformation.userId = userId
                    completionHandler(true, responseStatus, requestId, responseId)
                }
                else {
                    completionHandler(false, responseStatus, requestId, responseId)
                }
            case .failureResponse:
                completionHandler(false, responseStatus, requestId, responseId)
            case .noResponse:
                completionHandler(false, responseStatus, requestId, responseId)
            }
        }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithUserId,
            forBody: body) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     If query is successful, automatically sets UserInformation.userIdentifier, userId, familyId = nil and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithUserId,
            forBody: body) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                let keychain = KeychainSwift()
                
                // Clear userIdentifier out of storage so user is forced to login page again
                UserInformation.userIdentifier = nil
                keychain.delete(KeyConstant.userIdentifier.rawValue)
                UserDefaults.standard.removeObject(forKey: KeyConstant.userIdentifier.rawValue)
                
                UserInformation.userId = nil
                keychain.delete(KeyConstant.userId.rawValue)
                UserDefaults.standard.removeObject(forKey: KeyConstant.userId.rawValue)
                
                UserInformation.familyId = nil
                keychain.delete(KeyConstant.familyId.rawValue)
                UserDefaults.standard.removeObject(forKey: KeyConstant.familyId.rawValue)
                
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
