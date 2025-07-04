//
//  SKProductExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/14/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    // Attempts to use subscriptionPeriod unit and numberOfUnits to calculate an approximate monthly price, assuming 30 days / month.
    var monthlySubscriptionPrice: Double? {
        // what unit we are using: day, week, month, year
        let periodUnit = self.subscriptionPeriod?.unit
        // how many of the unit: x days, x weeks, x months, x years
        let numberOfUnits = self.subscriptionPeriod?.numberOfUnits

        guard let periodUnit = periodUnit, let numberOfUnits = numberOfUnits else {
            return nil
        }

        let numberOfMonths: Double? = {
            switch periodUnit {
            case .day:
                // days / 30 = months,
                return Double(numberOfUnits) / 30.0
            case .week:
                // weeks * 7 = days, days / 30 = months
                return (Double(numberOfUnits) * 7.0) / 30.0
            case .month:
                return Double(numberOfUnits)
            case .year:
                // years * 12 = months
                return Double(numberOfUnits) * 12.0
            default:
                return nil
            }
        }()

        guard let numberOfMonths = numberOfMonths else {
            return nil
        }

        var monthlySubscriptionPrice: Double = Double(truncating: self.price.dividing(by: NSDecimalNumber(value: numberOfMonths)))
        // truncate to 2 decimal places
        monthlySubscriptionPrice = floor(100 * monthlySubscriptionPrice) / 100
        return monthlySubscriptionPrice

    }

    /// Every SKProduct has a calculable monthlySubscriptionPrice. That means a certain SKProduct in subscriptionProducts will have the highest value of monthlySubscriptionPrice. If we take maximumMonthlySubscriptionPrice and apply it to the time frame of the subscription offered by this product, then we get the "full" price of this product. That is to say, we get the price that this product would cost if we use the highest possible price per time period. For example: 1 month $19.99 and 6 months $59.99. That would make the 1 month's fullPrice $19.99 and 6 month's fullPrice $119.99.
    var fullPrice: Double? {
        let maximumMonthlySubscriptionPrice: Double? = {
            // Find the SKProduct in subscriptionProducts with the highest value of monthlySubscriptionPrice
            var maximumMonthlySubscriptionPrice: Double?

            for product in InAppPurchaseManager.subscriptionProducts {
                guard let monthlySubscriptionPrice = product.monthlySubscriptionPrice else {
                    continue
                }

                maximumMonthlySubscriptionPrice = max(monthlySubscriptionPrice, maximumMonthlySubscriptionPrice ?? 0.0)
            }
            
            return maximumMonthlySubscriptionPrice
        }()
        
        guard let maximumMonthlySubscriptionPrice = maximumMonthlySubscriptionPrice else {
            return nil
        }

        // what unit we are using: day, week, month, year
        let periodUnit = self.subscriptionPeriod?.unit
        // how many of the unit: x days, x weeks, x months, x years
        let numberOfUnits = self.subscriptionPeriod?.numberOfUnits

        guard let periodUnit = periodUnit, let numberOfUnits = numberOfUnits else {
            return nil
        }

        let numberOfMonths: Double? = {
            switch periodUnit {
            case .day:
                // days / 30 = months,
                return Double(numberOfUnits) / 30.0
            case .week:
                // weeks * 7 = days, days / 30 = months
                return (Double(numberOfUnits) * 7.0) / 30.0
            case .month:
                return Double(numberOfUnits)
            case .year:
                // years * 12 = months
                return Double(numberOfUnits) * 12.0
            default:
                return nil
            }
        }()

        guard let numberOfMonths = numberOfMonths else {
            return nil
        }

        var fullPrice = numberOfMonths * maximumMonthlySubscriptionPrice
        
        // truncate to 2 decimal places
        fullPrice = floor(100 * fullPrice) / 100
        
        return fullPrice
    }
}
