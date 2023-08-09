//
//  Family.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class FamilyMember: NSObject {

    // MARK: - Main

    init(userId: String, firstName: String?, lastName: String?, isUserFamilyHead: Bool) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.isUserFamilyHead = isUserFamilyHead
        super.init()
    }

    /// Assume array of family properties
    convenience init(fromBody body: [String: Any], familyHeadUserId: String?) {
        let userId = body[KeyConstant.userId.rawValue] as? String ?? VisualConstant.TextConstant.unknownHash
        let firstName = body[KeyConstant.userFirstName.rawValue] as? String
        let lastName = body[KeyConstant.userLastName.rawValue] as? String
        self.init(userId: userId, firstName: firstName, lastName: lastName, isUserFamilyHead: familyHeadUserId == userId)
    }

    // MARK: - Properties

    /// The family member's first name
    private(set) var firstName: String?

    /// The family member's last name
    private(set) var lastName: String?

    /// The family member's userId
    private(set) var userId: String

    /// Indicates where or not this user is the head of the family
    private(set) var isUserFamilyHead: Bool = false

}

extension FamilyMember {
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
    var displayInitials: String? {
        let trimmedFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // check to see if anything is blank
        guard trimmedFirstName.isEmpty == false || trimmedLastName.isEmpty == false else {
            return nil
        }
        
        // User has a first name and/or a last name
        guard let firstNameInitial = trimmedFirstName.first else {
            // no first name but should have a last name
            if let initial = trimmedLastName.first {
                return String(initial).uppercased()
            }
            return nil
        }
        
        // User has a first name and maybe has a last name
        guard let lastNameInitial = trimmedLastName.first else {
            // no last name but should have a first name
            return String(firstNameInitial).uppercased()
        }
        
        return "\(firstNameInitial.uppercased()).\(lastNameInitial.uppercased())."
    }

}
