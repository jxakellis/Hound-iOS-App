//
//  SettingsSubscriptionCancelSuggestionsVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsSubscriptionCancelSuggestionsViewController: GeneralUIViewController {

    // MARK: - IB

    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }

        // TODO with the info from this page and the previous one, perform a server request to pass along the information
        InAppPurchaseManager.showManageSubscriptions()
    }
    
    // MARK: - Properties
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        // TODO NOW add placeholder to text view
    }
}
