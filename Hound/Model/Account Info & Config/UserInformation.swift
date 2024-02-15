//
//  UserInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import KeychainSwift

/// Information specific to the user.
final class UserInformation: UserDefaultPersistable {
    // MARK: - UserDefaultPersistable
    
    /// Persists all of the UserInformation variables to the specified UserDefaults and, selectively, some to KeychainSwift
    static func persist(toUserDefaults: UserDefaults) {
        let keychain = KeychainSwift()
        
        if let userIdentifier = UserInformation.userIdentifier {
            keychain.set(userIdentifier, forKey: KeyConstant.userIdentifier.rawValue)
            UserDefaults.standard.set(userIdentifier, forKey: KeyConstant.userIdentifier.rawValue)
        }

        if let email = UserInformation.userEmail {
            keychain.set(email, forKey: KeyConstant.userEmail.rawValue)
            UserDefaults.standard.set(email, forKey: KeyConstant.userEmail.rawValue)
        }

        if let firstName = UserInformation.userFirstName {
            keychain.set(firstName, forKey: KeyConstant.userFirstName.rawValue)
            UserDefaults.standard.set(firstName, forKey: KeyConstant.userFirstName.rawValue)
        }

        if let lastName = UserInformation.userLastName {
            keychain.set(lastName, forKey: KeyConstant.userLastName.rawValue)
            UserDefaults.standard.set(lastName, forKey: KeyConstant.userLastName.rawValue)
        }
        
        // The important
        toUserDefaults.set(UserInformation.userId, forKey: KeyConstant.userId.rawValue)
        toUserDefaults.set(UserInformation.familyId, forKey: KeyConstant.familyId.rawValue)
        toUserDefaults.set(UserInformation.userAppAccountToken, forKey: KeyConstant.userAppAccountToken.rawValue)
        toUserDefaults.set(UserInformation.userNotificationToken, forKey: KeyConstant.userNotificationToken.rawValue)
    }
    
    /// Loads all of the UserInformation variables from the specified UserDefaults and, selectively, some from KeychainSwift
    static func load(fromUserDefaults: UserDefaults) {
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier =
        keychain.get(KeyConstant.userIdentifier.rawValue)
        ?? fromUserDefaults.value(forKey: KeyConstant.userIdentifier.rawValue) as? String
        ?? DevelopmentConstant.developmentDatabaseTestUserIdentifier
        ?? UserInformation.userIdentifier
        
        UserInformation.userEmail =
        keychain.get(KeyConstant.userEmail.rawValue)
        ?? fromUserDefaults.value(forKey: KeyConstant.userEmail.rawValue) as? String
        ?? UserInformation.userEmail
        
        UserInformation.userFirstName =
        keychain.get(KeyConstant.userFirstName.rawValue)
        ?? fromUserDefaults.value(forKey: KeyConstant.userFirstName.rawValue) as? String
        ?? UserInformation.userFirstName
        
        UserInformation.userLastName =
        keychain.get(KeyConstant.userLastName.rawValue)
        ?? fromUserDefaults.value(forKey: KeyConstant.userLastName.rawValue) as? String
        ?? UserInformation.userLastName
        
        // MARK: Load Rest of User Information (excluding that which was loaded from the keychain)
        
        UserInformation.userId = fromUserDefaults.value(forKey: KeyConstant.userId.rawValue) as? String ?? UserInformation.userId ?? DevelopmentConstant.developmentDatabaseTestUserId
        
        UserInformation.familyId = fromUserDefaults.value(forKey: KeyConstant.familyId.rawValue) as? String ?? UserInformation.familyId
        
        UserInformation.userAppAccountToken = fromUserDefaults.value(forKey: KeyConstant.userAppAccountToken.rawValue) as? String ?? UserInformation.userAppAccountToken
        
        UserInformation.userNotificationToken = fromUserDefaults.value(forKey: KeyConstant.userNotificationToken.rawValue) as? String ?? UserInformation.userNotificationToken
    }
    
    // MARK: - Main
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any?]) {
        if let userId = body[KeyConstant.userId.rawValue] as? String {
            self.userId = userId
        }
        if let familyId = body[KeyConstant.familyId.rawValue] as? String {
            self.familyId = familyId
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
    
    static var familyId: String?

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
    static func createBody(addingOntoBody: [String: CompatibleDataTypeForJSON?]?) -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = addingOntoBody ?? [:]
        
        body[KeyConstant.userEmail.rawValue] = UserInformation.userEmail
        body[KeyConstant.userFirstName.rawValue] = UserInformation.userFirstName
        body[KeyConstant.userLastName.rawValue] = UserInformation.userLastName
        
        return body
    }
}
