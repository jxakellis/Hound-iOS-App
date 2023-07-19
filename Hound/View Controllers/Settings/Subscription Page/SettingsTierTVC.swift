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
    
    @IBOutlet private weak var totalPriceLabel: ScaledUILabel!
    @IBOutlet private weak var monthlyPriceLabel: ScaledUILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    // MARK: - Properties
    
    // The SKProduct this cell is displaying
    var product: SKProduct?
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false
    
    // MARK: - Functions
    
    func setup(forProduct product: SKProduct) {
        self.product = product
        
        // TO DO NOW find the right border then standardize this and add it as a constant to some class/enum
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        // setCustomSelectedTableViewCell doesn't update the cell if forSelected == isCustomSelected. Therefore, toggle isCustomSelected to incorrect value, then provide correct value to setCustomSelectedTableViewCell to setup to correct state
        isCustomSelected.toggle()
        
        // Now configure the cell to the correct value for isCustomSelected
        setCustomSelectedTableViewCell(forSelected: !isCustomSelected)
    }
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected selected: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }
        
        isCustomSelected = selected
        
        checkmarkImageView.isHidden = !isCustomSelected
        
        setupPriceLabels()
    }
    
    // Attempts to set the attributedText for totalPriceLabel and monthlyPriceLabel given the current product, productFullPrice, and isCustomSelected
    private func setupPriceLabels() {
        guard let product = product, let monthlySubscriptionPrice = product.monthlySubscriptionPrice, let unit = product.subscriptionPeriod?.unit, let numberOfUnits = product.subscriptionPeriod?.numberOfUnits else {
            totalPriceLabel.text = VisualConstant.TextConstant.unknownText
            monthlyPriceLabel.text = VisualConstant.TextConstant.unknownText
            return
        }
        
        // $2.99, €1.99, ¥9.99
        let totalPriceWithCurrencySymbol = "\(product.priceLocale.currencySymbol ?? "")\(product.price)"
        // Converts whatever the price, unit, and numberOfUnits is into an approximate monthly price: $2.99, €1.99, ¥9.99
        let monthlyPriceWithCurrencySymbol = "\(product.priceLocale.currencySymbol ?? "")\(monthlySubscriptionPrice)"
        
        // To explain the difference between discounted and full price, take for example "6 months - $59.99  $119.99". $120 is the "full" price if you used a $20 1 month subscription for 6 months and $60 is our "discounted" price for buying the 6 month subscription
        // If the cell isn't selected, all of the text is the tertiary label color
        let discountedTotalPriceTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium),
            NSAttributedString.Key.foregroundColor: isCustomSelected ? UIColor.label : UIColor.tertiaryLabel
        ]
        let fullTotalPricePrimaryTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium),
            NSAttributedString.Key.foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel,
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let monthlyPriceTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light),
            NSAttributedString.Key.foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel
        ]
        
        // "" -> "6 months - $59.99"
        var totalPriceLabelText = NSMutableAttributedString(
            string: "\(convertPeriodUnit(forUnit: unit, forNumberOfUnits: numberOfUnits)) - \(totalPriceWithCurrencySymbol)",
            attributes: discountedTotalPriceTextAttributes
        )
        
        // "1 month - $19.99 " -> "1 months - $19.99" (NO-OP)
        // "6 months - $59.99 " -> "6 months - $59.99 $119.99"
        if let fullPrice = product.fullPrice, fullPrice != Double(product.price) {
            // We need a space between the original text and the new text
            totalPriceLabelText.append(
                NSAttributedString(string: " ")
            )
            
            // Make the number more visually appealing by rounding up to the nearest x.99. The important calculations are done so we can perform this rounding
            let fullPriceRoundedUpToNearest99 = ceil(fullPrice) > 0.0 ? ceil(fullPrice) - 0.01 : 0.0
            
            totalPriceLabelText.append(
                NSAttributedString(
                string: "\(product.priceLocale.currencySymbol ?? "")\(fullPriceRoundedUpToNearest99)",
                attributes: fullTotalPricePrimaryTextAttributes
                )
            )
        }
        
        totalPriceLabel.attributedText = totalPriceLabelText
        monthlyPriceLabel.attributedText = NSAttributedString(
            string: "\(monthlyPriceWithCurrencySymbol)/month",
            attributes: monthlyPriceTextAttributes
        )
    }
    
    /// Converts period unit and numberOfUnits into string, e.g. "3 days", "1 week", "6 months"
    private func convertPeriodUnit(forUnit unit: SKProduct.PeriodUnit, forNumberOfUnits numberOfUnits: Int) -> String {
        
        // Display x year as 12x months
        guard unit != .year else {
            return "\(numberOfUnits * 12) months"
        }
        
        var string = "\(numberOfUnits) "
        
        switch unit {
        case .day:
            string.append("day")
        case .week:
            string.append("week")
        case .month:
            string.append("month")
        default:
            break
        }
        
        if numberOfUnits > 1 {
            string.append("s")
        }
        
        return string
    }
    
}
