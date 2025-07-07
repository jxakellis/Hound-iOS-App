//
//  FamilyInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
final class FamilyInformation: UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    static func persist(toUserDefaults: UserDefaults) {
        toUserDefaults.set(familyHeadUserId, forKey: KeyConstant.familyHeadUserId.rawValue)
        toUserDefaults.set(familyCode, forKey: KeyConstant.familyCode.rawValue)
        toUserDefaults.set(familyIsLocked, forKey: KeyConstant.familyIsLocked.rawValue)
        
        if let dataPreviousFamilyMembers = try? NSKeyedArchiver.archivedData(withRootObject: previousFamilyMembers, requiringSecureCoding: false) {
            toUserDefaults.set(dataPreviousFamilyMembers, forKey: KeyConstant.previousFamilyMembers.rawValue)
        }
        if let dataFamilyMembers = try? NSKeyedArchiver.archivedData(withRootObject: familyMembers, requiringSecureCoding: false) {
            toUserDefaults.set(dataFamilyMembers, forKey: KeyConstant.familyMembers.rawValue)
        }
        if let dataActiveFamilySubscription = try? NSKeyedArchiver.archivedData(withRootObject: familyActiveSubscription, requiringSecureCoding: false) {
            toUserDefaults.set(dataActiveFamilySubscription, forKey: KeyConstant.familyActiveSubscription.rawValue)
        }
    }
    
    static func load(fromUserDefaults: UserDefaults) {
        FamilyInformation.familyHeadUserId = fromUserDefaults.value(forKey: KeyConstant.familyHeadUserId.rawValue) as? String
        FamilyInformation.familyCode = fromUserDefaults.value(forKey: KeyConstant.familyCode.rawValue) as? String
        FamilyInformation.familyIsLocked = fromUserDefaults.value(forKey: KeyConstant.familyIsLocked.rawValue) as? Bool ?? FamilyInformation.familyIsLocked
       
        if let dataPreviousFamilyMembers: Data = UserDefaults.standard.data(forKey: KeyConstant.previousFamilyMembers.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataPreviousFamilyMembers) {
            unarchiver.requiresSecureCoding = false
            
            if let previousFamilyMembers = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [FamilyMember] {
                FamilyInformation.previousFamilyMembers = previousFamilyMembers
            }
            else {
                HoundLogger.general.error("step 2/2 Failed to decode previousFamilyMembers with unarchiver")
            }
        }
        else {
            HoundLogger.general.error("step 1/2 Failed to decode previousFamilyMembers with unarchiver")
        }
        
        if let dataFamilyMembers: Data = UserDefaults.standard.data(forKey: KeyConstant.familyMembers.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataFamilyMembers) {
            unarchiver.requiresSecureCoding = false
            
            if let familyMembers = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [FamilyMember] {
                FamilyInformation.familyMembers = familyMembers
            }
            else {
                HoundLogger.general.error("step 2/2 Failed to decode familyMembers with unarchiver")
            }
        }
        else {
            HoundLogger.general.error("step 1/2 Failed to decode familyMembers with unarchiver")
        }
        
        if let dataFamilyActiveSubscription: Data = UserDefaults.standard.data(forKey: KeyConstant.familyActiveSubscription.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataFamilyActiveSubscription) {
            unarchiver.requiresSecureCoding = false
            
            if let familyActiveSubscription = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? Subscription {
                // The familyActiveSubscription should always have isActive true. However, decodeBool might decode it as false if no key exists for that value.
                familyActiveSubscription.isActive = true
                FamilyInformation.addFamilySubscription(forSubscription: familyActiveSubscription)
            }
            else {
                HoundLogger.general.error("step 2/2 Failed to decode familyActiveSubscription with unarchiver")
            }
        }
        else {
            HoundLogger.general.error("step 1/2 Failed to decode familyActiveSubscription with unarchiver")
        }
    }
    
    // MARK: - Properties
    
    private(set) static var familyHeadUserId: String?

    /// The code used by new users to join the family
    private(set) static var familyCode: String?

    /// If a family is locked, then no new members can join. Only the family head can lock and unlock the family.
    static var familyIsLocked: Bool = false

    /// Users that used to be in the family
    private(set) static var previousFamilyMembers: [FamilyMember] = []

    /// Users that are currently in the family
    private(set) static var familyMembers: [FamilyMember] = []

    private(set) static var familySubscriptions: [Subscription] = []

    // MARK: - Main
    
    /// Sets the FamilyInformation values equal to all the values found in the fromBody. The key for the each fromBody value must match the name of the FamilyInformation property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody: [String: Any?]) {
        if let familyHeadUserId = fromBody[KeyConstant.familyHeadUserId.rawValue] as? String {
            self.familyHeadUserId = familyHeadUserId
        }
        if let familyIsLocked = fromBody[KeyConstant.familyIsLocked.rawValue] as? Bool {
            self.familyIsLocked = familyIsLocked
        }
        if let familyCode = fromBody[KeyConstant.familyCode.rawValue] as? String {
            self.familyCode = familyCode
        }
        if let familyMembersBody = fromBody[KeyConstant.familyMembers.rawValue] as? [[String: Any?]] {
            familyMembers.removeAll()
            // get individual bodies for members
            for familyMemberBody in familyMembersBody {
                // convert fromBody into family member
                familyMembers.append(FamilyMember(fromBody: familyMemberBody))
            }

            familyMembers.sort(by: { $0 <= $1 })
        }
        if let previousFamilyMembersBody = fromBody[KeyConstant.previousFamilyMembers.rawValue] as? [[String: Any?]] {
            previousFamilyMembers.removeAll()

            // get individual bodies for previous family members
            for previousFamilyMemberBody in previousFamilyMembersBody {
                // convert fromBody into family member; a previousFamilyMember can't be a family head so pass nil
                previousFamilyMembers.append(FamilyMember(fromBody: previousFamilyMemberBody))
            }

            previousFamilyMembers.sort(by: { $0 <= $1 })

        }
        if let familyActiveSubscriptionBody = fromBody[KeyConstant.familyActiveSubscription.rawValue] as? [String: Any?] {
            let familyActiveSubscription = Subscription(fromBody: familyActiveSubscriptionBody)
            addFamilySubscription(forSubscription: familyActiveSubscription)
        }
    }
    
    // MARK: - Computed Properties
    
    static var familyActiveSubscription: Subscription {
        let potentialSubscription = familySubscriptions.first { subscription in
            subscription.isActive
        }

        return potentialSubscription ?? ClassConstant.SubscriptionConstant.defaultSubscription
    }
    
    // MARK: - Functions
    
    static func findFamilyMember(forUserId userId: String?) -> FamilyMember? {
        guard let userId = userId else {
            return nil
        }

        let matchingFamilyMember: FamilyMember? = FamilyInformation.familyMembers.first { familyMember in
            familyMember.userId == userId
        } ?? FamilyInformation.previousFamilyMembers.first(where: { previousFamilyMember in
            previousFamilyMember.userId == userId
        })

        return matchingFamilyMember
    }

    static func addFamilySubscription(forSubscription subscription: Subscription) {
        // Remove any transactions that match the transactionId
        familySubscriptions.removeAll { existingSubscription in
            existingSubscription.transactionId == subscription.transactionId
        }

        if subscription.isActive {
            // There can only be one active subscription, so remove tag from others
            familySubscriptions.forEach { existingSubscription in
                existingSubscription.isActive = false
            }
            // Active subscription goes at the beginning
            familySubscriptions.insert(subscription, at: 0)
        }
        else {
            // Other subscriptions go at the end
            familySubscriptions.append(subscription)
        }
    }

    static func clearAllFamilySubscriptions() {
        familySubscriptions.removeAll()
    }

}
