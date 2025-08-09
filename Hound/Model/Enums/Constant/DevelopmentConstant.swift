//
//  EnumConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/17/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

public enum DevelopmentConstant {
    static let isProduction: Bool = {
#if DEBUG
        return false
#else
        return true
#endif
    }()
    /// True if the server we are contacting is our Ubuntu AWS instance, false if we are local hosting off personal computer
    static let isProductionAWSServer: Bool = {
#if DEBUG
        HoundLogger.general.debug("DEBUG configuration for server")
        // Return true to connect to AWS EC2 instance
        // Return false to connect to local
        return true
#else
        HoundLogger.general.debug("RELEASE configuration for server")
        // MARK: ALWAYS RETURN TRUE, WANT PROD SERVER FOR RELEASE
        return true
#endif
    }()
    /// True if we are contacting the production environment side of our server, false if we are contacting the development side
    static let isProductionDatabase: Bool = {
#if DEBUG
        HoundLogger.general.debug("DEBUG configuration for database")
        // MARK: ALWAYS RETURN FALSE, WANT DEV DATABASE FOR DEBUG
        return false
#else
        HoundLogger.general.debug("RELEASE configuration for database")
        // MARK: ALWAYS RETURN TRUE, WANT PROD DATABASE FOR RELEASE
        return true
#endif
    }()

    /// If testing the development of Hound with its development database, then use this user id for a test account.
    static let developmentDatabaseTestUserId: String? = isProductionDatabase ? nil : nil // "3314e13ce7fab539591cfa2d5c8e4a29105befdd9bc3398bbe457ef30448aa0c"

    /// If testing the development of Hound with its development database, then use this user identifier for a test account.
    static let developmentDatabaseTestUserIdentifier: String? = isProductionDatabase ? nil : nil // "001473.77422360ac5b4f8aabf48f816149efe8.1644"

    /// All Hound servers, development or producton, support HTTPS only
    private static let urlScheme: String = isProductionAWSServer ? "https://" : "http://"
    /// The production server is attached to a real domain name, whereas our development server is off the local network
    private static let urlDomainName: String = {
        if isProductionAWSServer && isProductionDatabase {
            return "api.houndorganizer.com"
        }
        else if isProductionAWSServer && !isProductionDatabase {
            return "development.houndorganizer.com"
        }
        else {
            return "0.0.0.0"
        }
    }()
    /// The production server uses https on port 443 for the production database and 8443 for the development database. The development server always uses http on port 80.
    private static let urlPort: String = ":443"
    /// All Hound app requests go under the app path
    private static let urlAppPath: String = "/app"
    /// The base url that api requests go to
    static let url: String = urlScheme + urlDomainName + urlPort + urlAppPath
    /// The interval at which the date picker should display minutes. Use this property to set the interval displayed by the minutes wheel (for example, 15 minutes). The interval value must be evenly divided into 60; if it is not, the default value is used. The default and minimum values are 1; the maximum value is 30.
    static let minuteInterval = isProductionDatabase ? 5 : 1
}
