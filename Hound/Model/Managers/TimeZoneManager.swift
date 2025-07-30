//
//  TimeZoneManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class TimeZoneMonitor {
    static let shared = TimeZoneMonitor()

    private var systemObserver: NSObjectProtocol?

    private init() {
        systemObserver = NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.systemTimeZoneDidChange()
        }

        updateDeviceTimeZoneOnServer()
    }

    deinit {
        if let systemObserver {
            NotificationCenter.default.removeObserver(systemObserver)
        }
    }

    private func systemTimeZoneDidChange() {
        updateDeviceTimeZoneOnServer()
        NotificationCenter.default.post(name: .didUpdateUserTimeZone, object: nil)
    }

    func updateDeviceTimeZoneOnServer() {
        guard UserInformation.userId != nil && UserInformation.userIdentifier != nil else {
            HoundLogger.general.error("TimeZoneMonitor.updateDeviceTimeZoneOnServer: Unable to send time zone to server")
            return
        }
        let body: JSONRequestBody = [
            Constant.Key.userConfigurationDeviceTimeZone.rawValue: .string(UserConfiguration.deviceTimeZone.identifier)
        ]
        UserRequest.update(forErrorAlert: .automaticallyAlertForNone, forBody: body) { _, _ in }
    }
}
