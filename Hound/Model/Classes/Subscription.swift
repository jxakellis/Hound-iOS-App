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

final class Subscription: NSObject, NSCoding {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedTransactionId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.transactionId.rawValue)
        let decodedProductId = aDecoder.decodeOptionalString(forKey: Constant.Key.productId.rawValue)
        let decodedPurchaseDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.purchaseDate.rawValue)
        let decodedExpiresDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.expiresDate.rawValue)
        let decodedNumberOfFamilyMembers = aDecoder.decodeOptionalInteger(forKey: Constant.Key.numberOfFamilyMembers.rawValue)
        let decodedIsActive = aDecoder.decodeOptionalBool(forKey: Constant.Key.isActive.rawValue)
        let decodedAutoRenewStatus = aDecoder.decodeOptionalBool(forKey: Constant.Key.autoRenewStatus.rawValue)
        let decodedAutoRenewProductId = aDecoder.decodeOptionalString(forKey: Constant.Key.autoRenewProductId.rawValue)

        self.init(
            internalTransactionId: decodedTransactionId,
            internalProductId: decodedProductId,
            internalPurchaseDate: decodedPurchaseDate,
            internalExpiresDate: decodedExpiresDate,
            internalNumberOfFamilyMembers: decodedNumberOfFamilyMembers,
            internalIsActive: decodedIsActive,
            internalAutoRenewStatus: decodedAutoRenewStatus,
            internalAutoRenewProductId: decodedAutoRenewProductId
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.

        if let transactionId = transactionId {
            aCoder.encode(transactionId, forKey: Constant.Key.transactionId.rawValue)
        }
        aCoder.encode(productId, forKey: Constant.Key.productId.rawValue)
        if let purchaseDate = purchaseDate {
            aCoder.encode(purchaseDate, forKey: Constant.Key.purchaseDate.rawValue)
        }
        if let expiresDate = expiresDate {
            aCoder.encode(expiresDate, forKey: Constant.Key.expiresDate.rawValue)
        }
        aCoder.encode(numberOfFamilyMembers, forKey: Constant.Key.numberOfFamilyMembers.rawValue)
        aCoder.encode(isActive, forKey: Constant.Key.isActive.rawValue)
        aCoder.encode(autoRenewStatus, forKey: Constant.Key.autoRenewStatus.rawValue)
        aCoder.encode(autoRenewProductId, forKey: Constant.Key.autoRenewProductId.rawValue)
    }
    
    // MARK: - Properties

    /// Transaction Id that of the subscription purchase
    private(set) var transactionId: Int?

    /// ProductId that the subscription purchase was for. No product means its a default subscription
    private(set) var productId: String

    /// Date at which the subscription was purchased and completed processing on Hound's server
    private(set) var purchaseDate: Date?

    /// Date at which the subscription will expire
    private(set) var expiresDate: Date?

    /// How many family members the subscription allows into the family
    private(set) var numberOfFamilyMembers: Int

    /// Indicates whether or not this subscription is the one thats active for the family
    var isActive: Bool

    /// Indicates whether or not this subscription will renew itself when it expires
    private(set) var autoRenewStatus: Bool

    /// The product identifier of the product that renews at the next billing period./
    private(set) var autoRenewProductId: String

    // MARK: - Main

    init(
        forTransactionId: Int?,
        forProductId: String,
        forPurchaseDate: Date?,
        forExpiresDate: Date?,
        forNumberOfFamilyMembers: Int,
        forIsActive: Bool,
        forAutoRenewStatus: Bool,
        forAutoRenewProductId: String
    ) {
        self.transactionId = forTransactionId
        self.productId = forProductId
        self.purchaseDate = forPurchaseDate
        self.expiresDate = forExpiresDate
        self.numberOfFamilyMembers = forNumberOfFamilyMembers
        self.isActive = forIsActive
        self.autoRenewStatus = forAutoRenewStatus
        self.autoRenewProductId = forAutoRenewProductId
        super.init()
    }
    
    private convenience init(
        internalTransactionId: Int?,
        internalProductId: String?,
        internalPurchaseDate: Date?,
        internalExpiresDate: Date?,
        internalNumberOfFamilyMembers: Int?,
        internalIsActive: Bool?,
        internalAutoRenewStatus: Bool?,
        internalAutoRenewProductId: String?
    ) {
        self.init(
            forTransactionId: internalTransactionId,
            forProductId: internalProductId ?? Constant.Class.Subscription.defaultProductId,
            forPurchaseDate: internalPurchaseDate,
            forExpiresDate: internalExpiresDate,
            forNumberOfFamilyMembers: internalNumberOfFamilyMembers ?? Constant.Class.Subscription.defaultSubscriptionNumberOfFamilyMembers,
            forIsActive: internalIsActive ?? false,
            forAutoRenewStatus: internalAutoRenewStatus ?? true,
            forAutoRenewProductId: internalAutoRenewProductId ?? internalProductId ?? Constant.Class.Subscription.defaultProductId
        )
    }

    /// Assume array of family properties
    convenience init(fromBody body: JSONResponseBody) {
        let transactionId: Int? = body[Constant.Key.transactionId.rawValue] as? Int
        let productId: String? = body[Constant.Key.productId.rawValue] as? String
        let purchaseDate: Date? = (body[Constant.Key.purchaseDate.rawValue] as? String)?.formatISO8601IntoDate()
        let expiresDate: Date? = (body[Constant.Key.expiresDate.rawValue] as? String)?.formatISO8601IntoDate()
        let numberOfFamilyMembers = body[Constant.Key.numberOfFamilyMembers.rawValue] as? Int
        let isActive = body[Constant.Key.isActive.rawValue] as? Bool
        let autoRenewStatus = body[Constant.Key.autoRenewStatus.rawValue] as? Bool
        let autoRenewProductId = body[Constant.Key.autoRenewProductId.rawValue] as? String

        self.init(
            internalTransactionId: transactionId,
            internalProductId: productId,
            internalPurchaseDate: purchaseDate,
            internalExpiresDate: expiresDate,
            internalNumberOfFamilyMembers: numberOfFamilyMembers,
            internalIsActive: isActive,
            internalAutoRenewStatus: autoRenewStatus,
            internalAutoRenewProductId: autoRenewProductId
        )
    }

}
