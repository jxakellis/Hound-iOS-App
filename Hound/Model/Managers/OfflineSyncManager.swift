//
//  OfflineSyncManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum OfflineSyncManager {
    
    private static var isCurrentlyMonitoring: Bool = false
    
    /// Invoke this function when there is an indication of lost connectivity to either the internet as a whole or the Hound server. OfflineSyncManager will attempt to start syncing its data with the Hound server once connection is re-established.
    static func startMonitoring() {
        guard isCurrentlyMonitoring == false else {
            // Alreadying monitoring
            return
        }
        
        // Display a message that Hound has entered offline mode and will sync once connectivity is restored
        
        // Once offline mode is enabled, any request that supports offline mode should automatically be .noResponse until everything is synced
        // E.g. create dog -> no response so save dog offline -> regain internet -> attempt to create reminder under dog before dog is synced -> that request fails because dog only exists locally.
        
        // Sit and wait for a connetion to the internet
           
        
        // Once a connection is established, check for objects to sync
            // If no objects to sync, exit offline mode and display a message
            // If at any point the requests below receive a no response when syncing, start monitoring should be automatically invoked again. This should stop all syncing and trigger a delay until we try again to sync.
            
        // If there are objects to sync, continue
        
        // Check to see if we should getUser or getFamily
            // There should be a flag set if any of these requests failed due to offline mode
        
        // Perform a getDogManager request.
            // Any server-side deletes should be propogated, also removing any matches from our OfflineSync deletion queue.
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
        
    }
}
