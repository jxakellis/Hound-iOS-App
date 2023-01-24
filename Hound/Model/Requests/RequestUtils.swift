//
//  RequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ResponseStatus {
    /// 200...299
    case successResponse
    /// != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
}

enum RequestUtils {
    
    /// Presents a fetchingInformationAlertController on the global presentor, indicating to the user that the app is currently retrieving some information. fetchingInformationAlertController stays until endRequestIndictator is called
    static func beginRequestIndictator() {
        guard AlertManager.shared.fetchingInformationAlertController.isBeingPresented == false && AlertManager.shared.fetchingInformationAlertController.isBeingDismissed == false else {
            return
        }
        
        AlertManager.enqueueAlertForPresentation(AlertManager.shared.fetchingInformationAlertController)
    }
    
    /// Dismisses the custom made contactingHoundServerAlertController. Allow the app to resume normal execution once the completion handler is called (as that indicates the contactingHoundServerAlertController was dismissed and new things can be presented/segued to).
    static func endRequestIndictator(completionHandler: (() -> Void)?) {
        guard AlertManager.shared.fetchingInformationAlertController.isBeingDismissed == false else {
            completionHandler?()
            return
        }
        
        AlertManager.shared.fetchingInformationAlertController.dismiss(animated: false) {
            completionHandler?()
        }
    }
    
    /// Takes an ISO8601 string from the Hound server then attempts to create a Date
    static func dateFormatter(fromISO8601String ISO8601String: String) -> Date? {
        // from client
        // 2023-04-06T21:03:15Z
        // from server
        // 2023-04-12T20:40:00.000Z
        let formatterWithMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithMilliseconds.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        let formatterWithoutMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithoutMilliseconds.formatOptions = [.withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        return formatterWithMilliseconds.date(from: ISO8601String) ?? formatterWithoutMilliseconds.date(from: ISO8601String) ?? nil
        
    }
}
