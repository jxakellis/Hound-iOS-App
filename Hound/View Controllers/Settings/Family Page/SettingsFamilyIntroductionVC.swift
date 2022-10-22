//
//  SettingsFamilyIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsFamilyIntroductionViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var upgradeFamilyWithSubscriptionLabel: ScaledUILabel!
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBAction private func willContinue(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Properties
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let familyActiveSubscription = FamilyInformation.activeFamilySubscription
        
        let spelledOutNumberOfFamilyMembers = formatter.string(from: familyActiveSubscription.numberOfFamilyMembers as NSNumber) ?? ClassConstant.SubscriptionConstant.defaultSubscriptionSpelledOutNumberOfFamilyMembers
        let familyMembersPlurality = familyActiveSubscription.numberOfFamilyMembers == 1
        ? "family member"
        : "family members"
        // "one family member " "two family members "
        let attributedFamilyMembersText = NSAttributedString(string: "\(spelledOutNumberOfFamilyMembers) \(familyMembersPlurality) ", attributes: [.font: VisualConstant.FontConstant.regularLabelEmphaziedTextFont])
        
        let spelledOutNumberOfDogs = formatter.string(from: familyActiveSubscription.numberOfDogs as NSNumber) ?? ClassConstant.SubscriptionConstant.defaultSubscriptionSpelledOutNumberOfDogs
        let dogsPlurality = familyActiveSubscription.numberOfDogs == 1
        ? "dog"
        : "dogs"
        // "one dog. " "two dogs. "
        let attributedDogsText = NSAttributedString(string: "\(spelledOutNumberOfDogs) \(dogsPlurality).\n\n", attributes: [.font: VisualConstant.FontConstant.regularLabelEmphaziedTextFont])
        
        // "Your family is currently limited to "
        let message: NSMutableAttributedString = NSMutableAttributedString(string: "Your family is currently limited to ", attributes: [.font: VisualConstant.FontConstant.regularLabelRegularTextFont])
        // "Your family is currently limited to one family member "
        message.append(attributedFamilyMembersText)
        // "Your family is currently limited to one family member and "
        message.append(NSAttributedString(string: "and ", attributes: [.font: VisualConstant.FontConstant.regularLabelRegularTextFont]))
        // "Your family is currently limited to one family member and two dogs. "
        message.append(attributedDogsText)
        
        // The user can't modify the family subscription if they aren't the family head, so add instructions to tell family head if they are ineligible
        // "Your family is currently limited to one family member and two dogs. If you would like to increase these limits, have your family head visit the Subscriptions page to upgrade your subscription. The first week of any subscription tier is free!"
        message.append(NSAttributedString(
            string:
                "If you would like to increase these limits, \(FamilyInformation.isUserFamilyHead == false ? "have your family head" : "") visit the Subscriptions page to upgrade your family. The first week of any subscription tier is free!",
            attributes: [.font: VisualConstant.FontConstant.regularLabelRegularTextFont]
        ))
        
        upgradeFamilyWithSubscriptionLabel.attributedText = message
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = true
    }
    
}
