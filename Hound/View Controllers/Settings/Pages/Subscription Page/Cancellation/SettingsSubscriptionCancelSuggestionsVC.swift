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

// TODO VERIFY UI
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
    
    // MARK: - Elements
    
    private let suggestionTextView: GeneralUITextView = {
        let textView = GeneralUITextView()
        
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.font = VisualConstant.FontConstant.primaryRegularLabel
        textView.borderWidth = 2
        textView.borderColor = .label
        textView.shouldRoundCorners = true
        textView.placeholder = "Share any suggestions or issues..."
        return textView
    }()
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Cancel Subscription", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        
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
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "What could we do to improve?"
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
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        
        return button
    }()
    @objc private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
            return
        }
        
        // Send the survey results to the server. Hope it gets through but don't throw an error if it doesn't
        SurveyFeedbackRequest.create(forErrorAlert: .automaticallyAlertForNone, userCancellationReason: cancellationReason, userCancellationFeedback: suggestionTextView.text ?? "") { _, _ in
            return
        }
        
        InAppPurchaseManager.showManageSubscriptions()
        // Now that we have just shown the page to manage subscriptions, dismiss all these feedback pages
        self.delegate?.didShowManageSubscriptions()
        
    }
    
    // MARK: - Properties
    
    private weak var delegate: SettingsSubscriptionCancelSuggestionsViewControllerDelegate?
    
    /// The cancellationReason passed to this view controller from SettingsSubscriptionCancelReasonViewController
    private var cancellationReason: SubscriptionCancellationReason?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.suggestionTextView.delegate = self
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsSubscriptionCancelSuggestionsViewControllerDelegate, forCancellationReason: SubscriptionCancellationReason?) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
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
        containerView.addSubview(continueButton)
        containerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(suggestionTextView)
        
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
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
        let backButtonMaxHeight = backButton.createMaxHeightConstraint( 75)

        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 15)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)

        // suggestionTextView
        let suggestionTextViewTop = suggestionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 25)
        let suggestionTextViewLeading = suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let suggestionTextViewTrailing = suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let suggestionTextViewHeight = suggestionTextView.heightAnchor.constraint(equalToConstant: 175)

        // continueButton
        let continueButtonTop = continueButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: 35)
        let continueButtonLeading = continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let continueButtonWidthRatio = continueButton.createHeightMultiplierConstraint(ConstraintConstant.Button.screenWideHeightMultiplier)
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

            // suggestionTextView
            suggestionTextViewTop, suggestionTextViewLeading, suggestionTextViewTrailing, suggestionTextViewHeight,

            // continueButton
            continueButtonTop, continueButtonLeading, continueButtonWidthRatio, continueButtonBottom,

            // containerView
            containerViewTop, containerViewLeading, containerViewWidth, viewSafeAreaBottom, viewSafeAreaTrailing,

            // scrollView
            scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing
        ])
    }

}
