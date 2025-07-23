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
        monitor.start(queue: queue)
        isConnected = monitor.currentPath.status == .satisfied
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
        }
    }
}
