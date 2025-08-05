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
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dog: Dog,
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
                    name: Constant.Key.previousDogManagerSynchronization.rawValue,
                    value: previousDogManagerSynchronization.ISO8601FormatWithFractionalSeconds()
                ))
        }
        
        guard let url = components.url else {
            completionHandler(nil, .failureResponse, nil)
            return nil
        }
        
        let body: JSONRequestBody = [Constant.Key.dogUUID.rawValue: .string(dog.dogUUID.uuidString)]
        
        return RequestUtils.genericGetRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: url,
            body: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(type: .dogManagerGet)
                }
                else if let newDogBody = responseBody?[Constant.Key.result.rawValue] as? [String: Any] {
                    // If we got a dogBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Dog(fromBody: newDogBody, dogToOverride: dog.copy() as? Dog), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(dog, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically combines client-side and server-side dogManagers and returns (dogManager, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogManager: DogManager,
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
                    name: Constant.Key.previousDogManagerSynchronization.rawValue,
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
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: url,
            body: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(type: .dogManagerGet)
                }
                else if let dogBodies = responseBody?[Constant.Key.result.rawValue] as? [[String: Any]] {
                    // If we got dogBodies, use them. This can only happen if responseStatus != .noResponse.
                    LocalConfiguration.previousDogManagerSynchronization = previousDogManagerSynchronization
                    
                    completionHandler(DogManager(fromDogBodies: dogBodies, dogManagerToOverride: dogManager.copy() as? DogManager), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(dogManager, responseStatus, error)
        }
        
    }
    
    /**
     If query is successful, automatically assigns dogId to the dog and manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dog: Dog,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = dog.createBody()
        
        return RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    dog.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                if let dogIcon = dog.dogIcon {
                    DogIconManager.addIcon(dogUUID: dog.dogUUID, dogIcon: dogIcon)
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be updated later
                    dog.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                }
                else if let dogId = responseBody?[Constant.Key.result.rawValue] as? Int {
                    // If we got a dogId, use it. This can only happen if responseStatus != .noResponse.
                    dog.dogId = dogId
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dog: Dog,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = dog.createBody()
        
        return RequestUtils.genericPutRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    dog.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                if let dogIcon = dog.dogIcon {
                    DogIconManager.addIcon(dogUUID: dog.dogUUID, dogIcon: dogIcon)
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be updated later
                    dog.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = [Constant.Key.dogUUID.rawValue: .string(dogUUID.uuidString)]
        
        return RequestUtils.genericDeleteRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                DogIconManager.removeIcon(dogUUID: dogUUID)
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the dog to be deleted later
                    OfflineModeManager.shared.addDeletedObjectToQueue(object: OfflineModeDeletedDog(dogUUID: dogUUID, deletedDate: Date()))
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
