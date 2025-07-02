//
//  SettingsSubscriptionCancelReasonView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsSubscriptionCancelReasonVC: ScrollUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionCancelReasonTVCDelegate, SettingsSubscriptionCancelSuggestionsVCDelegate {
    
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
    
    private let pageHeaderView: PageSheetHeaderView = {
        let view = PageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        
        view.pageHeaderLabel.text = "Sorry to See You Go!"
        view.pageHeaderLabel.textColor = .systemBackground
        
        view.isDescriptionEnabled = true
        view.pageDescriptionLabel.text = "What was wrong with your Hound+ subscription?"
        view.pageDescriptionLabel.textColor = .systemBackground
        
        view.backButton.tintColor = .systemBackground
        view.backButton.backgroundCircleTintColor = nil
        
        return view
    }()
    
    private lazy var tableView: GeneralUITableView = {
        let tableView = GeneralUITableView(huggingPriority: 340, compressionResistancePriority: 340)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.shouldAutomaticallyAdjustHeight = true
        
        tableView.bounces = false
        tableView.isScrollEnabled = false
        
        tableView.register(SettingsSubscriptionCancelReasonTVC.self, forCellReuseIdentifier: SettingsSubscriptionCancelReasonTVC.reuseIdentifier)
        tableView.sectionHeaderTopPadding = 12.5
        
        return tableView
    }()
    
    private lazy var continueButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 330, compressionResistancePriority: 330)
        
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        // Continue button is disabled until the user selects a cancellation reason
        button.isEnabled = false
        
        let continueAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let vc = SettingsSubscriptionCancelSuggestionsVC()
            self.settingsSubscriptionCancelSuggestionsViewController = vc
            vc.setup(forDelegate: self, forCancellationReason: lastSelectedCell?.cancellationReason)
            PresentationManager.enqueueViewController(vc)
        }
        button.addAction(continueAction, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionCancelReasonTVC?
    
    private var settingsSubscriptionCancelSuggestionsViewController: SettingsSubscriptionCancelSuggestionsVC?
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Only add spacing if NOT the last section
        let lastSection = SubscriptionCancellationReason.allCases.count - 1
        return section == lastSection ? 0 : ConstraintConstant.Spacing.contentIntraVertSpacing
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Only return a view if not the last section
        let lastSection = SubscriptionCancellationReason.allCases.count - 1
        if section == lastSection {
            return nil
        }
        
        let footer = GeneralUIHeaderFooterView()
        return footer
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
        containerView.addSubview(pageHeaderView)
        containerView.addSubview(tableView)
        containerView.addSubview(continueButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderView
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.sectionInterVertSpacing),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
        
        // continueButton constraints
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: ConstraintConstant.Spacing.sectionInterVertSpacing),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            continueButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: containerView),
            continueButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
        
    }
    
}
