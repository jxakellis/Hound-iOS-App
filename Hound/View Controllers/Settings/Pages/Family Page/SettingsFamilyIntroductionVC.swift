//
//  SettingsFamilyIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import UIKit

protocol SettingsFamilyIntroductionViewControllerDelegate: AnyObject {
    func didTouchUpInsideUpgrade()
}

class SettingsFamilyIntroductionViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var whiteBackgroundView: UIView!
    
    @IBOutlet private weak var upgradeFamilyTitleLabel: ScaledUILabel!
    @IBOutlet private weak var upgradeFamilyDescriptionLabel: ScaledUILabel!
    
    @IBAction private func didTouchUpInsideUpgrade(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.didTouchUpInsideUpgrade()
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: SettingsFamilyIntroductionViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.masksToBounds = true
        whiteBackgroundView.layer.cornerCurve = .continuous
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        // No need to go it alone! Grow your Hound family to six members with Hound+. Try it out today with a one week free trial.
        
        let keychain = KeychainSwift()
        // If true, the user has purchased a product from subscription group 20965379 and used their introductory offer. Otherwise, they have not.
        let userPurchasedProductFromSubscriptionGroup20965379: Bool = keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
        
        let message: NSMutableAttributedString = NSMutableAttributedString(
            string: "No need to go it alone! Grow your Hound family to ",
            attributes: [
                .font: VisualConstant.FontConstant.secondaryLabelColorFeaturePromotionLabel,
                .foregroundColor: UIColor.secondaryLabel
            ])
        
        message.append(NSAttributedString(
            string: "six members",
            attributes: [
                .font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeaturePromotionLabel,
                .foregroundColor: UIColor.secondaryLabel
            ])
        )
        
        message.append(NSAttributedString(
            string: " with Hound+. ",
            attributes: [
                .font: VisualConstant.FontConstant.secondaryLabelColorFeaturePromotionLabel,
                .foregroundColor: UIColor.secondaryLabel
            ])
        )
        
        if userPurchasedProductFromSubscriptionGroup20965379 == false {
            message.append(NSAttributedString(
                string: "Try it out today with a one week free trial.",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeaturePromotionLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ])
            )
        }
        
        upgradeFamilyDescriptionLabel.attributedText = message
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = true
    }
    
}
