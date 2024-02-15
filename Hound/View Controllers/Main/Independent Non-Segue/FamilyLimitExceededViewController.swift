//
//  FamilyLimitExceededViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class FamilyLimitExceededViewController: GeneralUIViewController {

    // MARK: - IB
    
    @IBOutlet private weak var pawWithHands: UIImageView!
    
    @IBOutlet private weak var limitedExceededDescriptionLabel: GeneralUILabel!
    
    @IBOutlet private weak var dismissButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var purchaseSubscriptionOrBackButton: GeneralUIButton!
    @IBAction private func didTapPurchaseSubscriptionOrBack(_ sender: Any) {
        // Functionality of this button varies depending on if you are a family member or not
        if UserInformation.isUserFamilyHead {
            StoryboardViewControllerManager.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
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

}
