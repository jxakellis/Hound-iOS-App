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

final class LogsViewController: GeneralUIViewController,
                               UIGestureRecognizerDelegate,
                               LogsTableViewControllerDelegate,
                               LogsAddLogDelegate,
                               LogsFilterDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    /// Allow multiple gesture recognizers to be recognized at once
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - LogsAddLogDelegate & LogsTableViewControllerDelegate

    /// Called when the dogManager is updated from add-log or table view
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }

    // MARK: - LogsTableViewControllerDelegate

    /// Called when a log is selected in the table view
    func didSelectLog(forDogUUID: UUID, forLog: Log) {
        logsAddLogViewControllerDogUUIDToUpdate = forDogUUID
        logsAddLogViewControllerLogToUpdate = forLog
        self.performSegueOnceInWindowHierarchy(segueIdentifier: "LogsAddLogViewController")
    }

    /// Show or hide the “No logs recorded” label, and update its text based on dog count
    func shouldUpdateNoLogsRecorded(forIsHidden: Bool) {
        noLogsRecordedLabel.isHidden = forIsHidden
        if dogManager.dogs.isEmpty {
            noLogsRecordedLabel.text = "No logs recorded! Try creating a dog and adding some logs to it..."
        }
        else if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            noLogsRecordedLabel.text = "No logs recorded! Try adding some to \(dog.dogName)..."
        }
        else {
            noLogsRecordedLabel.text = "No logs recorded! Try adding some to one of your dogs..."
        }
    }
    
    /// Adjust button alphas and hide/show based on scroll offset and log availability
    func shouldUpdateAlphaForButtons(forAlpha: Double) {
        addLogButton.alpha = forAlpha
        exportLogsButton.alpha = forAlpha
        filterLogsButton.alpha = forAlpha

        addLogButton.isHidden = (addLogButton.alpha == 0.0) || dogManager.dogs.isEmpty
        exportLogsButton.isHidden = (exportLogsButton.alpha == 0.0) || !familyHasAtLeastOneLog
        // In addition to other logic, hide filterLogsButton if there is ≤1 available in all filter categories
        filterLogsButton.isHidden = (filterLogsButton.alpha == 0.0)
            || !familyHasAtLeastOneLog
            || ((logsTableViewController?.logsFilter.availableDogs.count ?? 0) <= 1
                && (logsTableViewController?.logsFilter.availableLogActions.count ?? 0) <= 1
                && (logsTableViewController?.logsFilter.availableFamilyMembers.count ?? 0) <= 1)
    }
    
    /// Update filter button’s hidden state after filter values change
    func shouldUpdateFilterLogsButton() {
        filterLogsButton.isHidden = (filterLogsButton.alpha == 0.0)
            || !familyHasAtLeastOneLog
            || ((logsTableViewController?.logsFilter.availableDogs.count ?? 0) <= 1
                && (logsTableViewController?.logsFilter.availableLogActions.count ?? 0) <= 1
                && (logsTableViewController?.logsFilter.availableFamilyMembers.count ?? 0) <= 1)
    }
    
    // MARK: - LogsFilterDelegate
    
    /// Pass updated filter to the logs table view controller
    func didUpdateLogsFilter(forLogsFilter: LogsFilter) {
        logsTableViewController?.logsFilter = forLogsFilter
    }

    // MARK: - UI Elements (formerly IBOutlets)

    /// Container view to hold background or other layering (was UIContainerView in storyboard)
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        
        return view
    }()

    /// Label displayed when no logs exist; hidden by default
    private let noLogsRecordedLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.isHidden = true
        label.contentMode = .left
        label.text = "No logs recorded! Try creating some..."
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()

    /// Button to add a new log; tint color and background set
    private let addLogButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        button.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundUIButtonTintColor = .secondarySystemBackground
        return button
    }()

    /// Button to present filter UI; tint color and background set
    private let filterLogsButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        button.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(740), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(740), for: .vertical)
        
        
        button.tintColor = .systemBlue
        button.setImage(
            UIImage(systemName: "line.3.horizontal.decrease.circle.fill"),
            for: .normal
        )
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundUIButtonTintColor = .secondarySystemBackground
        return button
    }()

    /// Button to export logs; tint color and background set
    private let exportLogsButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        
        
        button.tintColor = .systemBlue
        button.setImage(
            UIImage(systemName: "square.and.arrow.up.circle.fill"),
            for: .normal
        )
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundUIButtonTintColor = .secondarySystemBackground
        return button
    }()

    /// Action for the export logs button; collects all logs and invokes export manager
    @objc private func didTouchUpInsideExportLogs(_ sender: Any) {
        guard let logsTableViewController = logsTableViewController else {
            ErrorConstant.ExportError.exportLogs().alert()
            return
        }

        var dogUUIDLogTuples: [(UUID, Log)] = []

        // Flatten the 2D array into a single array
        logsTableViewController.logsForDogUUIDsGroupedByDate.forEach {
            dogUUIDLogTuples += $0
        }

        ExportActivityViewManager.exportLogs(forDogUUIDLogTuples: dogUUIDLogTuples)
    }

    // MARK: - Properties

    /// Returns true if at least one dog has at least one log
    private var familyHasAtLeastOneLog: Bool {
        var containsAtLeastOneLog = false
        dogManager.dogs.forEach { dog in
            if dog.dogLogs.dogLogs.isEmpty == false {
                containsAtLeastOneLog = true
            }
        }
        return containsAtLeastOneLog
    }

    private(set) var logsTableViewController: LogsTableViewController?

    private var logsAddLogViewControllerDogUUIDToUpdate: UUID?
    private var logsAddLogViewControllerLogToUpdate: Log?
    private var logsAddLogViewController: LogsAddLogViewController?

    private var logsFilterViewController: LogsFilterViewController?

    weak var delegate: LogsViewControllerDelegate!

    // MARK: - Dog Manager

    private(set) var dogManager: DogManager = DogManager()

    /// Set the dogManager and update UI elements and child controllers
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    
        addLogButton.isHidden = dogManager.dogs.isEmpty
        exportLogsButton.isHidden = !familyHasAtLeastOneLog
        filterLogsButton.isHidden = !familyHasAtLeastOneLog

        if (sender.localized is LogsTableViewController) == false {
            logsTableViewController?.setDogManager(
                sender: Sender(origin: sender, localized: self),
                forDogManager: dogManager
            )
        }
        if (sender.localized is MainTabBarController) == true {
            if logsAddLogViewController?.viewIfLoaded?.window == nil {
                // If add‐log VC isn’t currently visible, dismiss it when dog data changes
                logsAddLogViewController?.dismiss(animated: true)
            }
            // Dismiss filter VC if data changes, so filters remain valid
            logsFilterViewController?.dismiss(animated: true)
        }
        if (sender.localized is MainTabBarController) == false {
            delegate.didUpdateDogManager(
                sender: Sender(origin: sender, localized: self),
                forDogManager: dogManager
            )
        }
    }

    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGeneratedViews()
        self.eligibleForGlobalPresenter = true
    }

    // MARK: - Navigation

    /// Prepare for segues to child view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let logsTableVC = segue.destination as? LogsTableViewController {
            self.logsTableViewController = logsTableVC
            logsTableVC.delegate = self

            logsTableVC.setDogManager(
                sender: Sender(origin: self, localized: self),
                forDogManager: dogManager
            )
        }
        else if let addLogVC = segue.destination as? LogsAddLogViewController {
            self.logsAddLogViewController = addLogVC
            addLogVC.setup(
                forDelegate: self,
                forDogManager: self.dogManager,
                forDogUUIDToUpdate: logsAddLogViewControllerDogUUIDToUpdate,
                forLogToUpdate: logsAddLogViewControllerLogToUpdate
            )
            logsAddLogViewControllerDogUUIDToUpdate = nil
            logsAddLogViewControllerLogToUpdate = nil
        }
        else if let filterVC = segue.destination as? LogsFilterViewController {
            self.logsFilterViewController = filterVC
            if let logsFilter = logsTableViewController?.logsFilter {
                filterVC.setup(forDelegate: self, forFilter: logsFilter)
            }
        }
    }
}

