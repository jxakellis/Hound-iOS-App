//
//  FamilyLimitExceededViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class FamilyLimitExceededViewController: GeneralUIViewController {

    // MARK: - Elements
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 790)

        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    private let limitedExceededDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Your family is exceeding it's x person limit and is unable to have data added or updated. To restore functionality, please have the family head remove x family members or upgrade your subscription."
        label.contentMode = .left
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    private let dismissButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        button.isPointerInteractionEnabled = true
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundUIButtonTintColor = .systemBlue
        button.shouldScaleImagePointSize = true
        button.shouldDismissParentViewController = true
        return button
    }()

    private let purchaseSubscriptionOrBackButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Upgrade Subscription", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
       
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Family Member Limit Exceeded"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    @objc private func didTapPurchaseSubscriptionOrBack(_ sender: Any) {
        // Functionality of this button varies depending on if you are a family member or not
        if UserInformation.isUserFamilyHead {
            StoryboardViewControllerManager.SettingsViewControllers.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
                guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                    // Error message automatically handled
                    return
                }
                
                PresentationManager.enqueueViewController(settingsSubscriptionViewController)
            }
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Properties
    
    /// By how many family members the family is exceeding its family member limit
    private var numberOfExceededFamilyMembers: Int {
        return FamilyInformation.familyMembers.count - FamilyInformation.familyActiveSubscription.numberOfFamilyMembers
    }
    
    /// Inside viewIsAppearing, if the family isn't exceeding its family member limit, then we will automatically dismiss the view. This helps track an edge case where the view may be dismissed on its first appearance when the user's local active family subscription is outdated
    private var isFirstTimeAppearing: Bool = true
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        if UserInformation.isUserFamilyHead {
            // We make the primary button allow the family head to purchase a subscription and enable a secondary button to allow them to dismiss
            purchaseSubscriptionOrBackButton.setTitle("Upgrade Subscription", for: .normal)
            dismissButton.isHidden = false
        }
        else {
            // We make the primary button the dismiss button for non family members
            purchaseSubscriptionOrBackButton.setTitle("Back", for: .normal)
            dismissButton.isHidden = true
        }
        
        limitedExceededDescriptionLabel.text = {
            return ErrorConstant.FamilyResponseError.limitFamilyMemberExceeded(forRequestId: -1, forResponseId: -1).description
        }()
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard isFirstTimeAppearing == false else {
            isFirstTimeAppearing = false
            return
        }
        
        // If this isn't the views first time appearing, that means this view was presented, then likely another view appeared on top (e.g. the screen to buy a new subscription). Therefore, its possible the user bought a new subscription which would solve the issue of why this view controller was presented
        
        // Check if the user's family is in compliance now
        if numberOfExceededFamilyMembers <= 0 {
            self.dismiss(animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands
        }
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        view.addSubview(pawWithHands)
        view.addSubview(headerLabel)
        view.addSubview(limitedExceededDescriptionLabel)
        view.addSubview(purchaseSubscriptionOrBackButton)
        view.addSubview(dismissButton)
        
        purchaseSubscriptionOrBackButton.addTarget(self, action: #selector(didTapPurchaseSubscriptionOrBack), for: .touchUpInside)
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor, multiplier: 1 / 1),
            pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 4 / 10),
        
            purchaseSubscriptionOrBackButton.topAnchor.constraint(equalTo: limitedExceededDescriptionLabel.bottomAnchor, constant: 35),
            purchaseSubscriptionOrBackButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            purchaseSubscriptionOrBackButton.widthAnchor.constraint(equalTo: purchaseSubscriptionOrBackButton.heightAnchor, multiplier: 1 / 0.16),
        
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            dismissButton.widthAnchor.constraint(equalTo: dismissButton.heightAnchor, multiplier: 1 / 1),
            dismissButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 50 / 414),
            dismissButton.heightAnchor.constraint(equalToConstant: 75),
            dismissButton.heightAnchor.constraint(equalToConstant: 25),
        
            limitedExceededDescriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            limitedExceededDescriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
        
            headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            headerLabel.trailingAnchor.constraint(equalTo: limitedExceededDescriptionLabel.trailingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: purchaseSubscriptionOrBackButton.trailingAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        ])
        
    }
}
