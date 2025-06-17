# Hound TODOs

## 📋 General (Non–iOS Related)
- **Create a Facebook page** and join relevant pet-care groups.  
- **Redesign the website** for a more modern look and clearer messaging.  
- **Design a new cover image** for the app’s landing page.

---

## 🚀 Now

### Backend
- **Batch updates for logs**  
  - Convert `LogsRequest` into a batch updater (like `RemindersRequest`).  
  - Update offline-mode manager to send log and reminder changes in batches per dog.

### Reminders
- **Per-reminder notification settings**  
  Allow users to configure notification options per reminder and select which family members are notified.

### Filters
- **Advanced filter view**  
  Enable filtering by date range and custom sort order (e.g. newest-first, oldest-first).

### Style
- **New app icon**  
  Replace the paw icon with a new GPT icon

---

## 🐛 Bugs

### Logs View Controller
- **Infinite scroll glitch**  
  New logs don’t load until scrolling stops.  
- **“Scroll to top” quirk**  
  Tapping the tab bar sometimes requires two taps to return to the top.

---

## 🎯 Future

### Marketing & Onboarding
- **Referral program**  
  “Give a Month, Get a Month”: users share a code; when a friend signs up and completes 30 days, both receive a free month. See how Monarch Money does it  
- **Google Sign-In**  
  Add “Sign in with Google” alongside Apple ID.

### Data & Global Types
- **Auto-refresh missing GlobalTypes**  
  If the app encounters an unknown global type, force a refetch before failing.

### Logs UX
- **Search bar**  
  Search logs by action, custom name, timestamp, notes, or family member.  
- **Calendar view**  
  Visualize logs on a calendar grid in addition to the daily scroll.

### Smart Form Flows
- **Adaptive dropdowns** in Add-Log screen  
  - Automatically open the next relevant field once the previous one is set.  
  - Skip optional fields (e.g. end date) when not required.  
  - Centralize this logic in one reusable function.

### Metrics & Analytics
- **Integrate SwiftMetrics** to track:  
  - Daily/weekly active users  
  - Feature usage  
  - Crash and performance data

### Time & Timezones
- **24-hour clock option**  
- **DST detection**  
  When timezone changes (DST start/end), prompt user to adjust reminders. Track per family to avoid repeat prompts.

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
- **Apple Watch Companion**  
  “Log Now” buttons and haptic reminders on your wrist.  
- **HealthKit Integration**  
  Import weight trends or export pet health data alongside HealthKit.  
- **Data Export & Import**  
  CSV/JSON export of logs and reminders; bulk import from other apps.  
- **Localization & Accessibility**  
  Translate into top languages and add VoiceOver labels for all UI elements.  
- **iCloud Backup & Restore**  
  Backup settings, profiles, and logs; provide an easy restore flow.  
- **Community Features**  
  Optional in-app feed to share pet moments; family chat or notes section.
