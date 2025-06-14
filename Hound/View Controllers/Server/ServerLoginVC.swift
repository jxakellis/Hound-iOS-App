//
//  ServerLoginViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import AuthenticationServices
import UIKit

final class ServerLoginViewController: GeneralUIViewController,
                                       ASAuthorizationControllerDelegate,
                                       ASAuthorizationControllerPresentationContextProviding,
                                       UITextFieldDelegate {
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the window into which the authorization controller should present
        return self.view.window ?? ASPresentationAnchor()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            ErrorConstant.SignInWithAppleError.other().alert()
            return
        }
        
        // Persist Apple ID info (only available on first sign–in) into UserInformation & UserDefaults
        UserInformation.userIdentifier = appleIDCredential.user
        UserInformation.userEmail = appleIDCredential.email ?? UserInformation.userEmail
        UserInformation.userFirstName = appleIDCredential.fullName?.givenName ?? UserInformation.userFirstName
        UserInformation.userLastName = appleIDCredential.fullName?.familyName ?? UserInformation.userLastName
        UserInformation.persist(toUserDefaults: UserDefaults.standard)
        
        signInUser()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle errors from Sign In with Apple
        guard let authError = error as? ASAuthorizationError else { return }
        switch authError.code {
        case .canceled:
            // The user cancelled Apple sign–in; no alert needed
            break
        case .unknown:
            ErrorConstant.SignInWithAppleError.notSignedIn().alert()
        default:
            ErrorConstant.SignInWithAppleError.other().alert()
        }
    }
    
    // MARK: - Elements
    
    /// Covers the bottom content; white background overlapping the image
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    /// Top “hero” image
    private let imageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        
        imageView.image = UIImage(named: "darkTealMeadowsMenWalkingDogs")
        
        return imageView
    }()
    
    /// “Welcome” title label
    private let welcomeLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    /// Under‐title description, potentially multiline
    private let welcomeDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    /// “Sign In/Up with Apple” button; its type depends on whether userIdentifier exists
    private lazy var signInWithAppleButton: ASAuthorizationAppleIDButton = {
        let buttonType: ASAuthorizationAppleIDButton.ButtonType = (UserInformation.userIdentifier != nil) ? .signIn : .signUp
        let btn = ASAuthorizationAppleIDButton(type: buttonType, style: .whiteOutline)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.cornerRadius = CGFloat.greatestFiniteMagnitude
        btn.addTarget(self, action: #selector(didTouchUpInsideSignInWithApple), for: .touchUpInside)
        return btn
    }()
    
    /// Description below the Apple button
    private let signInWithAppleDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.tertiaryLabelColorButtonDescriptionLabel
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        let mode = (UserInformation.userIdentifier == nil) ? "Up" : "In"
        label.text = """
            Currently, Hound only offers accounts through the “Sign \(mode) With Apple” feature. \
            As per Apple, this requires you have an Apple ID with two‐factor authentication enabled.
            """
        return label
    }()
    
    // MARK: - Main Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // Dynamically decide which “Welcome” text to show:
        if UserInformation.userIdentifier != nil {
            welcomeLabel.text = "Welcome back to Hound"
            welcomeDescriptionLabel.text = """
                Sign in to your existing Hound account below. If you don't have one, \
                creating or joining a family will come soon...
                """
        }
        else {
            welcomeLabel.text = "Welcome to Hound"
            welcomeDescriptionLabel.text = """
                Create your Hound account below. Creating or joining a family will come soon...
                """
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust corner radius & border of the Apple button once sizes are known
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
    
    /// Kick off the user sign‐in / sign‐up flow, showing activity indicator and dismissing on success.
    private func signInUser() {
        PresentationManager.beginFetchingInformationIndicator()
        
        UserRequest.create(forErrorAlert: .automaticallyAlertForNone) { responseStatus, houndErrorCreate in
            guard responseStatus != .failureResponse else {
                // If creation failed, try “get” in case the account already exists:
                UserRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure) { responseStatus, houndErrorGet in
                    PresentationManager.endFetchingInformationIndicator {
                        guard responseStatus != .failureResponse else {
                            // Show error from GET if it failed:
                            (houndErrorGet ?? ErrorConstant.GeneralResponseError.getFailureResponse(forRequestId: -1, forResponseId: -1)).alert()
                            return
                        }
                        // If GET succeeded, but userId is still missing, that’s unexpected:
                        guard UserInformation.userId != nil else {
                            (houndErrorGet ?? ErrorConstant.GeneralResponseError.getNoResponse()).alert()
                            return
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            // On successful create (or no‐response but userId set):
            guard UserInformation.userId != nil else {
                (houndErrorCreate ?? ErrorConstant.GeneralResponseError.getNoResponse()).alert()
                return
            }
            
            // All good; dismiss:
            PresentationManager.endFetchingInformationIndicator {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(imageView)
        view.addSubview(whiteBackgroundView)
        view.addSubview(welcomeLabel)
        view.addSubview(welcomeDescriptionLabel)
        view.addSubview(signInWithAppleButton)
        view.addSubview(signInWithAppleDescriptionLabel)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -25),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            welcomeLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 30),
            
            welcomeDescriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 7.5),
            welcomeDescriptionLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            welcomeDescriptionLabel.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            
            signInWithAppleButton.topAnchor.constraint(
                greaterThanOrEqualTo: welcomeDescriptionLabel.bottomAnchor,
                constant: 15.0
            ),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            signInWithAppleButton.heightAnchor.constraint(
                equalTo: signInWithAppleButton.widthAnchor,
                multiplier: 0.16
            ),
            
            signInWithAppleDescriptionLabel.topAnchor.constraint(
                equalTo: signInWithAppleButton.bottomAnchor,
                constant: 12.5
            ),
            signInWithAppleDescriptionLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            signInWithAppleDescriptionLabel.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            signInWithAppleDescriptionLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15.0
            )
        ])
    }
}
