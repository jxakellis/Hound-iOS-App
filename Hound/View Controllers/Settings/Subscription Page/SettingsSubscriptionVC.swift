//
//  SettingsSubscriptionsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

final class SettingsSubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var dismissButton: ScaledImageUIButton!
    @IBAction private func willDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet private weak var redeemButton: UIButton!
    @IBAction private func didTapRedeem(_ sender: Any) {
        InAppPurchaseManager.presentCodeRedemptionSheet()
    }
    
    // TO DO NOW add expiration date for current subscription,
    /*
     guard let expirationDate = FamilyInformation.activeFamilySubscription.expirationDate else {
     return "Never Expires"
     }
     let dateFormatter = DateFormatter()
     dateFormatter.locale = Calendar.localCalendar.locale
     // Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32 PM PST”.
     dateFormatter.dateStyle = .long
     // Specifies no style.
     dateFormatter.timeStyle = .none
     
     return "Expires on \(dateFormatter.string(from: expirationDate))"
     */
    
    /* TO DO NOW if the user is eligible for intro offer, then display text for it
     
     let keychain = KeychainSwift()
     // if we don't have a value stored, then that means the value is false. A Bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
     let userPurchasedProductFromSubscriptionGroup20965379: Bool = keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
     */
    @IBOutlet private weak var restoreButton: UIButton!
    @IBAction private func didTapRestoreTransactions(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard FamilyInformation.isUserFamilyHead else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        restoreButton.isEnabled = false
        AlertManager.beginFetchingInformationIndictator()
        
        InAppPurchaseManager.restorePurchases { requestWasSuccessful in
            AlertManager.endFetchingInformationIndictator {
                self.restoreButton.isEnabled = true
                guard requestWasSuccessful else {
                    return
                }
                
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.restoreTransactionsTitle, forSubtitle: VisualConstant.BannerTextConstant.restoreTransactionsSubtitle, forStyle: .success)
            }
        }
    }
    
    @IBOutlet private weak var continueButton: ScreenWidthUIButton!
    @IBAction private func didTapContinue(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard FamilyInformation.isUserFamilyHead else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        // TO DO NOW add logic for continue or manage, depending upon circumstance
        // disable continue button
        // purchase selected item or manage subscription (if selected something currently bought)
        // reenable continue button
        // // The user selected their current subscription, show them the manage subscription page. This could mean they want to mean they potentially want to cancel their current subscription
        // InAppPurchaseManager.showManageSubscriptions()
        
        // The user is upgrading their subscription so no need for a disclaimer
        // purchaseSelectedProduct()
        
        /*
         func purchaseSelectedProduct() {
         // If the cell has no SKProduct, that means it's the default subscription cell
         guard let product = cell.product else {
         InAppPurchaseManager.showManageSubscriptions()
         return
         }
         
         AlertManager.beginFetchingInformationIndictator()
         InAppPurchaseManager.purchaseProduct(forProduct: product) { productIdentifier in
         AlertManager.endFetchingInformationIndictator {
         guard productIdentifier != nil else {
         // ErrorManager already invoked by purchaseProduct
         return
         }
         
         AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.purchasedSubscriptionTitle, forSubtitle: VisualConstant.BannerTextConstant.purchasedSubscriptionSubtitle, forStyle: .success)
         
         tableView.reloadData()
         }
         }
         }
         */
    }
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This page should be light. Blue background does not transfer well to dark mode
        self.overrideUserInterfaceStyle = .light
        
        restoreButton.isHidden = !FamilyInformation.isUserFamilyHead
        if let text = restoreButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            restoreButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
        
        redeemButton.isHidden = !FamilyInformation.isUserFamilyHead
        if let text = redeemButton.titleLabel?.text {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            redeemButton.setAttributedTitle(NSAttributedString(string: text, attributes: attributes), for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
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
        AlertManager.beginFetchingInformationIndictator()
        InAppPurchaseManager.fetchProducts { products  in
            guard products != nil else {
                // If the product request returned nil, meaning there was an error, then end the request indicator early and exit
                AlertManager.endFetchingInformationIndictator(completionHandler: nil)
                return
            }
            
            // request indictator is still active
            SubscriptionRequest.get(invokeErrorManager: true) { requestWasSuccessful, _ in
                AlertManager.endFetchingInformationIndictator {
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
        
        // Whatever SKProduct is at index 0 is presumed to be the most important, so we select that one by default. Its also visually appealing to have the first cell selected
        if indexPath.section == 0 {
            cell.setCustomSelectedTableViewCell(forSelected: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Let a user select cells even if they don't have the permission to as a non-family head.
        
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTableViewCell else {
            return
        }
        
        // TO DO NOW deselect any other selected row
        
        // flip isCustomSelected status
        selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
        
        // TO DO NOW if current cell is already purchased, make the continue button a manage subscription button
        // TO DO NOW otherwise, make the continue button say continue
        
    }
    
}
