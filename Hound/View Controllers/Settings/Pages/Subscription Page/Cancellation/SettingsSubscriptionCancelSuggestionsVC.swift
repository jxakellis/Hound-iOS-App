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

final class SettingsSubscriptionCancelSuggestionsVC: ScrollUIViewController, UITextViewDelegate {
    
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

    private let pageHeaderView: PageSheetHeaderView = {
        let view = PageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        
        view.pageHeaderLabel.text = "Sorry to See You Go!"
        view.pageHeaderLabel.textColor = .systemBackground
        
        view.isDescriptionEnabled = true
        view.pageDescriptionLabel.text = "What could we do to improve?"
        view.pageDescriptionLabel.textColor = .systemBackground
        
        view.backButton.tintColor = .systemBackground
        view.backButton.backgroundCircleTintColor = nil
        
        return view
    }()
    
    private lazy var suggestionTextView: GeneralUITextView = {
        let textView = GeneralUITextView(huggingPriority: 320, compressionResistancePriority: 320)
        textView.delegate = self
        
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        
        textView.font = VisualConstant.FontConstant.primaryRegularLabel
        
        textView.borderWidth = 2
        textView.borderColor = .label
        textView.shouldRoundCorners = true
        
        textView.placeholder = "Share any suggestions or issues..."
        
        return textView
    }()
    
    private lazy var continueButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.setTitle("Cancel Subscription", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
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
        view.backgroundColor = .systemBlue
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
            pageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        // suggestionTextView
        NSLayoutConstraint.activate([
            suggestionTextView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.sectionInterVertSpacing),
            suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            suggestionTextView.createHeightMultiplier(ConstraintConstant.Input.textViewHeightMultiplier, relativeToWidthOf: containerView),
            suggestionTextView.createMaxHeight( ConstraintConstant.Input.textViewMaxHeight)
        ])
        
        // continueButton
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: ConstraintConstant.Spacing.sectionInterVertSpacing),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            continueButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: containerView),
            continueButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }
}
