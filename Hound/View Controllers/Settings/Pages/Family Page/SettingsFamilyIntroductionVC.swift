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

final class SettingsFamilyIntroductionViewController: GeneralUIViewController {

    // MARK: - IB

    @IBOutlet private weak var whiteBackgroundView: UIView!

    @IBOutlet private weak var upgradeFamilyTitleLabel: GeneralUILabel!
    @IBOutlet private weak var upgradeFamilyDescriptionLabel: GeneralUILabel!

    @IBOutlet private weak var updateButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideUpgrade(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.didTouchUpInsideUpgrade()
        }
    }

    // MARK: - Properties

    weak var delegate: SettingsFamilyIntroductionViewControllerDelegate!
    
    // If true, the user has purchased a product from subscription group 20965379 and used their introductory offer. Otherwise, they have not.
    private var userPurchasedProductFromSubscriptionGroup20965379: Bool {
        let keychain = KeychainSwift()
        return keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous

        upgradeFamilyDescriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
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

            if self.userPurchasedProductFromSubscriptionGroup20965379 == false {
                message.append(NSAttributedString(
                    string: "Try it out today with a one week free trial.",
                    attributes: [
                        .font: VisualConstant.FontConstant.secondaryLabelColorFeaturePromotionLabel,
                        .foregroundColor: UIColor.secondaryLabel
                    ])
                )
            }

            return message
        }

        updateButton.setTitle(self.userPurchasedProductFromSubscriptionGroup20965379 ? "Upgrade" : "Start Free Trial", for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = true
    }

}
