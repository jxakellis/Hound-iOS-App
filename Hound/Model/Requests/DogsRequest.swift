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
    @discardableResult static func get(invokeErrorManager: Bool, dog currentDog: Dog, completionHandler: @escaping (Dog?, ResponseStatus, HoundError?) -> Void) -> Progress? {

        guard var components = URLComponents(url: baseURL.appendingPathComponent("/\(currentDog.dogId)"), resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }

        // if we are querying about a dog, we always want its reminders and logs
        components.queryItems = [
            URLQueryItem(name: "isRetrievingReminders", value: "true"),
            URLQueryItem(name: "isRetrievingLogs", value: "true")
        ]

        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization {
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

        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                // dog JSON {dog1:'foo'}
                if let newDogBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    completionHandler(Dog(forDogBody: newDogBody, overrideDog: currentDog.copy() as? Dog), responseStatus, error)
                }
                else {
                    // Don't return nil. This is because we pass through previousDogManagerSynchronization. That means a successful result could be completely blank (and fail the above if statement), indicating that the user is fully up to date.
                    completionHandler(currentDog, responseStatus, error)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, error)
            case .noResponse:
                completionHandler(nil, responseStatus, error)
            }
        }
    }

    /**
     If query is successful, automatically combines client-side and server-side dogManagers and returns (dogManager, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
    */
    @discardableResult static func get(invokeErrorManager: Bool, dogManager currentDogManager: DogManager, completionHandler: @escaping (DogManager?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .noResponse, nil)
            return nil
        }

        // if we are querying about a dog, we always want its reminders and logs
        components.queryItems = [
            URLQueryItem(name: "isRetrievingReminders", value: "true"),
            URLQueryItem(name: "isRetrievingLogs", value: "true")
        ]

        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization {
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
            forURL: url) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                if let newDogBodies = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                    // successful sync, so we can update value
                    LocalConfiguration.previousDogManagerSynchronization = previousDogManagerSynchronization

                    completionHandler(DogManager(forDogBodies: newDogBodies, overrideDogManager: currentDogManager.copy() as? DogManager), responseStatus, error)
                }
                else {
                    // Don't return nil. This is because we pass through previousDogManagerSynchronization. That means a successful result could be completely blank (and fail the above if statement), indicating that the user is fully up to date.
                    completionHandler(currentDogManager, responseStatus, error)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, error)
            case .noResponse:
                completionHandler(nil, responseStatus, error)
            }
        }

    }

    /**
     If query is successful, automatically assigns dogId to the dog and manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = dog.createBody()

        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
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

                    // assign new dogId to the dog
                    dog.dogId = dogId

                    completionHandler(true, responseStatus, error)
                }
                else {
                    completionHandler(false, responseStatus, error)
                }
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }

    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func update(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let url = baseURL.appendingPathComponent("/\(dog.dogId)")
        let body = dog.createBody()

        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url,
            forBody: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so update dogIcon locally
                // overwrite the locally stored dogIcon as user could have updated it
                if let dogIcon = dog.dogIcon {
                    DogIconManager.addIcon(forDogId: dog.dogId, forDogIcon: dogIcon)
                }

                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }

    /**
     If query is successful, automatically manages local storage of dogIcon and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let url: URL = baseURL.appendingPathComponent("/\(dogId)")

        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so remove the stored dogIcons that have the same dogId as the removed dog
                DogIconManager.removeIcon(forDogId: dogId)
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }
}
