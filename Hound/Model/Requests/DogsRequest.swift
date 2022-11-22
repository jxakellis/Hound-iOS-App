//
//  DogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsRequest {
    
    static var baseURLWithoutParams: URL { return FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/dogs") }
    
    // MARK: - Private Functions
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        var urlComponents: URLComponents = {
            if let dogId = dogId, let component = URLComponents(url: baseURLWithoutParams.appendingPathComponent("/\(dogId)"), resolvingAgainstBaseURL: false) {
                return component
            }
            else if let component = URLComponents(url: baseURLWithoutParams.appendingPathComponent(""), resolvingAgainstBaseURL: false) {
                return component
            }
            else {
                return URLComponents()
            }
        }()
        // special case where we append the query parameter of all. Its value doesn't matter but it just tells the server that we want the logs and reminders of the dog too.
        
        // if we are querying about a dog, we always want its reminders and logs
        urlComponents.queryItems = [
            URLQueryItem(name: "isRetrievingReminders", value: "true"),
            URLQueryItem(name: "isRetrievingLogs", value: "true")
        ]
        
        if LocalConfiguration.userConfigurationPreviousDogManagerSynchronization != ClassConstant.DateConstant.default1970Date {
            // if we have a userConfigurationPreviousDogManagerSynchronization that isn't equal to 1970 (the default value), then provide it as that means we have a custom value.
            urlComponents.queryItems?.append(
                URLQueryItem(
                    name: "userConfigurationPreviousDogManagerSynchronization",
                    value: LocalConfiguration.userConfigurationPreviousDogManagerSynchronization.ISO8601FormatWithFractionalSeconds()
                ))
        }
        
        guard let URLWithParams = urlComponents.url else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }
        
        // make get request
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
    /**
    completionHandler returns response data: dogId for the created dog and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = dog.createBody()
        
        // make put request, assume body valid as constructed with method
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalUpdate(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dog.dogId)")
        
        let body = dog.createBody()
        
        // make put request, assume body valid as constructed with method
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)")
        
        // make delete request
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
}

extension DogsRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a dog and response status. If the query is successful and the dog isn't deleted, then the dog is returned (the client-side dog is combined with the server-side updated dog). Otherwise, nil is returned.
    */
    @discardableResult static func get(invokeErrorManager: Bool, dog currentDog: Dog, completionHandler: @escaping (Dog?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return DogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: currentDog.dogId) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                // dog JSON {dog1:'foo'}
                if let newDogBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    completionHandler(Dog(forDogBody: newDogBody, overrideDog: currentDog.copy() as? Dog), responseStatus, responseError)
                }
                else {
                    // Don't return nil. This is because we pass through userConfigurationPreviousDogManagerSynchronization. That means a successful result could be completely blank (and fail the above if statement), indicating that the user is fully up to date.
                    completionHandler(currentDog, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, responseError)
            case .noResponse:
                completionHandler(nil, responseStatus, responseError)
            }
        }
    }
    
    /**
    completionHandler returns a dogManager and response status. If the query is successful, then the dogManager is returned (the client-side dog is combined with the server-side updated dog). Otherwise, nil is returned.
    */
    @discardableResult static func get(invokeErrorManager: Bool, dogManager currentDogManager: DogManager, completionHandler: @escaping (DogManager?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        // we want this Date() to be slightly in the past. If we set  LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = Date() after the request is successful then any changes that might have occured DURING our query (e.g. we are querying and at the exact same moment a family member creates a log) will not be saved. Therefore, this is more redundant and makes sure nothing is missed
        let userConfigurationPreviousDogManagerSynchronization = Date()
        
        // Now can get the dogManager
        return DogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: nil) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let newDogBodies = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                    // successful sync, so we can update value
                    LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = userConfigurationPreviousDogManagerSynchronization
                    
                    completionHandler(DogManager(forDogBodies: newDogBodies, overrideDogManager: currentDogManager.copy() as? DogManager), responseStatus, responseError)
                }
                else {
                    // Don't return nil. This is because we pass through userConfigurationPreviousDogManagerSynchronization. That means a successful result could be completely blank (and fail the above if statement), indicating that the user is fully up to date.
                    completionHandler(currentDogManager, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, responseError)
            case .noResponse:
                completionHandler(nil, responseStatus, responseError)
            }
        }
        
    }
    
    /**
    completionHandler returns a possible dogId and the ResponseStatus.
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Int?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return DogsRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDog: dog) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let dogId = responseBody?[KeyConstant.result.rawValue] as? Int {
                    // Successfully saved to server, so save dogIcon locally
                    // remove dogIcon that was stored under placeholderId
                    DogIconManager.removeIcon(forDogId: dog.dogId)
                    
                    // add a localDogIcon under offical dogId for newly created dog
                    if let dogIcon = dog.dogIcon {
                        DogIconManager.addIcon(forDogId: dogId, forDogIcon: dogIcon)
                    }
                    
                    completionHandler(dogId, responseStatus, responseError)
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
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return DogsRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDog: dog) { _, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so update dogIcon locally
                // overwrite the locally stored dogIcon as user could have updated it
                if let dogIcon = dog.dogIcon {
                    DogIconManager.addIcon(forDogId: dog.dogId, forDogIcon: dogIcon)
                }
               
                completionHandler(true, responseStatus, responseError)
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
    
    /**
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return DogsRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId) { _, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so remove the stored dogIcons that have the same dogId as the removed dog
                DogIconManager.removeIcon(forDogId: dogId)
                completionHandler(true, responseStatus, responseError)
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
}
