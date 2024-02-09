//
//  OfflineManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum OfflineManager {
    private static
    
    /*
     IMPLEMENTATION PLAN:
        - What can be done in offline
            - Get dog, reminder, and log (just return local copy)
            - Create dog, reminder, and log (add flag to them that they need to be synced with the server)
            - Update dog, reminder, and log (add flag to them that they need to be synced with the server)
            - Delete dog, reminder, and log (create a queue within offline manager )
        -
            - This class should conform to nscoding so that it can be
     
     - this should allow most of everything to be done in offline mode (dogs, reminders, logs, etc)
     - the only thing we should generally not allow are user/family changes
     - this will invoke a offline manager which should store a queue of objects of different subclasses (OfflineLogRequest, OfflineDogRequest, etc) that store the required information to perform the requests sequentially once connection is re-established
     - there should be some indicator to the user that offline mode has been enabled because no internet connection
     - many get requests should be able to go thru if bad response. so if .success or .no, then let it go through, either using currently stored data or new data and go on that. if its a .fail, then we know its not offline mode and so then we dont let it go through. e.g. allow a user to open the page to edit a log if they receieve no or a success response.
     */
}
