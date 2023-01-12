//
//  RequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
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
    
    enum RequestIndicatorType {
        case apple
        case hound
    }
    
    /// Presents a custom made contactingHoundServerAlertController on the global presentor that blocks everything until endRequestIndictator is called
    static func beginRequestIndictator(forRequestIndicatorType requestIndicatorType: RequestIndicatorType = .hound) {
        switch requestIndicatorType {
        case .hound:
            AlertManager.shared.contactingServerAlertController.title = "Contacting Hound's Server..."
        case .apple:
            AlertManager.shared.contactingServerAlertController.title = "Contacting Apple's Server..."
        }
        
        AlertManager.enqueueAlertForPresentation(AlertManager.shared.contactingServerAlertController)
    }
    
    /// Dismisses the custom made contactingHoundServerAlertController. Allow the app to resume normal execution once the completion handler is called (as that indicates the contactingHoundServerAlertController was dismissed and new things can be presented/segued to).
    static func endRequestIndictator(completionHandler: (() -> Void)?) {
        let alertController = AlertManager.shared.contactingServerAlertController
        guard alertController.isBeingDismissed == false else {
            completionHandler?()
            return
        }
        
        alertController.dismiss(animated: false) {
            completionHandler?()
        }
    }
    
    /// Takes an ISO8601 string from the Hound server then attempts to create a Date
    static func dateFormatter(fromISO8601String ISO8601String: String) -> Date? {
        // from client
        // 2022-04-06T21:03:15Z
        // from server
        // 2022-04-12T20:40:00.000Z
        let formatterWithMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithMilliseconds.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        let formatterWithoutMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithoutMilliseconds.formatOptions = [.withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        return formatterWithMilliseconds.date(from: ISO8601String) ?? formatterWithoutMilliseconds.date(from: ISO8601String) ?? nil
        
    }
}
