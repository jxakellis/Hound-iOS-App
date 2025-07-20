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
            keychain.set(userIdentifier, forKey: Constant.Key.userIdentifier.rawValue)
            UserDefaults.standard.set(userIdentifier, forKey: Constant.Key.userIdentifier.rawValue)
        }

        if let email = UserInformation.userEmail {
            keychain.set(email, forKey: Constant.Key.userEmail.rawValue)
            UserDefaults.standard.set(email, forKey: Constant.Key.userEmail.rawValue)
        }

        if let firstName = UserInformation.userFirstName {
            keychain.set(firstName, forKey: Constant.Key.userFirstName.rawValue)
            UserDefaults.standard.set(firstName, forKey: Constant.Key.userFirstName.rawValue)
        }

        if let lastName = UserInformation.userLastName {
            keychain.set(lastName, forKey: Constant.Key.userLastName.rawValue)
            UserDefaults.standard.set(lastName, forKey: Constant.Key.userLastName.rawValue)
        }
        
        // The important
        toUserDefaults.set(UserInformation.userId, forKey: Constant.Key.userId.rawValue)
        toUserDefaults.set(UserInformation.familyId, forKey: Constant.Key.familyId.rawValue)
        toUserDefaults.set(UserInformation.userAppAccountToken, forKey: Constant.Key.userAppAccountToken.rawValue)
        toUserDefaults.set(UserInformation.userNotificationToken, forKey: Constant.Key.userNotificationToken.rawValue)
    }
    
    /// Loads all of the UserInformation variables from the specified UserDefaults and, selectively, some from KeychainSwift
    static func load(fromUserDefaults: UserDefaults) {
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier =
        keychain.get(Constant.Key.userIdentifier.rawValue)
        ?? fromUserDefaults.value(forKey: Constant.Key.userIdentifier.rawValue) as? String
        ?? Constant.Development.developmentDatabaseTestUserIdentifier
        ?? UserInformation.userIdentifier
        
        UserInformation.userEmail =
        keychain.get(Constant.Key.userEmail.rawValue)
        ?? fromUserDefaults.value(forKey: Constant.Key.userEmail.rawValue) as? String
        ?? UserInformation.userEmail
        
        UserInformation.userFirstName =
        keychain.get(Constant.Key.userFirstName.rawValue)
        ?? fromUserDefaults.value(forKey: Constant.Key.userFirstName.rawValue) as? String
        ?? UserInformation.userFirstName
        
        UserInformation.userLastName =
        keychain.get(Constant.Key.userLastName.rawValue)
        ?? fromUserDefaults.value(forKey: Constant.Key.userLastName.rawValue) as? String
        ?? UserInformation.userLastName
        
        // MARK: Load Rest of User Information (excluding that which was loaded from the keychain)
        
        UserInformation.userId = fromUserDefaults.value(forKey: Constant.Key.userId.rawValue) as? String ?? UserInformation.userId ?? Constant.Development.developmentDatabaseTestUserId
        
        UserInformation.familyId = fromUserDefaults.value(forKey: Constant.Key.familyId.rawValue) as? String ?? UserInformation.familyId
        
        UserInformation.userAppAccountToken = fromUserDefaults.value(forKey: Constant.Key.userAppAccountToken.rawValue) as? String ?? UserInformation.userAppAccountToken
        
        UserInformation.userNotificationToken = fromUserDefaults.value(forKey: Constant.Key.userNotificationToken.rawValue) as? String ?? UserInformation.userNotificationToken
    }
    
    // MARK: - Properties
    
    static var userId: String?

    static var userIdentifier: String?
    
    static var familyId: String?

    static var userAppAccountToken: String?

    static var userNotificationToken: String?

    static var userEmail: String?

    static var userFirstName: String?

    static var userLastName: String?
    
    // MARK: - Main
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: JSONResponseBody) {
        if let userId = body[Constant.Key.userId.rawValue] as? String {
            self.userId = userId
        }
        if let familyId = body[Constant.Key.familyId.rawValue] as? String {
            self.familyId = familyId
        }
        if let userAppAccountToken = body[Constant.Key.userAppAccountToken.rawValue] as? String {
            self.userAppAccountToken = userAppAccountToken
        }
        if let userNotificationToken = body[Constant.Key.userNotificationToken.rawValue] as? String {
            self.userNotificationToken = userNotificationToken
        }
        if let userEmail = body[Constant.Key.userEmail.rawValue] as? String {
            self.userEmail = userEmail
        }
        if let userFirstName = body[Constant.Key.userFirstName.rawValue] as? String {
            self.userFirstName = userFirstName
        }
        if let userLastName = body[Constant.Key.userLastName.rawValue] as? String {
            self.userLastName = userLastName
        }
    }
    
    // MARK: - Computed Properties
    
    /// The users member's full name. Handles cases where the first name and/or last name may be ""
    static var displayFullName: String {
        let trimmedFirstName = userFirstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = userLastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // check to see if anything is blank
        if trimmedFirstName.isEmpty && trimmedLastName.isEmpty {
            return Constant.VisualText.unknownName
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
    
    // MARK: - Function
    
    /// Returns an array literal of the user information's properties. This is suitable to be used as the JSON body for a HTTP request
    static func createBody(addingOntoBody: JSONRequestBody?) -> JSONRequestBody {
        var body: JSONRequestBody = addingOntoBody ?? [:]
        body[Constant.Key.userEmail.rawValue] = .string(UserInformation.userEmail)
        body[Constant.Key.userFirstName.rawValue] = .string(UserInformation.userFirstName)
        body[Constant.Key.userLastName.rawValue] = .string(UserInformation.userLastName)
        return body
    }
}
