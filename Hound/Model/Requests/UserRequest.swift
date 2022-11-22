//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
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
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        // We don't need to add the userId for a get request as we simply only need the userIdentifier
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
    /**
    completionHandler returns a response data: dictionary of the body and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: UserConfiguration.createBody(addingOntoBody: UserInformation.createBody(addingOntoBody: nil))) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithUserId, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
}

extension UserRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a userId, familyId, and response status. If the query is successful, automatically sets up userConfiguration and userInformation and returns userId and familyId. Otherwise, nil is returned
    */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (String?, String?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return UserRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any], let userId = result[KeyConstant.userId.rawValue] as? String {
                    
                    // set all local configuration equal to whats in the server
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)
                    
                    let familyId: String? = result[KeyConstant.familyId.rawValue] as? String
                    
                    completionHandler(userId, familyId, .successResponse, responseError)
                }
                else {
                    completionHandler(nil, nil, .failureResponse, responseError)
                }
            case .failureResponse:
                completionHandler(nil, nil, .failureResponse, responseError)
            case .noResponse:
                completionHandler(nil, nil, .noResponse, responseError)
            }
        }
    }
    
    /**
     Creates a user's account on the server
    completionHandler returns a possible userId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (String?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return UserRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[KeyConstant.result.rawValue] as? String {
                    completionHandler(userId, responseStatus, responseError)
                }
                else {
                    completionHandler(nil, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, responseError)
            case .noResponse:
                completionHandler(nil, responseStatus, responseError)
            }
        }
    }
    
    /**
     Updates specific piece(s) of userInformation or userConfiguration
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return UserRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus, responseError)
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
        
    }
}
