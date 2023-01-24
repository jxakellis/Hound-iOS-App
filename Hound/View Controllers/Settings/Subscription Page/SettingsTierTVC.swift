//
//  SettingsSubscriptionTierTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import StoreKit
import UIKit

final class SettingsSubscriptionTierTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var subscriptionTierTitleLabel: ScaledUILabel!
    @IBOutlet private weak var subscriptionTierDescriptionLabel: ScaledUILabel!
    
    @IBOutlet private weak var subscriptionTierPricingLabel: ScaledUILabel!
    
    // MARK: - Properties
    
    var product: SKProduct?
    var subscriptionGroup20965379Product: SubscriptionGroup20965379Product?
    
    // MARK: - Functions
    
    func setup(forProduct product: SKProduct?) {
        self.product = product
        
        let activeFamilySubscriptionProduct = FamilyInformation.activeFamilySubscription.product
        
        guard let product: SKProduct = product, let productSubscriptionPeriod = product.subscriptionPeriod, let subscriptionProduct = SubscriptionGroup20965379Product(rawValue: product.productIdentifier) else {
            // default subscription
            changeCellColors(isProductActiveSubscription: FamilyInformation.activeFamilySubscription.product == nil)
            
            subscriptionTierTitleLabel.text = SubscriptionGroup20965379Product.localizedTitleExpanded(forSubscriptionGroup20965379Product: nil)
            subscriptionTierDescriptionLabel.text = SubscriptionGroup20965379Product.localizedDescriptionExpanded(forSubscriptionGroup20965379Product: nil)
            
            subscriptionTierPricingLabel.text = "Completely and always free!"
            return
        }
        
        self.subscriptionGroup20965379Product = subscriptionProduct
        
        changeCellColors(isProductActiveSubscription: subscriptionProduct == activeFamilySubscriptionProduct)
        
        // if we know what product it is, then highlight the cell if its product is the current, active subscription
        subscriptionTierTitleLabel.text = SubscriptionGroup20965379Product.localizedTitleExpanded(forSubscriptionGroup20965379Product: subscriptionProduct)
        subscriptionTierDescriptionLabel.text = SubscriptionGroup20965379Product.localizedDescriptionExpanded(forSubscriptionGroup20965379Product: subscriptionProduct)
        
        let keychain = KeychainSwift()
        // if we don't have a value stored, then that means the value is false. A bool (true) is only stored for this key in the case that a user purchases a product from subscription group 20965379
        let userPurchasedProductFromSubscriptionGroup20965379: Bool = keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue) ?? false
        
        // $2.99, €1.99, ¥9.99
        let subscriptionPriceWithSymbol = "\(product.priceLocale.currencySymbol ?? "")\(product.price)"
        // 7 days, week, 2 months, year
        let subscriptionPeriodString = convertSubscriptionPeriodUnits(forUnit: productSubscriptionPeriod.unit, forNumberOfUnits: productSubscriptionPeriod.numberOfUnits, isFreeTrialText: false)
        // $x.xx per day, $x.xx every 2 weeks, $x.xx per month.
        let perOrEveryForSubscriptionPeriod = productSubscriptionPeriod.numberOfUnits == 1 ? "per" : "every"
        
        // tier offers a free trial
        if let introductoryPrice = product.introductoryPrice, introductoryPrice.paymentMode == .freeTrial && userPurchasedProductFromSubscriptionGroup20965379 == false {
            let freeTrialSubscriptionPeriod = convertSubscriptionPeriodUnits(forUnit: introductoryPrice.subscriptionPeriod.unit, forNumberOfUnits: introductoryPrice.subscriptionPeriod.numberOfUnits, isFreeTrialText: true)
            
            subscriptionTierPricingLabel.text = "\(freeTrialSubscriptionPeriod) free trial, then \(subscriptionPriceWithSymbol) \(perOrEveryForSubscriptionPeriod) \(subscriptionPeriodString)"
        }
        // no free trial or the user has used up their free trial
        else {
            subscriptionTierPricingLabel.text = "\(subscriptionPriceWithSymbol) \(perOrEveryForSubscriptionPeriod) \(subscriptionPeriodString)"
        }
    }
    
    /// If the cell has a product identifier that is the same as the family's active subscription, then we change the colors of the cell to make it highlighted
    private func changeCellColors(isProductActiveSubscription: Bool) {
        self.backgroundColor = isProductActiveSubscription
        ? .systemBlue
        : .systemBackground
        
        subscriptionTierTitleLabel.textColor = isProductActiveSubscription
        ? .white
        : .label
        
        subscriptionTierDescriptionLabel.textColor = isProductActiveSubscription
        ? .white
        : .secondaryLabel
        
        subscriptionTierPricingLabel.textColor = isProductActiveSubscription
        ? .white
        : .secondaryLabel
    }
    
    /// Converts from units (time period: day, week, month, year) and numberOfUnits (duration: 1, 2, 3...) to the correct string. See function body for full list of examples
    private func convertSubscriptionPeriodUnits(forUnit unit: SKProduct.PeriodUnit, forNumberOfUnits numberOfUnits: Int, isFreeTrialText: Bool) -> String {
        /*
         unit: 0 numberOfUnits 1 isFreeTrialText: true
         1 day
         unit: 0 numberOfUnits 1 isFreeTrialText: false
         day

         unit: 0 numberOfUnits 2 isFreeTrialText: true
         2 day
         unit: 0 numberOfUnits 2 isFreeTrialText: false
         2 days

         unit: 0 numberOfUnits 3 isFreeTrialText: true
         3 day
         unit: 0 numberOfUnits 3 isFreeTrialText: false
         3 days

         unit: 0 numberOfUnits 4 isFreeTrialText: true
         4 day
         unit: 0 numberOfUnits 4 isFreeTrialText: false
         4 days

         unit: 1 numberOfUnits 1 isFreeTrialText: true
         1 week
         unit: 1 numberOfUnits 1 isFreeTrialText: false
         week

         unit: 1 numberOfUnits 2 isFreeTrialText: true
         2 week
         unit: 1 numberOfUnits 2 isFreeTrialText: false
         2 weeks

         unit: 1 numberOfUnits 3 isFreeTrialText: true
         3 week
         unit: 1 numberOfUnits 3 isFreeTrialText: false
         3 weeks

         unit: 1 numberOfUnits 4 isFreeTrialText: true
         4 week
         unit: 1 numberOfUnits 4 isFreeTrialText: false
         4 weeks

         unit: 2 numberOfUnits 1 isFreeTrialText: true
         1 month
         unit: 2 numberOfUnits 1 isFreeTrialText: false
         month

         unit: 2 numberOfUnits 2 isFreeTrialText: true
         2 month
         unit: 2 numberOfUnits 2 isFreeTrialText: false
         2 months

         unit: 2 numberOfUnits 3 isFreeTrialText: true
         3 month
         unit: 2 numberOfUnits 3 isFreeTrialText: false
         3 months

         unit: 2 numberOfUnits 4 isFreeTrialText: true
         4 month
         unit: 2 numberOfUnits 4 isFreeTrialText: false
         4 months

         unit: 3 numberOfUnits 1 isFreeTrialText: true
         1 year
         unit: 3 numberOfUnits 1 isFreeTrialText: false
         year

         unit: 3 numberOfUnits 2 isFreeTrialText: true
         2 year
         unit: 3 numberOfUnits 2 isFreeTrialText: false
         2 years

         unit: 3 numberOfUnits 3 isFreeTrialText: true
         3 year
         unit: 3 numberOfUnits 3 isFreeTrialText: false
         3 years

         unit: 3 numberOfUnits 4 isFreeTrialText: true
         4 year
         unit: 3 numberOfUnits 4 isFreeTrialText: false
         4 years
         */
        
        var string = {
            if isFreeTrialText == true {
                return "\(numberOfUnits) "
            }
            else if isFreeTrialText == false && numberOfUnits > 1 {
                return "\(numberOfUnits) "
            }
            else {
                return ""
            }
        }()
        
        switch unit.rawValue {
        case 0:
            string.append("day")
        case 1:
            string.append("week")
        case 2:
            string.append("month")
        case 3:
            string.append("year")
        default:
            string.append(VisualConstant.TextConstant.unknownText)
        }
        
        // If our unit is plural (e.g. 2 days, 3 days), then we need to append that "s" to go from day -> days. Additionally we check to make sure our unit is within a valid range, otherwise we don't want to append "s" to "unknown⚠️"
        if isFreeTrialText == false && numberOfUnits != 1 && 0...3 ~= unit.rawValue {
            string.append("s")
        }
        
        return string
        
    }
    
}
