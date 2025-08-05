//
//  LimitExceededViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LimitExceededViewController: BluePawVC {

    // MARK: - Elements
    
    private let upgradeSubscriptionOrBackButton: HoundButton = {
        let button = HoundButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.setTitle("Upgrade Subscription", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
       
        return button
    }()
    
    @objc private func didTapPurchaseSubscriptionOrBack(_ sender: Any) {
        // Functionality of this button varies depending on if you are a family member or not
        if UserInformation.isUserFamilyHead {
            SettingsSubscriptionVC.fetchProductsThenGetViewController { vc in
                guard let vc = vc else {
                    // Error message automatically handled
                    return
                }
                
                PresentationManager.enqueueViewController(vc)
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
        
        headerLabel.text = "Family Member Limit Exceeded"
        
        if UserInformation.isUserFamilyHead {
            // We make the primary button allow the family head to purchase a subscription and enable a secondary button to allow them to dismiss
            upgradeSubscriptionOrBackButton.setTitle("Upgrade Subscription", for: .normal)
            backButton.isHidden = false
        }
        else {
            // We make the primary button the dismiss button for non family members
            upgradeSubscriptionOrBackButton.setTitle("Back", for: .normal)
            backButton.isHidden = true
        }
        
        descriptionLabel.text = {
            return Constant.Error.FamilyResponseError.limitFamilyMemberExceeded(requestId: -1, responseId: -1).description
        }()
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

    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(upgradeSubscriptionOrBackButton)
        
        upgradeSubscriptionOrBackButton.addTarget(self, action: #selector(didTapPurchaseSubscriptionOrBack), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // upgradeSubscriptionOrBackButton
        NSLayoutConstraint.activate([
            upgradeSubscriptionOrBackButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35),
            upgradeSubscriptionOrBackButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upgradeSubscriptionOrBackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upgradeSubscriptionOrBackButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: contentView),
            upgradeSubscriptionOrBackButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
    }
}
