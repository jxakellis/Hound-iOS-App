//
//  LogsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsViewController: GeneralUIViewController, UIGestureRecognizerDelegate, LogsTableViewControllerDelegate, LogsAddLogDelegate, LogsFilterDelegate {
    
    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: - LogsAddLogDelegate & LogsTableViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)

        if sender.origin is LogsAddLogViewController {
            CheckManager.checkForReview()
            CheckManager.checkForShareHound()
        }
    }

    // MARK: - LogsTableViewControllerDelegate

    func didSelectLog(forDogId: Int, forLog: Log) {
        logsAddLogViewControllerDogIdToUpdate = forDogId
        logsAddLogViewControllerLogToUpdate = forLog
        self.performSegueOnceInWindowHierarchy(segueIdentifier: "LogsAddLogViewController")
    }

    func shouldUpdateNoLogsRecorded(forIsHidden: Bool) {
        noLogsRecordedLabel?.isHidden = forIsHidden
        if dogManager.dogs.isEmpty {
            noLogsRecordedLabel?.text = "No logs recorded! Try creating a dog and adding some logs to it..."
        }
        else if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            noLogsRecordedLabel?.text = "No logs recorded! Try adding some to \(dog.dogName)..."
        }
        else if dogManager.dogs.count >= 1 {
            noLogsRecordedLabel?.text = "No logs recorded! Try adding some to one of your dogs..."
        }
    }
    
    func shouldUpdateAlphaForButtons(forAlpha: Double) {
        addLogButton.alpha = forAlpha
        exportLogsButton.alpha = forAlpha
        filterLogsButton.alpha = forAlpha

        addLogButton.isHidden = (addLogButton.alpha == 0.0) || dogManager.dogs.isEmpty
        exportLogsButton.isHidden = (exportLogsButton.alpha == 0.0) || !familyHasAtLeastOneLog
        // In addition to the other logic, hide the filterLogsButton if there is <= 1 available for all of the log types. If this condition is met, that means there is nothing unique to filter by, so we don't present the filter button
        filterLogsButton.isHidden = (filterLogsButton.alpha == 0.0)
        || !familyHasAtLeastOneLog
        || ((logsTableViewController?.logsFilter.availableDogs.count ?? 0) <= 1 && (logsTableViewController?.logsFilter.availableLogActions.count ?? 0) <= 1 && (logsTableViewController?.logsFilter.availableFamilyMembers.count ?? 0) <= 1)
    }
    
    func shouldUpdateFilterLogsButton() {
        // In addition to the other logic, hide the filterLogsButton if there is <= 1 available for all of the log types. If this condition is met, that means there is nothing unique to filter by, so we don't present the filter button
        filterLogsButton.isHidden = (filterLogsButton.alpha == 0.0)
        || !familyHasAtLeastOneLog
        || ((logsTableViewController?.logsFilter.availableDogs.count ?? 0) <= 1 && (logsTableViewController?.logsFilter.availableLogActions.count ?? 0) <= 1 && (logsTableViewController?.logsFilter.availableFamilyMembers.count ?? 0) <= 1)
    }
    
    // MARK: - LogsFilterDelegate
    
    func didUpdateLogsFilter(forLogsFilter: LogsFilter) {
        logsTableViewController?.logsFilter = forLogsFilter
    }

    // MARK: - IB

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet private weak var noLogsRecordedLabel: GeneralUILabel!

    @IBOutlet private weak var addLogButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var filterLogsButton: GeneralWithBackgroundUIButton!

    @IBOutlet private weak var exportLogsButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideExportLogs(_ sender: Any) {
        guard let logsTableViewController = logsTableViewController else {
            ErrorConstant.ExportError.exportLogs().alert()
            return
        }

        var dogIdLogTuples: [(Int, Log)] = []

        // logsForDogIdsGroupedByDate is a 2D array, where each parent array is a given day of year and each child array is the chronologically sorted logs for that day
        logsTableViewController.logsForDogIdsGroupedByDate.forEach { arrayOfDogIdLogTuples in
            dogIdLogTuples += arrayOfDogIdLogTuples
        }

        ExportManager.exportLogs(forDogIdLogTuples: dogIdLogTuples)
    }

    // MARK: - Properties

    private var familyHasAtLeastOneLog: Bool {
        dogManager.dogs.contains { dog in
            dog.dogLogs.logs.isEmpty == false
        }
    }

    private(set) var logsTableViewController: LogsTableViewController?

    private var logsAddLogViewControllerDogIdToUpdate: Int?
    private var logsAddLogViewControllerLogToUpdate: Log?
    private var logsAddLogViewController: LogsAddLogViewController?
    
    private var logsFilterViewController: LogsFilterViewController?

    weak var delegate: LogsViewControllerDelegate!

    // MARK: - Dog Manager

    private(set) var dogManager: DogManager = DogManager()

    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    
        addLogButton?.isHidden = dogManager.dogs.isEmpty
        exportLogsButton?.isHidden = !familyHasAtLeastOneLog
        filterLogsButton?.isHidden = !familyHasAtLeastOneLog

        if (sender.localized is LogsTableViewController) == false {
            logsTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is MainTabBarController) == true {
            if logsAddLogViewController?.viewIfLoaded?.window == nil {
                // If logsAddLogViewController isn't being actively viewed, we dismiss it when the dog manager updates. This is because a dog could have been added or removed, however if a user is actively viewing the page, this interruption would cause too much inconvience for the slight edge case where a dog was modified.
                logsAddLogViewController?.dismiss(animated: true)
            }
            
            // logsFilterViewController is heavily dependent on the dogManager. We don't want the user to be able to create an invalid filter. Dismiss this view if the data updates as it could potentially be invalid
            logsFilterViewController?.dismiss(animated: true)
        }
        // we dont want to update MainTabBarController with the delegate if its the one providing the update
        if (sender.localized is MainTabBarController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
    }

    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let logsTableViewController = segue.destination as? LogsTableViewController {
            self.logsTableViewController = logsTableViewController
            logsTableViewController.delegate = self

            logsTableViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let logsAddLogViewController = segue.destination as? LogsAddLogViewController {
            self.logsAddLogViewController = logsAddLogViewController
            logsAddLogViewController.setup(forDelegate: self, forDogManager: self.dogManager, forDogIdToUpdate: logsAddLogViewControllerDogIdToUpdate, forLogToUpdate: logsAddLogViewControllerLogToUpdate)
            logsAddLogViewControllerDogIdToUpdate = nil
            logsAddLogViewControllerLogToUpdate = nil
        }
        else if let logsFilterViewController = segue.destination as? LogsFilterViewController {
            self.logsFilterViewController = logsFilterViewController
            if let logsFilter = logsTableViewController?.logsFilter {
                // logsFilter should always exist
                logsFilterViewController.setup(forDelegate: self, forFilter: logsFilter)
            }
            
        }
    }

}
