//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest {
    
    static var baseURLWithoutParams: URL { return InternalRequestUtils.baseURLWithoutParams.appendingPathComponent("/user")}
    // UserRequest baseURL with the userId URL param appended on
    static var baseURLWithUserId: URL { return UserRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.userId ?? Hash.defaultSHA256Hash)") }
    
    // MARK: - Private Functions
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        // We don't need to add the userId for a get request as we simply only need the userIdentifier
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
    completionHandler returns a response data: dictionary of the body and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: UserConfiguration.createBody(addingOntoBody: UserInformation.createBody(addingOntoBody: nil))) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithUserId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension UserRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a userId, familyId, and response status. If the query is successful, automatically sets up userConfiguration and userInformation and returns userId and familyId. Otherwise, nil is returned
    */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (String?, String?, ResponseStatus) -> Void) -> Progress? {
        return UserRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any], let userId = result[KeyConstant.userId.rawValue] as? String {
                    
                    // set all local configuration equal to whats in the server
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)
                    
                    let familyId: String? = result[KeyConstant.familyId.rawValue] as? String
                    
                    completionHandler(userId, familyId, .successResponse)
                }
                else {
                    completionHandler(nil, nil, .failureResponse)
                }
            case .failureResponse:
                completionHandler(nil, nil, .failureResponse)
            case .noResponse:
                completionHandler(nil, nil, .noResponse)
            }
        }
    }
    
    /**
     Creates a user's account on the server
    completionHandler returns a possible userId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (String?, ResponseStatus) -> Void) -> Progress? {
        return UserRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[KeyConstant.result.rawValue] as? String {
                    completionHandler(userId, responseStatus)
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
     Updates specific piece(s) of userInformation or userConfiguration
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return UserRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
