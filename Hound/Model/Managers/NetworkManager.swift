//
//  NetworkManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/9/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import Network

final class NetworkManager: NSObject {
    @objc static let shared = NetworkManager()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor

    @objc private(set) dynamic var isConnected: Bool = false

    override private init() {
        monitor = NWPathMonitor()
        super.init()
        // Start monitoring the internet connection
        monitor.start(queue: queue)
        // Immediately populate isConnected so that early requests have an
        // accurate state instead of waiting for the asynchronous
        // pathUpdateHandler callback.
        isConnected = monitor.currentPath.status == .satisfied
        monitor.pathUpdateHandler = { [self] path in
            self.isConnected = path.status == .satisfied
        }
    }
}
