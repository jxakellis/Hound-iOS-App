//
//  Subscription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/14/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum SubscriptionGroup20965379Product: String, CaseIterable {

    // This order is specific, the lower indicies get sorted to the first positions
    case sixFamilyMembersOneYear = "com.jonathanxakellis.hound.sixfamilymembers.oneyear"
    case sixFamilyMembersSixMonth = "com.jonathanxakellis.hound.sixfamilymembers.sixmonth"
    case sixFamilyMembersOneMonth = "com.jonathanxakellis.hound.sixfamilymembers.onemonth"

    // case twoFMTwoDogs = "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly"
    // case fourFMFourDogs = "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly"
    // case sixFMSixDogs = "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly"
    // case tenFMTenDogs = "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly"
}

final class Subscription: NSObject {

    // MARK: - Main

    init(
        transactionId: Int?,
        productId: String,
        purchaseDate: Date?,
        expirationDate: Date?,
        numberOfFamilyMembers: Int,
        isActive: Bool,
        isAutoRenewing: Bool,
        autoRenewProductId: String
    ) {
        self.transactionId = transactionId
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.numberOfFamilyMembers = numberOfFamilyMembers
        self.isActive = isActive
        self.isAutoRenewing = isAutoRenewing
        self.autoRenewProductId = autoRenewProductId
        super.init()
    }

    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let transactionId = body[KeyConstant.transactionId.rawValue] as? Int

        let productId: String = body[KeyConstant.productId.rawValue] as? String ?? ClassConstant.SubscriptionConstant.defaultProductId

        var purchaseDate: Date?
        if let purchaseDateString = body[KeyConstant.purchaseDate.rawValue] as? String {
            purchaseDate = purchaseDateString.formatISO8601IntoDate()
        }

        var expirationDate: Date?
        if let expirationDateString = body[KeyConstant.expirationDate.rawValue] as? String {
            expirationDate = expirationDateString.formatISO8601IntoDate()
        }

        let numberOfFamilyMembers = body[KeyConstant.numberOfFamilyMembers.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfFamilyMembers

        let isActive = body[KeyConstant.isActive.rawValue] as? Bool ?? false

        let isAutoRenewing = body[KeyConstant.isAutoRenewing.rawValue] as? Bool ?? true

        let autoRenewProductId = body[KeyConstant.autoRenewProductId.rawValue] as? String ?? productId

        self.init(
            transactionId: transactionId,
            productId: productId,
            purchaseDate: purchaseDate,
            expirationDate: expirationDate,
            numberOfFamilyMembers: numberOfFamilyMembers,
            isActive: isActive,
            isAutoRenewing: isAutoRenewing,
            autoRenewProductId: autoRenewProductId
        )
    }

    // MARK: - Properties

    /// Transaction Id that of the subscription purchase
    private(set) var transactionId: Int?

    /// ProductId that the subscription purchase was for. No product means its a default subscription
    private(set) var productId: String

    /// Date at which the subscription was purchased and completed processing on Hound's server
    private(set) var purchaseDate: Date?

    /// Date at which the subscription will expire
    private(set) var expirationDate: Date?

    /// How many family members the subscription allows into the family
    private(set) var numberOfFamilyMembers: Int

    /// Indicates whether or not this subscription is the one thats active for the family
    var isActive: Bool

    /// Indicates whether or not this subscription will renew itself when it expires
    private(set) var isAutoRenewing: Bool

    /// The product identifier of the product that renews at the next billing period./
    private(set) var autoRenewProductId: String

}
