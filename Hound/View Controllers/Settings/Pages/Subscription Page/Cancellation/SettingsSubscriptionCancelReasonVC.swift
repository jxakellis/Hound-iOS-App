//
//  SettingsSubscriptionCancelReasonView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsSubscriptionCancelReasonViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionCancelReasonTableViewCellDelegate, SettingsSubscriptionCancelSuggestionsViewControllerDelegate {
    
    // MARK: - SettingsSubscriptionCancelReasonTableViewCellDelegate
    
    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelReasonTableViewCell, forIsCustomSelected: Bool) {
        lastSelectedCell = forCell
        
        // The user can only continue if they have selected a cancellation reason
        continueButton.isEnabled = forIsCustomSelected
    }
    
    // MARK: - SettingsSubscriptionCancelSuggestionsViewControllerDelegate
    
    func didShowManageSubscriptions() {
        // Now that we have just shown the page to manage subscriptions, dismiss all these feedback pages
        settingsSubscriptionCancelSuggestionsViewController?.dismiss(animated: true, completion: {
            self.dismiss(animated: true)
        })
    }
    
    // MARK: - Elements
    
    private let tableView: GeneralUITableView = {
        let tableView = GeneralUITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.bouncesZoom = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.alwaysBounceVertical = true
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        
        return view
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Sorry to see you go!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "What was wrong with your Hound+ subscription?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20)
        label.textColor = .systemBackground
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBlue
        
        button.shouldDismissParentViewController = true
        button.shouldRoundCorners = true
        return button
    }()
    
    // MARK: - Properties
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionCancelReasonTableViewCell?
    
    private var settingsSubscriptionCancelSuggestionsViewController: SettingsSubscriptionCancelSuggestionsViewController?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        // Continue button is disabled until the user selects a cancellation reason
        self.continueButton.isEnabled = false
        // By default the tableView pads a header, even of height 0.0, by about 20.0 points
        self.tableView.sectionHeaderTopPadding = 0.0
    }
    
    // MARK: - Table View Data Source
    
    // Make each cell its own section, allows us to easily space the cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return SubscriptionCancellationReason.allCases.count
    }
    
    // Make each cell its own section, allows us to easily space the cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set the spacing between sections by configuring the header height
        return 12.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Make a blank headerView so that there is a header view
        return GeneralUIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO UIKIT CONVERSION find and replace all dequeueReusableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionCancelReasonTableViewCell", for: indexPath) as? SettingsSubscriptionCancelReasonTableViewCell else {
            return UITableViewCell()
        }
        
        if lastSelectedCell == cell {
            // cell has been used before and lastSelectedCell is a reference to this cell. However, this cell could be changing to a different SubscriptionCancellationReason in setup, so that would invaliate lastSelectedCell. Therefore, clear lastSelectedCell
            lastSelectedCell = nil
        }
        
        let cellCancellationReason: SubscriptionCancellationReason = SubscriptionCancellationReason.allCases[indexPath.section]
        let cellIsCustomSelected: Bool = {
            // We do not want to override the lastSelectedCell as this function could be called after a user selceted a cell manually by themselves
            return lastSelectedCell?.cancellationReason == cellCancellationReason
        }()
        
        // We can only have one cell selected at once, therefore clear lastSelectedCell's selection state
        if cellIsCustomSelected == true {
            lastSelectedCell?.setCustomSelectedTableViewCell(forSelected: false, isAnimated: false)
        }
        
        cell.setup(forDelegate: self, forCancellationReason: cellCancellationReason, forIsCustomSelected: cellIsCustomSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Let a user select cells even if they don't have the permission to as a non-family head.
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionCancelReasonTableViewCell else {
            return
        }
        
        // Check if lastSelectedCell and selectedCells are actually different cells
        if let lastSelectedCell = lastSelectedCell, lastSelectedCell != selectedCell {
            // If they are different cells, then that must mean a new cell is being selected to transition into the selected state. Unselect the old cell and select the new one
            lastSelectedCell.setCustomSelectedTableViewCell(forSelected: false, isAnimated: true)
            selectedCell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: true)
        }
        // We are selecting the same cell as last time. However, a cell always needs to be selected. Therefore, we cannot deselect the current cell as that would mean we would have no cell selected at all, so always select.
        else {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: true)
        }
        
        lastSelectedCell = selectedCell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingsSubscriptionCancelSuggestionsViewController {
            self.settingsSubscriptionCancelSuggestionsViewController = destination
            destination.setup(forDelegate: self, forCancellationReason: lastSelectedCell?.cancellationReason)
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(continueButton)
        containerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(backButton)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 35),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            continueButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            continueButton.widthAnchor.constraint(equalTo: continueButton.heightAnchor, multiplier: 1 / 0.16),
            
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 5),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50 / 414),
            backButton.heightAnchor.constraint(equalToConstant: 25),
            backButton.heightAnchor.constraint(equalToConstant: 75),
            
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tableView.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
            
        ])
        
    }
}
