//
//  Completion.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// CompletionTracker helps manage the progress of multiple async API queries. It checks that these tasks were all successful in order to invoke successfulCompletionHandler or otherwise invokes failureCompletionHandler
final class CompletionTracker: NSObject {
    
    // MARK: - Properties

    /// Number of completions of current tasks
    private var numberOfCompletions: Int = 0

    /// Number of tasks that need to be successful in order to invoke successfulCompletionHandler
    private var numberOfTasks: Int

    /// Once a completedAllTasksCompletionHandler or failedTaskCompletionHandler is invoked, we track it here. This indicates that the CompletionTracker has completed/failed and it should execute no more code
    private var completionTrackerFinished = false

    /// Completion handler invoked every time a task successfully completes
    private var completedTaskCompletionHandler: (() -> Void)

    /// Completion handler invoked if all tasks successfully complete
    private var completedAllTasksCompletionHandler: (() -> Void)

    /// Completion handler invoked if one or more of the tasks failed
    private var failedTaskCompletionHandler: (() -> Void)

    // MARK: - Main

    init(numberOfTasks: Int, completedTaskCompletionHandler: @escaping (() -> Void), completedAllTasksCompletionHandler: @escaping (() -> Void), failedTaskCompletionHandler: @escaping (() -> Void)) {
        self.numberOfTasks = max(numberOfTasks, 0)
        self.completedTaskCompletionHandler = completedTaskCompletionHandler
        self.completedAllTasksCompletionHandler = completedAllTasksCompletionHandler
        self.failedTaskCompletionHandler = failedTaskCompletionHandler
        super.init()
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if either a task has failed or all tasks have completed, meaning the CompletionTracker invoked the corresponding completionHandler and will invoke no further action
    var isFinished: Bool {
        return completionTrackerFinished
    }

    // MARK: - Functions

    /// If a task has been failed or all tasks have been completed, then this function does nothing. Otherwise, this function invokes completedTaskCompletionHandler then if numberOfCompeltion == numberOfTasks, then function also invokes completedAllTasksCompletionHandler
    func completedTask() {
        guard completionTrackerFinished == false else {
            return
        }

        numberOfCompletions += 1
        completedTaskCompletionHandler()

        guard numberOfCompletions >= numberOfTasks else {
            return
        }

        completionTrackerFinished = true
        completedAllTasksCompletionHandler()
    }

    /// If a task has been failed or all tasks have been completed, then this function does nothing. Otherwise, this function invokes failedTaskCompletionHandler
    func failedTask() {
        guard completionTrackerFinished == false else {
            return
        }

        completionTrackerFinished = true
        failedTaskCompletionHandler()
    }
}
