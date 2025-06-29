//
//  SettingsSubscriptionCancelReasonView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsSubscriptionCancelReasonVC: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionCancelReasonTVCDelegate, SettingsSubscriptionCancelSuggestionsVCDelegate {
    
    // MARK: - SettingsSubscriptionCancelReasonTVCDelegate
    
    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelReasonTVC, forIsCustomSelected: Bool) {
        lastSelectedCell = forCell
        
        // The user can only continue if they have selected a cancellation reason
        continueButton.isEnabled = forIsCustomSelected
    }
    
    // MARK: - SettingsSubscriptionCancelSuggestionsVCDelegate
    
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
        return tableView
    }()
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
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
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "What was wrong with your Hound+ subscription?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
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
    private var lastSelectedCell: SettingsSubscriptionCancelReasonTVC?
    
    private var settingsSubscriptionCancelSuggestionsViewController: SettingsSubscriptionCancelSuggestionsVC?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        // Continue button is disabled until the user selects a cancellation reason
        self.continueButton.isEnabled = false
        self.tableView.register(SettingsSubscriptionCancelReasonTVC.self, forCellReuseIdentifier: SettingsSubscriptionCancelReasonTVC.reuseIdentifier)
        self.tableView.sectionHeaderTopPadding = 12.5
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSubscriptionCancelReasonTVC.reuseIdentifier, for: indexPath) as? SettingsSubscriptionCancelReasonTVC else {
            return GeneralUITableViewCell()
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
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionCancelReasonTVC else {
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
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(continueButton)
        containerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(backButton)
        
        let continueAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let vc = SettingsSubscriptionCancelSuggestionsVC()
            self.settingsSubscriptionCancelSuggestionsViewController = vc
            vc.setup(forDelegate: self, forCancellationReason: lastSelectedCell?.cancellationReason)
            PresentationManager.enqueueViewController(vc)
        }
        continueButton.addAction(continueAction, for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15)
        let headerLabelCenterX = headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)

        // backButton
        let backButtonTop = backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10)
        let backButtonLeading = backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 5)
        let backButtonTrailing = backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        let backButtonWidth = backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor)
        let backButtonWidthRatio = backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50.0 / 414.0)
        backButtonWidthRatio.priority = .defaultHigh
        let backButtonMinHeight = backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)
        let backButtonMaxHeight = backButton.createMaxHeight( 75)

        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 15)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // tableView
        let tableViewTop = tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10)
        let tableViewLeading = tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let tableViewTrailing = tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // continueButton
        let continueButtonTop = continueButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 35)
        let continueButtonLeading = continueButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
        let continueButtonWidthRatio = continueButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view)
        let continueButtonBottom = continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)

        // containerView
        let containerViewTop = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let containerViewLeading = containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let containerViewWidth = containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        let viewSafeAreaBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let viewSafeAreaTrailing = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // scrollView
        let scrollViewTop = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        let scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let scrollViewLeading = scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let scrollViewTrailing = scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([
            // headerLabel
            headerLabelTop, headerLabelCenterX,

            // backButton
            backButtonTop, backButtonLeading, backButtonTrailing,
            backButtonWidth, backButtonWidthRatio, backButtonMinHeight, backButtonMaxHeight,

            // descriptionLabel
            descriptionLabelTop, descriptionLabelLeading, descriptionLabelTrailing,

            // tableView
            tableViewTop, tableViewLeading, tableViewTrailing,

            // continueButton
            continueButtonTop, continueButtonLeading, continueButtonWidthRatio, continueButtonBottom,

            // containerView
            containerViewTop, containerViewLeading, containerViewWidth,
            viewSafeAreaBottom, viewSafeAreaTrailing,

            // scrollView
            scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing
        ])
    }

}
