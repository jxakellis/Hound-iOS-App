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
    static func setup(fromBody body: [String: Any]) {
        if let familyHeadUserId = body[KeyConstant.familyHeadUserId.rawValue] as? String {
            self.familyHeadUserId = familyHeadUserId
        }
        if let familyIsLocked = body[KeyConstant.familyIsLocked.rawValue] as? Bool {
            self.familyIsLocked = familyIsLocked
        }
        if let familyCode = body[KeyConstant.familyCode.rawValue] as? String {
            self.familyCode = familyCode
        }
        if let familyMembersBody = body[KeyConstant.familyMembers.rawValue] as? [[String: Any]] {
            familyMembers.removeAll()
            // get individual bodies for members
            for familyMemberBody in familyMembersBody {
                // convert body into family member
                familyMembers.append(FamilyMember(fromBody: familyMemberBody))
            }

            // sort so family head is first then users in ascending userid order
            familyMembers.sort { familyMember1, familyMember2 in
                // the family head should always be first
                if familyMember1.isUserFamilyHead == true {
                    // 1st element is head so should come before therefore return true
                    return true
                }
                else if familyMember2.isUserFamilyHead == true {
                    // 2nd element is head so should come before therefore return false
                    return false
                }
                else {
                    // the user with the lower userId should come before the higher id
                    // if familyMember1 has a smaller userId then comparison returns true and then true is returned again, bringing familyMember1 to be first
                    // if familyMember2 has a smaller userId then comparison returns false and then false is returned, bringing familyMember2 to be first
                    return (familyMember1.userId < familyMember2.userId)
                }
            }
        }
        if let previousFamilyMembersBody = body[KeyConstant.previousFamilyMembers.rawValue] as? [[String: Any]] {
            previousFamilyMembers.removeAll()

            // get individual bodies for previous family members
            for previousFamilyMemberBody in previousFamilyMembersBody {
                // convert body into family member; a previousFamilyMember can't be a family head so pass nil
                previousFamilyMembers.append(FamilyMember(fromBody: previousFamilyMemberBody))
            }

            previousFamilyMembers.sort { previousFamilyMember1, previousFamilyMember2 in
                // the user with the lower userId should come before the higher id
                // if familyMember1 has a smaller userId then comparison returns true and then true is returned again, bringing familyMember1 to be first
                // if familyMember2 has a smaller userId then comparison returns false and then false is returned, bringing familyMember2 to be first
                return previousFamilyMember1.userId < previousFamilyMember2.userId
            }

        }
        if let familyActiveSubscriptionBody = body[KeyConstant.familyActiveSubscription.rawValue] as? [String: Any] {
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
    private static var previousFamilyMembers: [FamilyMember] = []

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
