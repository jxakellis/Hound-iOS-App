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
    
    static var baseURLWithoutParams: URL { return UserRequest.baseURLWithUserId.appendingPathComponent("/family") }
    // UserRequest baseURL with the userId path param appended on
    static var baseURLWithFamilyId: URL { return FamilyRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.familyId ?? Hash.defaultSHA256Hash)") }
    
    // MARK: - Private Functions
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: [ : ]) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // the user is trying to join a family with the family code, so omit familyId (as we don't have one)
        if body[KeyConstant.familyCode.rawValue] != nil {
            return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        // user isn't trying to join a family, so add familyId
        else {
            return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalDelete(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension FamilyRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a bool and response status. If the query is successful, automatically sets up familyInformation and returns true. Otherwise, false is returned.
    */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return FamilyRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
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
    completionHandler returns a possible familyId and the ResponseStatus.
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (String?, ResponseStatus) -> Void) -> Progress? {
        return FamilyRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // check for familyId
                if let familyId = responseBody?[KeyConstant.result.rawValue] as? String {
                    completionHandler(familyId, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
    Update specific piece(s) of the family
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return FamilyRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
    If the user is a familyMember, lets the user leave the family. If the user is a familyHead and are the only member, deletes the family. If they are a familyHead and there are other familyMembers, the request fails.
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return FamilyRequest.internalDelete(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
}
