//
//  ServerFamilyIntroductionVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ServerFamilyIntroductionVCDelegate: AnyObject {
    /// Invoked by FamilyRequest completionHandler either when successfully created or joined a family. If this function is invoked, this view has completed
    func didCreateOrJoinFamily()
}

final class ServerFamilyIntroductionVC: HoundViewController, UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn newRange: NSRange, replacementString newString: String) -> Bool {
        // attempt to read the range they are trying to change
        guard let previousText = textField.text, let newStringRange = Range(newRange, in: previousText) else {
            return true
        }
        
        // add their newString in the newRange to the previousText and uppercase it all
        var uppercasedUpdatedText = previousText
            .replacingCharacters(in: newStringRange, with: newString)
            .uppercased()
        
        // The user can delete whatever they want. We only want to check when they add a character
        guard uppercasedUpdatedText.count > previousText.count else {
            // The user deleted a character. Therefore, the join button should always be disabled as code can't exceed length of 8
            familyCodeJoinAction?.isEnabled = uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength
            return true
        }
        
        // MARK: Verify new character is a valid character
        // A family code input can only contain the alphabet, numbers, and a dash (exclude 0, O, I, L). We automatically convert lowercase to uppercase.
        let acceptableCharacters = "ABCDEFGHJKMNPQRSTUVWXYZ123456789-"
        var containsInvalidCharacter = false
        uppercasedUpdatedText.forEach { character in
            if acceptableCharacters.firstIndex(of: character) == nil {
                containsInvalidCharacter = true
            }
        }
        guard !containsInvalidCharacter else {
            return false
        }
        
        // MARK: Verify dash (-) placement and count
        // If uppercasedUpdatedText has a dash and previousText doesn't have a dash, the user added a dash.
        if let dashIndexInNew = uppercasedUpdatedText.firstIndex(of: "-"),
           previousText.firstIndex(of: "-") == nil {
            let indexOfAddedDash = uppercasedUpdatedText.distance(from: uppercasedUpdatedText.startIndex, to: dashIndexInNew)
            // If the dash isn't exactly in index 4, reject the change
            if indexOfAddedDash != 4 {
                return false
            }
        }
        // If the previousText's first dash and uppercasedUpdatedText's last dash are in different indices, then the user is trying to add another dash
        else if previousText.firstIndex(of: "-") != uppercasedUpdatedText.lastIndex(of: "-") {
            return false
        }
        // If uppercasedUpdatedText doesn't have a dash and its length is ≥ 4, insert a dash at position 4
        else if uppercasedUpdatedText.firstIndex(of: "-") == nil && uppercasedUpdatedText.count >= 4 {
            let dashIndexPosition = uppercasedUpdatedText.index(uppercasedUpdatedText.startIndex, offsetBy: 4)
            uppercasedUpdatedText.insert("-", at: dashIndexPosition)
        }
        
        // MARK: Verify length
        if uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count > familyCodeWithoutDashLength {
            return false
        }
        
        // MARK: Check family code completion
        // To reach this point, the updated text only contains valid characters at valid positions
        familyCodeJoinAction?.isEnabled = uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength
        
        // Update the text field's text
        textField.text = uppercasedUpdatedText
        
