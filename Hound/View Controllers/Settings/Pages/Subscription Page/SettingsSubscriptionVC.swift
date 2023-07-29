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

final class SettingsSubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB
    
    @IBOutlet private weak var pawWithHands: UIImageView!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var freeTrialScaledLabel: GeneralUILabel!
    @IBOutlet private weak var freeTrialHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var freeTrialTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var freeTrialBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var redeemButton: UIButton!
    @IBAction private func didTapRedeem(_ sender: Any) {
        InAppPurchaseManager.presentCodeRedemptionSheet()
    }
    
    @IBOutlet private weak var restoreButton: UIButton!
    @IBAction private func didTapRestoreTransactions(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard FamilyInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        restoreButton.isEnabled = false
        PresentationManager.beginFetchingInformationIndictator()
        
        InAppPurchaseManager.restorePurchases { requestWasSuccessful in
            PresentationManager.endFetchingInformationIndictator {
                self.restoreButton.isEnabled = true
                guard requestWasSuccessful else {
                    return
                }
                
                PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.restoreTransactionsTitle, forSubtitle: VisualConstant.BannerTextConstant.restoreTransactionsSubtitle, forStyle: .success)
                
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard FamilyInformation.isUserFamilyHead else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        // If the last selected cell contains a subscription already owned, open the Apple menu to allow a user to edit their current subscription (e.g. cancel)
        // The second case shouldn't happen. The last selected cell shouldn't be nil ever nor should a cell's product
        guard lastSelectedCellIsActiveSubscription == false, let product = lastSelectedCell?.product else {
            InAppPurchaseManager.showManageSubscriptions()
            return
        }
        
        continueButton.isEnabled = false
        
        // Attempt to purchase the selected product
        PresentationManager.beginFetchingInformationIndictator()
        InAppPurchaseManager.purchaseProduct(forProduct: product) { productIdentifier in
            PresentationManager.endFetchingInformationIndictator {
                self.continueButton.isEnabled = true
                
                guard productIdentifier != nil else {
                    // ErrorManager already invoked by purchaseProduct
                    return
                }
                
                PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.purchasedSubscriptionTitle, forSubtitle: VisualConstant.BannerTextConstant.purchasedSubscriptionSubtitle, forStyle: .success)
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    // MARK: - Properties
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var storedLastSelectedCell: SettingsSubscriptionTierTableViewCell?
    
    /// The subscription tier that is currently selected by the user. Theoretically, this shouldn't ever be nil.
    private var lastSelectedCell: SettingsSubscriptionTierTableViewCell? {
        get {
            return storedLastSelectedCell
        }
        set (newLastSelectedCell) {
            storedLastSelectedCell = newLastSelectedCell
            // If the subscription current selected is the same as the one currently bought, make the button say manage to indicate that clicking the button would have them manage their current subscription instead of continuing to buy a new one
            if let attributedText = continueButton.titleLabel?.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.mutableString.setString(lastSelectedCellIsActiveSubscription ? "Manage" : "Continue")
                UIView.performWithoutAnimation {
                    // By default it does an unnecessary, ugly animation. The combination of performWithoutAnimation and layoutIfNeeded prevents this.
                    continueButton.setAttributedTitle(mutableAttributedText, for: .normal)
                    continueButton.layoutIfNeeded()
                }
            }
            
        }
    }
    
    /// Returns true if the productIdentifier of the SKProduct contained by lastSelectedCell is the same as the productId of the activeFamilySubscription
    private var lastSelectedCellIsActiveSubscription: Bool {
        guard let lastSelectedProductId = lastSelectedCell?.product?.productIdentifier else {
            return false
        }
        
        return FamilyInformation.activeFamilySubscription.productId == lastSelectedProductId
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
        
        let keychain = KeychainSwift()
        // if we don't have a value stored, then that means the value is false. A Bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
        let userPurchasedProductFromSubscriptionGroup20965379: Bool = keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
        
        // Depending upon whether or not the user has used their introductory offer, hide/show the label
        // If we hide the label, set all the constraints to 0.0, except for bottom so 5.0 space between "Grow your family with up to six members" and table view.
        freeTrialScaledLabel.isHidden = userPurchasedProductFromSubscriptionGroup20965379
        freeTrialHeightConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : 25.0
        freeTrialTopConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 0.0 : 15.0
        freeTrialBottomConstraint.constant = userPurchasedProductFromSubscriptionGroup20965379 ? 5.0 : -15.0
        if let text = freeTrialScaledLabel.text {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground
            ]
            freeTrialScaledLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        
        restoreButton.isHidden = !FamilyInformation.isUserFamilyHead
        if let text = restoreButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: VisualConstant.FontConstant.underlinedClickableLabel,
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            restoreButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
        
        redeemButton.isHidden = !FamilyInformation.isUserFamilyHead
        if let text = redeemButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: VisualConstant.FontConstant.underlinedClickableLabel,
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            redeemButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .didDismissForSettingsPageViewController, object: self)
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
    func willRefreshAfterTransactionsSyncronizedInBackground() {
        // If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, we don't want to cause any visual indicators that would confuse the user. Instead we just update the information on the server then reload the labels. No fancy animations or error messages if anything fails.
        
        SubscriptionRequest.get(invokeErrorManager: false) { requestWasSuccessful, _ in
            guard requestWasSuccessful else {
                return
            }
            
            self.tableView.reloadData()
        }
    }
    
    /// Fetches updated hound subscription offerings and current account subscription. Then attempts to perform a "SettingsSubscriptionViewController" segue. This ensures the products available for purchase and th active subscription displayed are up to date. IMPORTANT: forViewController must have a "SettingsSubscriptionViewController" segue.
    static func performSegueToSettingsSubscriptionViewController(forViewController viewController: UIViewController) {
        PresentationManager.beginFetchingInformationIndictator()
        
        InAppPurchaseManager.fetchProducts { products  in
            guard products != nil else {
                // If the product request returned nil, meaning there was an error, then end the request indicator early and exit
                PresentationManager.endFetchingInformationIndictator(completionHandler: nil)
                return
            }
            
            // request indictator is still active
            SubscriptionRequest.get(invokeErrorManager: true) { requestWasSuccessful, _ in
                PresentationManager.endFetchingInformationIndictator {
                    guard requestWasSuccessful else {
                        return
                    }
                    
                    viewController.performSegueOnceInWindowHierarchy(segueIdentifier: "SettingsSubscriptionViewController")
                }
                
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
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // This is not 0.0 by default, so leave this code in to set it to 0.0
        return 0.0
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionTierTableViewCell", for: indexPath) as? SettingsSubscriptionTierTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(
            forProduct: InAppPurchaseManager.subscriptionProducts[indexPath.section]
        )
        
        // If we haven't selected a cell, then the SKProduct at index 0 is presumed to be the most important, so we select that one.
        // If we have selected a cell and that
        if lastSelectedCell == nil && indexPath.section == 0 {
            cell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: false)
            lastSelectedCell = cell
        }
        // If we have selected a cell and that cell happens to have the same productIdentifier, that means lastSelectedCell and cell are the same. To ensure that cell is configured to be set as selected and lastSelectedCell is the correct reference, perform those actions again.
        else if let product = lastSelectedCell?.product, product.productIdentifier == InAppPurchaseManager.subscriptionProducts[indexPath.section].productIdentifier {
            cell.setCustomSelectedTableViewCell(forSelected: true, isAnimated: false)
            lastSelectedCell = cell
        }
        
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
