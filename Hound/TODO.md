# Hound TODOs

## 📋 General (Non–iOS Related)
- **Create a Facebook page** and join relevant pet-care groups.  
- **Redesign the website** for a more modern look and clearer messaging.  

---

## 🚀 Now

- Batch updates for logs
  - Convert LogsRequest into a batch updater (like RemindersRequest).  
  - Update offline-mode manager to send log and reminder changes in batches per dog
  
- Log favoriting
    - Mimic feature from DogNote
    - Have a heart in the bottom right of each log cell that can be tapped to favorite log
    - if log is liked by any person, then this whole element has a rounded background added to it (similar to how we display log note/log unit). in this whole background highlight, there is the heart on the RHS (either selected or not), then on the LHS is the initials (in little bubbles/circle) of the people who liked it
    - add ability to filter logs by favorites
    
- Referral program
    - “Give a Month, Get a Month”: users share a code; when a friend signs up and completes 30 days, both receive a free month. See how Monarch Money does it  
    - Build referral page that users can get a code to share with other users
    - They can also track the progress of their rewards
    - Only get reward if user actually buys subscription
    
- Google Sign-In
    - Add “Sign in with Google” alongside Apple ID.

---

## 🎯 Future

- Multiple times of day for remidners
    - e.g. a reminder could be for MWF, then a user instead of a single time of day 7:00AM they could make as many times as they want

- Websockers
    - Use web sockets to update logs in real-time across devices

- About Page
    - Brief description of me and how hound came to be
    - Picture or two
    
- 24-hour clock setting

- dynamic error messages
    - if an error cannot be matched to one defined in Constant.Error / ErrorConstant, then create a custom one. This should pull all available info from the error returned by the server.

- Calendar view
    - Visualize logs on a calendar grid in addition to the daily scroll.
    
- email service
    - whenever a user submits feedback about the app, send me an email
    - later we can do actual email that go to users about stuff but thats a whole thing

- caching of local day/minute/hour for a reminder component
    - we do a lot of calculations for it and when doing things like comparison, we call it lots of time. not very performant

### Metrics & Analytics
- **Integrate SwiftMetrics** to track:  
  - Daily/weekly active users  
  - Feature usage  
  - Crash and performance data

### Notifications & Alarms
- **Custom alarm UI**  
  Replace default alerts with a branded, Hound-styled view.  Also,
- **Bulk reminder actions**  
  If there are a lot of pending reminders at once, offer a view that allows for bulk actions (e.g. See all, snooze all, dismiss all)

### Live Activities
- **Activity timers (Pup-To-Date)**  
  - Start a live Activity (e.g. “Walk Timer”) from the log screen.  
  - Display it on Lock Screen and Notification Center.  
  - Tap to stop and save duration as a log.

### Notification Actions
- **Rich actions for reminders**  
  In the notification, dynamically offer “Log Now,” “Snooze,” or “Dismiss,” matching in-app options.

### Authentication Security
- **Server-side Apple ID verification**  
  Send `identityToken` + `authorizationCode` to backend for validation and secure user extraction.

### Dog Profiles
- **Additional dog fields**  
  - Photo  
  - Date of birth  
  - Sex  
  - Microchip #  
  - License #  
  - Rabies vaccine #  
  - Insurance provider & #  
  - Notes  
- **UI restructuring options**  
  1. Move reminders off the dog-edit page  
  2. Nest dog info under a sub-page  
  3. Use a single scrolling layout with clear sections

### Media Sync
- **Sync icons and photos**  
  - Family-member icons  
  - Dog icons  
  - Log photos  
- **Display in feeds**  
  Show dog photo + name and family-member icon + name in each log cell; tap to view full-size images.

---

## 💡 Additional Ideas

- **Siri Shortcuts & Widgets**  
  Quick “Log a Walk” or “Log Water” shortcuts; Home Screen widget showing today’s reminders.  
- **HealthKit Integration**  
  Import weight trends or export pet health data alongside HealthKit.  
- **Community Features**  
  Optional in-app feed to share pet moments; family chat or notes section.
