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

// TODO VERIFY UI
final class SettingsSubscriptionVC: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionTierTVCDelegate {
    
    // MARK: - SettingsSubscriptionTierTableViewCellSettingsSubscriptionTierTVC
    
    func didSetCustomIsSelectedToTrue(forCell: SettingsSubscriptionTierTVC) {
        lastSelectedCell = forCell
        
        if let attributedText = continueButton.titleLabel?.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let buttonTitle: String = {
                if FamilyInformation.familyActiveSubscription.autoRenewProductId == lastSelectedCell?.product?.productIdentifier {
                    return "Cancel Subscription"
                }
                
                return userPurchasedProductFromSubscriptionGroup20965379 ? "Upgrade" : "Start Free Trial"
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
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)
        
        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    private let tableView: GeneralUITableView = {
        let tableView = GeneralUITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.bouncesZoom = false
        tableView.shouldAutomaticallyAdjustHeight = true
        return tableView
    }()
    
    private let freeTrialHeightConstraintConstant: CGFloat = 25
    private weak var freeTrialHeightConstraint: NSLayoutConstraint!
    private let freeTrialTopConstraintConstant: CGFloat = 10
    private weak var freeTrialTopConstraint: NSLayoutConstraint!
    private let freeTrialScaledLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Start with a 1 week free trial"
        label.textAlignment = .center
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let redeemHeightConstaintConstant: CGFloat = 20
    private weak var redeemHeightConstaint: NSLayoutConstraint!
    private let redeemBottomConstraintConstant: CGFloat = 20
    private weak var redeemBottomConstraint: NSLayoutConstraint!
    private let redeemButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.titleLabel?.font = VisualConstant.FontConstant.primaryRegularLabel
        button.setTitle("Redeem", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    @objc private func didTapRedeem(_ sender: Any) {
        InAppPurchaseManager.presentCodeRedemptionSheet()
    }
    
    private let restoreButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.titleLabel?.font = VisualConstant.FontConstant.primaryRegularLabel
        button.setTitle("Restore", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        return button
    }()
    
    @objc private func didTapRestoreTransactions(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
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
                
                PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.successRestoreTransactionsTitle, forSubtitle: VisualConstant.BannerTextConstant.successRestoreTransactionsSubtitle, forStyle: .success)
                
                // When we reload the tableView, cells are reusable.
                self.lastSelectedCell = nil
                self.tableView.reloadData()
            }
        }
    }
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
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
                
                PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.successPurchasedSubscriptionTitle, forSubtitle: VisualConstant.BannerTextConstant.successPurchasedSubscriptionSubtitle, forStyle: .success)
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    private let subscriptionDisclaimerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Subscriptions can only be purchased by the family head. Cancel anytime."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.alwaysBounceVertical = true
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        
        return view
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Hound+"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 50)
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Grow your family with up to six members"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.textColor = .systemBackground
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBlue
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    // MARK: - Properties
    
    private static var settingsSubscriptionViewController: SettingsSubscriptionVC?
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionTierTVC?
    
    // if we don't have a value stored, then that means the value is false. A Bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
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
        
        tableView.sectionHeaderTopPadding = 15.0
        
        SettingsSubscriptionVC.settingsSubscriptionViewController = self
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
        
        // Depending upon whether or not the user has used their introductory offer, hide/show the label
        // If we hide the label, set all the constraints to 0.0, except for bottom
        freeTrialScaledLabel.isHidden = userPurchasedProductFromSubscriptionGroup20965379
        freeTrialHeightConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : freeTrialHeightConstraintConstant
        freeTrialTopConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : freeTrialTopConstraintConstant
        
        if let precalculatedDynamicFreeTrialText = freeTrialScaledLabel.text {
            
            freeTrialScaledLabel.attributedTextClosure = {
                // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                let message = NSMutableAttributedString(
                    string: precalculatedDynamicFreeTrialText,
                    attributes: [
                        .font: UIFont.italicSystemFont(ofSize: 20),
                        .foregroundColor: UIColor.systemBackground
                    ]
                )
                
                return message
            }
        }
        
        self.tableView.register(SettingsSubscriptionTierTVC.self, forCellReuseIdentifier: SettingsSubscriptionTierTVC.reuseIdentifier)
        // By default the tableView pads a header, even of height 0.0, by about 20.0 points
        self.tableView.sectionHeaderTopPadding = 0.0
        
        let shouldHideRestoreAndRedeemButtons = !UserInformation.isUserFamilyHead
        restoreButton.isHidden = shouldHideRestoreAndRedeemButtons
        if let text = restoreButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: VisualConstant.FontConstant.primaryRegularLabel,
                .foregroundColor: UIColor.systemBackground,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            restoreButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
        
        redeemButton.isHidden = shouldHideRestoreAndRedeemButtons
        if let text = redeemButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: VisualConstant.FontConstant.primaryRegularLabel,
                .foregroundColor: UIColor.systemBackground,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            redeemButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
        redeemHeightConstaint.constant = shouldHideRestoreAndRedeemButtons ? 0.0 : redeemHeightConstaintConstant
        redeemBottomConstraint.constant = shouldHideRestoreAndRedeemButtons ? 0.0 : redeemBottomConstraintConstant
        
        subscriptionDisclaimerLabel.text = "Subscriptions can only be purchased by the family head"
        if let familyHeadFullName = FamilyInformation.familyMembers.first(where: { familyMember in
            return familyMember.isUserFamilyHead
        })?.displayFullName {
            subscriptionDisclaimerLabel.text?.append(" (\(familyHeadFullName))")
        }
        subscriptionDisclaimerLabel.text?.append(". Cancel anytime.")
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        // The manage subscriptions page could have been presented and now has disappeared.
        SettingsSubscriptionVC.willRefreshIfNeeded()
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
    
    // MARK: - Functions
    
    /// If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, call this function. It will refresh the page without any animations that would confuse the user
    static func willRefreshIfNeeded() {
        // If the subscriptions page is loaded and onscreen, then we reload it
        guard let settingsSubscriptionViewController = SettingsSubscriptionVC.settingsSubscriptionViewController, settingsSubscriptionViewController.viewIfLoaded?.window != nil else {
            return
        }
        // If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, we don't want to cause any visual indicators that would confuse the user. Instead we just update the information on the server then reload the labels. No fancy animations or error messages if anything fails.
        
        TransactionsRequest.get(forErrorAlert: .automaticallyAlertForNone) { responseStatus, _ in
            guard responseStatus == .successResponse else {
                return
            }
            
            settingsSubscriptionViewController.tableView.reloadData()
        }
    }
    
    /// In order to present SettingsSubscriptionVC, starts a fetching indicator. Then, performs a both a product and transactions request, to ensure those are both updated. If all of that completes successfully, returns the subscription view controller. Otherwise, automatically displays an error message and returns nil
    static func fetchProductsThenGetViewController(completionHandler: @escaping ((SettingsSubscriptionVC?) -> Void)) {
        let viewController = SettingsSubscriptionVC()
        
        PresentationManager.beginFetchingInformationIndicator()
        
        InAppPurchaseManager.fetchProducts { error  in
            guard error == nil else {
                // If the product request returned nil, meaning there was an error, then end the request indicator early and exit
                PresentationManager.endFetchingInformationIndicator(completionHandler: nil)
                error?.alert()
                completionHandler(nil)
                return
            }

            // request indictator is still active
            TransactionsRequest.get(forErrorAlert: .automaticallyAlertForAll) { responseStatus, houndError in
                PresentationManager.endFetchingInformationIndicator {
                    guard responseStatus == .successResponse else {
                        (error ?? houndError)?.alert()
                        completionHandler(nil)
                        return
                    }
                    
                    completionHandler(viewController)
                }

            }
        }
    }
    
    // MARK: - Table View Data Source
    
    // Make each cell its own section, allows us to easily space the cells
    func numberOfSections(in tableView: UITableView) -> Int {
        InAppPurchaseManager.subscriptionProducts.count
    }
    
    // Make each cell its own section, allows us to easily space the cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSubscriptionTierTVC.reuseIdentifier, for: indexPath) as? SettingsSubscriptionTierTVC else {
            return GeneralUITableViewCell()
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
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTVC else {
            return
        }
        
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
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(continueButton)
        containerView.addSubview(pawWithHands)
        containerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(redeemButton)
        containerView.addSubview(restoreButton)
        containerView.addSubview(freeTrialScaledLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(subscriptionDisclaimerLabel)
        
        redeemButton.addTarget(self, action: #selector(didTapRedeem), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(didTapRestoreTransactions), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // freeTrialScaledLabel
        freeTrialHeightConstraint = freeTrialScaledLabel.heightAnchor.constraint(equalToConstant: freeTrialHeightConstraintConstant)
        freeTrialTopConstraint = freeTrialScaledLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: freeTrialTopConstraintConstant)
        let freeTrialLeading = freeTrialScaledLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let freeTrialTrailing = freeTrialScaledLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // pawWithHands
        let pawWithHandsTop = pawWithHands.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 15)
        let pawWithHandsCenterX = pawWithHands.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let pawWithHandsWidthRatio = pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor)
        let pawWithHandsWidthScreenRatio = pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 3.0 / 10.0)

        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15)
        let headerLabelCenterX = headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)

        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // tableView
        let tableViewTop = tableView.topAnchor.constraint(equalTo: freeTrialScaledLabel.bottomAnchor, constant: 10)
        let tableViewLeading = tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20)
        let tableViewTrailing = tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)

        // continueButton
        let continueButtonTop = continueButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 25)
        let continueButtonLeading = continueButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
        let continueButtonWidthRatio = continueButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view)

        // redeemButton
        redeemHeightConstaint = redeemButton.heightAnchor.constraint(equalToConstant: redeemHeightConstaintConstant)
        let redeemButtonTop = redeemButton.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20)
        let redeemButtonLeading = redeemButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)

        // restoreButton
        let restoreButtonTop = restoreButton.topAnchor.constraint(equalTo: redeemButton.topAnchor)
        let restoreButtonLeading = restoreButton.leadingAnchor.constraint(equalTo: redeemButton.trailingAnchor)
        let restoreButtonWidth = restoreButton.widthAnchor.constraint(equalTo: redeemButton.widthAnchor)
        let restoreButtonHeight = restoreButton.heightAnchor.constraint(equalTo: redeemButton.heightAnchor)

        // subscriptionDisclaimerLabel
        redeemBottomConstraint = subscriptionDisclaimerLabel.topAnchor.constraint(equalTo: redeemButton.bottomAnchor, constant: redeemBottomConstraintConstant)
        let subscriptionDisclaimerLabelLeading = subscriptionDisclaimerLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
        let subscriptionDisclaimerLabelTrailing = subscriptionDisclaimerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        let subscriptionDisclaimerLabelBottom = subscriptionDisclaimerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)

        // backButton
        let backButtonTop = backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10)
        let backButtonLeading = backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let backButtonTrailing = backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        let backButtonWidth = backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor)
        let backButtonWidthRatio = backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50.0 / 414.0)
        let backButtonMinHeight = backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)
        let backButtonMaxHeight = backButton.createMaxHeight( 75)

        // containerView
        let containerViewTop = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let containerViewLeading = containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let containerViewWidth = containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        let viewSafeAreaBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let viewSafeAreaTrailing = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

        // scrollView
        let scrollViewTop = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        let scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let scrollViewLeading = scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let scrollViewTrailing = scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([
            freeTrialTopConstraint, freeTrialHeightConstraint, freeTrialLeading, freeTrialTrailing,

            pawWithHandsTop, pawWithHandsCenterX, pawWithHandsWidthRatio, pawWithHandsWidthScreenRatio,

            headerLabelTop, headerLabelCenterX,

            descriptionLabelTop, descriptionLabelLeading, descriptionLabelTrailing,

            tableViewTop, tableViewLeading, tableViewTrailing,

            continueButtonTop, continueButtonLeading, continueButtonWidthRatio,

            redeemButtonTop, redeemButtonLeading, redeemHeightConstaint,

            restoreButtonTop, restoreButtonLeading, restoreButtonWidth, restoreButtonHeight,

            redeemBottomConstraint, subscriptionDisclaimerLabelLeading, subscriptionDisclaimerLabelTrailing, subscriptionDisclaimerLabelBottom,

            backButtonTop, backButtonLeading, backButtonTrailing, backButtonWidth, backButtonWidthRatio, backButtonMinHeight, backButtonMaxHeight,

            containerViewTop, containerViewLeading, containerViewWidth, viewSafeAreaBottom, viewSafeAreaTrailing,

            scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing
        ])
    }

}
