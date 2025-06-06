//
//  ExportActivityViewManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/12/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ExportActivityViewManager {

    /// Verifys that the family has space for a new family member and is unlocked. If conditions are passed, meaning the family can have a new user join, constructs an activityViewController with the information to share (i.e. the familyCode and short description of Hound) then presents it on forViewController
    static func shareFamilyCode(forFamilyCode familyCode: String) {
        guard let globalPresenter = PresentationManager.lastFromGlobalPresenterStack else {
            ErrorConstant.ExportError.shareFamilyCode().alert()
            return
        }

        // Check that the family has space for at least one new member, otherwise block them from sharing the family.
        guard FamilyInformation.familyMembers.count < FamilyInformation.familyActiveSubscription.numberOfFamilyMembers else {
            StoryboardViewControllerManager.SettingsViewControllers.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
                guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                    // Error message automatically handled
                    return
                }
                
                PresentationManager.enqueueViewController(settingsSubscriptionViewController)
            }
            return
        }

        /*
         // Make sure that the family is unlocked so new
        guard FamilyInformation.familyIsLocked == false else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareSubtitle, forStyle: .danger)
            return
        }
         */

        let shareHoundText = "Connect our family with Hound! It streamlines our pet care routine with shared logs and timely reminders to look after our dog.\n\nJoin my Hound family today by using the following code: \(familyCode)\n\nhttps://apps.apple.com/app/hound-dog-schedule-organizer/id1564604025"

        exportToActivityViewController(forObjectToShare: [shareHoundText], forGlobalPresenter: globalPresenter)
    }

    static func exportLogs(forDogUUIDLogTuples: [(UUID, Log)]) {
        PresentationManager.beginFetchingInformationIndicator()

        guard let globalPresenter = PresentationManager.lastFromGlobalPresenterStack else {
            PresentationManager.endFetchingInformationIndicator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }

        // Attempt to get a url to the user's document directory
        guard let documentsDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            PresentationManager.endFetchingInformationIndicator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }

        let dateFormatter = DateFormatter()
        // Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
        dateFormatter.dateStyle = .short
        // Specifies no style.
        dateFormatter.timeStyle = .none
        
        let dateString = dateFormatter.string(from: Date()).replacingOccurrences(of: "/", with: "-")

        let houndExportedLogsURL: URL = documentsDirectoryURL.appendingPathComponent("Hound-Exported-Logs-\(dateString)").appendingPathExtension("csv")
        // Header for CSV file
        var logsString = "Family Member,Dog Name,Log Action,Log Start Date,Log End Date,Log Unit,Log Note\n\n"
        // to speed up runtime, save a dictionary of dogUUIDs keys and dogNames values here. Skips searching for same dog repeatedly
        var dogUUIDToDogNames: [UUID: String] = [:]
        // to speed up runtime, save a dictionary of userIds keys and full names values here. Skips searching for same family member repeatedly
        var userIdToFamilyMemberFullName: [String: String] = [:]

        // Individual rows for CSV file
        for forDogUUIDLogTuple in forDogUUIDLogTuples {
            let dogUUID = forDogUUIDLogTuple.0
            let log = forDogUUIDLogTuple.1

            var familyMemberFullName = userIdToFamilyMemberFullName[log.userId]
            if familyMemberFullName == nil {
                // if we don't have familyMemberFullName stored in the dictionary for quick reference, store it
                familyMemberFullName = FamilyInformation.findFamilyMember(forUserId: log.userId)?.displayFullName ?? VisualConstant.TextConstant.unknownName
                userIdToFamilyMemberFullName[log.userId] = familyMemberFullName
            }

            var dogName = dogUUIDToDogNames[dogUUID]
            if dogName == nil {
                // if we don't have dogName stored in the dictionary for quick reference, store it
                dogName = DogManager.globalDogManager?.findDog(forDogUUID: dogUUID)?.dogName ?? VisualConstant.TextConstant.unknownName
                dogUUIDToDogNames[dogUUID] = dogName
            }

           // neither should be nil as in the odd case we can't locate either, we just put in VisualConstant.TextConstant.unknownName in its place
            guard let dogName = dogName, let familyMemberFullName = familyMemberFullName else {
                continue
            }

            let logActionType = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName)

            let dateFormatter = DateFormatter()
            // January 25, 2023 at 7:53 AM
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdyyyyhma")
            let logStartDate = dateFormatter.string(from: log.logStartDate)
            
            let logEndDate = {
                guard let logEndDate = log.logEndDate else {
                    return ""
                }
                
                return dateFormatter.string(from: logEndDate)
            }()
            
            let logUnit = {
                guard let logUnitType = log.logUnitType, let logNumberOfLogUnits = log.logNumberOfLogUnits else {
                    return ""
                }
                
                return logUnitType.convertedMeasurementString(
                    forLogNumberOfLogUnits: logNumberOfLogUnits,
                    toTargetSystem: UserConfiguration.measurementSystem
                ) ?? ""
            }()
            
            let logNote = log.logNote

            var logString = ""
            logString.append("\(familyMemberFullName.formatIntoCSV()),")
            logString.append("\(dogName.formatIntoCSV()),")
            logString.append("\(logActionType.formatIntoCSV()),")
            logString.append("\(logStartDate.formatIntoCSV()),")
            logString.append("\(logEndDate.formatIntoCSV()),")
            logString.append("\(logUnit.formatIntoCSV()),")
            logString.append("\(logNote.formatIntoCSV())")
            logString.append("\n")

            logsString.append(logString)
        }

        guard (try? logsString.write(to: houndExportedLogsURL, atomically: true, encoding: .utf8)) != nil else {
            PresentationManager.endFetchingInformationIndicator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }

        PresentationManager.endFetchingInformationIndicator {
            exportToActivityViewController(forObjectToShare: [houndExportedLogsURL], forGlobalPresenter: globalPresenter)
        }
    }

    /// Creates an activityViewController used to share the objects passed. We purposefully pass through globalPresenter here, so if earlier in the flow one of the invoking functions can't resolve a globalPresenter, we are able to present a custom error message then and there
    private static func exportToActivityViewController(forObjectToShare objectToShare: [Any], forGlobalPresenter globalPresenter: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        // Configure so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView = globalPresenter.view

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes =
        [ UIActivity.ActivityType.addToReadingList ]

        if #available(iOS 15.4, *) {
            activityViewController.excludedActivityTypes?.append(UIActivity.ActivityType.sharePlay)
        }

        PresentationManager.enqueueViewController(activityViewController)
    }
}
