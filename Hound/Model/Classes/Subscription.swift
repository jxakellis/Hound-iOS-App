//
//  Subscription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/14/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// productIdentifiers that belong to the subscription group of id 20965379
enum SubscriptionGroup20965379Product: String, CaseIterable {
    case twoFMTwoDogs = "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly"
    case fourFMFourDogs = "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly"
    case sixFMSixDogs = "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly"
    case tenFMTenDogs = "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly"
    
    /// Expands the product;s localizedTitle to add emojis, as Apple won't let you add emojis.
    static func localizedTitleExpanded(forSubscriptionGroup20965379Product subscriptionGroup20965379Product: SubscriptionGroup20965379Product?) -> String {
        guard let subscriptionGroup20965379Product = subscriptionGroup20965379Product else {
            return "Single 🧍‍♂️"
        }
        
        switch subscriptionGroup20965379Product {
        case .twoFMTwoDogs:
            return "Partner 👫"
        case .fourFMFourDogs:
            return "Household 👨‍👩‍👧‍👦"
        case .sixFMSixDogs:
            return "Neighborhood 👨‍👩‍👧‍👦👫"
        case .tenFMTenDogs:
            return "Community 👨‍👩‍👧‍👦👨‍👩‍👧‍👦👫"
        }
    }
    
    /// Expand the product's localizedDescription to add detail, as Apple limits their length
    static func localizedDescriptionExpanded(forSubscriptionGroup20965379Product subscriptionGroup20965379Product: SubscriptionGroup20965379Product?) -> String {
        guard let subscriptionGroup20965379Product = subscriptionGroup20965379Product else {
            return "Explore Hound's default subscription tier by yourself with up to two different dogs."
        }
        switch subscriptionGroup20965379Product {
        case .twoFMTwoDogs:
            return "Share your Hound family with a significant other. Unlock up to two different family members and dogs."
        case .fourFMFourDogs:
            return "Get the essential friends and family to join your Hound family. Upgrade to up to four different family members and dogs"
        case .sixFMSixDogs:
            return "Expand your Hound family to all new heights. Add up to six different family members and dogs."
        case .tenFMTenDogs:
            return "Take full advantage of Hound and make your family into its best (and biggest) self. Boost up to ten different family members and dogs."
        }
    }
}

final class Subscription: NSObject {
    
    // MARK: - Main
    
    init(
        transactionId: Int?,
        product: SubscriptionGroup20965379Product?,
        purchaseDate: Date?,
        expirationDate: Date?,
        numberOfFamilyMembers: Int,
        numberOfDogs: Int,
        isActive: Bool,
        isAutoRenewing: Bool?
    ) {
        self.transactionId = transactionId
        self.product = product
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.numberOfFamilyMembers = numberOfFamilyMembers
        self.numberOfDogs = numberOfDogs
        self.isActive = isActive
        self.isAutoRenewing = isAutoRenewing
        super.init()
    }
    
    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let transactionId = body[KeyConstant.transactionId.rawValue] as? Int
        
        var product: SubscriptionGroup20965379Product?
        if let productId = body[KeyConstant.productId.rawValue] as? String {
            product = SubscriptionGroup20965379Product(rawValue: productId)
        }
        
        var purchaseDate: Date?
        if let purchaseDateString = body[KeyConstant.purchaseDate.rawValue] as? String {
            purchaseDate = RequestUtils.dateFormatter(fromISO8601String: purchaseDateString)
        }
        
        var expirationDate: Date?
        if let expirationDateString = body[KeyConstant.expirationDate.rawValue] as? String {
            expirationDate = RequestUtils.dateFormatter(fromISO8601String: expirationDateString)
        }
        
        let numberOfFamilyMembers = body[KeyConstant.numberOfFamilyMembers.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfFamilyMembers
        
        let numberOfDogs = body[KeyConstant.numberOfDogs.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfDogs
        
        let isActive = body[KeyConstant.isActive.rawValue] as? Bool ?? false
        
        let isAutoRenewing = body[KeyConstant.isAutoRenewing.rawValue] as? Bool
        
        self.init(
            transactionId: transactionId,
            product: product,
            purchaseDate: purchaseDate,
            expirationDate: expirationDate,
            numberOfFamilyMembers: numberOfFamilyMembers,
            numberOfDogs: numberOfDogs,
            isActive: isActive,
            isAutoRenewing: isAutoRenewing
        )
    }
    
    // MARK: - Properties
    
    /// Transaction Id that of the subscription purchase
    private(set) var transactionId: Int?
    
    /// Product Id that the subscription purchase was for. No product means its a default subscription
    private(set) var product: SubscriptionGroup20965379Product?
    
    /// Date at which the subscription was purchased and completed processing on Hound's server
    private(set) var purchaseDate: Date?
    
    /// Date at which the subscription will expire
    private(set) var expirationDate: Date?
    
    /// How many family members the subscription allows into the family
    private(set) var numberOfFamilyMembers: Int
    
    /// How many dogs the subscription allows into the family
    private(set) var numberOfDogs: Int
    
    /// Indicates whether or not this subscription is the one thats active for the family
    var isActive: Bool
    
    /// Indicates whether or not this subscription will renew itself when it expires
    private(set) var isAutoRenewing: Bool?
    
}