extension LogsViewController {
    
    /// Add all subviews and set up targets
    private func setupGeneratedViews() {
        view.backgroundColor = .secondarySystemBackground
        
        addSubViews()
        setupConstraints()
    }

    /// Add subviews and attach button targets immediately after each view is added
    private func addSubViews() {
        view.addSubview(containerView)
        view.addSubview(noLogsRecordedLabel)
        view.addSubview(addLogButton)
        view.addSubview(filterLogsButton)
        view.addSubview(exportLogsButton)

        // Attach export button’s action now that ‘self’ is available
        exportLogsButton.addTarget(
            self,
            action: #selector(didTouchUpInsideExportLogs),
            for: .touchUpInside
        )
    }

    /// Activate NSLayoutConstraint instances for all subviews
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Add-Log Button at bottom-right
            addLogButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -10
            ),
            addLogButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),
            addLogButton.widthAnchor.constraint(
                equalTo: addLogButton.heightAnchor,
                multiplier: 1.0
            ),
            addLogButton.widthAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.widthAnchor,
                multiplier: 100.0/414.0
            ),
            addLogButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Filter-Logs Button aligned with Export-Logs Button
            filterLogsButton.bottomAnchor.constraint(
                equalTo: exportLogsButton.bottomAnchor
            ),
            filterLogsButton.widthAnchor.constraint(
                equalTo: filterLogsButton.heightAnchor,
                multiplier: 1.0
            ),

            // Export-Logs Button at top-right
            exportLogsButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 5
            ),
            exportLogsButton.leadingAnchor.constraint(
                equalTo: filterLogsButton.trailingAnchor,
                constant: 5
            ),
            exportLogsButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),
            exportLogsButton.widthAnchor.constraint(
                equalTo: exportLogsButton.heightAnchor,
                multiplier: 1.0
            ),
            exportLogsButton.widthAnchor.constraint(
                equalTo: addLogButton.widthAnchor,
                multiplier: 0.5
            ),
            exportLogsButton.widthAnchor.constraint(
                equalTo: filterLogsButton.widthAnchor
            ),

            // ContainerView spans entire view
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // No-Logs Label centered horizontally
            noLogsRecordedLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            noLogsRecordedLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            noLogsRecordedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
