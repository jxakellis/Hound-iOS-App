//
//  Family.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class FamilyMember: NSObject, NSCoding, Comparable {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedUserId: String? = aDecoder.decodeObject(forKey: KeyConstant.userId.rawValue) as? String
        let decodedUserFirstName: String? = aDecoder.decodeObject(forKey: KeyConstant.userFirstName.rawValue) as? String
        let decodedUserLastName: String? = aDecoder.decodeObject(forKey: KeyConstant.userLastName.rawValue) as? String
        
        self.init(
            internalUserId: decodedUserId,
            internalFirstName: decodedUserFirstName,
            internalLastName: decodedUserLastName
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        aCoder.encode(firstName, forKey: KeyConstant.userFirstName.rawValue)
        aCoder.encode(lastName, forKey: KeyConstant.userLastName.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: FamilyMember, rhs: FamilyMember) -> Bool {
        // the family head should always be first
        if lhs.isUserFamilyHead == true {
            // 1st element is head so should come before therefore return true
            return true
        }
        else if rhs.isUserFamilyHead == true {
            // 2nd element is head so should come before therefore return false
            return false
        }
        
        // Sort based upon name
        let lhsName = lhs.displayFullName ?? ""
        let rhsName = rhs.displayFullName ?? ""
        
        if lhsName.isEmpty && rhsName.isEmpty {
            // Both names are blank, use userId to determine order
            return lhs.userId <= rhs.userId
        }
        // we know one of OR both of the lhsName and rhsName are != nil &&.isEmpty == false
        else if lhsName.isEmpty {
            // no lhs name but has a rhs name
            return false
        }
        else if rhsName.isEmpty {
            // no rhs name but has lhs name
            return true
        }
        
        // Neither names are empty
        // "Bella" would come before "Zach"
        return lhsName <= rhsName
    }

    // MARK: - Properties
    
    /// The family member's userId
    private(set) var userId: String

    /// The family member's first name
    private(set) var firstName: String?

    /// The family member's last name
    private(set) var lastName: String?
    
    // MARK: - Main

    init(forUserId: String, forFirstName: String?, forLastName: String?) {
        self.userId = forUserId
        self.firstName = forFirstName
        self.lastName = forLastName
        super.init()
    }
    
    private convenience init(
        internalUserId: String?,
        internalFirstName: String?,
        internalLastName: String?
    ) {
        self.init(
            forUserId: internalUserId ?? VisualConstant.TextConstant.unknownHash,
            forFirstName: internalFirstName,
            forLastName: internalLastName
        )
    }

    /// Assume array of family properties
    convenience init(fromBody body: [String: Any?]) {
        let userId = body[KeyConstant.userId.rawValue] as? String
        let firstName = body[KeyConstant.userFirstName.rawValue] as? String
        let lastName = body[KeyConstant.userLastName.rawValue] as? String
        self.init(
            internalUserId: userId,
            internalFirstName: firstName,
            internalLastName: lastName
        )
    }
    
    // MARK: - Computed Properties
    
    var isUserFamilyHead: Bool {
        return self.userId == FamilyInformation.familyHeadUserId
    }
    
    /// The family member's full name. Handles cases where the first name and/or last name may be ""
    var displayFullName: String? {
        let trimmedFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // check to see if anything is blank
        if trimmedFirstName.isEmpty && trimmedLastName.isEmpty {
            return nil
        }
        // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil &&.isEmpty == false
        else if trimmedFirstName.isEmpty {
            // no first name but has last name
            return trimmedLastName
        }
        else if trimmedLastName.isEmpty {
            // no last name but has first name
            return trimmedFirstName
        }
        else {
            return "\(trimmedFirstName) \(trimmedLastName)"
        }
    }

    /// The family member's first name. Handles cases where the first name may be "", therefore trying to use the last name to substitute
    var displayPartialName: String? {
        if let trimmedFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return trimmedFirstName
        }
        else if let trimmedLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return trimmedLastName
        }
        
        return nil
    }
}
