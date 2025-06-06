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

final class SettingsSubscriptionViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsSubscriptionTierTableViewCellDelegate {
    
    // MARK: - SettingsSubscriptionTierTableViewCellSettingsSubscriptionTierTableViewCell

    func didSetCustomIsSelectedToTrue(forCell: SettingsSubscriptionTierTableViewCell) {
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

    // MARK: - IB

    @IBOutlet private weak var pawWithHands: UIImageView!

    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var freeTrialScaledLabel: GeneralUILabel!
    @IBOutlet private weak var freeTrialHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var freeTrialTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var redeemHeightConstaint: NSLayoutConstraint!
    @IBOutlet private weak var redeemBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var redeemButton: UIButton!
    @IBAction private func didTapRedeem(_ sender: Any) {
        InAppPurchaseManager.presentCodeRedemptionSheet()
    }

    @IBOutlet private weak var restoreButton: UIButton!
    @IBAction private func didTapRestoreTransactions(_ sender: Any) {
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

    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard UserInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.notFamilyHeadInvalidPermissionSubtitle, forStyle: .danger)
            return
        }

        // If the last selected cell contains a subscription that is going to be renewed, open the Apple menu to allow a user to edit their current subscription (e.g. cancel). If we attempt to purchase a product that is set to be renewed, we get the 'Youre already subscribed message'
        // The second case shouldn't happen. The last selected cell shouldn't be nil ever nor should a cell's product
        guard FamilyInformation.familyActiveSubscription.autoRenewProductId != lastSelectedCell?.product?.productIdentifier, let product = lastSelectedCell?.product else {
            performSegueOnceInWindowHierarchy(segueIdentifier: "SettingsSubscriptionCancelReasonViewController")
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

    @IBOutlet private weak var subscriptionDisclaimerLabel: GeneralUILabel!
    
    // MARK: - Properties
    
    private static var settingsSubscriptionViewController: SettingsSubscriptionViewController?

    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionTierTableViewCell?
    
    // if we don't have a value stored, then that means the value is false. A Bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
    private var userPurchasedProductFromSubscriptionGroup20965379: Bool {
        let keychain = KeychainSwift()
        return keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        SettingsSubscriptionViewController.settingsSubscriptionViewController = self

        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands

        // Depending upon whether or not the user has used their introductory offer, hide/show the label
        // If we hide the label, set all the constraints to 0.0, except for bottom
        freeTrialScaledLabel.isHidden = userPurchasedProductFromSubscriptionGroup20965379
        freeTrialHeightConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : freeTrialHeightConstraint.constant
        freeTrialTopConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : freeTrialTopConstraint.constant
        
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
        
        // By default the tableView pads a header, even of height 0.0, by about 20.0 points
        self.tableView.sectionHeaderTopPadding = 0.0

        let shouldHideRestoreAndRedeemButtons = !UserInformation.isUserFamilyHead
        restoreButton.isHidden = shouldHideRestoreAndRedeemButtons
        if let text = restoreButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: VisualConstant.FontConstant.underlinedClickableLabel,
                .foregroundColor: UIColor.systemBackground,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            restoreButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }

        redeemButton.isHidden = shouldHideRestoreAndRedeemButtons
        if let text = redeemButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: VisualConstant.FontConstant.underlinedClickableLabel,
                .foregroundColor: UIColor.systemBackground,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            redeemButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
        redeemHeightConstaint.constant = shouldHideRestoreAndRedeemButtons ? 0.0 : redeemHeightConstaint.constant
        redeemBottomConstraint.constant = shouldHideRestoreAndRedeemButtons ? 0.0 : redeemBottomConstraint.constant
        
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
        SettingsSubscriptionViewController.willRefreshIfNeeded()
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
        guard let settingsSubscriptionViewController = SettingsSubscriptionViewController.settingsSubscriptionViewController, settingsSubscriptionViewController.viewIfLoaded?.window != nil else {
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

    // MARK: - Table View Data Source

    // Make each cell its own section, allows us to easily space the cells
    func numberOfSections(in tableView: UITableView) -> Int {
        InAppPurchaseManager.subscriptionProducts.count
    }

    // Make each cell its own section, allows us to easily space the cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set the spacing between sections by configuring the header height
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Make a blank headerView so that there is a header view
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionTierTableViewCell", for: indexPath) as? SettingsSubscriptionTierTableViewCell else {
            return UITableViewCell()
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
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTableViewCell else {
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

}
