//
//  SettingsSubscriptionCancelReasonView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsSubscriptionCancelReasonViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionCancelReasonTableViewCellDelegate {

    // MARK: - SettingsSubscriptionCancelReasonTableViewCellDelegate

    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelReasonTableViewCell, forIsCustomSelected: Bool) {
        lastSelectedCell = forCell

        // The user can only continue if they have selected a cancellation reason
        continueButton.isEnabled = forIsCustomSelected
    }

    // MARK: - IB

    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }

        // TODO go to next feedback page and pass along info
    }
    
    // MARK: - Properties
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionCancelReasonTableViewCell?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        // Continue button is disabled until the user selects a cancellation reason
        self.continueButton.isEnabled = false
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

    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // This is not 0.0 by default, so leave this code in to set it to 0.0
        return 15.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

}
