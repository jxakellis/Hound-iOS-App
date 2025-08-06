//
//  LogsVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
}

// UI VERIFIED 6/25/25
final class LogsVC: HoundViewController,
                    LogsTableVCDelegate,
                    LogsAddLogDelegate,
                    LogsFilterDelegate, LogsSortDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    /// Allow multiple gesture recognizers to be recognized at once
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - LogsAddLogDelegate & LogsTableVCDelegate
    
    /// Called when the dogManager is updated from add-log or table view
    func didUpdateDogManager(sender: Sender, dogManager: DogManager) {
        setDogManager(sender: sender, dogManager: dogManager)
    }
    
    // MARK: - LogsTableVCDelegate
    
    /// Called when a log is selected in the table view
    func didSelectLog(dogUUID: UUID, log: Log) {
        let vc = LogsAddLogVC()
        logsAddLogViewController = vc
        vc.setup(
            delegate: self,
            dogManager: self.dogManager,
            dogUUIDToUpdate: dogUUID,
            logToUpdate: log
        )
        PresentationManager.enqueueViewController(vc)
    }
    
    /// Show or hide the “No logs recorded” label, and update its text based on dog count
    func shouldUpdateNoLogsRecorded(isHidden: Bool) {
        noLogsRecordedLabel.isHidden = isHidden
        guard !dogManager.dogs.isEmpty else {
            noLogsRecordedLabel.text = "No logs created yet!\n\nTry creating a dog and adding some logs to it..."
            return
        }
        
        if logsTableViewController.logsFilter.hasActiveFilter && familyHasAtLeastOneLog {
            noLogsRecordedLabel.text = "No logs found with the current filter!\n\nTry changing or clearing it..."
        }
        else if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            noLogsRecordedLabel.text = "No logs created yet!\n\nTry adding some to \(dog.dogName)..."
        }
        else {
            noLogsRecordedLabel.text = "No logs created yet!\n\nTry adding some to one of your dogs..."
        }
    }
    
    /// Adjust button alphas and hide/show based on scroll offset and log availability
    func shouldUpdateAlphaForButtons(alpha: Double) {
        addLogButton.alpha = alpha
        exportLogsButton.alpha = alpha
        sortLogsButton.alpha = alpha
        filterLogsButton.alpha = alpha
        resetFilterAndSortButton.alpha = alpha
        
        addLogButton.isHidden = (addLogButton.alpha == 0.0) || dogManager.dogs.isEmpty
        exportLogsButton.isHidden = (exportLogsButton.alpha == 0.0) || !familyHasAtLeastOneLog
        sortLogsButton.isHidden = (sortLogsButton.alpha == 0.0) || !familyHasAtLeastOneLog
        updateFilterLogsButton()
        updateResetFilterAndSortButton()
    }
    
    func updateFilterLogsButton() {
        filterLogsButton.isHidden = (filterLogsButton.alpha == 0.0) || !familyHasAtLeastOneLog
    }
    
    func updateResetFilterAndSortButton() {
        resetFilterAndSortButton.isHidden = (resetFilterAndSortButton.alpha == 0.0) || !familyHasAtLeastOneLog || (!logsTableViewController.logsFilter.hasActiveFilter && !logsTableViewController.logsSort.hasActiveSort)
    }
    
    // MARK: - LogsFilterDelegate
    
    /// Pass updated filter to the logs table view controller
    func didUpdateLogsFilter(logsFilter: LogsFilter) {
        logsTableViewController.logsFilter = logsFilter
        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) { [weak self] in
            guard let self = self else {
                return
            }
            filterLogsButton.badgeVisible = logsFilter.hasActiveFilter
            filterLogsButton.badgeValue = logsFilter.numActiveFilters
            updateResetFilterAndSortButton()
        }
    }
    
    // MARK: - LogsSortDelegate
    
    func didUpdateLogsSort(logsSort: LogsSort) {
        logsTableViewController.logsSort = logsSort
        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) { [weak self] in
            guard let self = self else { return }
            if logsSort.sortDirection == .descending {
                self.sortLogsButton.imageView?.transform = .identity
            }
            else {
                self.sortLogsButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
            }
            
            sortLogsButton.badgeVisible = logsSort.hasActiveSort
            updateResetFilterAndSortButton()
        }
    }
    
    // MARK: - Elements
    
    /// Container view to hold background or other layering (was UIContainerView in storyboard)
    let logsTableViewController: LogsTableVC = LogsTableVC(style: .grouped)
    
    /// Label displayed when no logs exist; hidden by default
    private let noLogsRecordedLabel: HoundLabel = {
        let label = HoundLabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        label.textColor = UIColor.systemBlue
        return label
    }()
    
    private lazy var addLogButton: HoundButton = {
        let button = HoundButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.tintColor = UIColor.systemBlue
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let vc = LogsAddLogVC()
            vc.setup(delegate: self, dogManager: dogManager, dogUUIDToUpdate: nil, logToUpdate: nil)
            PresentationManager.enqueueViewController(vc)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var resetFilterAndSortButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.tintColor = UIColor.systemRed
        button.setImage(
            UIImage(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        button.isHidden = true
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let filter = logsTableViewController.logsFilter
            filter.reset()
            didUpdateLogsFilter(logsFilter: filter)
            
            let sort = logsTableViewController.logsSort
            sort.reset()
            didUpdateLogsSort(logsSort: sort)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var filterLogsButton: HoundButton = {
        let button = HoundButton(huggingPriority: 240, compressionResistancePriority: 240)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(
            UIImage(systemName: "line.3.horizontal.decrease.circle.fill"),
            for: .normal
        )
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let vc = LogsFilterVC()
            vc.setup(delegate: self, filter: logsTableViewController.logsFilter)
            PresentationManager.enqueueViewController(vc)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var sortLogsButton: HoundButton = {
        let button = HoundButton(huggingPriority: 240, compressionResistancePriority: 240)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(
            UIImage(systemName: "arrow.down.circle.fill"),
            for: .normal
        )
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let vc = LogsSortVC()
            vc.setup(delegate: self, sort: logsTableViewController.logsSort)
            PresentationManager.enqueueViewController(vc)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    /// Button to export logs; tint color and background set
    private lazy var exportLogsButton: HoundButton = {
        let button = HoundButton(huggingPriority: 250, compressionResistancePriority: 250)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(
            UIImage(systemName: "square.and.arrow.up.circle.fill"),
            for: .normal
        )
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = UIColor.secondarySystemBackground
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            var dogUUIDLogTuples: [(UUID, Log)] = []
            
            // Flatten the 2D array into a single array
            logsTableViewController.logsForDogUUIDsGroupedByDate.forEach {
                dogUUIDLogTuples += $0
            }
            
            ExportActivityViewManager.exportLogs(dogUUIDLogTuples: dogUUIDLogTuples)
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    /// Action for the export logs button; collects all logs and invokes export manager
    @objc private func didTouchUpInsideExportLogs(_ sender: Any) {
        
    }
    
    // MARK: - Properties
    
    /// Returns true if at least one dog has at least one log
    private var familyHasAtLeastOneLog: Bool {
        return dogManager.dogs.contains(where: { !$0.dogLogs.dogLogs.isEmpty })
    }
    
    private var logsAddLogViewController: LogsAddLogVC?
    
    private var logsFilterViewController: LogsFilterVC?
    
    private weak var delegate: LogsVCDelegate?
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Set the dogManager and update UI elements and child controllers
    func setDogManager(sender: Sender, dogManager: DogManager) {
        self.dogManager = dogManager
        
        addLogButton.isHidden = dogManager.dogs.isEmpty
        exportLogsButton.isHidden = !familyHasAtLeastOneLog
        filterLogsButton.isHidden = !familyHasAtLeastOneLog
        sortLogsButton.isHidden = !familyHasAtLeastOneLog
        
        if (sender.localized is LogsTableVC) == false {
            logsTableViewController.setDogManager(
                sender: Sender(origin: sender, localized: self),
                dogManager: dogManager
            )
        }
        if (sender.localized is MainTabBarController) == true {
            //            if logsAddLogViewController?.viewIfLoaded?.window == nil {
            //                // If add‐log VC isn’t currently visible, dismiss it when dog data changes
            //                logsAddLogViewController?.dismiss(animated: true)
            //            }
            // Dismiss filter VC if data changes, so filters remain valid
            //            logsFilterViewController?.dismiss(animated: true)
        }
        if (sender.localized is MainTabBarController) == false {
            delegate?.didUpdateDogManager(
                sender: Sender(origin: sender, localized: self),
                dogManager: dogManager
            )
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        logsTableViewController.setup(delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // don't use .maxY because this adds height + safe area inset, but logsTableVC already accounts for safe area inset, so that offsets it too much
        let exportButtonBottom = exportLogsButton.convert(exportLogsButton.bounds, to: view).height
        
        logsTableViewController.tableView.contentInset.top = exportLogsButton.isHidden
        ? Constant.Constraint.Spacing.absoluteVertInset
        : (exportButtonBottom + Constant.Constraint.Spacing.absoluteVertInset)
        logsTableViewController.tableView.contentInset.bottom = Constant.Constraint.Spacing.absoluteVertInset
    }
    
    // MARK: - Setup
    
    func setup(delegate: LogsVCDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Setup Elements
    
    /// Add all subviews and set up targets
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.secondarySystemBackground
        super.setupGeneratedViews()
    }
    
    /// Add subviews and attach button targets immediately after each view is added
    override func addSubViews() {
        super.addSubViews()
        embedChild(logsTableViewController)
        
        view.addSubview(noLogsRecordedLabel)
        view.addSubview(addLogButton)
        
        view.addSubview(exportLogsButton)
        
        view.addSubview(resetFilterAndSortButton)
        view.addSubview(filterLogsButton)
        view.addSubview(sortLogsButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // logsTableViewController.view
        NSLayoutConstraint.activate([
            logsTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            logsTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            logsTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logsTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // addLogButton
        NSLayoutConstraint.activate([
            addLogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            addLogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            addLogButton.createSquareAspectRatio(),
            addLogButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            addLogButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight)
        ])
        
        // exportLogsButton
        NSLayoutConstraint.activate([
            exportLogsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            exportLogsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteCircleHoriInset),
            exportLogsButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            exportLogsButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            exportLogsButton.createSquareAspectRatio()
        ])
        
        // sortLogsButton
        NSLayoutConstraint.activate([
            sortLogsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            sortLogsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            sortLogsButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            sortLogsButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            sortLogsButton.createSquareAspectRatio()
        ])
        
        // filterLogsButton
        NSLayoutConstraint.activate([
            filterLogsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            filterLogsButton.trailingAnchor.constraint(equalTo: sortLogsButton.leadingAnchor, constant: -Constant.Constraint.Spacing.contentTightIntraHori),
            filterLogsButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            filterLogsButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            filterLogsButton.createSquareAspectRatio()
        ])
        
        // resetFilterAndSortButton
        NSLayoutConstraint.activate([
            resetFilterAndSortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            resetFilterAndSortButton.trailingAnchor.constraint(equalTo: filterLogsButton.leadingAnchor, constant: -Constant.Constraint.Spacing.contentTightIntraHori),
            resetFilterAndSortButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            resetFilterAndSortButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            resetFilterAndSortButton.createSquareAspectRatio()
        ])
        
        // noLogsRecordedLabel
        NSLayoutConstraint.activate([
            noLogsRecordedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            noLogsRecordedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            noLogsRecordedLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
