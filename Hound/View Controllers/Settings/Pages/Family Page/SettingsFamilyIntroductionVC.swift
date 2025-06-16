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
    
    // MARK: - Elements
    
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 290, compressionResistancePriority: 290)
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let upgradeFamilyTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Family"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let upgradeFamilyDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "No need to go it alone! Grow your Hound family to six members with Hound+. Try it out today with a one week free trial."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let upgradeButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
      
        button.setTitle("Upgrade", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBlue
        
        button.shouldRoundCorners = true
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 300)
        
        imageView.image = UIImage(named: "darkGreenForestWithMountainsFamilyWalkingDog")
        
        return imageView
    }()
    
    private let maybeLaterButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        return button
    }()
    @objc private func didTouchUpInsideUpgrade(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didTouchUpInsideUpgrade()
        }
    }
    
    // MARK: - Properties
    
    private weak var delegate: SettingsFamilyIntroductionViewControllerDelegate?
    
    // If true, the user has purchased a product from subscription group 20965379 and used their introductory offer. Otherwise, they have not.
    private var userPurchasedProductFromSubscriptionGroup20965379: Bool {
        let keychain = KeychainSwift()
        return keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
    }
    
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
        
        upgradeButton.setTitle(self.userPurchasedProductFromSubscriptionGroup20965379 ? "Upgrade" : "Start Free Trial", for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = true
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsFamilyIntroductionViewControllerDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(backgroundImageView)
        view.addSubview(whiteBackgroundView)
        view.addSubview(upgradeFamilyTitleLabel)
        view.addSubview(upgradeFamilyDescriptionLabel)
        view.addSubview(upgradeButton)
        view.addSubview(maybeLaterButton)
        
        upgradeButton.addTarget(self, action: #selector(didTouchUpInsideUpgrade), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // backgroundImageView
        let backgroundTop = backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor)
        let backgroundLeading = backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let backgroundTrailing = backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let backgroundWidth = backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor)

        // whiteBackgroundView
        let whiteBackgroundTop = whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25)
        let whiteBackgroundBottom = whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let whiteBackgroundLeading = whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let whiteBackgroundTrailing = whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        // upgradeFamilyTitleLabel
        let titleTop = upgradeFamilyTitleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25)
        let titleLeading = upgradeFamilyTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        let titleTrailing = upgradeFamilyTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let titleHeight = upgradeFamilyTitleLabel.heightAnchor.constraint(equalToConstant: 30)

        // upgradeFamilyDescriptionLabel
        let descriptionTop = upgradeFamilyDescriptionLabel.topAnchor.constraint(equalTo: upgradeFamilyTitleLabel.bottomAnchor, constant: 15)
        let descriptionLeading = upgradeFamilyDescriptionLabel.leadingAnchor.constraint(equalTo: upgradeFamilyTitleLabel.leadingAnchor)
        let descriptionTrailing = upgradeFamilyDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)

        // upgradeButton
        let upgradeTop = upgradeButton.topAnchor.constraint(equalTo: upgradeFamilyDescriptionLabel.bottomAnchor, constant: 15)
        let upgradeLeading = upgradeButton.leadingAnchor.constraint(equalTo: upgradeFamilyTitleLabel.leadingAnchor)
        let upgradeTrailing = upgradeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let upgradeWidthRatio = upgradeButton.widthAnchor.constraint(equalTo: upgradeButton.heightAnchor, multiplier: 1 / 0.16)

        // maybeLaterButton
        let maybeLaterTop = maybeLaterButton.topAnchor.constraint(equalTo: upgradeButton.bottomAnchor, constant: 45)
        let maybeLaterBottom = maybeLaterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        let maybeLaterLeading = maybeLaterButton.leadingAnchor.constraint(equalTo: upgradeFamilyTitleLabel.leadingAnchor)
        let maybeLaterTrailing = maybeLaterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let maybeLaterWidthRatio = maybeLaterButton.widthAnchor.constraint(equalTo: maybeLaterButton.heightAnchor, multiplier: 1 / 0.16)
        let maybeLaterHeight = maybeLaterButton.heightAnchor.constraint(equalTo: upgradeButton.heightAnchor)

        NSLayoutConstraint.activate([
            backgroundTop, backgroundLeading, backgroundTrailing, backgroundWidth,
            whiteBackgroundTop, whiteBackgroundBottom, whiteBackgroundLeading, whiteBackgroundTrailing,
            titleTop, titleLeading, titleTrailing, titleHeight,
            descriptionTop, descriptionLeading, descriptionTrailing,
            upgradeTop, upgradeLeading, upgradeTrailing, upgradeWidthRatio,
            maybeLaterTop, maybeLaterBottom, maybeLaterLeading, maybeLaterTrailing, maybeLaterWidthRatio, maybeLaterHeight
        ])
    }

}
