//
//  SettingsSubscriptionTierTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

protocol SettingsSubscriptionTierTVCDelegate: AnyObject {
    func didSetCustomIsSelectedToTrue(forCell: SettingsSubscriptionTierTVC)
}

final class SettingsSubscriptionTierTVC: GeneralUITableViewCell {

    // MARK: - Elements

    private let savePercentLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .systemGreen
        label.font = .systemFont(ofSize: 17.5, weight: .medium)
        label.textColor = .systemBackground
        label.shouldRoundCorners = true
        return label
    }()

    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.shouldRoundCorners = true
        view.backgroundColor = .systemBackground
        return view
    }()

    private let totalPriceLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 300)
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private let monthlyPriceLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()

    private let checkmarkImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 280)
        
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        
        return imageView
    }()
    
    private let alignmentViewForSavePercent: GeneralUIView = {
        let view = GeneralUIView()
        view.isHidden = true
        return view
    }()

    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsSubscriptionTierTVC"

    /// The SKProduct this cell is displaying
    private(set) var product: SKProduct?

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false

    private weak var delegate: SettingsSubscriptionTierTVCDelegate?

    // MARK: - Functions

    func setup(forDelegate: SettingsSubscriptionTierTVCDelegate, forProduct: SKProduct, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.product = forProduct

        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected: Bool, isAnimated: Bool) {
        isCustomSelected = forSelected

        if isCustomSelected == true {
            delegate?.didSetCustomIsSelectedToTrue(forCell: self)
        }

        UIView.animate(withDuration: isAnimated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.checkmarkImageView.isHidden = !self.isCustomSelected
            self.savePercentLabel.isHidden = !self.isCustomSelected && self.savePercentLabel.text != nil

            self.containerView.borderColor = self.isCustomSelected ? UIColor.systemGreen : UIColor.label
            self.containerView.borderWidth = self.isCustomSelected ? 4.0 : 2.0

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
            guard let expiresDate = FamilyInformation.familyActiveSubscription.expiresDate else {
                return ""
            }
            
            let expiresYear = Calendar.current.component(.year, from: expiresDate)
            let currentYear = Calendar.current.component(.year, from: Date())
            
            let dateFormatter = DateFormatter()
            // January 25 OR January 25, 2023
            dateFormatter.setLocalizedDateFormatFromTemplate(expiresYear == currentYear ? "MMMMd" : "MMMMdyyyy")

            guard FamilyInformation.familyActiveSubscription.productId == product.productIdentifier else {
                // This cell isn't the active subscription, however it is set to renew
                if FamilyInformation.familyActiveSubscription.autoRenewStatus == true && FamilyInformation.familyActiveSubscription.autoRenewProductId == product.productIdentifier {
                    return ", renewing \(dateFormatter.string(from: expiresDate))"
                }
                return ""
            }
            // This cell is the active subscription with an expiresDate. It could be renewing or expiring on the expiresDate

            return ", \(FamilyInformation.familyActiveSubscription.autoRenewStatus == true && FamilyInformation.familyActiveSubscription.autoRenewProductId == product.productIdentifier ? "renewing" : "expiring") \(dateFormatter.string(from: expiresDate))"
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
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(savePercentLabel)
        containerView.addSubview(alignmentViewForSavePercent)
        containerView.addSubview(totalPriceLabel)
        containerView.addSubview(monthlyPriceLabel)
        containerView.addSubview(checkmarkImageView)
        
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            checkmarkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            checkmarkImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            checkmarkImageView.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 10),
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            checkmarkImageView.widthAnchor.constraint(equalTo: checkmarkImageView.heightAnchor),
        
            alignmentViewForSavePercent.topAnchor.constraint(equalTo: containerView.topAnchor),
            alignmentViewForSavePercent.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            alignmentViewForSavePercent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        
            monthlyPriceLabel.topAnchor.constraint(equalTo: totalPriceLabel.bottomAnchor, constant: 7.5),
            monthlyPriceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            monthlyPriceLabel.leadingAnchor.constraint(equalTo: totalPriceLabel.leadingAnchor),
        
            totalPriceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            totalPriceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            totalPriceLabel.trailingAnchor.constraint(equalTo: monthlyPriceLabel.trailingAnchor),
        
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.centerXAnchor.constraint(equalTo: alignmentViewForSavePercent.trailingAnchor),
        
            savePercentLabel.centerXAnchor.constraint(equalTo: alignmentViewForSavePercent.centerXAnchor),
            savePercentLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor)
        
        ])
        
    }
}
