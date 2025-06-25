//
//  FamilyUpgradeIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import UIKit

protocol FamilyUpgradeIntroductionViewControllerDelegate: AnyObject {
    func didTouchUpInsideUpgrade()
}

// UI VERIFIED
final class FamilyUpgradeIntroductionViewController: GeneralUIViewController {

    // MARK: - Elements

    private let introductionView = IntroductionView()

    private lazy var upgradeButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)
        button.setTitle(self.userPurchasedProductFromSubscriptionGroup20965379 ? "Upgrade" : "Start Free Trial", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        button.backgroundColor = .systemBlue
        button.shouldRoundCorners = true
        button.addTarget(self, action: #selector(didTouchUpInsideUpgrade), for: .touchUpInside)
        return button
    }()

    private lazy var maybeLaterButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        button.backgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()

    /// Stack view containing both buttons
    private var buttonStack: UIStackView!

    // MARK: - Properties

    private weak var delegate: FamilyUpgradeIntroductionViewControllerDelegate?

    private var userPurchasedProductFromSubscriptionGroup20965379: Bool {
        KeychainSwift().getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
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

        introductionView.backgroundImageView.image = UIImage(named: "darkGreenForestWithMountainsFamilyWalkingDog")
        introductionView.pageHeaderLabel.text = "Family"

        introductionView.pageDescriptionLabel.attributedTextClosure = {
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "No need to go it alone! Grow your Hound family to ",
                attributes: [
                    .font: VisualConstant.FontConstant.regularLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ])

            message.append(NSAttributedString(
                string: "six members",
                attributes: [
                    .font: UIFont.systemFont(ofSize: VisualConstant.FontConstant.regularLabel.pointSize, weight: .bold),
                    .foregroundColor: UIColor.secondaryLabel
                ]))

            message.append(NSAttributedString(
                string: " with Hound+. ",
                attributes: [
                    .font: VisualConstant.FontConstant.regularLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ]))

            if self.userPurchasedProductFromSubscriptionGroup20965379 == false {
                message.append(NSAttributedString(
                    string: "Try it out today with a one week free trial.",
                    attributes: [
                        .font: VisualConstant.FontConstant.regularLabel,
                        .foregroundColor: UIColor.secondaryLabel
                    ]))
            }

            return message
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController = true
    }

    // MARK: - Setup

    func setup(forDelegate: FamilyUpgradeIntroductionViewControllerDelegate) {
        self.delegate = forDelegate
    }

    // MARK: - Functions

    @objc private func didTouchUpInsideUpgrade(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didTouchUpInsideUpgrade()
        }
    }

    // MARK: - Setup Elements

    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(introductionView)

        buttonStack = UIStackView(arrangedSubviews: [upgradeButton, maybeLaterButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = ConstraintConstant.Section.interSectionVertSpacing
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        introductionView.contentView.addSubview(buttonStack)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            introductionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            introductionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            introductionView.topAnchor.constraint(equalTo: view.topAnchor),
            introductionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: introductionView.contentView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: introductionView.contentView.trailingAnchor),

            upgradeButton.heightAnchor.constraint(equalTo: upgradeButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            upgradeButton.heightAnchor.constraint(lessThanOrEqualToConstant: ConstraintConstant.Button.screenWideMaxHeight),

            maybeLaterButton.heightAnchor.constraint(equalTo: upgradeButton.heightAnchor)
        ])
    }
}
