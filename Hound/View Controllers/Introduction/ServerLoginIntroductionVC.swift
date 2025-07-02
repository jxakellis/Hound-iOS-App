//
//  ServerLoginIntroductionVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import AuthenticationServices
import UIKit

// UI VERIFIED 6/24/25
final class ServerLoginIntroductionVC: GeneralUIViewController,
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
    
    private let introductionView = IntroductionView()
    
    /// "Sign In/Up with Apple" button; its type depends on whether userIdentifier exists
    private lazy var signInWithAppleButton: ASAuthorizationAppleIDButton = {
        let buttonType: ASAuthorizationAppleIDButton.ButtonType = (UserInformation.userIdentifier != nil) ? .signIn : .signUp
        let btn = ASAuthorizationAppleIDButton(type: buttonType, style: .whiteOutline)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.cornerRadius = CGFloat.greatestFiniteMagnitude
        btn.addTarget(self, action: #selector(didTouchUpInsideSignInWithApple), for: .touchUpInside)
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = UIColor.label.cgColor
        return btn
    }()
    
    /// Description below the Apple button
    private let signInWithAppleDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.tertiaryColorDescLabel
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        let mode = (UserInformation.userIdentifier == nil) ? "Up" : "In"
        label.text = """
            Currently, Hound only offers accounts through the "Sign \(mode) With Apple" feature. \
            As per Apple, this requires you have an Apple ID with two‐factor authentication enabled.
            """
        return label
    }()
    
    /// Stack view containing sign-in button and description
    private var signInStack: UIStackView!
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        introductionView.backgroundImageView.image = UIImage(named: "darkTealMeadowsMenWalkingDogs")
        
        introductionView.pageHeaderLabel.text = "Welcome to Hound"
        
        if UserInformation.userIdentifier != nil {
            introductionView.pageDescriptionLabel.text = """
                Sign in to your existing Hound account below. If you don't have one, \
                creating or joining a family will come soon...
                """
        }
        else {
            introductionView.pageDescriptionLabel.text = """
                Create your Hound account below. Creating or joining a family will come soon...
                """
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust corner radius & border of the Apple button once sizes are known
        signInWithAppleButton.layer.cornerRadius = signInWithAppleButton.frame.height / 2
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
        super.addSubViews()
        
        view.addSubview(introductionView)
        
        signInStack = UIStackView(arrangedSubviews: [signInWithAppleButton, signInWithAppleDescriptionLabel])
        signInStack.axis = .vertical
        signInStack.alignment = .center
        signInStack.distribution = .fill
        signInStack.spacing = 12.5
        signInStack.translatesAutoresizingMaskIntoConstraints = false
        introductionView.contentView.addSubview(signInStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // introductionView
        NSLayoutConstraint.activate([
            introductionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            introductionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            introductionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            introductionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // signInStack
        NSLayoutConstraint.activate([
            signInStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            signInStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            signInStack.widthAnchor.constraint(equalTo: introductionView.contentView.widthAnchor)
        ])
        
        // signInWithAppleButton
        NSLayoutConstraint.activate([
            signInWithAppleButton.widthAnchor.constraint(equalTo: introductionView.contentView.widthAnchor),
            signInWithAppleButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            signInWithAppleButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
        
        // signInWithAppleDescriptionLabel
        NSLayoutConstraint.activate([
            signInWithAppleDescriptionLabel.widthAnchor.constraint(equalTo: signInWithAppleDescriptionLabel.widthAnchor)
        ])
    }

}
