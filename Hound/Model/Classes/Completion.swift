//
//  Completion.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// CompletionTracker helps manage the progress of multiple async API queries. It checks that these tasks were all successful in order to invoke successfulCompletionHandler or otherwise invokes failureCompletionHandler
final class CompletionTracker: NSObject {
    
    // MARK: - Main
    
    init(numberOfTasks: Int, completedTaskCompletionHandler: @escaping (() -> Void), completedAllTasksCompletionHandler: @escaping (() -> Void), failedTaskCompletionHandler: @escaping (() -> Void)) {
        self.numberOfTasks = numberOfTasks
        self.completedTaskCompletionHandler = completedTaskCompletionHandler
        self.completedAllTasksCompletionHandler = completedAllTasksCompletionHandler
        self.failedTaskCompletionHandler = failedTaskCompletionHandler
        super.init()
    }
    
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
    
    // MARK: - Functions
    
    /// Increments numberOfCompletions. If numberOfCompletions == numberOfTasks, then executes the successfulCompletionHandler
    func completedTask() {
        guard completionTrackerFinished == false else {
            return
        }
        
        numberOfCompletions += 1
        
        completedTaskCompletionHandler()
        
        guard numberOfCompletions == numberOfTasks else {
            return
        }
        
        completionTrackerFinished = true
        completedAllTasksCompletionHandler()
    }
    
    /// Executes failureCompletionHandler
    func failedTask() {
        guard completionTrackerFinished == false else {
            return
        }
        
        completionTrackerFinished = true
        failedTaskCompletionHandler()
    }
}
