//
//  UserInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Information specific to the user.
enum UserInformation {
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: PrimativeTypeProtocol?]) {
        if let userId = body[KeyConstant.userId.rawValue] as? String {
            self.userId = userId
        }
        if let userAppAccountToken = body[KeyConstant.userAppAccountToken.rawValue] as? String {
            self.userAppAccountToken = userAppAccountToken
        }
        if let userNotificationToken = body[KeyConstant.userNotificationToken.rawValue] as? String {
            self.userNotificationToken = userNotificationToken
        }
        if let userEmail = body[KeyConstant.userEmail.rawValue] as? String {
            self.userEmail = userEmail
        }
        if let userFirstName = body[KeyConstant.userFirstName.rawValue] as? String {
            self.userFirstName = userFirstName
        }
        if let userLastName = body[KeyConstant.userLastName.rawValue] as? String {
            self.userLastName = userLastName
        }
    }

    static var userId: String?

    static var userIdentifier: String?

    static var userAppAccountToken: String?

    static var userNotificationToken: String?

    static var userEmail: String?

    static var userFirstName: String?

    static var userLastName: String?
}

extension UserInformation {
    // MARK: -

    /// The users member's full name. Handles cases where the first name and/or last name may be ""
    static var displayFullName: String {
        let trimmedFirstName = userFirstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = userLastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // check to see if anything is blank
        if trimmedFirstName.isEmpty && trimmedLastName.isEmpty {
            return VisualConstant.TextConstant.unknownName
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
    
    static var isUserFamilyHead: Bool {
        return FamilyInformation.findFamilyMember(forUserId: UserInformation.userId)?.isUserFamilyHead ?? false
    }

    // MARK: - Request
    /// Returns an array literal of the user information's properties. This is suitable to be used as the JSON body for a HTTP request
    static func createBody(addingOntoBody body: [String: PrimativeTypeProtocol?]?) -> [String: PrimativeTypeProtocol?] {
        var body: [String: PrimativeTypeProtocol?] = body ?? [:]
        body[KeyConstant.userEmail.rawValue] = UserInformation.userEmail
        body[KeyConstant.userFirstName.rawValue] = UserInformation.userFirstName
        body[KeyConstant.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
}
