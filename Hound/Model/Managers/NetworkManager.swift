//
//  NetworkManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/9/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import Network

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    private(set) var isConnected: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
}
