//
//  OfflineManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum OfflineManager {
    /*
     IMPLEMENTATION PLAN:
        - 
            - Put in todo stubs as this will change logic, certain requests should be handled differently
                - e.g. getting a log to open update log page, go through w/o error and use local copy
                - e.g. creating reminder, add flag to sync later and go throgub w/o error
                - e.g. trying to refresh by pulling down on the table view, throw an error that says they are offline currently
                - this requires a careful distinction between a non-nil return result and the response status
                    - there could be a returned object (e.g. a dog) but a no response status.
                    - The link between no return object and a no/failed response status is no longer true/valid
        - Node server should add uuids for dogs, reminders, and logs
            - make it accept both ids and uuids for get, create, update, and delete. Take prio for uuids over ids.
        - server sync at the beginning should proceed through
            - this means the device should store certain pieces of user configuration, etc.
            - if the user doesnt have an account or family or similar, then of course force them to the login pages
            - otherwise, show a pop-up that asks if they want to start hound in offline mode
                - e.g. "do you want to use hound in offline mode? Your change will be synced once you come back online"
        - offline manager
            - needs to be invoked a couple ways
                - when a no response is receieved from a api request, make it start monitoring
                - when the flag for a dog, reminder, or log is set true, make it start monitoring
            - it should sit and wait to detect an internet connection to the hound server
                - it should first sit and wait for a connection to the internet in general, this is easy to monitor
                - once there is a internet connection, it should attempt to find items that need synced
                    - if there are no objects to sync, stop monitoring
                    - dogs that need synced come before logs and reminders that need synced
                    - a get dog manager call should be made to the hound server. additionally, we might also want to do a user request to the server first as that call could've been skipped when the app launched and perms could have updated.
                        - if we receive data that is updated, we should probably override our "needs synced" stuff. This will account for things like deletions.
                        - Consider if there is an update to a dog/reminder/log from the server, that may override our "needs to be synced" data. Potentially use time stamps to determine priority. Additionally, if we do override a dog/log/reminder that was marked as needed to be synced, the flag to need to be synced should be set to false
                    - once we get updated information from the server and a connection is reestablished. start syncing
                            - we can find created/updated dogs/logs/reminders easily by looking for the flag, but we need to also go through the offline manager queue to find objects that are deleted (as their instances with the flag no longer exist).
                            - Deletions should probably occur first, so we don't try to update anything that they decided to delete
                            - once deletions are complete, build that array of dogs/logs/reminders that need to be synced and iterate through. A timestamp of when they were created/updated would probably be helpful so we can mimick the order the user made them in
                    - if we receieve a failure response from attempting to sync with the server, save that message for later
                        - once we have stopped syncing (either due to a lost connection, completing all dogs/logs/reminders to sync, or failing all dogs/logs/reminders), display a message that x amount of objects failed to sync
                    - if we receive a no response at any point, put offline manager back into idle mode. it should check maybe once a minute for internet and then see if it can hit the hound server.
     */
}
