//
//  FamilyUpgradeIntroductionVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import UIKit

protocol FamilyUpgradeIntroductionVCDelegate: AnyObject {
    func didTouchUpInsideUpgrade()
}

final class FamilyUpgradeIntroductionVC: HoundViewController {

    // MARK: - Elements

    private let introductionView = HoundIntroductionView()

    private lazy var upgradeButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)
        button.setTitle(self.userPurchasedProductFromSubscriptionGroup20965379 ? "Upgrade" : "Start Free Trial", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = Constant.VisualFont.wideButton
        button.backgroundColor = UIColor.systemBlue
        button.shouldRoundCorners = true
        button.addTarget(self, action: #selector(didTouchUpInsideUpgrade), for: .touchUpInside)
        return button
    }()

    private lazy var maybeLaterButton: HoundButton = {
        let button = HoundButton(huggingPriority: 260, compressionResistancePriority: 260)
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.VisualFont.wideButton
        button.backgroundColor = UIColor.systemBackground
        button.applyStyle(.labelBorder)
        button.shouldDismissParentViewController = true
        return button
    }()

    /// Stack view containing both buttons
    private var buttonStack: UIStackView!

    // MARK: - Properties

    private weak var delegate: FamilyUpgradeIntroductionVCDelegate?

    private var userPurchasedProductFromSubscriptionGroup20965379: Bool {
        KeychainSwift().getBool(Constant.Key.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
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
                    .font: Constant.VisualFont.primaryRegularLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ])

            message.append(NSAttributedString(
                string: "six members",
                attributes: [
                    .font: Constant.VisualFont.emphasizedPrimaryRegularLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ]))

            message.append(NSAttributedString(
                string: " with Hound+. ",
                attributes: [
                    .font: Constant.VisualFont.primaryRegularLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ]))

            if self.userPurchasedProductFromSubscriptionGroup20965379 == false {
                message.append(NSAttributedString(
                    string: "Try it out today with a one week free trial.",
                    attributes: [
                        .font: Constant.VisualFont.primaryRegularLabel,
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

    func setup(forDelegate: FamilyUpgradeIntroductionVCDelegate) {
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
        view.backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(introductionView)

        buttonStack = UIStackView(arrangedSubviews: [upgradeButton, maybeLaterButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = Constant.Constraint.Spacing.contentSectionVert
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

            upgradeButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            upgradeButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight),

            maybeLaterButton.heightAnchor.constraint(equalTo: upgradeButton.heightAnchor)
        ])
    }
}
