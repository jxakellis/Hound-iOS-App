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

final class SettingsSubscriptionCancelSuggestionsViewController: GeneralUIViewController, UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't allow the user to add a new line. If they do, we interpret that as the user hitting the done button.
        guard text != "\n" else {
            self.dismissKeyboard()
            return false
        }
        
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under logNoteCharacterLimit
        return updatedText.count <= ClassConstant.FeedbackConstant.subscriptionCancellationSuggestionCharacterLimit
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var suggestionTextView: GeneralUITextView!
    
    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        // Send the survey results to the server. Hope it gets through but don't throw an error if it doesn't
        SurveyFeedbackRequest.create(invokeErrorManager: false, userCancellationReason: cancellationReason, userCancellationFeedback: suggestionTextView.text ?? "") { _, _, _ in
            return
        }
        
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
        self.suggestionTextView.placeholder = "Share any suggestions or issues..."
        self.suggestionTextView.delegate = self
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: SettingsSubscriptionCancelSuggestionsViewControllerDelegate, forCancellationReason: SubscriptionCancellationReason?) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
    }
    
}
