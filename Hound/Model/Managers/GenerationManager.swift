//
//  GenerationManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/5/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum GenerationManager {
    private static func generateRandomAlphanumericString(ofLength: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        
        for _ in 0..<ofLength {
            randomString.append(characters.randomElement() ?? Character(""))
        }
        
        return randomString
    }
    
    /// For a given dogManager, generates numberOfLogs of logs total and distrubutes them randomly among its dogs. Once all of these logs have been added to the Hound server, invoked completionHandler
    static func generateRandomLogs(toDogManager: DogManager, numberOfLogs: Int, completionHandler: (() -> Void)?) {
        
        let completionTracker = CompletionTracker(numberOfTasks: numberOfLogs) {
            // Do nothing if one task was completed
        } completedAllTasksCompletionHandler: {
            // Invoke completionHandler if all tasks completed
            completionHandler?()
        } failedTaskCompletionHandler: {
            // Invoke completionHandler if one task failed
            completionHandler?()
        }

        for i in 0..<numberOfLogs {
            guard let logActionType = GlobalTypes.shared.logActionTypes.randomElement() else {
                return
            }
            // If the logActionType is custom, then 50% chance for a random note and 50% chance for no note
            let logCustomActionName = logActionType.allowsCustom
            ? (Int.random(in: 0...1) == 0 ? generateRandomAlphanumericString(ofLength: Int.random(in: 0...32)) : nil)
            : nil
            
            let referenceDate = Calendar.user.date(byAdding: .month, value: -1, to: Date()) ?? Date(timeIntervalSinceReferenceDate: 0.0)
            let logStartDate = referenceDate.addingTimeInterval(
                Double.random(in: 0.0...referenceDate.distance(to: Date()))
            )
            let logEndDate = Int.random(in: 0...1) == 0
            ? nil
            : logStartDate.addingTimeInterval(Double.random(in: 0.0...logStartDate.distance(to: Date())))
            
            let logNote = Int.random(in: 0...1) == 0
            ? nil
            : generateRandomAlphanumericString(ofLength: Int.random(in: 0...100))
            
            let logUnitType = logActionType.associatedLogUnitTypes.randomElement()
            
            let logNumberOfUnits = Double.random(in: 0.0...1000.0)
            
            let log = Log(
                forLogId: nil,
                forLogActionTypeId: logActionType.logActionTypeId,
                forLogCustomActionName: logCustomActionName,
                forLogStartDate: logStartDate,
                forLogEndDate: logEndDate,
                forLogNote: logNote,
                forLogUnitTypeId: logUnitType?.logUnitTypeId,
                forLogNumberOfUnits: logNumberOfUnits,
                forCreatedByReminderUUID: nil
            )
            
            let dog = toDogManager.dogs.randomElement()
            
            guard let dog = dog else {
                continue
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.3)) {
                guard completionTracker.isFinished == false else {
                    return
                }
                
                LogsRequest.create(forErrorAlert: .automaticallyAlertForNone, forDogUUID: dog.dogUUID, forLog: log) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        completionTracker.failedTask()
                        return
                    }
                    
                    completionTracker.completedTask()
                    dog.dogLogs.addLog(forLog: log, invokeDogTriggers: false)
                }
            }
        }
    }
    
    /// Generates a representative set of two dogs with realistic reminders, logs, and automations
    /// for use in App Store screenshots. Data is relative to the user's current time zone.
    /// Both dogs have routines that show clear, real-world use of Hound across today/yesterday.
    /// Generates a default, screenshot-friendly DogManager with two realistic dogs, reminders, logs, and triggers.
    /// All dates are relative to today/yesterday and the user's time zone.
    static func generateScreenshotDogManager() -> DogManager? {
        func logType(_ internalValue: String) -> LogActionType? {
            GlobalTypes.shared.logActionTypes.first { $0.internalValue == internalValue }
        }
        func reminderTypeId(_ internalValue: String) -> Int? {
            GlobalTypes.shared.reminderActionTypes.first { $0.internalValue == internalValue }?.reminderActionTypeId
        }
        func logUnit(_ symbol: String) -> LogUnitType? {
            GlobalTypes.shared.logUnitTypes.first { $0.unitSymbol == symbol }
        }
        func todayAt(_ hour: Int, _ minute: Int) -> Date {
            let cal = Calendar.user
            let today = cal.startOfDay(for: Date())
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }
        func yesterdayAt(_ hour: Int, _ minute: Int) -> Date {
            let cal = Calendar.user
            let today = cal.startOfDay(for: Date())
            let yesterday = cal.date(byAdding: .day, value: -1, to: today) ?? today
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: yesterday) ?? yesterday
        }
        func walkUnitSymbol() -> String {
            UserConfiguration.measurementSystem == .metric ? "km" : "mi"
        }
        func foodUnitSymbol() -> String { "cup" }
        
        // --- 1. Dogs ---
        guard
            let bella = try? Dog(forDogName: "Bella"),
            let charlie = try? Dog(forDogName: "Charlie")
        else { return nil }
        
        // --- 2. Reminders ---
        if let feedId = reminderTypeId("feed") {
            let weekly = WeeklyComponents()
            weekly.setZonedWeekdays(Weekday.allCases)
            weekly.zonedHour = 7
            weekly.zonedMinute = 0
            let reminder = Reminder(
                reminderActionTypeId: feedId,
                reminderType: .weekly,
                reminderTimeZone: UserConfiguration.timeZone,
                weeklyComponents: weekly
            )
            bella.dogReminders.addReminder(forReminder: reminder)
        }
        if let walkId = reminderTypeId("walk") {
            let weekly = WeeklyComponents()
            weekly.setZonedWeekdays(Weekday.allCases)
            weekly.zonedHour = 17
            weekly.zonedMinute = 0
            let reminder = Reminder(
                reminderActionTypeId: walkId,
                reminderType: .weekly,
                reminderTimeZone: UserConfiguration.timeZone,
                weeklyComponents: weekly
            )
            bella.dogReminders.addReminder(forReminder: reminder)
        }
        
        // Charlie: Feed (8:00am), Water (12:00pm), Walk (6:00pm) - all days
        if let feedId = reminderTypeId("feed") {
            let weekly = WeeklyComponents()
            weekly.setZonedWeekdays(Weekday.allCases)
            weekly.zonedHour = 8
            weekly.zonedMinute = 0
            let reminder = Reminder(
                reminderActionTypeId: feedId,
                reminderType: .weekly,
                reminderTimeZone: UserConfiguration.timeZone,
                weeklyComponents: weekly
            )
            charlie.dogReminders.addReminder(forReminder: reminder)
        }
        if let waterId = reminderTypeId("water") {
            let weekly = WeeklyComponents()
            weekly.setZonedWeekdays(Weekday.allCases)
            weekly.zonedHour = 12
            weekly.zonedMinute = 0
            let reminder = Reminder(
                reminderActionTypeId: waterId,
                reminderType: .weekly,
                reminderTimeZone: UserConfiguration.timeZone,
                weeklyComponents: weekly
            )
            charlie.dogReminders.addReminder(forReminder: reminder)
        }
        if let walkId = reminderTypeId("walk") {
            let weekly = WeeklyComponents()
            weekly.setZonedWeekdays(Weekday.allCases)
            weekly.zonedHour = 18
            weekly.zonedMinute = 0
            let reminder = Reminder(
                reminderActionTypeId: walkId,
                reminderType: .weekly,
                reminderTimeZone: UserConfiguration.timeZone,
                weeklyComponents: weekly
            )
            charlie.dogReminders.addReminder(forReminder: reminder)
        }
        
        // --- 3. Triggers / Automations ---
        bella.dogTriggers.addTriggers(forDogTriggers: Constant.Class.Trigger.defaultTriggers)
        charlie.dogTriggers.addTriggers(forDogTriggers: Constant.Class.Trigger.defaultTriggers)
        
        // --- 4. Logs (balanced between aesthetic, realistic, and feature showcase) ---
        func addLog(
            to dog: Dog,
            action: String,
            customName: String? = nil,
            start: Date,
            end: Date? = nil,
            unitSymbol: String? = nil,
            units: Double? = nil,
            note: String? = nil
        ) {
            guard let logType = logType(action) else { return }
            let unitId = unitSymbol.flatMap { logUnit($0)?.logUnitTypeId }
            let log = Log(
                forLogActionTypeId: logType.logActionTypeId,
                forLogCustomActionName: customName,
                forLogStartDate: start,
                forLogEndDate: end,
                forLogNote: note,
                forLogUnitTypeId: unitId,
                forLogNumberOfUnits: units
            )
            dog.dogLogs.addLog(forLog: log, invokeDogTriggers: false)
        }
        
        // Bella (Yesterday and Today)
        addLog(
            to: bella,
            action: "feed",
            start: yesterdayAt(7, 0),
            unitSymbol: foodUnitSymbol(),
            units: 1.5,
            note: "Dry kibble"
        )
        addLog(
            to: bella,
            action: "both",
            start: yesterdayAt(7, 18)
        )
        addLog(
            to: bella,
            action: "walk",
            start: yesterdayAt(17, 0),
            end: yesterdayAt(17, 35),
            unitSymbol: walkUnitSymbol(),
            units: 1.1,
            note: "Nice long walk"
        )
        addLog(
            to: bella,
            action: "feed",
            start: todayAt(7, 0),
            unitSymbol: foodUnitSymbol(),
            units: 1.25,
            note: "Dry kibble"
        )
        addLog(
            to: bella,
            action: "both",
            start: todayAt(7, 14)
        )
        addLog(
            to: bella,
            action: "walk",
            start: todayAt(17, 0),
            end: todayAt(17, 34),
            unitSymbol: walkUnitSymbol(),
            units: 1.0,
            note: "She sniffed around a lot!"
        )
        addLog(
            to: bella,
            action: "treat",
            start: todayAt(18, 58),
            note: "After training"
        )
        
        // Charlie (Yesterday and Today)
        addLog(
            to: charlie,
            action: "feed",
            start: yesterdayAt(8, 0),
            unitSymbol: foodUnitSymbol(),
            units: 0.9
        )
        addLog(
            to: charlie,
            action: "water",
            customName: "Refilled bowl",
            start: yesterdayAt(12, 15),
        )
        addLog(
            to: charlie,
            action: "walk",
            start: yesterdayAt(18, 0),
            end: yesterdayAt(18, 33),
            unitSymbol: walkUnitSymbol(),
            units: 1.4
        )
        addLog(
            to: charlie,
            action: "treat",
            start: yesterdayAt(19, 12)
        )
        addLog(
            to: charlie,
            action: "feed",
            start: todayAt(8, 0),
            unitSymbol: foodUnitSymbol(),
            units: 1.0
        )
        addLog(
            to: charlie,
            action: "water",
            start: todayAt(12, 11),
            unitSymbol: "cup",
            units: 1.75
        )
        addLog(
            to: charlie,
            action: "medicine",
            customName: "Heartworm",
            start: todayAt(20, 0)
        )
        addLog(
            to: charlie,
            action: "pee",
            start: todayAt(18, 42)
        )
        addLog(
            to: charlie,
            action: "walk",
            start: todayAt(18, 0),
            end: todayAt(18, 28),
            unitSymbol: walkUnitSymbol(),
            units: 1.2
        )
        
        // --- 5. Compose manager ---
        let manager = DogManager()
        manager.addDogs(forDogs: [bella, charlie])
        return manager
    }

}
