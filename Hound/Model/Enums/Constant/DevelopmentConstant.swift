//
//  EnumConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/17/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DevelopmentConstant {
    /// True if the server we are contacting is our Ubuntu AWS instance, false if we are local hosting off personal computer
    static let isProductionServer: Bool = {
#if DEBUG
        AppDelegate.generalLogger.info("DEBUG configuration for server")
        // Return true to connect to AWS EC2 instance
        // Return false to connect to local
        return true
#else
        AppDelegate.generalLogger.info("RELEASE configuration for server")
        // MARK: ALWAYS RETURN TRUE, WANT PROD SERVER FOR RELEASE
        return true
#endif
    }()
    /// True if we are contacting the production environment side of our server, false if we are contacting the development side
    static let isProductionDatabase: Bool = {
#if DEBUG
        AppDelegate.generalLogger.info("DEBUG configuration for database")
        // MARK: ALWAYS RETURN FALSE, WANT DEV DATABASE FOR DEBUG
        return false
#else
        AppDelegate.generalLogger.info("RELEASE configuration for database")
        // MARK: ALWAYS RETURN TRUE, WANT PROD DATABASE FOR RELEASE
        return true
#endif
    }()
    
    static let developmentDatabaseUserId: String? = {
        return isProductionDatabase ? nil : "3991d3ce3891651df1f722ed8f4ba555986e82b968c7039aec2e8fb603352e65"
    }()
    
    static let developmentDatabaseUserIdentifier: String? = {
        return isProductionDatabase ? nil : "1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a"
    }()
    /// Only the production server supports HTTPS
    private static let urlScheme: String = isProductionServer ? "https" : "http"
    /// The production server is attached to a real domain name, whereas our development server is off the local network
    private static let urlDomainName: String = isProductionServer ? "://api.houndorganizer.com" : "://172.17.77.172"
    /// The production server uses https on port 443 for the production database and 8443 for the development database. The development server always uses http on port 80.
    private static let urlPort: String = isProductionServer ? isProductionDatabase ? ":443" : ":8443" : ":80"
    /// The production environment goes off the prod path, whereas development goes off the dev path
    private static let urlBasePath: String = isProductionDatabase ? "/prod" : "/dev"
    /// All Hound app requests go under the app path
    private static let urlAppPath: String = "/app"
    /// The base url that api requests go to
    static let url: String = urlScheme + urlDomainName + urlPort + urlBasePath + urlAppPath
    /// The interval at which the date picker should display minutes. Use this property to set the interval displayed by the minutes wheel (for example, 15 minutes). The interval value must be evenly divided into 60; if it is not, the default value is used. The default and minimum values are 1; the maximum value is 30.
    static let reminderMinuteInterval = isProductionDatabase ? 5 : 1
    /// If a subscription is bought on the production database / server, then we display the purchase/expiration date as the format: Thursday, August 18th, 2022. If it's not the production database, then we display it as Thursday, August 18th, 11:00 AM, 2022
    static let subscriptionDateFormatTemplate = isProductionDatabase ? "EEEE, MMMM d, yyyy" : "EEEE, MMMM d yyyy, h:mm a"
}
