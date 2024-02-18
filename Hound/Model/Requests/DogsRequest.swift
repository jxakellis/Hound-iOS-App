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
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDog: Dog,
        completionHandler: @escaping (Dog?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .failureResponse, nil)
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
            completionHandler(nil, .failureResponse, nil)
            return nil
        }
        
        let body: [String: CompatibleDataTypeForJSON?] = [KeyConstant.dogUUID.rawValue: forDog.dogUUID.uuidString]
        
        return RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: url,
            forBody: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(forType: .dogManagerGet)
                }
                else if let newDogBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    // If we got a dogBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Dog(fromDogBody: newDogBody, dogToOverride: forDog.copy() as? Dog), responseStatus, error)
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
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogManager: DogManager,
        completionHandler: @escaping (DogManager?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .failureResponse, nil)
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
            completionHandler(nil, .failureResponse, nil)
            return nil
        }
        
        // If the query is successful, we want new previousDogManagerSynchronization to be before the query took place. This ensures that any changes that might have occured DURING our query will be synced at a future date.
        let previousDogManagerSynchronization = Date()
        
        return RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: url,
            forBody: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(forType: .dogManagerGet)
                }
                else if let dogBodies = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                    // If we got dogBodies, use them. This can only happen if responseStatus != .noResponse.
                    LocalConfiguration.previousDogManagerSynchronization = previousDogManagerSynchronization
                    
                    completionHandler(DogManager(fromDogBodies: dogBodies, dogManagerToOverride: forDogManager.copy() as? DogManager), responseStatus, error)
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
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDog: Dog,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = forDog.createBody()
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forDog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                }
                
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
                    forDog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
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
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDog: Dog,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = forDog.createBody()
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forDog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                }
                
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
                    forDog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON] = [KeyConstant.dogUUID.rawValue: forDogUUID.uuidString]
        
        return RequestUtils.genericDeleteRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
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
                    // If we got no response, then mark the dog to be deleted later
                    OfflineModeManager.shared.addDeletedObjectToQueue(forObject: OfflineModeDeletedDog(dogUUID: forDogUUID, deletedDate: Date()))
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
