//
//  SettingsSubscriptionsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import StoreKit
import UIKit

final class SettingsSubscriptionVC: HoundScrollViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionTierTVCDelegate {
    
    // MARK: - SettingsSubscriptionTierTableViewCellSettingsSubscriptionTierTVC
    
    func didSetCustomIsSelectedToTrue(forCell: SettingsSubscriptionTierTVC) {
        lastSelectedCell = forCell
        
        if let attributedText = continueButton.titleLabel?.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let buttonTitle: String = {
                if FamilyInformation.familyActiveSubscription.autoRenewProductId == lastSelectedCell?.product?.productIdentifier {
                    return "Cancel Subscription"
                }
                
                return SettingsSubscriptionVC.userPurchasedProductFrom20965379 ? "Upgrade" : "Start Free Trial"
            }()
            mutableAttributedText.mutableString.setString(buttonTitle)
            UIView.performWithoutAnimation {
                // By default it does an unnecessary, ugly animation. The combination of performWithoutAnimation and layoutIfNeeded prevents this.
                continueButton.setAttributedTitle(mutableAttributedText, for: .normal)
                continueButton.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Elements
    
    private let houndPaw: HoundPawImageView = {
        let imageView = HoundPawImageView(huggingPriority: 290, compressionResistancePriority: 290)
        
        return imageView
    }()
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Hound+"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 47.5, weight: .bold)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Grow your family with up to six members"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        label.textColor = UIColor.secondarySystemBackground
        return label
    }()
    
    private let backButton: HoundButton = {
        let button = HoundButton()
        
        button.tintColor = UIColor.systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBlue
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private lazy var tableView: HoundTableView = {
        let tableView = HoundTableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.emptyStateEnabled = true
        tableView.emptyStateMessage = "No subscriptions available..."
        tableView.emptyStateMessageColor = .systemBackground
        
        // allow the save x% label for a TVC to go outside cell bound
        tableView.clipsToBounds = false
        
        return tableView
    }()
    
    private let freeTrialScaledLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.textColor = UIColor.systemBackground
        
        label.isHidden = userPurchasedProductFrom20965379
        
        label.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message = NSMutableAttributedString(
                string: "Start with a 1 week free trial",
                attributes: [
                    .font: UIFont.italicSystemFont(ofSize: Constant.Visual.Font.primaryRegularLabel.pointSize),
                    .foregroundColor: UIColor.systemBackground
                ]
            )
            
            return message
        }
        
        return label
    }()
    
