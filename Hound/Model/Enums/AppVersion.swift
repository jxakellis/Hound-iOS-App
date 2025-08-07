//
//  AppVersion.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum AppVersion: String, CaseIterable, Comparable {

    case v4_0_0 = "4.0.0"
    
    case v4_0_1 = "4.0.1"
    
    case v4_1_0 = "4.1.0"

    // MARK: - Init
    /// Creates an AppVersion from a raw value. If the raw value does not match a known
    /// version, defaults to the latest known version.
    init?(from string: String) {
        guard let value = AppVersion(rawValue: string) else {
            return nil
        }
        self = value
    }

    // MARK: - Comparable
    
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let lhsComponents = lhs.rawValue.split(separator: ".").compactMap { Int($0) }
        let rhsComponents = rhs.rawValue.split(separator: ".").compactMap { Int($0) }
        let count = max(lhsComponents.count, rhsComponents.count)
        var lhsPadded = lhsComponents
        var rhsPadded = rhsComponents
        if lhsPadded.count < count {
            lhsPadded.append(contentsOf: Array(repeating: -1, count: count - lhsPadded.count))
        }
        if rhsPadded.count < count {
            rhsPadded.append(contentsOf: Array(repeating: -1, count: count - rhsPadded.count))
        }
        for (l, r) in zip(lhsPadded, rhsPadded) where l != r {
            return l < r
        }
        return false
    }

    // MARK: - Compatibility
    
    /// Oldest compatible version of the app. Any version older than this should
    /// have its data considered incompatible.
    static var oldestCompatible: AppVersion { .v4_1_0 }

    static func isCompatible(previous: AppVersion?) -> Bool {
        guard let prev = previous else {
            return false
        }
        return prev >= oldestCompatible
    }

    // MARK: - Release Notes
    var releaseNotes: NSAttributedString {
        switch self {
        case .v4_0_0, .v4_0_1:
            var builder = ReleaseNotesBuilder()
            builder.addFeature(
                title: "Automations",
                description: "Hound can now create reminders for you when you add certain logs.\n\nFor example, setup an automation to get reminded to take Bella out 30 mins after you feed her!"
            )
            
            builder.addFeature(
                title: "Fresh Interface",
                description: "A snazzy look built to shine on iPad, plus a slew of visual enhancements"
            )
            
            builder.addFeature(
                title: "Per‑Reminder Notifications",
                description: "Want to be notified for certain reminders but not others? Now you can choose which reminders send notifications and to who."
            )
            
            builder.addFeature(
                title: "New Log Type",
                description: "When your dog doesn't eat, now you can add a \"Did't Eat 🍽️\" log to track it!"
            )
            
            builder.addFeature(
                title: "Skippable Reminders",
                description: "Easily skip a reminder when playtime runs long."
            )
            
            builder.addFeature(
                title: "More Filter Options",
                description: "Filter your logs by text or time range to fetch just what you need"
            )
            
            builder.addFeature(
                title: "Haptics",
                description: "Give your fingertips a break or feel each tap - flip haptics on or off in Settings."
            )
            
            builder.addFeature(
                title: "Time Zones",
                description: "Hound can now adjust to your desired time zone, allowing you to collaborate from anywhere in the world."
            )
            
            builder.addFeature(
                title: "Duplicate-able Reminders",
                description: "Copy a reminder and tweak the details in seconds."
            )
            
            builder.addFeature(
                title: "Release Notes",
                description: "This page keeps you up to date on every new trick."
            )
            
            builder.addFeature(
                title: "Reliable Timing",
                description: "We tuned up our calculations so reminders pop up right on cue."
            )
            
            builder.addFeature(
                title: "New App Icon",
                description: "Spot Hound faster with our crisp new look."
            )
            return builder.buildAttributedString()
        case .v4_1_0:
            var builder = ReleaseNotesBuilder()
            
            // TODO RELEASE NOTES
            // log favoriting
            // sign in w google
            // new log sorting
            // log tracks creation / modified time and by who
            // automations track when last activated
            
            return builder.buildAttributedString()
        }
    }

    // MARK: - Helpers
    
    static var current: AppVersion {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return AppVersion.allCases.max() ?? AppVersion.oldestCompatible
        }
        
        return AppVersion(from: version) ?? AppVersion.allCases.max() ?? AppVersion.oldestCompatible
    }
    
    static var previousAppVersion: AppVersion?
        
}
