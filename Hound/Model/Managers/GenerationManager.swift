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
            let logAction = LogAction.allCases.randomElement() ?? LogAction.feed
            // If the logAction is custom, then 50% chance for a random note and 50% chance for no note
            let logCustomActionName = (logAction != .medicine && logAction != .vaccine && logAction != .custom)
            ? nil
            : (Int.random(in: 0...1) == 0 ? generateRandomAlphanumericString(ofLength: Int.random(in: 0...32)) : nil)
            
            let referenceDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(timeIntervalSinceReferenceDate: 0.0)
            let logStartDate = referenceDate.addingTimeInterval(
                Double.random(in: 0.0...referenceDate.distance(to: Date()))
            )
            let logEndDate = Int.random(in: 0...1) == 0
            ? nil
            : logStartDate.addingTimeInterval(Double.random(in: 0.0...logStartDate.distance(to: Date())))
            
            let logNote = Int.random(in: 0...1) == 0
            ? nil
            : generateRandomAlphanumericString(ofLength: Int.random(in: 0...100))
            
            let logUnit = Int.random(in: 0...2) == 0
            ? nil
            : LogUnit.logUnits(forLogAction: logAction).randomElement()
            
            let logNumberOfUnits = Double.random(in: 0.0...1000.0)
            
            let log = Log(
                forLogId: nil,
                forLogAction: logAction,
                forLogCustomActionName: logCustomActionName,
                forLogStartDate: logStartDate,
                forLogEndDate: logEndDate,
                forLogNote: logNote,
                forLogUnit: logUnit,
                forLogNumberOfUnits: logNumberOfUnits
            )
            
            let dog = toDogManager.dogs.randomElement()
            
            guard let dog = dog else {
                continue
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 1.0)) {
                guard completionTracker.isFinished == false else {
                    return
                }
                
                LogsRequest.create(errorAlert: .automaticallyAlertForNone, forDogUUID: dog.dogUUID, forLog: log) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        completionTracker.failedTask()
                        return
                    }
                    
                    completionTracker.completedTask()
                    dog.dogLogs.addLog(forLog: log)
                }
            }
        }
    }
}
