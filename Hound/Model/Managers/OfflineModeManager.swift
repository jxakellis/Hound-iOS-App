//
//  OfflineModeManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum OfflineModeManager {
    
    // MARK: - Properties
    
    /// If true, a getUser request got no response. The user's data is outdated and needs to be fetched from the server
    private static var shouldGetUser: Bool = false
    /// If true, a getFamily request got no response. The user's family data is outdated and needs to be fetched from the server
    private static var shouldGetFamily: Bool = false
    /// If true, the first invocation of sync from startMonitoring requires that the dogManager be synced.
    private static var shouldGetDogManager: Bool = false
    /// Dogs, reminders, or logs that were deleted in offline mode and need their deletion synced with the Hound server
    private static var offlineModeDeletedObjects: [OfflineModeDeletedObject] = []
    
    private static var internetConnectionObserver: NSKeyValueObservation?
    /// If true, OfflineModeManager is currently observing and waiting for the user's device to get internet so that it can start resyncing.
    private static var isWaitingForInternetConnection: Bool = false {
        didSet {
            if isWaitingForInternetConnection == true && internetConnectionObserver == nil {
                // If we are going to be waiting for an internet connection and have nothing to monitor for that, start monitoring
                internetConnectionObserver = NetworkManager.shared.observe(\.isConnected, options: [.new]) { _, change in
                    if let newValue = change.newValue {
                        print("Network connectivity changed. isConnected now \(newValue)")
                        isWaitingForInternetConnection = false
                    }
                }
            }
            
            if isWaitingForInternetConnection == false && internetConnectionObserver != nil {
                // No longer waiting for an internet connection so destroy
                internetConnectionObserver?.invalidate()
                internetConnectionObserver = nil
                // isWaitingForInternetConnection can only be changed by startMonitoring and internetConnectionObserver. If it was set to false and internetConnectionObserver is not nil, then the observer just observed the user getting internet connection again.
                startMonitoring()
            }
        }
    }
    
    /// True if the process of either determining if a sync is needed or actual syncing is in progress. False if there is no active syncing.
    private static var isSyncInProgress: Bool = false
    /// The delay that OfflineModeManger waits before attempting to sync again after receiving not response from the Hound server
    private static var delayBeforeAttemptingToSyncAgain: TimeInterval = 15.0
    
    // MARK: - Sync Queue Management
    
    enum OfflineModeGetNoResponseTypes {
        case userRequestGet
        case familyRequestGet
        case dogManagerGet
    }
    
    static func didGetNoResponse(forType: OfflineModeGetNoResponseTypes) {
        switch forType {
        case .userRequestGet:
            shouldGetUser = true
        case .familyRequestGet:
            shouldGetFamily = true
        case .dogManagerGet:
            shouldGetDogManager = true
        }
    }
    
    /// Invoke this function if a dog, reminder, or log was attempted to be deleted, however it failed due to no response from the Hound server
    static func addDeletedObjectToQueue(forObject: OfflineModeDeletedObject) {
        // Ensure that the queue doesn't already have the deleted object waiting in it.
        guard offlineModeDeletedObjects.contains(where: { object in
            // Cast the objects as the possible different classes. If they are the same class and are equal, then the queue contains that object
            if let object = object as? OfflineModeDeletedDog, let forObject = forObject as? OfflineModeDeletedDog {
                return object == forObject
            }
            else if let object = object as? OfflineModeDeletedReminder, let forObject = forObject as? OfflineModeDeletedReminder {
                return object == forObject
            }
            else if let object = object as? OfflineModeDeletedLog, let forObject = forObject as? OfflineModeDeletedLog {
                return object == forObject
            }
            
            return false
        }) == false else {
            return
        }
        offlineModeDeletedObjects.append(forObject)
        
        offlineModeDeletedObjects.sort { objectOne, objectTwo in
            guard type(of: objectOne) !== type(of: objectTwo) else {
                // Both objectOne and objectTwo are the same type, so the object that was deleted first comes first
                return objectOne.deletedDate <= objectTwo.deletedDate
            }
            
            // objectOne and objectTwo are different types
            
            if objectOne is OfflineModeDeletedDog {
                // objectOne is a dog and objectTwo is not a dog, so objectOne comes first
                return true
            }
            else if objectOne is OfflineModeDeletedReminder {
                if objectTwo is OfflineModeDeletedDog {
                    // objectOne is a reminder and objectTwo is a dog, so objectTwo comes first
                    return false
                }
                
                // objectOne is a reminder and objectTwo must be a log, so objectOne comes first
                return true
            }
            
            // objectOne is a log and objectTwo is a reminder or dog, so objectTwo comes first
            return false
        }
    }
    
    /// Invoke this function if a dog, reminder, or log was successfully deleted with a response from the Hound server
    static func removeDeletedObjectFromQueue(forObject: OfflineModeDeletedObject) {
        offlineModeDeletedObjects.removeAll { object in
            // Cast the objects as the possible different classes. If they are the same class and are equal, then remove the object
            if let object = object as? OfflineModeDeletedDog, let forObject = forObject as? OfflineModeDeletedDog {
                return object == forObject
            }
            else if let object = object as? OfflineModeDeletedReminder, let forObject = forObject as? OfflineModeDeletedReminder {
                return object == forObject
            }
            else if let object = object as? OfflineModeDeletedLog, let forObject = forObject as? OfflineModeDeletedLog {
                return object == forObject
            }
            
            return false
        }
    }
    
    // MARK: - Monitoring and Syncing
    
    /// Invoke this function when there is an indication of lost connectivity to either the internet as a whole or the Hound server. OfflineModeManager will attempt to start syncing its data with the Hound server once connection is re-established.
    static func startMonitoring() {
        // Avoid invoking the code below unless a sync is not in progress
        guard isSyncInProgress == false else {
            // Already syncing
            return
        }
        // TODO Display a message that Hound has entered offline mode and will sync once connectivity is restored
        
        guard isWaitingForInternetConnection == false && NetworkManager.shared.isConnected == true else {
            // OfflineModeManager can't do anything until its connected to the internet. We wait until we get a signal that internet connection is restored
            isWaitingForInternetConnection = true
            return
        }
        
        // The sync begins now that a connection is established
        isSyncInProgress = true
        
        // True if an object is found that needs to be synced with the Hound server
        let isSyncNeeded: Bool = {
            if shouldGetUser == true {
                return true
            }
            
            if shouldGetFamily == true {
                return true
            }
            
            if offlineModeDeletedObjects.isEmpty == false {
                return true
            }
            
            for dog in DogManager.globalDogManager?.dogs ?? [] {
                if dog.offlineModeComponents.needsSyncedWithHoundServer == true {
                    return true
                }
                
                for reminder in dog.dogReminders.reminders where reminder.offlineModeComponents.needsSyncedWithHoundServer == true {
                    return true
                }
            }
            
            return false
        }()
        
        guard isSyncNeeded == true else {
            // If we don't need a sync, exit out of this mode
            isSyncInProgress = false
            return
        }
        
        // There are objects to sync, continue
        
        sync()
    }
    
    /// In order of a heirarchy of priority, begins to perform requests to the Hound server to progressively re-sync the users data with the server. Waits for a single network call to finish before that request's completionHandler invokes sync()
    private static func sync() {
        // TODO Once offline mode is enabled, any request that supports offline mode should automatically be .noResponse until everything is synced
            // E.g. create dog -> no response so save dog offline -> regain internet -> attempt to create reminder under dog before dog is synced -> that request fails because dog only exists locally.
       
        guard shouldGetUser == false else {
            // Set this flag to false before we perform the request. If the request fails again, then the flag will be set to true again.
            shouldGetUser = false
            UserRequest.get(errorAlert: .automaticallyAlertForNone) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    noResponseForSync()
                    return
                }
                
                // Continue to sync more upon successful completion
                self.sync()
            }
            return
        }
        
        guard shouldGetFamily == false else {
            // Set this flag to false before we perform the request. If the request fails again, then the flag will be set to true again.
            shouldGetFamily = false
            FamilyRequest.get(errorAlert: .automaticallyAlertForNone) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    noResponseForSync()
                    return
                }
                
                // Continue to sync more upon successful completion
                self.sync()
            }
            return
        }
        
        guard shouldGetDogManager == false else {
            // Set this flag to false before we perform the request. If the request fails again, then the flag will be set to true again.
            shouldGetDogManager = false
            guard let globalDogManager = DogManager.globalDogManager else {
                // Unable to retrieve a dogManager to use to sync from
                sync()
                return
            }
            
            DogsRequest.get(errorAlert: .automaticallyAlertForNone, forDogManager: globalDogManager) { dogManager, responseStatus, _ in
                guard responseStatus != .noResponse else {
                    noResponseForSync()
                    return
                }
                
                if let dogManager = dogManager {
                    // TODO pass this dogManager back to the user somehow
                }
                
                // Continue to sync more upon successful completion
                self.sync()
            }
            return
        }
        
        
        // Start sync-ing updates according to priority:
        // 1. deleted dogs
        // 2. deleted reminders/logs
        // 3. dogs
        // 4. reminders/logs
        // *** consider moving the removeDeletedObjectFromQueue logic from the Request functions into here. Once we perform a request and its successful, then remove it from the queue. that would allow us to remove it from the queue if success or if failure, but leave if no response.
        
        
        // Handling no/failure responses
        // If we get a no response for something, we just try again later at some point. See above for handling no response in general
        // If we get a failure response for something, we stop trying to sync it. Attempt to perform a get request on that object to resync its current state from the server.
        
        // Keep track of every single server request made by offline manager. We need a system to delay calls to not exceed cloudflare rate limit.
        
        // TODO Allow a user to change their configuration, then add a flag when connection is restored that we need to resync all of their configurations
    }
    
    /// Invoke if a request to the Hound server from sync() received no response. This invoke a delay before the client will restart the syncing process.
    private static func noResponseForSync() {
        // Stop all syncing and wait for a delay until we try again to sync. This should begin again from startMonitoring so it goes through the same network checks to see if the user still has connection.
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeAttemptingToSyncAgain) {
            isSyncInProgress = false
            startMonitoring()
        }
    }
}
