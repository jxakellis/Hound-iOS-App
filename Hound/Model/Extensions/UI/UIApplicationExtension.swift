//
//  UIApplicationExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIApplication {

    /// Special keyWindow
    static var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }

    static var previousAppVersion: String?

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "3.2.0"
    }
    
    /// Any appVersion that is older than this version is considered incompatible. App should consider local data as faulty.
    static var lastCompatibleAppVersion: String = "3.2.0"
    
    /// Returns true if the previousAppVersion is nil or is greater than or equal to to the lastCompatibleAppVersion. Returns false if the previousAppVersion is less than lastCompatibleAppVersion
    static var isPreviousAppVersionCompatible: Bool {
        guard let previousAppVersion = UIApplication.previousAppVersion else {
            return true
        }
        // 3.1.0 -> [3,1,0]
        var previousAppVersionComponents = previousAppVersion.split(separator: ".").map { substring in
            return Int(substring) ?? -1
        }
        
        // 3.2.1 -> [3,2,1]
        var lastCompatibleAppVersionComponents = UIApplication.lastCompatibleAppVersion.split(separator: ".").map { substring in
            return Int(substring) ?? -1
        }
        
        // If one of the arrays is shorter than the other array, pad it with -1 so they are the same length
        if previousAppVersionComponents.count < lastCompatibleAppVersionComponents.count {
            for _ in 0..<(lastCompatibleAppVersionComponents.count - previousAppVersionComponents.count) {
                previousAppVersionComponents.append(-1)
            }
        }
        else if lastCompatibleAppVersionComponents.count < previousAppVersionComponents.count {
            for _ in 0..<(previousAppVersionComponents.count - lastCompatibleAppVersionComponents.count) {
                lastCompatibleAppVersionComponents.append(-1)
            }
        }
        
        for (index, lastCompatibleAppVersionComponent) in lastCompatibleAppVersionComponents.enumerated() {
            let previousAppVersionComponent = previousAppVersionComponents[index]
            
            guard previousAppVersionComponent != lastCompatibleAppVersionComponent else {
                // Two components are equal, iterate to the next component
                continue
            }
            
            // The previousAppVersionComponent doesn't equal the lastCompatibleAppVersionComponent, e.g. [3,1,0] & [3,1,1] -> 0 != 1
            return previousAppVersionComponent >= lastCompatibleAppVersionComponent
        }
        
        // previousAppVersion == lastCompatibleAppVersion, so return true
        return true
    }
}
