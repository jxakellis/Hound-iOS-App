//
//  ServerLoginViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import AuthenticationServices
import UIKit

final class ServerLoginViewController: GeneralUIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate {

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
        UserInformation.userEmail = appleIDCredential.email ?? UserInformation.userEmail
        UserInformation.userFirstName = appleIDCredential.fullName?.givenName ?? UserInformation.userFirstName
        UserInformation.userLastName = appleIDCredential.fullName?.familyName ?? UserInformation.userLastName

        // Important to persist this information to immediately
        UserInformation.persist(toUserDefaults: UserDefaults.standard)

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
            // this is normal, don't show an error
            // ErrorConstant.SignInWithAppleError.canceled().alert()
            break
        case .unknown:
            // user not signed into apple id
            ErrorConstant.SignInWithAppleError.notSignedIn().alert()
        default:
            ErrorConstant.SignInWithAppleError.other().alert()
        }
    }

    // MARK: - IB

    @IBOutlet private weak var whiteBackgroundView: UIView!

    @IBOutlet private weak var welcomeLabel: GeneralUILabel!
    @IBOutlet private weak var welcomeDescriptionLabel: GeneralUILabel!

    // MARK: - Properties

    private var signInWithAppleButton: ASAuthorizationAppleIDButton!

    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

        if UserInformation.userIdentifier != nil {
            // we found a userIdentifier in the keychain (during recurringSetup) so we change the info to match.
            // we could technically automatically log then in but this is easier. this verifies that an account exists and creates once if needed (if old one was deleted somehow)
            welcomeLabel.text = "Welcome back to Hound"
            welcomeDescriptionLabel.text = "Sign in to your existing Hound account below. If you don't have one, creating or joining a family will come soon..."
        }
        else {
            // no info in keychain, assume first time setup
            welcomeLabel.text = "Welcome to Hound"
            welcomeDescriptionLabel.text = "Create your Hound account below. Creating or joining a family will come soon..."
        }

        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous

        // Create signInWithAppleButton and constrain it in the subview
        signInWithAppleButton = ASAuthorizationAppleIDButton(type: UserInformation.userIdentifier != nil ? .signIn : .signUp, style: .whiteOutline)

        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleButton.cornerRadius = CGFloat.greatestFiniteMagnitude

        signInWithAppleButton.addTarget(self, action: #selector(didTouchUpInsideSignInWithApple), for: .touchUpInside)
        self.view.addSubview(signInWithAppleButton)

        let signInWithAppleButtonConstraints = [
            signInWithAppleButton.topAnchor.constraint(greaterThanOrEqualTo: welcomeDescriptionLabel.bottomAnchor, constant: 15.0),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            signInWithAppleButton.heightAnchor.constraint(equalTo: signInWithAppleButton.widthAnchor, multiplier: 0.16)
        ]
        NSLayoutConstraint.activate(signInWithAppleButtonConstraints)

        // Create signInWithAppleDescriptionLabel and constrain it in the subview
        let signInWithAppleDescriptionLabel = GeneralUILabel()

        signInWithAppleDescriptionLabel.text = "Currently, Hound only offers accounts through the 'Sign \(UserInformation.userIdentifier == nil ? "Up" : "In") With Apple' feature. As per Apple, this feature requires you have an Apple ID with two-factor authentication enabled."
        signInWithAppleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleDescriptionLabel.numberOfLines = 0
        signInWithAppleDescriptionLabel.font = VisualConstant.FontConstant.tertiaryLabelColorButtonDescriptionLabel
        signInWithAppleDescriptionLabel.textColor = .tertiaryLabel
        signInWithAppleDescriptionLabel.textAlignment = .center
        self.view.addSubview(signInWithAppleDescriptionLabel)

        let signInWithAppleDescriptionLabelConstraints = [
            signInWithAppleDescriptionLabel.topAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: 12.5),
            signInWithAppleDescriptionLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            signInWithAppleDescriptionLabel.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            signInWithAppleDescriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15.0)
        ]
        NSLayoutConstraint.activate(signInWithAppleDescriptionLabelConstraints)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // This code will not work correctly inside viewIsAppearing. The signInWithAppleButton is special.
        signInWithAppleButton.layer.cornerRadius = signInWithAppleButton.frame.height / 2
        signInWithAppleButton.layer.borderWidth = 2.0
        signInWithAppleButton.layer.borderColor = UIColor.label.cgColor
    }

    // MARK: - Functions

    @objc private func didTouchUpInsideSignInWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func signInUser() {
        PresentationManager.beginFetchingInformationIndicator()
        
        UserRequest.create(forErrorAlert: .automaticallyAlertForNone) { responseStatus, houndErrorCreate in
            guard responseStatus != .failureResponse else {
                
                UserRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure) { responseStatus, houndErrorGet in
                    
                    PresentationManager.endFetchingInformationIndicator {
                        guard responseStatus != .failureResponse else {
                            // Failure response for UserRequest.get
                            (houndErrorGet ?? ErrorConstant.GeneralResponseError.getFailureResponse(forRequestId: -1, forResponseId: -1)).alert()
                            return
                        }
                        
                        guard UserInformation.userId != nil else {
                            // responseStatus is either .successful or .noResponse, but the user doesn't have a userId.
                            (houndErrorGet ?? ErrorConstant.GeneralResponseError.getNoResponse()).alert()
                            return
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
                
                return
            }
            
            guard UserInformation.userId != nil else {
                // responseStatus is either .successful or .noResponse, but the user doesn't have a userId.
                (houndErrorCreate ?? ErrorConstant.GeneralResponseError.getNoResponse()).alert()
                return
            }
            
            // Either successful or no response, but the user has a userId, so we can proceed
            PresentationManager.endFetchingInformationIndicator {
                self.dismiss(animated: true)
            }
        }
    }
}
