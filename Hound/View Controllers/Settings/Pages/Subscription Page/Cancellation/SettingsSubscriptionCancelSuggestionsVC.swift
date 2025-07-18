//
//  SettingsSubscriptionCancelSuggestionsVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsSubscriptionCancelSuggestionsVCDelegate: AnyObject {
    func didShowManageSubscriptions()
}

final class SettingsSubscriptionCancelSuggestionsVC: HoundScrollViewController, UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't allow new lines; treat as "done"
        guard text != "\n" else {
            self.dismissKeyboard()
            return false
        }
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= ClassConstant.FeedbackConstant.subscriptionCancellationSuggestionCharacterLimit
    }
    
    // MARK: - Elements

    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        
        view.pageHeaderLabel.text = "Sorry to See You Go!"
        view.pageHeaderLabel.textColor = UIColor.systemBackground
        
        view.isDescriptionEnabled = true
        view.pageDescriptionLabel.text = "What could we do to improve?"
        view.pageDescriptionLabel.textColor = UIColor.systemBackground
        
        view.backButton.tintColor = UIColor.systemBackground
        view.backButton.backgroundCircleTintColor = nil
        
        return view
    }()
    
    private lazy var suggestionTextView: HoundTextView = {
        let textView = HoundTextView(huggingPriority: 320, compressionResistancePriority: 320)
        textView.delegate = self
        
        textView.backgroundColor = UIColor.systemBackground
        textView.textColor = UIColor.label
        
        textView.font = VisualConstant.FontConstant.primaryRegularLabel
        
        textView.applyStyle(.labelBorder)
        
        textView.placeholder = "Share any suggestions or issues..."
        
        return textView
    }()
    
    private lazy var continueButton: HoundButton = {
        let button = HoundButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.setTitle("Cancel Subscription", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
        
        let action = UIAction { [weak self] _ in
            guard let self = self else {
                return
            }
            // Only allow if user is a family head
            guard UserInformation.isUserFamilyHead else {
                PresentationManager.enqueueBanner(
                    forTitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionTitle,
                    forSubtitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionSubtitle,
                    forStyle: .danger
                )
                return
            }
            
            SurveyFeedbackRequest.create(
                forErrorAlert: .automaticallyAlertForNone,
                userCancellationReason: self.cancellationReason,
                userCancellationFeedback: self.suggestionTextView.text ?? ""
            ) { _, _ in return }
            
            InAppPurchaseManager.showManageSubscriptions()
            delegate?.didShowManageSubscriptions()
        }
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    
    private weak var delegate: SettingsSubscriptionCancelSuggestionsVCDelegate?
    
    /// The cancellationReason passed from the previous VC
    private var cancellationReason: SubscriptionCancellationReason?
    
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
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsSubscriptionCancelSuggestionsVCDelegate, forCancellationReason: SubscriptionCancellationReason?) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBlue
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
        containerView.addSubview(suggestionTextView)
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
        
        // suggestionTextView
        NSLayoutConstraint.activate([
            suggestionTextView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            suggestionTextView.createHeightMultiplier(ConstraintConstant.Input.textViewHeightMultiplier, relativeToWidthOf: containerView),
            suggestionTextView.createMaxHeight(ConstraintConstant.Input.textViewMaxHeight)
        ])
        
        // continueButton
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            continueButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: containerView),
            continueButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }
}
