# Hound TODOs

## 🚀 Now

- LOG FAVORITING
    - Mimic feature from DogNote
    - Have a heart in the bottom right of each log cell that can be tapped to favorite log
    - if log is liked by any person, then this whole element has a rounded background added to it (similar to how we display log note/log unit). in this whole background highlight, there is the heart on the RHS (either selected or not), then on the LHS is the initials (in little bubbles/circle) of the people who liked it
    - add ability to filter logs by favorites
    
- GOOGLE SIGN-IN
    - Add “Sign in with Google” alongside Apple ID.
    
- NEW LOG FIELDS
    - Poop stool quality
    - logCreated
    - logCreatedBy (RENAME userId to this)
    - logLastModifiedBy (update upon modification)

- DIFFERENT LOG SORTING METHODS 
    - start date asc/desc
    - end date asc/desc
    - modified date asc/desc

- SERVER SHOULD SEND LATEST VERSION
    - only do it when the app first opens (maybe tie into get globaltypes call)
    - store the latest app version
    - if we open dog manager and detect latest version is diff, have banner saying new version available
    
- PREPARE FUTURE VERSIONS FOR SCHEAM CHANGES IN API RESPONS
    - instead of being { message: ""} or { result: "" }, make it more flexible
    - right now we cause the api response to be tightly coupled and not allow passage of extra data
    - e.g. { message: "", result: { log/dog/etc: {}, otherProperty, .... } }

---

## 🎯 Future

- REFERRAL PROGRAM
    - “Give a Month, Get a Month”: users share a code; when a friend signs up and completes 30 days, both receive a free month. See how Monarch Money does it  
    - Build referral page that users can get a code to share with other users
    - They can also track the progress of their rewards
    - Only get reward if user actually buys subscription
    
- LOG ANALYTICS PAGE (like DogLog)
    - e.g. for the past 14 days for feed, you've had this many logs for each days
    - further, you could aggregate this data then bin it by hour, so over the past 14 days youve had x logs between 6-7am, x logs between 7-8am, etc.

- MULTIPLE TIMES OF DAY FOR SINGLE REMINDERS
    - e.g. a reminder could be for MWF, then a user instead of a single time of day 7:00AM they could make as many times as they want

- WEBSOCKETS
    - Use web sockets to update logs in real-time across devices

- ABOUT PAGE
    - Brief description of me and how hound came to be
    - Picture or two
    
- 24 HOUR TIME/CLOCK SETTING

- DYNAMIC ERROR MESSAGES
    - if an error cannot be matched to one defined in Constant.Error / ErrorConstant, then create a custom one. This should pull all available info from the error returned by the server.

- API CALLS RETURN UPDATED/CREATED OBJECT
    - instead of returning success or the id of the created item, the api call should return the full object
    - will help in detection of data saving faults along with tricky scenarios where server may save part of object 
    - e.g. take this kinda stupid hypothetical. updateLog is called with a log. it has new logLikeUserIds that haven't been synced (it was in offline mode), so offline mode manager knows the log needs to update with some new info, sending the log to the server. however, in the process, it detects that one of the new/removed userIds is invalid for some reason. thus everything succeeds but maybe only some of the userIds are added/saved.
    - or maybe the server may mutate certain data, we want the user to have the accurate representation

- CALENDAR VIEW
    - Visualize logs on a calendar grid in addition to the daily scroll.
    
- EMAIL SERVICE
    - whenever a user submits feedback about the app, send me an email
    - later we can do actual email that go to users about stuff but thats a whole thing

- MULTIPLE FAMILIES SIMULTANOUESLY
    - you should be able to invite users (e.g. dog walker or sitter) to your family temporarily and possible limit permissions or visibility
    - need a way to manage multiple families at once
        - create page for multiple navigation.
        - if you open the app and you have multiple families, then you can select which family to view
        - in settings page, nexxt to delete/leave family, would be "create another family" and "join another family"
        - permissions would need to be revamped. lock a user's subscption to a single family, but still allow them to navigate to diff families
    - revamp family invitations
        - add inviting by: username, email, and invitation links

- ADDITIONAL DOG FIELDS
    - There should be static 1:1 fields on a dog itself
        - Date of birth  
        - Sex  
        - Microchip #  
        - License #  
        - Rabies vaccine #  
        - Insurance provider & #  
        - Notes  
    - there should also be dynamic fields
        - weight
        - temperature
        - etc.
        - you could view statistics on these fields over time, see how your dog is envolving. tie into "Analytics on Dogs"

- CUSTOM ALARM UI
    - Replace default alerts with a branded, Hound-styled view
    - Also, if there are a lot of pending reminders, offer a view that allows for bulk actions (e.g. See all, snooze all, dismiss all)
    
- LIVE ACTIVITIES (similar to Pup-To-Date)
    - Add live activities for tracking walks or other activities in real-time
    - Show on lock screen and notification center
      - Tap to stop and save duration as a log.

- NOTIFICATION ACTIONS
    - Rich actions for reminders  
    - In the iOS notification, dynamically offer “Log Now,” “Snooze,” or “Dismiss,” matching in-app options.

- SERVER SIDE APPLE ID VERIFICATION
    - Send `identityToken` + `authorizationCode` to backend for validation and secure user extraction.

- BATCH LOG UPDATES
  - Convert LogsRequest into a batch updater (like RemindersRequest).  
  - Update offline-mode manager to send log and reminder changes in batches per dog
    
- MEDIA SYNC
    - Sync icons and photos across devices
    - family member icons, dog icons, log photos
    - Show dog photo + name and family-member icon + name in each log cell; tap to view full-size images.

- SWIFT METRICS
    - Integrate SwiftMetrics to track app usage and performance
    - Monitor daily/weekly active users, feature usage, and crash data
    - Helpful for understanding user engagement and app health

- COMMENTING SYSTEM
    - Allow users to comment on logs
    - Comment has: text, user, timestamp
    - You could also go indepth and allow editing of comment 
    - Allow comment delete but then show deleted comment in log
    - Show comments in a collapsible section below each log

---

## 💡 Additional Ideas

- **Siri Shortcuts & Widgets**  
  Quick “Log a Walk” or “Log Water” shortcuts; Home Screen widget showing today’s reminders.  
- **HealthKit Integration**  
  Import weight trends or export pet health data alongside HealthKit.  
- **Community Features**  
  Optional in-app feed to share pet moments; family chat or notes section.
