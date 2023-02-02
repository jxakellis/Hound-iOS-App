//
//  ExportManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/12/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ExportManager {
    
    /// Verifys that the family has space for a new family member and is unlocked. If conditions are passed, meaning the family can have a new user join, constructs an activityViewController with the information to share (i.e. the familyCode and short description of Hound) then presents it on forViewController
    static func shareFamilyCode(forFamilyCode familyCode: String) {
        guard let globalPresenter = AlertManager.globalPresenter else {
            ErrorConstant.ExportError.shareFamilyCode().alert()
            return
        }
        
        // Check that the family has space for at least one new member, otherwise block them from sharing the family.
        guard FamilyInformation.familyMembers.count < FamilyInformation.activeFamilySubscription.numberOfFamilyMembers else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidSubscriptionFamilyShareTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidSubscriptionFamilyShareSubtitle, forStyle: .danger)
            return
        }
        
        // Make sure that the family is unlocked so new
        guard FamilyInformation.familyIsLocked == false else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareSubtitle, forStyle: .danger)
            return
        }
        
        let shareHoundText = "Download Hound to help our family stay on track with caring for our pets! Never forget to lend a helping hand with Hound's reminders, and never question when your pets were last helped with logs of care.\n\nJoin my Hound family today by using the following code: \(familyCode)\n\nhttps://apps.apple.com/us/app/hound-dog-schedule-organizer/id1564604025"
        
        exportToActivityViewController(forObjectToShare: [shareHoundText], forGlobalPresenter: globalPresenter)
    }
    
    /// Constructs an activityViewController with the information to share (i.e.  short description of Hound) then presents it on forViewController
    static func shareHound() {
        guard let globalPresenter = AlertManager.globalPresenter else {
            ErrorConstant.ExportError.shareHound().alert()
            return
        }
        
        let shareHoundText = "Download Hound to stay on track with caring for your pets! Never forget to lend a helping hand with Hound's reminders, and never question when your pets were last helped with logs of care.\n\nCreate your own Hound family for your houndhold or join mine to work together!\n\nhttps://apps.apple.com/us/app/hound-dog-schedule-organizer/id1564604025"
        
        exportToActivityViewController(forObjectToShare: [shareHoundText], forGlobalPresenter: globalPresenter)
    }
    
    static func exportLogs(forDogIdLogTuples dogIdLogTuples: [(Int, Log)]) {
        AlertManager.beginProcessingIndictator()
        
        guard let globalPresenter = AlertManager.globalPresenter else {
            AlertManager.endProcessingIndictator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }
        
        // Attempt to get a url to the user's document directory
        guard let documentsDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            AlertManager.endProcessingIndictator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.localCalendar.locale
        // Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
        dateFormatter.dateStyle = .short
        // Specifies no style.
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: Date()).replacingOccurrences(of: "/", with: "-")
        
        let houndExportedLogsURL: URL = documentsDirectoryURL.appendingPathComponent("Hound-Exported-Logs-\(dateString)").appendingPathExtension("csv")
        // Header for CSV file
        var logsString = "Family Member,Dog Name,Log Action,Log Date,Log Note\n\n"
        // to speed up runtime, save a dictionary of dogIds keys and dogNames values here. Skips searching for same dog repeatedly
        var dogIdToDogNames: [Int: String] = [:]
        // to speed up runtime, save a dictionary of userIds keys and full names values here. Skips searching for same family member repeatedly
        var userIdToFamilyMemberFullName: [String: String] = [:]
        
        // Individual rows for CSV file
        for dogIdLogTuple in dogIdLogTuples {
            let dogId = dogIdLogTuple.0
            let log = dogIdLogTuple.1
            
            var familyMemberFullName = userIdToFamilyMemberFullName[log.userId]
            if familyMemberFullName == nil {
                // if we don't have familyMemberFullName stored in the dictionary for quick reference, store it
                familyMemberFullName = FamilyInformation.findFamilyMember(forUserId: log.userId)?.displayFullName ?? VisualConstant.TextConstant.unknownName
                userIdToFamilyMemberFullName[log.userId] = familyMemberFullName
            }
            
            var dogName = dogIdToDogNames[dogId]
            if dogName == nil {
                // if we don't have dogName stored in the dictionary for quick reference, store it
                dogName = MainTabBarViewController.mainTabBarViewController?.dogManager.findDog(forDogId: dogId)?.dogName ?? VisualConstant.TextConstant.unknownName
                dogIdToDogNames[dogId] = dogName
            }
            
           // neither should be nil as in the odd case we can't locate either, we just put in VisualConstant.TextConstant.unknownName in its place
            guard let dogName = dogName, let familyMemberFullName = familyMemberFullName else {
                continue
            }
            
            let logAction = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Calendar.localCalendar.locale
            // Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32 PM PST”.
            dateFormatter.dateStyle = .long
            // Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
            dateFormatter.timeStyle = .short
            let logDate = dateFormatter.string(from: log.logDate)
            
            let logNote = log.logNote
            
            var logString = ""
            logString.append("\(familyMemberFullName.formatIntoCSV()),")
            logString.append("\(dogName.formatIntoCSV()),")
            logString.append("\(logAction.formatIntoCSV()),")
            logString.append("\(logDate.formatIntoCSV()),")
            logString.append("\(logNote.formatIntoCSV())")
            logString.append("\n")
            
            logsString.append(logString)
        }
        
        guard (try? logsString.write(to: houndExportedLogsURL, atomically: true, encoding: .utf8)) != nil else {
            AlertManager.endProcessingIndictator {
                ErrorConstant.ExportError.exportLogs().alert()
            }
            return
        }
        
        AlertManager.endProcessingIndictator {
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
        
        globalPresenter.present(activityViewController, animated: true, completion: nil)
    }
}
