//
//  SettingsSubscriptionCancelSuggestionsVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsSubscriptionCancelSuggestionsViewControllerDelegate: AnyObject {
    func didShowManageSubscriptions()
}

final class SettingsSubscriptionCancelSuggestionsViewController: GeneralUIViewController {

    // MARK: - IB

    @IBOutlet private weak var suggestionTextView: GeneralUITextView!
    
    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }

        // TODO with the info from this page and the previous one, perform a server request to pass along the information
        InAppPurchaseManager.showManageSubscriptions()
        // Now that we have just shown the page to manage subscriptions, dismiss all these feedback pages
        self.delegate?.didShowManageSubscriptions()
        
    }
    
    // MARK: - Properties
    
    private var delegate: SettingsSubscriptionCancelSuggestionsViewControllerDelegate?
    
    /// The cancellationReason passed to this view controller from SettingsSubscriptionCancelReasonViewController
    private var cancellationReason: SubscriptionCancellationReason?
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        suggestionTextView.placeholder = "Share any suggestions or issues..."
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: SettingsSubscriptionCancelSuggestionsViewControllerDelegate, forCancellationReason: SubscriptionCancellationReason?) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
    }
    
}