        // Return false because we manually set the text field's text
        return false
    }
    
    // MARK: - Elements
    
    private let introductionView = HoundIntroductionView()
    
    private lazy var createFamilyButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.addTarget(self, action: #selector(willCreateFamily), for: .touchUpInside)
        
        return button
    }()
    
    private let subDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "As the head of your own Hound family, you'll manage its members and any in-app purchases."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.tertiaryColorDescLabel
        label.textColor = UIColor.tertiaryLabel
        return label
    }()
    
    private lazy var joinFamilyButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.addTarget(self, action: #selector(willJoinFamily), for: .touchUpInside)
        
        return button
    }()
    
    /// Stack view containing createFamilyButton and subDescriptionLabel
    private var createStack: UIStackView!
    
    /// Stack view containing both the createStack and joinFamilyButton
    private var mainStack: UIStackView!
    
    // MARK: - Properties
    
    private weak var delegate: ServerFamilyIntroductionVCDelegate?
    
    /// Keep track of this alert action so we can later reference it to enable and disable it
    private var familyCodeJoinAction: UIAlertAction?
    
    /// A family's join code is eight characters long
    private let familyCodeWithoutDashLength = 8
    
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
        
        introductionView.backgroundImageView.image = UIImage(named: "lightBeachFamilyPicnicWithDog")
        
        introductionView.pageHeaderLabel.text = "Family"
        
        introductionView.pageDescriptionLabel.text = "To use Hound, you must create or join a family. Families allow multiple users to collaborate on their dogs' care."
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: ServerFamilyIntroductionVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Functions
    
    @objc private func willCreateFamily(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndicator()
        FamilyRequest.create(forErrorAlert: .automaticallyAlertForNone) { responseStatus, houndError in
            PresentationManager.endFetchingInformationIndicator {
                // The user is already in a family so can't create a new one
                if houndError?.name == ErrorConstant.FamilyResponseError.joinInFamilyAlready(forRequestId: -1, forResponseId: -1).name {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                guard responseStatus == .successResponse else {
                    // Manually alert because we want to intercept the possible joinInFamilyAlready error
                    houndError?.alert()
                    return
                }
                
                self.delegate?.didCreateOrJoinFamily()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func willJoinFamily(_ sender: Any) {
        let familyCodeAlertController = UIAlertController(
            title: "Join a Family",
            message: "The code is case-insensitive",
            preferredStyle: .alert
        )
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter a family code..."
            textField.autocapitalizationType = .allCharacters
            textField.delegate = self
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        let joinAction = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textField = familyCodeAlertController?.textFields?.first else { return }
            
            // Uppercase everything then strip dashes, whitespace, newlines
            let familyCode = (textField.text ?? "")
                .uppercased()
                .replacingOccurrences(of: "-", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Code is empty
            if familyCode.isEmpty {
                ErrorConstant.FamilyRequestError.familyCodeBlank().alert()
            }
            // Code isn't long enough
            else if familyCode.count != self.familyCodeWithoutDashLength {
                ErrorConstant.FamilyRequestError.familyCodeInvalid().alert()
            }
            // Client-side code is OK
            else {
                PresentationManager.beginFetchingInformationIndicator()
                FamilyRequest.update(
                    forErrorAlert: .automaticallyAlertForNone,
                    forBody: [KeyConstant.familyCode.rawValue: .string(familyCode)]
                ) { responseStatus, houndError in
                    PresentationManager.endFetchingInformationIndicator {
                        // Already in a family
                        if houndError?.name == ErrorConstant.FamilyResponseError.joinInFamilyAlready(forRequestId: -1, forResponseId: -1).name {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        // Family limit too low
                        if houndError?.name == ErrorConstant.FamilyResponseError.limitFamilyMemberTooLow(forRequestId: -1, forResponseId: -1).name {
                            let vc = LimitTooLowViewController()
                            PresentationManager.enqueueViewController(vc)
                            return
                        }
                        guard responseStatus == .successResponse else {
                            // Manually alert for all other errors
                            houndError?.alert()
                            return
                        }
                        self.delegate?.didCreateOrJoinFamily()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        joinAction.isEnabled = false
        familyCodeJoinAction = joinAction
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        familyCodeAlertController.addAction(joinAction)
        familyCodeAlertController.addAction(cancelAction)
        
        PresentationManager.enqueueAlert(familyCodeAlertController)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        
        view.addSubview(introductionView)
        
        createStack = UIStackView(arrangedSubviews: [createFamilyButton, subDescriptionLabel])
        createStack.axis = .vertical
        createStack.alignment = .center
        createStack.distribution = .fill
        createStack.spacing = ConstraintConstant.Spacing.contentIntraVert
        createStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack = UIStackView(arrangedSubviews: [createStack, joinFamilyButton])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.distribution = .fill
        mainStack.spacing = 30
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        introductionView.contentView.addSubview(mainStack)
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
        
        // mainStack
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: introductionView.contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: introductionView.contentView.trailingAnchor)
        ])
        
        // createFamilyButton
        NSLayoutConstraint.activate([
            createFamilyButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            createFamilyButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            createFamilyButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
        
        // subDescriptionLabel
        NSLayoutConstraint.activate([
            subDescriptionLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ])
        
        // joinFamilyButton
        NSLayoutConstraint.activate([
            joinFamilyButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            joinFamilyButton.heightAnchor.constraint(equalTo: createFamilyButton.heightAnchor)
        ])
    }
}
