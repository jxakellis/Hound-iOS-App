//
//  SettingsSubscriptionTierTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import StoreKit
import UIKit

final class SettingsSubscriptionTierTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var subscriptionTierTitleLabel: ScaledUILabel!
    @IBOutlet private weak var subscriptionTierDescriptionLabel: ScaledUILabel!
    
    @IBOutlet private weak var subscriptionTierPricingTitleLabel: ScaledUILabel!
    @IBOutlet private weak var subscriptionTierPricingDescriptionLabel: ScaledUILabel!
    
    // MARK: - Properties
    
    var product: SKProduct?
    var subscriptionGroup20965379Product: SubscriptionGroup20965379Product?
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func setup(forProduct product: SKProduct?) {
        
        self.product = product
        let activeFamilySubscriptionProduct = FamilyInformation.activeFamilySubscription.product
        
        guard let product: SKProduct = product, let productSubscriptionPeriod = product.subscriptionPeriod, let subscriptionProduct = SubscriptionGroup20965379Product(rawValue: product.productIdentifier) else {
            // default subscription
            changeCellColors(isProductActiveSubscription: FamilyInformation.activeFamilySubscription.product == nil)
            subscriptionTierTitleLabel.text = SubscriptionGroup20965379Product.localizedTitleExpanded(forSubscriptionGroup20965379Product: nil)
            subscriptionTierDescriptionLabel.text = SubscriptionGroup20965379Product.localizedDescriptionExpanded(forSubscriptionGroup20965379Product: nil)
            subscriptionTierPricingDescriptionLabel.text = "Completely and always free! You get to benefit from the same features as paid subscribers. The only difference is family member and dog limits."
            return
        }
        
        self.subscriptionGroup20965379Product = subscriptionProduct
        
        changeCellColors(isProductActiveSubscription: subscriptionProduct == activeFamilySubscriptionProduct)
        
        // if we know what product it is, then highlight the cell if its product is the current, active subscription
        subscriptionTierTitleLabel.text = SubscriptionGroup20965379Product.localizedTitleExpanded(forSubscriptionGroup20965379Product: subscriptionProduct)
        subscriptionTierDescriptionLabel.text = SubscriptionGroup20965379Product.localizedDescriptionExpanded(forSubscriptionGroup20965379Product: subscriptionProduct)
        
        let keychain = KeychainSwift()
        let userPurchasedProductFromSubscriptionGroup20965379WithPaymentDiscount = keychain.getBool(KeyConstant.userPurchasedProductFromSubscriptionGroup20965379WithPaymentDiscount.rawValue)
        
        // now we have to determine what the pricing is like
        let subscriptionPriceWithSymbol = "\(product.priceLocale.currencySymbol ?? "")\(product.price)"
        let subscriptionPeriodString = convertSubscriptionPeriodUnits(forUnit: productSubscriptionPeriod.unit, forNumberOfUnits: productSubscriptionPeriod.numberOfUnits, isFreeTrialText: false)
        
        // tier offers a free trial
        if let introductoryPrice = product.introductoryPrice, introductoryPrice.paymentMode == .freeTrial && userPurchasedProductFromSubscriptionGroup20965379WithPaymentDiscount == false {
            let freeTrialSubscriptionPeriod = convertSubscriptionPeriodUnits(forUnit: introductoryPrice.subscriptionPeriod.unit, forNumberOfUnits: introductoryPrice.subscriptionPeriod.numberOfUnits, isFreeTrialText: true)
            
            subscriptionTierPricingDescriptionLabel.text = "Begin with a free \(freeTrialSubscriptionPeriod) trial then continue your \(product.localizedTitle) experience for \(subscriptionPriceWithSymbol) per \(subscriptionPeriodString)"
        }
        // no free trial or the user has used up their free trial
        else {
            subscriptionTierPricingDescriptionLabel.text = "Enjoy all \(product.localizedTitle) has to offer for \(subscriptionPriceWithSymbol) per \(subscriptionPeriodString)"
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
        
        subscriptionTierPricingTitleLabel.textColor = isProductActiveSubscription
        ? .white
        : .label
        subscriptionTierPricingDescriptionLabel.textColor = isProductActiveSubscription
        ? .white
        : .secondaryLabel
    }
    
    /// Converts from units (time period: day, week, month, year) and numberOfUnits (duration: 1, 2, 3...) to the correct string. For example: unit = 2 & numerOfUnits = 3 -> "three (3) months"; unit = 1 & numerOfUnits = 2 -> "two (2) weeks"
    private func convertSubscriptionPeriodUnits(forUnit unit: SKProduct.PeriodUnit, forNumberOfUnits numberOfUnits: Int, isFreeTrialText: Bool) -> String {
        var string = ""
        
        // if the numberOfUnits isn't equal to 1, then we append its value. This is so we get the returns of "month", "two (2) months", "three (3) months"
        
        if numberOfUnits != 1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let numberOfUnitsValueSpelledOut = formatter.string(from: numberOfUnits as NSNumber)
            
            // make sure to add an extra space onto the back. we can remove that at the end.
            if let numberOfUnitsValueSpelledOut = numberOfUnitsValueSpelledOut {
                // NO TEXT FOR ONE (1)
                // "two (2) "
                // "three (3) "
                // ...
                string.append("\(numberOfUnitsValueSpelledOut) (\(numberOfUnits)) ")
            }
            else {
                // NO TEXT FOR 1
                // "2 "
                // "3 "
                // ...
                string.append("\(numberOfUnits) ")
            }
        }
        
        // At this point, depending on our numberOfUnits.rawValue, we have:
        // " "
        // "two (2) "
        // "three (3) "
        
        // Now we need to append the correct time period
        
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
