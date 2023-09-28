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

protocol SettingsSubscriptionTierTableViewCellDelegate: AnyObject {
    func didSetCustomIsSelectedToTrue(forCell: SettingsSubscriptionTierTableViewCell)
}

final class SettingsSubscriptionTierTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var savePercentLabel: GeneralUILabel!

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet private weak var totalPriceLabel: GeneralUILabel!
    @IBOutlet private weak var monthlyPriceLabel: GeneralUILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!

    // MARK: - Properties

    /// The SKProduct this cell is displaying
    private(set) var product: SKProduct?

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false

    private weak var delegate: SettingsSubscriptionTierTableViewCellDelegate?

    // MARK: - Functions

    func setup(forDelegate: SettingsSubscriptionTierTableViewCellDelegate, forProduct: SKProduct, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.product = forProduct

        containerView.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        containerView.layer.cornerCurve = .continuous

        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected: Bool, isAnimated: Bool) {
        isCustomSelected = forSelected

        if isCustomSelected == true {
            delegate?.didSetCustomIsSelectedToTrue(forCell: self)
        }

        UIView.animate(withDuration: isAnimated ? VisualConstant.AnimationConstant.setCustomSelectedTableViewCell : 0.0) {
            self.checkmarkImageView.isHidden = !self.isCustomSelected
            self.savePercentLabel.isHidden = !self.isCustomSelected && self.savePercentLabel.text != nil

            self.containerView.layer.borderColor = self.isCustomSelected ? UIColor.systemGreen.cgColor : UIColor.label.cgColor
            self.containerView.layer.borderWidth = self.isCustomSelected ? 4.0 : 2.0

            self.setupPriceLabels()
        }
    }

    /// Attempts to set the attributedText for totalPriceLabel and monthlyPriceLabel given the current product, productFullPrice, and isCustomSelected
    private func setupPriceLabels() {
        guard let product = product, let monthlySubscriptionPrice = product.monthlySubscriptionPrice, let unit = product.subscriptionPeriod?.unit, let numberOfUnits = product.subscriptionPeriod?.numberOfUnits else {
            totalPriceLabel.text = VisualConstant.TextConstant.unknownText
            monthlyPriceLabel.text = VisualConstant.TextConstant.unknownText
            return
        }

        // $2.99, €1.99, ¥9.99
        let totalPriceWithCurrencySymbol = "\(product.priceLocale.currencySymbol ?? "")\(product.price)"

        // Make the number more visually appealing by rounding to the nearest x.x9.
        let roundedMonthlySubscriptionPrice = (Int(ceil(monthlySubscriptionPrice * 100)) % 10) >= 5
        ? (ceil(monthlySubscriptionPrice * 10) / 10) - 0.01 // round up to nearest x.x9
        : (floor(monthlySubscriptionPrice * 10) / 10) - 0.01 // round down to nearest x.x9

        // Converts whatever the price, unit, and numberOfUnits is into an approximate monthly price: $2.99, €1.99, ¥9.99
        let roundedMonthlyPriceWithCurrencySymbol = "\(product.priceLocale.currencySymbol ?? "")\(String(format: "%.2f", roundedMonthlySubscriptionPrice))"

        // To explain the difference between discounted and full price, take for example "6 months - $59.99  $119.99". $120 is the "full" price if you used a $20 1 month subscription for 6 months and $60 is our "discounted" price for buying the 6 month subscription
        // If the cell isn't selected, all of the text is the tertiary label color
        let discountedTotalPriceTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: isCustomSelected ? UIColor.label : UIColor.tertiaryLabel
        ]
        let fullTotalPricePrimaryTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let monthlyPriceTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .light),
            .foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel
        ]

        // "" -> "6 months - $59.99"
        let precalculatedDynamicSubscriptionLengthAndPriceText = "\(convertPeriodUnit(forUnit: unit, forNumberOfUnits: numberOfUnits)) - \(totalPriceWithCurrencySymbol)"

        // "1 month - $19.99 " -> "1 months - $19.99" (NO-OP)
        // "6 months - $59.99 " -> "6 months - $59.99 $119.99"
        var precalculatedDynamicFullPriceText: String?
        if let fullPrice = product.fullPrice, fullPrice != Double(truncating: product.price) {
            // e.g. 78.5 product.price / 100.0 fullPrice -> 0.785 -> 1 - 0.785 -> 0.225 -> 0.225 * 100 -> 22.5 -> 23
            var unroundedPercentageSaved = Int(
                ceil(
                    (1 - (Double(truncating: product.price) / fullPrice)) * 100.0
                )
            )

            // Round up to the nearest 5
            // 20 -> 20, 21 -> 25, 22 -> 25, 23 -> 25, 24 -> 25, 25 -> 25
            unroundedPercentageSaved = (unroundedPercentageSaved % 5 > 0)
            ? (unroundedPercentageSaved + 5) - (unroundedPercentageSaved % 5)
            : unroundedPercentageSaved

            savePercentLabel.text = " SAVE \(unroundedPercentageSaved)%   "

            // Make the number more visually appealing by rounding up to the nearest x.99. The important calculations are done so we can perform this rounding
            let fullPriceRoundedUpToNearest99 = ceil(fullPrice) > 0.0 ? ceil(fullPrice) - 0.01 : 0.0

            precalculatedDynamicFullPriceText = "\(product.priceLocale.currencySymbol ?? "")\(fullPriceRoundedUpToNearest99)"
        }
        else {
            savePercentLabel.text = nil
        }

        totalPriceLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            // "" -> "6 months - $59.99"
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: precalculatedDynamicSubscriptionLengthAndPriceText,
                attributes: discountedTotalPriceTextAttributes)

            // "1 month - $19.99 " -> "1 months - $19.99" (NO-OP)
            // "6 months - $59.99 " -> "6 months - $59.99 $119.99"
            if let precalculatedDynamicFullPriceText = precalculatedDynamicFullPriceText {
                // We need a space between the original text and the new text
                message.append(
                    NSAttributedString(string: " ")
                )

                message.append(
                    NSAttributedString(
                    string: precalculatedDynamicFullPriceText,
                    attributes: fullTotalPricePrimaryTextAttributes
                    )
                )
            }

            return message
        }

        // If the prodcut displayed by this cell is the active subscription, have this cell also show the active subscriptions expiration date
        let activeSubscriptionExpirationText: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Calendar.localCalendar.locale
            // Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32 PM PST”.
            dateFormatter.dateStyle = .long
            // Specifies no style.
            dateFormatter.timeStyle = .none

            guard let expiresDate = FamilyInformation.activeFamilySubscription.expiresDate else {
                return ""
            }

            guard FamilyInformation.activeFamilySubscription.productId == product.productIdentifier else {
                // This cell isn't the active subscription, however it is set to renew
                if FamilyInformation.activeFamilySubscription.autoRenewStatus == true && FamilyInformation.activeFamilySubscription.autoRenewProductId == product.productIdentifier {
                    return ", renewing \(dateFormatter.string(from: expiresDate))"
                }
                return ""
            }
            // This cell is the active subscription with an expiresDate. It could be renewing or expiring on the expiresDate

            return ", \(FamilyInformation.activeFamilySubscription.autoRenewStatus == true && FamilyInformation.activeFamilySubscription.autoRenewProductId == product.productIdentifier ? "renewing" : "expiring") \(dateFormatter.string(from: expiresDate))"
        }()

        let precalculatedDynamicMonthlyPriceText = "\(roundedMonthlyPriceWithCurrencySymbol)/month\(activeSubscriptionExpirationText)"

        monthlyPriceLabel.attributedTextClosure = {
            NSAttributedString(
                string: precalculatedDynamicMonthlyPriceText,
                attributes: monthlyPriceTextAttributes
            )
        }
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