    private lazy var continueButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
        
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var redeemButton: HoundButton = {
        let button = HoundButton()
        
        button.isHidden = !UserInformation.isUserFamilyHead
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constant.Visual.Font.primaryRegularLabel,
            .foregroundColor: UIColor.systemBackground,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "Redeem", attributes: attributes), for: .normal)
        
        button.addTarget(self, action: #selector(didTapRedeem), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var restoreButton: HoundButton = {
        let button = HoundButton()
        
        button.isHidden = !UserInformation.isUserFamilyHead
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constant.Visual.Font.primaryRegularLabel,
            .foregroundColor: UIColor.systemBackground,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "Restore", attributes: attributes), for: .normal)
        
        button.addTarget(self, action: #selector(didTapRestoreTransactions), for: .touchUpInside)
       
        return button
    }()
    
    private lazy var redeemRestoreButtonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [redeemButton, restoreButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = Constant.Constraint.Spacing.contentIntraHori
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let subscriptionDisclaimerLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondarySystemBackground
        
        label.text = "Subscriptions can only be purchased by the family head"
        if let familyHeadFullName = FamilyInformation.familyMembers.first(where: { familyMember in
            return familyMember.isUserFamilyHead
        })?.displayFullName {
            label.text?.append(" (\(familyHeadFullName))")
        }
        label.text?.append(". Cancel anytime.")
        
        return label
    }()
    
    @objc private func didTapRedeem(_ sender: Any) {
        InAppPurchaseManager.presentCodeRedemptionSheet()
    }
    
    @objc private func didTapRestoreTransactions(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.notFamilyHeadInvalidPermissionTitle, forSubtitle: Constant.Visual.BannerText.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
            return
        }
        
        restoreButton.isEnabled = false
        PresentationManager.beginFetchingInformationIndicator()
        
        InAppPurchaseManager.restorePurchases { requestWasSuccessful in
            PresentationManager.endFetchingInformationIndicator {
                self.restoreButton.isEnabled = true
                guard requestWasSuccessful else {
                    return
                }
                
                PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.successRestoreTransactionsTitle, forSubtitle: Constant.Visual.BannerText.successRestoreTransactionsSubtitle, forStyle: .success)
                
                // When we reload the tableView, cells are reusable.
                self.lastSelectedCell = nil
                UIView.transition(with: self.tableView, duration: Constant.Visual.Animation.moveMultipleElements, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    @objc private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.notFamilyHeadInvalidPermissionTitle, forSubtitle: Constant.Visual.BannerText.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
            return
        }
        
        // If the last selected cell contains a subscription that is going to be renewed, open the Apple menu to allow a user to edit their current subscription (e.g. cancel). If we attempt to purchase a product that is set to be renewed, we get the 'Youre already subscribed message'
        // The second case shouldn't happen. The last selected cell shouldn't be nil ever nor should a cell's product
        guard FamilyInformation.familyActiveSubscription.autoRenewProductId != lastSelectedCell?.product?.productIdentifier, let product = lastSelectedCell?.product else {
            PresentationManager.enqueueViewController(SettingsSubscriptionCancelReasonVC())
            return
        }
        
        continueButton.isEnabled = false
        
        // Attempt to purchase the selected product
        PresentationManager.beginFetchingInformationIndicator()
        InAppPurchaseManager.purchaseProduct(forProduct: product) { productIdentifier in
            PresentationManager.endFetchingInformationIndicator {
                self.continueButton.isEnabled = true
                
                guard productIdentifier != nil else {
                    // ErrorManager already invoked by purchaseProduct
                    return
                }
                
                PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.successPurchasedSubscriptionTitle, forSubtitle: Constant.Visual.BannerText.successPurchasedSubscriptionSubtitle, forStyle: .success)
                
                UIView.transition(with: self.tableView, duration: Constant.Visual.Animation.moveMultipleElements, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
    // MARK: - Properties
    
    private static var settingsSubscriptionViewController: SettingsSubscriptionVC?
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionTierTVC?
    
    // if we don't have a value stored, then that means the value is false. A Bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
    private static var userPurchasedProductFrom20965379: Bool {
        let keychain = KeychainSwift()
        return keychain.getBool(Constant.Key.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
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
        
        SettingsSubscriptionVC.settingsSubscriptionViewController = self
        
        self.tableView.register(SettingsSubscriptionTierTVC.self, forCellReuseIdentifier: SettingsSubscriptionTierTVC.reuseIdentifier)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        // The manage subscriptions page could have been presented and now has disappeared.
        SettingsSubscriptionVC.willRefreshIfNeeded()
    }
    
    // MARK: - Functions
    
    /// If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, call this function. It will refresh the page without any animations that would confuse the user
    static func willRefreshIfNeeded() {
        // If the subscriptions page is loaded and onscreen, then we reload it
        guard let settingsSubscriptionViewController = SettingsSubscriptionVC.settingsSubscriptionViewController, settingsSubscriptionViewController.viewIfLoaded?.window != nil else { return }
        // If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, we don't want to cause any visual indicators that would confuse the user. Instead we just update the information on the server then reload the labels. No fancy animations or error messages if anything fails.
        
        TransactionsRequest.get(forErrorAlert: .automaticallyAlertForNone) { responseStatus, _ in
            guard responseStatus == .successResponse else {
                return
            }
            
            // this is a background refresh so no animations
            settingsSubscriptionViewController.tableView.reloadData()
        }
    }
    
    /// In order to present SettingsSubscriptionVC, starts a fetching indicator. Then, performs a both a product and transactions request, to ensure those are both updated. If all of that completes successfully, returns the subscription view controller. Otherwise, automatically displays an error message and returns nil
    static func fetchProductsThenGetViewController(completionHandler: @escaping ((SettingsSubscriptionVC?) -> Void)) {
        let viewController = SettingsSubscriptionVC()
        
        PresentationManager.beginFetchingInformationIndicator()
        
        TransactionsRequest.get(forErrorAlert: .automaticallyAlertForAll) { responseStatus, houndError in
            PresentationManager.endFetchingInformationIndicator {
                guard responseStatus == .successResponse else {
                    houndError?.alert()
                    completionHandler(nil)
                    return
                }
                
                completionHandler(viewController)
            }

        }
    }
    
    // MARK: - Table View Data Source
    
    // Make each cell its own section, allows us to easily space the cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return InAppPurchaseManager.subscriptionProducts.count
    }
    
    // Make each cell its own section, allows us to easily space the cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Only add spacing if NOT the last section
        let lastSection = InAppPurchaseManager.subscriptionProducts.count - 1
        return section == lastSection ? 0 : Constant.Constraint.Spacing.contentTallIntraVert
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Only return a view if not the last section
        let lastSection = InAppPurchaseManager.subscriptionProducts.count - 1
        if section == lastSection {
            return nil
        }
        
        let footer = HoundHeaderFooterView()
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSubscriptionTierTVC.reuseIdentifier, for: indexPath) as? SettingsSubscriptionTierTVC else {
            return HoundTableViewCell()
        }
        
        if lastSelectedCell == cell {
            // cell has been used before and lastSelectedCell is a reference to this cell. However, this cell could be changing to a different SKProduct in setup, so that would invaliate lastSelectedCell. Therefore, clear lastSelectedCell
            lastSelectedCell = nil
        }
        
        // If true, then one of the cells we are going to display is an active subscription, meaning its already been purchased.
        let renewingSubscriptionIsPartOfSubscriptionProducts = InAppPurchaseManager.subscriptionProducts.first { product in
            FamilyInformation.familyActiveSubscription.autoRenewProductId == product.productIdentifier
        } != nil
        
        let cellProduct: SKProduct = InAppPurchaseManager.subscriptionProducts[indexPath.section]
        let cellIsCustomSelected: Bool = {
            // We do not want to override the lastSelectedCell as this function could be called after a user selceted a cell manually by themselves
            guard lastSelectedCell == nil else {
                return lastSelectedCell?.product?.productIdentifier == cellProduct.productIdentifier
            }
            
            if renewingSubscriptionIsPartOfSubscriptionProducts {
                // One of the cells are we going to display is the active subscription, and this cell is that active subscription cell
                return cellProduct.productIdentifier == FamilyInformation.familyActiveSubscription.autoRenewProductId
            }
            else {
                // None of the cells are we going to display are the active subscription, SKProduct at index 0 is presumed to be the most important, so we select that one.
                return indexPath.section == 0
            }
        }()
        
        // We can only have one cell selected at once, therefore clear lastSelectedCell's selection state
        if cellIsCustomSelected == true {
            lastSelectedCell?.setCustomSelectedTableViewCell(forSelected: false, isAnimated: false)
        }
        
        cell.setup(forDelegate: self, forProduct: cellProduct, forIsCustomSelected: cellIsCustomSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Let a user select cells even if they don't have the permission to as a non-family head.
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTVC else { return }
        
        // Check if lastSelectedCell and selectedCells are actually different cells
        if let lastSelectedCell = lastSelectedCell, lastSelectedCell != selectedCell {
            // If they are different cells, then that must mean a new cell is being selected to transition into the selected state. Unselect the old cell and select the new one
            lastSelectedCell.setCustomSelectedTableViewCell(forSelected: false, isAnimated: true)
            selectedCell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: true)
        }
        // We are selecting the same cell as last time. However, a cell always needs to be selected. Therefore, we cannot deselect the current cell as that would mean we would have no cell selected at all, so always select.
        else {
            selectedCell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: true)
        }
        
        lastSelectedCell = selectedCell
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(tableView)
        containerView.addSubview(continueButton)
        containerView.addSubview(houndPaw)
        containerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(freeTrialScaledLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(subscriptionDisclaimerLabel)
        containerView.addSubview(redeemRestoreButtonStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: backButton.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori)
        ])

        // pawWithHands
        NSLayoutConstraint.activate([
            houndPaw.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            houndPaw.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            houndPaw.createHeightMultiplier(Constant.Constraint.Text.pawHeightMultiplier, relativeToWidthOf: view),
            houndPaw.createMaxHeight(Constant.Constraint.Text.pawMaxHeight),
            houndPaw.createSquareAspectRatio()
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: houndPaw.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])

        // freeTrialScaledLabel
        if freeTrialScaledLabel.isHidden {
            // If the user has purchased a product from subscription group 20965379, then we don't show the free trial label
            NSLayoutConstraint.activate([
                freeTrialScaledLabel.heightAnchor.constraint(equalToConstant: 0),
                freeTrialScaledLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0),
                freeTrialScaledLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
                freeTrialScaledLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                freeTrialScaledLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
                freeTrialScaledLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
                freeTrialScaledLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
            ])
        }

        // tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: freeTrialScaledLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])

        // continueButton
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            continueButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: view),
            continueButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
        
        // redeemRestoreButtonStack
        if restoreButton.isHidden && redeemButton.isHidden {
            NSLayoutConstraint.activate([
                redeemRestoreButtonStack.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 0),
                redeemRestoreButtonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
                redeemRestoreButtonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                redeemRestoreButtonStack.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
                redeemRestoreButtonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
                redeemRestoreButtonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
            ])
        }

        // subscriptionDisclaimerLabel
        NSLayoutConstraint.activate([
            subscriptionDisclaimerLabel.topAnchor.constraint(equalTo: redeemRestoreButtonStack.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            subscriptionDisclaimerLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            subscriptionDisclaimerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            subscriptionDisclaimerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }

}
