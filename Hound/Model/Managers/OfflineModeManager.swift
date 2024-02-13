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
    
    // MARK: - Sync Queue Management
    
    enum OfflineModeGetNoResponseTypes {
        case userRequestGet
        case familyRequestGet
    }
    
    static func didGetNoResponse(forType: OfflineModeGetNoResponseTypes) {
        switch forType {
        case .userRequestGet:
            shouldGetUser = true
        case .familyRequestGet:
            shouldGetFamily = true
        }
    }
    
    static func didDeleteObject(forOfflineModeDeletedObject: OfflineModeDeletedObject) {
        offlineModeDeletedObjects.append(forOfflineModeDeletedObject)
        
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
    
    private static func sync() {
        // TODO Once offline mode is enabled, any request that supports offline mode should automatically be .noResponse until everything is synced
            // E.g. create dog -> no response so save dog offline -> regain internet -> attempt to create reminder under dog before dog is synced -> that request fails because dog only exists locally.
       
        if shouldGetUser {
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
        
        if shouldGetFamily {
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
        
        // Perform a getDogManager request.
            // Any server-side deletes should be propogated, also removing any matches from our OfflineMode deletion queue.
            // Server-side updates to objects should override our local updates as long as they happened later in time than our local updates (compare dog/reminder/logLastModified to offlineComponents.initialCreationDate)
            // If a server-side update overrides out local update, then mark the reminder as not needing synced anymore
        
        // Start sync-ing updates according to priority:
        // 1. deleted dogs
        // 2. deleted reminders/logs
        // 3. dogs
        // 4. reminders/logs
        
        
        // Handling no/failure responses
        // If we get a no response for something, we just try again later at some point. See above for handling no response in general
        // If we get a failure response for something, we stop trying to sync it. Attempt to perform a get request on that object to resync its current state from the server.
        
        // Keep track of every single server request made by offline manager. We need a system to delay calls to not exceed cloudflare rate limit.
        
        // TODO Allow a user to change their configuration, then add a flag when connection is restored that we need to resync all of their configurations
    }
    
    /// A request to the Hound server from sync() received no response. This invoke a delay before the client will restart the syncing process.
    private static func noResponseForSync() {
        isSyncInProgress = false
        startMonitoring()
        
        // TODO If at any point the requests below receive a no response when syncing, start monitoring should be automatically invoked again. This should stop all syncing and trigger a delay until we try again to sync.
    }
}
