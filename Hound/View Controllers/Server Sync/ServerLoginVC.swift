//
//  ServerLoginViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import AuthenticationServices
import KeychainSwift
import UIKit

final class ServerLoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate {
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else {
            return ASPresentationAnchor()
        }
        
        return window
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            ErrorConstant.SignInWithAppleError.other().alert()
            return
        }
        
        // TO DO FUTURE send identityToken and authorizationCode to the server. Have the server then extract components from that
        // appleIDCredential.identityToken
        // appleIDCredential.authorizationCode
        
        let keychain = KeychainSwift()
        
        // IMPORTANT NOTES ABOUT PERSISTANCE AND KEYCHAIN
        // fullName and email are ONLY provided on the FIRST time the user uses sign in with apple
        // If they are signing in again to Hound, only userIdentifier is provided
        // Therefore we must persist these email, firstName, and lastName to the keychain until an account is successfully created.
        
        // REASONING ABOUT PERSISTANCE AND KEYCHAIN
        // If the user signs in with apple and we go to create an account on Hound's server, but the request fails. We are in a tricky spot. If the user tries to 'Sign In With Apple' again, we can't retrieve the first name, last name, or email again... we only get userIdentifier.
        // Therefore, this could create an edge case where the user could be
        // 1. try to sign up in
        // 2. the sign up fails for whatever reason (e.g. they have no internet)
        // 3. they uninstall Hound
        // 4. they reinstall Hound
        // 5. they go to 'sign in with apple', but since Apple recognizes they have already done that with Hound, we only get the userIdentifier
        // 6. the user is stuck. they have no account on the server and can't create one since we are unable to access the email, first name, and last name. The only way to fix this would be having them go into the iCloud 'Password & Security' settings and deleting Hound, giving them a fresh start.
        
        UserInformation.userIdentifier = appleIDCredential.user
        
        if let userIdentifier = UserInformation.userIdentifier {
            keychain.set(userIdentifier, forKey: KeyConstant.userIdentifier.rawValue)
            UserDefaults.standard.set(userIdentifier, forKey: KeyConstant.userIdentifier.rawValue)
        }
        
        if let email = appleIDCredential.email {
            UserInformation.userEmail = email
            keychain.set(email, forKey: KeyConstant.userEmail.rawValue)
            UserDefaults.standard.set(email, forKey: KeyConstant.userEmail.rawValue)
        }
    
        if let firstName = appleIDCredential.fullName?.givenName {
            UserInformation.userFirstName = firstName
            keychain.set(firstName, forKey: KeyConstant.userFirstName.rawValue)
            UserDefaults.standard.set(firstName, forKey: KeyConstant.userFirstName.rawValue)
        }
    
        if let lastName = appleIDCredential.fullName?.familyName {
            UserInformation.userLastName = lastName
            keychain.set(lastName, forKey: KeyConstant.userLastName.rawValue)
            UserDefaults.standard.set(lastName, forKey: KeyConstant.userLastName.rawValue)
        }
        
        // not currently in use but we still persist them for potential future use
        if let middleName = appleIDCredential.fullName?.middleName {
            keychain.set(middleName, forKey: KeyConstant.userMiddleName.rawValue)
            UserDefaults.standard.set(middleName, forKey: KeyConstant.userMiddleName.rawValue)
        }
        if let namePrefix = appleIDCredential.fullName?.namePrefix {
            keychain.set(namePrefix, forKey: KeyConstant.userNamePrefix.rawValue)
            UserDefaults.standard.set(namePrefix, forKey: KeyConstant.userNamePrefix.rawValue)
        }
        if let nameSuffix = appleIDCredential.fullName?.nameSuffix {
            keychain.set(nameSuffix, forKey: KeyConstant.userNameSuffix.rawValue)
            UserDefaults.standard.set(nameSuffix, forKey: KeyConstant.userNameSuffix.rawValue)
        }
        if let nickname = appleIDCredential.fullName?.nickname {
            keychain.set(nickname, forKey: KeyConstant.userNickname.rawValue)
            UserDefaults.standard.set(nickname, forKey: KeyConstant.userNickname.rawValue)
        }
        
        signInUser()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user hit cancel on the 'Data and privacy information screen'
            ErrorConstant.SignInWithAppleError.canceled().alert()
        case .unknown:
            // user not signed into apple id
            ErrorConstant.SignInWithAppleError.notSignedIn().alert()
        default:
            ErrorConstant.SignInWithAppleError.other().alert()
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var welcome: ScaledUILabel!
    
    @IBOutlet private weak var welcomeMessage: ScaledUILabel!
    
    // MARK: - Properties
    
    private var signInWithApple: ASAuthorizationAppleIDButton!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we want the user to have a fresh login experience, so we reset the introduction pages
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = false
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = false
        
        // all other information tracks something important and shouldn't be modified, we simply do this so the user is greeted
        
        if UserInformation.userIdentifier != nil {
            // we found a userIdentifier in the keychain (during recurringSetup) so we change the info to match.
            // we could technically automatically log then in but this is easier. this verifies that an account exists and creates once if needed (if old one was deleted somehow)
            welcome.text = "Welcome Back"
            welcomeMessage.text = "Sign in to your existing Hound account below. If you don't have one, creating or joining a family will come soon..."
        }
        else {
            // no info in keychain, assume first time setup
            welcome.text = "Welcome"
            welcomeMessage.text = "Create your Hound account below. Creating or joining a family will come soon..."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupSignInWithApple()
        setupSignInWithAppleDisclaimer()
        func setupSignInWithApple() {
            // make actual button
            if UserInformation.userIdentifier != nil {
                // pre existing data
                signInWithApple = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            }
            else {
                // no preexisting data, new
                signInWithApple = ASAuthorizationAppleIDButton(type: .signUp, style: .whiteOutline)
            }
            
            signInWithApple.translatesAutoresizingMaskIntoConstraints = false
            signInWithApple.addTarget(self, action: #selector(signInWithAppleTapped), for: .touchUpInside)
            self.view.addSubview(signInWithApple)
            
            let constraints = [signInWithApple.topAnchor.constraint(equalTo: welcomeMessage.bottomAnchor, constant: 45),
                               signInWithApple.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                               signInWithApple.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                               signInWithApple.heightAnchor.constraint(equalTo: signInWithApple.widthAnchor, multiplier: 0.16)]
            NSLayoutConstraint.activate(constraints)
            // set to made to have fully rounded corners
            signInWithApple.cornerRadius = CGFloat.greatestFiniteMagnitude
            
        }
        
        func setupSignInWithAppleDisclaimer() {
            let signInWithAppleDisclaimer = ScaledUILabel()
            
            signInWithAppleDisclaimer.text = "Currently, Hound only offers accounts through the 'Sign \(UserInformation.userIdentifier == nil ? "Up" : "In") With Apple' feature. This requires you have an Apple ID with two-factor authentication enabled."
            
            signInWithAppleDisclaimer.translatesAutoresizingMaskIntoConstraints = false
            signInWithAppleDisclaimer.numberOfLines = 0
            signInWithAppleDisclaimer.font = VisualConstant.FontConstant.lightDescriptionUILabel
            signInWithAppleDisclaimer.textColor = .white
            
            self.view.addSubview(signInWithAppleDisclaimer)
            
            let constraints = [
                signInWithAppleDisclaimer.topAnchor.constraint(equalTo: signInWithApple.bottomAnchor, constant: 12.5),
                signInWithAppleDisclaimer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0 + (signInWithApple.frame.height / 2)),
                signInWithAppleDisclaimer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10 - (signInWithApple.frame.height / 2))]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    @objc private func signInWithAppleTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func signUpUser() {
        AlertManager.beginFetchingInformationIndictator()
        UserRequest.create(invokeErrorManager: true) { _, responseStatus, requestId, responseId in
            switch responseStatus {
            case .successResponse:
                // successful, continue
                if UserInformation.userId != nil {
                    AlertManager.endFetchingInformationIndictator {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    AlertManager.endFetchingInformationIndictator {
                        ErrorConstant.GeneralResponseError.postFailureResponse(forRequestId: requestId, forResponseId: responseId).alert()
                    }
                }
            case .failureResponse:
                AlertManager.endFetchingInformationIndictator {
                    ErrorConstant.GeneralResponseError.postFailureResponse(forRequestId: requestId, forResponseId: responseId).alert()
                }
            case .noResponse:
                AlertManager.endFetchingInformationIndictator {
                    ErrorConstant.GeneralResponseError.postNoResponse().alert()
                }
            }
        }
    }
    
    private func signInUser() {
        AlertManager.beginFetchingInformationIndictator()
        UserRequest.get(invokeErrorManager: false) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                AlertManager.endFetchingInformationIndictator {
                    self.dismiss(animated: true)
                }
            case .failureResponse:
                self.signUpUser()
            case .noResponse:
                AlertManager.endFetchingInformationIndictator {
                    ErrorConstant.GeneralResponseError.getNoResponse().alert()
                }
            }
        }
    }
}
