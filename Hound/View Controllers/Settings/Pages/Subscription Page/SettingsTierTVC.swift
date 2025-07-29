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

final class SettingsSubscriptionTierTVC: HoundTableViewCell {

    // MARK: - Elements
    
    private let containerView: HoundView = {
        let view = HoundView()
        view.shouldRoundCorners = true
        view.staticCornerRadius = Constant.Visual.Layer.defaultCornerRadius
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let alignmentViewForSavePercent: HoundView = {
        let view = HoundView()
        view.isHidden = true
        return view
    }()

    private let savePercentLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.systemGreen
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        label.textColor = UIColor.systemBackground
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    private lazy var priceStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalPriceLabel, monthlyPriceLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = Constant.Constraint.Spacing.contentIntraVert
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let totalPriceLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        // font set in attributed
        return label
    }()

    private let monthlyPriceLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.numberOfLines = 0
        // font set in attributed
        label.textColor = UIColor.secondaryLabel
        return label
    }()

    private let checkmarkImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 320, compressionResistancePriority: 320)
        
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = UIColor.systemGreen
        
        return imageView
    }()

    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsSubscriptionTierTVC"

    /// The SKProduct this cell is displaying
    private(set) var product: SKProduct?

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false

    private weak var delegate: SettingsSubscriptionTierTVCDelegate?

    // MARK: - Setup

    func setup(forDelegate: SettingsSubscriptionTierTVCDelegate, forProduct: SKProduct, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.product = forProduct

        setCustomSelected(forIsCustomSelected, animated: false)
    }
    
    // MARK: - Functions

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelected(_ selected: Bool, animated: Bool) {
        isCustomSelected = selected

        if isCustomSelected == true {
            delegate?.didSetCustomIsSelectedToTrue(forCell: self)
        }
        
        // this must come first as savePercentLabel.text changes
        self.setupPriceLabels()

        UIView.animate(withDuration: animated ? Constant.Visual.Animation.selectSingleElement : 0.0) {
            self.checkmarkImageView.isHidden = !self.isCustomSelected
            self.savePercentLabel.isHidden = !self.isCustomSelected && self.savePercentLabel.text != nil

            self.containerView.applyStyle(self.isCustomSelected ? .greenSelectionBorder : .labelBorder)
        }
    }

    /// Attempts to set the attributedText for totalPriceLabel and monthlyPriceLabel given the current product, productFullPrice, and isCustomSelected
    private func setupPriceLabels() {
        guard let product = product, let monthlySubscriptionPrice = product.monthlySubscriptionPrice, let unit = product.subscriptionPeriod?.unit, let numberOfUnits = product.subscriptionPeriod?.numberOfUnits else {
            totalPriceLabel.text = Constant.Visual.Text.unknownText
            monthlyPriceLabel.text = Constant.Visual.Text.unknownText
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
            .font: Constant.Visual.Font.emphasizedTertiaryHeaderLabel,
            .foregroundColor: isCustomSelected ? UIColor.label : UIColor.tertiaryLabel
        ]
        let fullTotalPricePrimaryTextAttributes: [NSAttributedString.Key: Any] = [
            .font: Constant.Visual.Font.emphasizedTertiaryHeaderLabel,
            .foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let monthlyPriceTextAttributes: [NSAttributedString.Key: Any] = [
            .font: Constant.Visual.Font.secondaryRegularLabel,
            .foregroundColor: isCustomSelected ? UIColor.secondaryLabel : UIColor.tertiaryLabel
        ]

        // "" -> "6 months - $59.99"
        let precalculatedDynamicSubscriptionLengthAndPriceText = "\(convertPeriodUnit(forUnit: unit, forNumberOfUnits: numberOfUnits)) - \(totalPriceWithCurrencySymbol)"

        // "1 month - $19.99 " -> "1 months - $19.99" (NO-OP)
        // "6 months - $59.99 " -> "6 months - $59.99 $119.99"
        var fullPriceText: String?
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

            fullPriceText = "\(product.priceLocale.currencySymbol ?? "")\(fullPriceRoundedUpToNearest99)"
        }
        else {
            savePercentLabel.text = nil
        }

        totalPriceLabel.attributedText = {
            // "" -> "6 months - $59.99"
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: precalculatedDynamicSubscriptionLengthAndPriceText,
                attributes: discountedTotalPriceTextAttributes)

            // "1 month - $19.99 " -> "1 months - $19.99" (NO-OP)
            // "6 months - $59.99 " -> "6 months - $59.99 $119.99"
            if let fullPriceText = fullPriceText {
                // We need a space between the original text and the new text
                message.append(
                    NSAttributedString(string: " ")
                )

                message.append(
                    NSAttributedString(
                    string: fullPriceText,
                    attributes: fullTotalPricePrimaryTextAttributes
                    )
                )
            }

            return message
        }()

        // If the prodcut displayed by this cell is the active subscription, have this cell also show the active subscriptions expiration date
        let activeSubscriptionExpirationText: String = {
            guard let expiresDate = FamilyInformation.familyActiveSubscription.expiresDate else {
                return ""
            }
            
            let expiresYear = Calendar.user.component(.year, from: expiresDate)
            let currentYear = Calendar.user.component(.year, from: Date())
            
            // January 25 OR January 25, 2023
            let template = expiresYear == currentYear ? "MMMMd" : "MMMMdyyyy"

            guard FamilyInformation.familyActiveSubscription.productId == product.productIdentifier else {
                // This cell isn't the active subscription, however it is set to renew
                if FamilyInformation.familyActiveSubscription.autoRenewStatus == true && FamilyInformation.familyActiveSubscription.autoRenewProductId == product.productIdentifier {
                    return ", renewing \(expiresDate.houndFormatted(.template(template), displayTimeZone: UserConfiguration.timeZone))"
                }
                return ""
            }
            // This cell is the active subscription with an expiresDate. It could be renewing or expiring on the expiresDate

            return ", \(FamilyInformation.familyActiveSubscription.autoRenewStatus == true && FamilyInformation.familyActiveSubscription.autoRenewProductId == product.productIdentifier ? "renewing" : "expiring") \(expiresDate.houndFormatted(.template(template), displayTimeZone: UserConfiguration.timeZone))"
        }()

        monthlyPriceLabel.attributedText = {
            NSAttributedString(
                string: "\(roundedMonthlyPriceWithCurrencySymbol) / month\(activeSubscriptionExpirationText)",
                attributes: monthlyPriceTextAttributes
            )
        }()
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
        super.addSubViews()
        contentView.addSubview(containerView)
        contentView.addSubview(savePercentLabel)
        containerView.addSubview(alignmentViewForSavePercent)
        containerView.addSubview(priceStack)
        containerView.addSubview(checkmarkImageView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // alignmentViewForSavePercent
        NSLayoutConstraint.activate([
            alignmentViewForSavePercent.topAnchor.constraint(equalTo: containerView.topAnchor),
            alignmentViewForSavePercent.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            alignmentViewForSavePercent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            alignmentViewForSavePercent.trailingAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])

        // savePercentLabel
        NSLayoutConstraint.activate([
            savePercentLabel.centerXAnchor.constraint(equalTo: alignmentViewForSavePercent.centerXAnchor),
            savePercentLabel.centerYAnchor.constraint(equalTo: alignmentViewForSavePercent.centerYAnchor)
        ])
        
        // priceStack
        NSLayoutConstraint.activate([
            priceStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            priceStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            priceStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
        
        // checkmarkImageView
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(greaterThanOrEqualTo: priceStack.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            checkmarkImageView.centerYAnchor.constraint(equalTo: priceStack.centerYAnchor),
            checkmarkImageView.heightAnchor.constraint(equalTo: priceStack.heightAnchor),
            checkmarkImageView.createSquareAspectRatio()
        ])
    }

}
