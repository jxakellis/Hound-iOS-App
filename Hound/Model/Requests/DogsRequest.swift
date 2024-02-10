//
//  DogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsRequest {
    static var baseURL: URL { FamilyRequest.baseURL.appendingPathComponent("/dogs") }
    
    /**
     If query is successful, automatically combines client-side and server-side dogs and returns (dog, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDog: Dog, completionHandler: @escaping (Dog?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }
        
        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization {
            components.queryItems = components.queryItems ?? []
            // if we have a previousDogManagerSynchronization that isn't equal to 1970 (the default value), then provide it as that means we have a custom value.
            components.queryItems?.append(
                URLQueryItem(
                    name: KeyConstant.previousDogManagerSynchronization.rawValue,
                    value: previousDogManagerSynchronization.ISO8601FormatWithFractionalSeconds()
                ))
        }
        
        guard let url = components.url else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }
        
        let body: [String: PrimativeTypeProtocol?] = [KeyConstant.dogId.rawValue: forDog.dogId]
        
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url,
            forBody: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then do nothing. This is because a get request will be made by the offline manager, so that anything updated while offline will be synced.
                }
                else if let newDogBody = responseBody?[KeyConstant.result.rawValue] as? [String: PrimativeTypeProtocol] {
                    // If we got a dogBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Dog(forDogBody: newDogBody, overrideDog: forDog.copy() as? Dog), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(forDog, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically combines client-side and server-side dogManagers and returns (dogManager, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDogManager: DogManager, completionHandler: @escaping (DogManager?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }
        
        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization {
            components.queryItems = components.queryItems ?? []
            // if we have a previousDogManagerSynchronization that isn't equal to 1970 (the default value), then provide it as that means we have a custom value.
            components.queryItems?.append(
                URLQueryItem(
                    name: KeyConstant.previousDogManagerSynchronization.rawValue,
                    value: previousDogManagerSynchronization.ISO8601FormatWithFractionalSeconds()
                ))
        }
        
        guard let url = components.url else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }
        
        // If the query is successful, we want new previousDogManagerSynchronization to be before the query took place. This ensures that any changes that might have occured DURING our query will be synced at a future date.
        let previousDogManagerSynchronization = Date()
        
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url,
            forBody: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then do nothing. This is because a get request will be made by the offline manager, so that anything updated while offline will be synced.
                }
                else if let newDogBodies = responseBody?[KeyConstant.result.rawValue] as? [[String: PrimativeTypeProtocol]] {
                    // If we got dogBodies, use them. This can only happen if responseStatus != .noResponse.
                    LocalConfiguration.previousDogManagerSynchronization = previousDogManagerSynchronization
                    
                    completionHandler(DogManager(forDogBodies: newDogBodies, overrideDogManager: forDogManager.copy() as? DogManager), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(forDogManager, responseStatus, error)
        }
        
    }
    
    /**
     If query is successful, automatically assigns dogId to the dog and manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDog: Dog, completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = forDog.createBody()
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                if let dogIcon = forDog.dogIcon {
                    DogIconManager.addIcon(forDogUUID: forDog.dogUUID, forDogIcon: dogIcon)
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be updated later
                    forDog.offlineSyncComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
                else if let dogId = responseBody?[KeyConstant.result.rawValue] as? Int {
                    // If we got a dogId, use it. This can only happen if responseStatus != .noResponse.
                    forDog.dogId = dogId
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDog: Dog, completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = forDog.createBody()
        
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                if let dogIcon = forDog.dogIcon {
                    DogIconManager.addIcon(forDogUUID: forDog.dogUUID, forDogIcon: dogIcon)
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be updated later
                    forDog.offlineSyncComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogUUID: UUID, completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body: [String: PrimativeTypeProtocol] = [KeyConstant.dogUUID.rawValue: forDogUUID]
        
        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                DogIconManager.removeIcon(forDogUUID: forDogUUID)
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be updated later
                    // TODO add dog to queue to be deleted
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
