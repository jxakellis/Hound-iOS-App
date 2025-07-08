//
//  DataTaskQueue.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/18/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

private final class AppActiveTaskQueue {
    private static var tasks: [() -> Void] = []
    private static var isObserving = false

    static func performWhenActive(_ task: @escaping () -> Void) {
        // UIApplication.applicationState must be used from main thread only
        DispatchQueue.main.async {
            guard UIApplication.shared.applicationState != .active else {
                task()
                return
            }
            HoundLogger.apiRequest.warning("AppActiveTaskQueue: App is not active, queuing task to be performed when app becomes active")
            tasks.append(task)
            startObserving()
        }
    }

    @objc private static func handleDidBecomeActive() {
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        HoundLogger.apiRequest.warning("AppActiveTaskQueu: App is now active, executing \(tasks.count) tasks immediately")
        let queued = tasks
        tasks.removeAll()
        for task in queued {
            task()
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        isObserving = false
    }

    private static func startObserving() {
        guard isObserving == false else { return }
        isObserving = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

enum DataTaskQueue {
    
    // MARK: - Properties
    /// Tracks the date at which a certain task made a request to the Hound server in order to make sure the rate limit isn't exceeded.
    private static var houndServerRequestDates: [Date] = []
    
    /// For a given rateLimitEvaluationTimePeriod, this is the amount of requests that can be performed without triggering a rate limit. Requests per period: The number of requests over the period of time that will trigger the rate limiting rule.
    private static let numberOfRequestsAllowedInTimePeriod: Int = (20 - 1)

    /// The time period in which a specified number of requests can be made to the hound server without getting a rate limit from cloudflare. The true value is multiplied by 1.2 to provide extra padding. Period: The period of time to consider (in seconds) when evaluating the rate.
    private static let rateLimitEvaluationTimePeriod: Double = (10.0 * 1.2)
    
    /// If a rate limit is triggered, this is the time period for how long we are timed out for. The true value is multiplied by 1.2 to provide extra padding
    private static let rateLimitTimeOutTimePeriod: Double = (10.0 * 1.2)
    
    /// If we receive a rate limit from the Hound server, track this date so we can delay
    static var lastDateRateLimitReceived: Date?
    
    /// The queue of URLSessionDataTask that need to perform their requests to the Hound server. Index 0 is highest priority
    private static var taskQueue: [URLSessionDataTask] = []
    
    /// If startTask triggered a delay that is a recursive call to itself, waiting a specified amount of time to avoid the rate limit, then this is true
    private static var isDelayInProgress: Bool = false
    
    /// If a dataTask hasn't been queued yet
    static func enqueueTask(forDataTask: URLSessionDataTask) {
        // Guard against enqueuing the same dataTask twice
        guard taskQueue.contains(where: { dataTask in
            return dataTask.taskIdentifier == forDataTask.taskIdentifier
        }) == false else {
            return
        }
        
        // When dataTasks are created, they start in the suspended state. Don't try to initiate from other states
        guard forDataTask.state == .suspended else {
            return
        }
        
        taskQueue.append(forDataTask)
        
        startTask()
    }
    
    /// Attempts to send the dataTask at index 0 of the taskQueue. If the app has sent too many requests in a given time frame, then delays the next requests until
    private static func startTask() {
        // If API calls are made when the app isn't active, we will have pathing errors to internet which is hard to pickup with NetworkMonitor
        AppActiveTaskQueue.performWhenActive {
            // startTask already triggered a delay to avoid the rate limit. Wait for that to return
            guard isDelayInProgress == false else {
                return
            }
            
            let delayNeededToAvoidRateLimit: Double = {
                if let lastDateRateLimitReceived = lastDateRateLimitReceived, lastDateRateLimitReceived.distance(to: Date()) <= rateLimitTimeOutTimePeriod {
                    // E.g. rateLimitTimeOutTimePeriod 10 seconds
                    // lastDateRateLimitReceived 30.0 seconds ago -> 30.0 <= 10.0 -> false -> this code not invoked
                    // lastDateRateLimitReceived 5.0 seconds ago -> 10.0 - 5.0 -> 5.0
                    return rateLimitTimeOutTimePeriod - lastDateRateLimitReceived.distance(to: Date())
                }
                
                // Check if enough requests have been performed where we could have exceeded the rate limit
                guard let oldestRequestAtStartOfTimePeriod = houndServerRequestDates[safe: houndServerRequestDates.count - 1 - numberOfRequestsAllowedInTimePeriod] else {
                    return 0.0
                }
                
                // Find the delay in which we wait long enough to perform the next request, so the tail end of the rate limit requests is older than the rate limit period. This ensures that, for examples, we have a 10 second rate limit period where CloudFlare won't allow more than 20 requests, we wait long enough so that 20th request is older than 10 seconds. Ensuring CloudFlare is ready to accept a new request.
                // E.g. rateLimitEvaluationTimePeriod 10 seconds
                // oldestRequestAtStartOfTimePeriod 30.0 seconds ago -> (10.0 - 30.0) -> -20.0 -> 0.0
                // oldestRequestAtStartOfTimePeriod 5.0 seconds ago -> (10.0 - 5.0) -> 5.0 -> 5.0
                return max(0.0, rateLimitEvaluationTimePeriod - oldestRequestAtStartOfTimePeriod.distance(to: Date()))
            }()
            
            guard delayNeededToAvoidRateLimit <= 0.1 else {
                isDelayInProgress = true
                HoundLogger.apiRequest.warning("Rate limit triggered, delaying next request by \(delayNeededToAvoidRateLimit) seconds for \(taskQueue.first?.originalRequest?.url?.description ?? "NO URL")")
                DispatchQueue.global().asyncAfter(deadline: .now() + delayNeededToAvoidRateLimit) {
                    self.isDelayInProgress = false
                    self.startTask()
                }
                return
            }
            
            guard let dataTask = taskQueue.first else {
                // We have no data tasks to send
                return
            }
            
            // If we successfully for the first element from taskQueue, we can explictely remove that element without fear of crashing
            taskQueue.removeFirst()
            
            houndServerRequestDates.append(Date())
            
            dataTask.resume()
            
            startTask()
        }
    }
    
}
