//
//  FamilyInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
enum FamilyInformation {

    // MARK: - Main

    /// Sets the FamilyInformation values equal to all the values found in the body. The key for the each body value must match the name of the FamilyInformation property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any?]) {
        if let familyHeadUserId = body[KeyConstant.familyHeadUserId.rawValue] as? String {
            self.familyHeadUserId = familyHeadUserId
        }
        if let familyIsLocked = body[KeyConstant.familyIsLocked.rawValue] as? Bool {
            self.familyIsLocked = familyIsLocked
        }
        if let familyCode = body[KeyConstant.familyCode.rawValue] as? String {
            self.familyCode = familyCode
        }
        if let familyMembersBody = body[KeyConstant.familyMembers.rawValue] as? [[String: Any?]] {
            familyMembers.removeAll()
            // get individual bodies for members
            for familyMemberBody in familyMembersBody {
                // convert body into family member
                familyMembers.append(FamilyMember(fromBody: familyMemberBody))
            }

            familyMembers.sort(by: { $0 <= $1 })
        }
        if let previousFamilyMembersBody = body[KeyConstant.previousFamilyMembers.rawValue] as? [[String: Any?]] {
            previousFamilyMembers.removeAll()

            // get individual bodies for previous family members
            for previousFamilyMemberBody in previousFamilyMembersBody {
                // convert body into family member; a previousFamilyMember can't be a family head so pass nil
                previousFamilyMembers.append(FamilyMember(fromBody: previousFamilyMemberBody))
            }

            previousFamilyMembers.sort(by: { $0 <= $1 })

        }
        if let familyActiveSubscriptionBody = body[KeyConstant.familyActiveSubscription.rawValue] as? [String: Any?] {
            let familyActiveSubscription = Subscription(fromBody: familyActiveSubscriptionBody)
            addFamilySubscription(forSubscription: familyActiveSubscription)
        }
    }

    // MARK: - Main
    
    private(set) static var familyHeadUserId: String?

    /// The code used by new users to join the family
    private(set) static var familyCode: String = ""

    /// If a family is locked, then no new members can join. Only the family head can lock and unlock the family.
    static var familyIsLocked: Bool = false

    /// Users that used to be in the family
    private(set) static var previousFamilyMembers: [FamilyMember] = []

    /// Users that are currently in the family
    private(set) static var familyMembers: [FamilyMember] = []

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

    private(set) static var familySubscriptions: [Subscription] = []

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

    static var activeFamilySubscription: Subscription {
        let potentialSubscription = familySubscriptions.first { subscription in
            subscription.isActive
        }

        return potentialSubscription ?? ClassConstant.SubscriptionConstant.defaultSubscription
    }

}
