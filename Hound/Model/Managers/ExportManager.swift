//
//  ExportManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/12/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ExportManager {
    /// Verifys that the family has space for a new family member and is unlocked. If conditions are passed, meaning the family can have a new user join, constructs an activityViewController with the information to share (i.e. the familyCode and short description of Hound) then presents it on forViewController
    static func shareFamilyCode(forViewController viewController: UIViewController, forFamilyCode familyCode: String) {
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
        
        let shareHoundText = "Download Hound to help our family stay on track with caring for our pets! Never forget to lend a helping hand with Hound's reminders, and never question when your pets were last helped with logs of care. Join my Hound family today by using the following code: \(familyCode)\n\nhttps://apps.apple.com/us/app/hound-dog-schedule-organizer/id1564604025"
        
        let textToShare = [ shareHoundText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        // Configure so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes =
        [ UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.openInIBooks ]
        
        if #available(iOS 15.4, *) {
            activityViewController.excludedActivityTypes?.append(UIActivity.ActivityType.sharePlay)
        }
        
        // present the view controller
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    // TO DO FUTURE add export logs button
}
