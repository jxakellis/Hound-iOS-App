//
//  ServerFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ServerFamilyViewControllerDelegate: AnyObject {
    /// Invoked by FamilyRequest completionHandler either when successfully created or joined a family. If this function is invoked, this view has completed
    func didCreateOrJoinFamily()
}

final class ServerFamilyViewController: GeneralUIViewController, UITextFieldDelegate {
    
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
    
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        
        imageView.image = UIImage(named: "lightBeachFamilyPicnicWithDog")
        
        return imageView
    }()
    
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let titleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "Family"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "To use Hound, you must create or join a family. Families allow multiple users to collaborate on their dogs' care."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let createFamilyButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let subDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "As the head of your own Hound family, you'll manage its members and any in-app purchases."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private let joinFamilyButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    // MARK: - Properties
    
    private weak var delegate: ServerFamilyViewControllerDelegate?
    
    /// Keep track of this alert action so we can later reference it to enable and disable it
    private var familyCodeJoinAction: UIAlertAction?
    
    /// A family's join code is eight characters long
    private let familyCodeWithoutDashLength = 8
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: ServerFamilyViewControllerDelegate) {
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
                    forBody: [KeyConstant.familyCode.rawValue: familyCode]
                ) { responseStatus, houndError in
                    PresentationManager.endFetchingInformationIndicator {
                        // Already in a family
                        if houndError?.name == ErrorConstant.FamilyResponseError.joinInFamilyAlready(forRequestId: -1, forResponseId: -1).name {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        // Family limit too low
                        if houndError?.name == ErrorConstant.FamilyResponseError.limitFamilyMemberTooLow(forRequestId: -1, forResponseId: -1).name {
                            let vc = FamilyLimitTooLowViewController()
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
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(backgroundImageView)
        view.addSubview(whiteBackgroundView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(createFamilyButton)
        view.addSubview(joinFamilyButton)
        view.addSubview(subDescriptionLabel)
        
        createFamilyButton.addTarget(self, action: #selector(willCreateFamily), for: .touchUpInside)
        joinFamilyButton.addTarget(self, action: #selector(willJoinFamily), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // backgroundImageView
        let backgroundImageViewTop = backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor)
        let backgroundImageViewLeading = backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let backgroundImageViewTrailing = backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let backgroundImageViewWidthToHeight = backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor)
        
        // whiteBackgroundView
        let whiteBackgroundViewTop = whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25)
        let whiteBackgroundViewLeading = whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let whiteBackgroundViewTrailing = whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let whiteBackgroundViewBottom = whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        // titleLabel
        let titleLabelTop = titleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25)
        let titleLabelLeading = titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        let titleLabelTrailing = titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let titleLabelHeight = titleLabel.heightAnchor.constraint(equalToConstant: 30)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7.5)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        
        // createFamilyButton
        let createFamilyButtonTop = createFamilyButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15)
        let createFamilyButtonLeading = createFamilyButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        let createFamilyButtonWidthToHeight = createFamilyButton.widthAnchor.constraint(equalTo: createFamilyButton.heightAnchor, multiplier: 1.0 / 0.16)
        
        // subDescriptionLabel
        let subDescriptionLabelTop = subDescriptionLabel.topAnchor.constraint(equalTo: createFamilyButton.bottomAnchor, constant: 7.5)
        let subDescriptionLabelLeading = subDescriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        let subDescriptionLabelTrailing = subDescriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        let subDescriptionLabelHeight = subDescriptionLabel.heightAnchor.constraint(equalToConstant: 17.5)
        
        // joinFamilyButton
        let joinFamilyButtonTop = joinFamilyButton.topAnchor.constraint(equalTo: subDescriptionLabel.bottomAnchor, constant: 30)
        let joinFamilyButtonLeading = joinFamilyButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        let joinFamilyButtonTrailing = joinFamilyButton.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let joinFamilyButtonHeight = joinFamilyButton.heightAnchor.constraint(equalTo: createFamilyButton.heightAnchor)
        let joinFamilyButtonWidthToHeight = joinFamilyButton.widthAnchor.constraint(equalTo: joinFamilyButton.heightAnchor, multiplier: 1.0 / 0.16)
        let joinFamilyButtonBottom = joinFamilyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        
        NSLayoutConstraint.activate([
            // backgroundImageView
            backgroundImageViewTop,
            backgroundImageViewLeading,
            backgroundImageViewTrailing,
            backgroundImageViewWidthToHeight,
            
            // whiteBackgroundView
            whiteBackgroundViewTop,
            whiteBackgroundViewLeading,
            whiteBackgroundViewTrailing,
            whiteBackgroundViewBottom,
            
            // titleLabel
            titleLabelTop,
            titleLabelLeading,
            titleLabelTrailing,
            titleLabelHeight,
            
            // descriptionLabel
            descriptionLabelTop,
            descriptionLabelLeading,
            descriptionLabelTrailing,
            
            // createFamilyButton
            createFamilyButtonTop,
            createFamilyButtonLeading,
            createFamilyButtonWidthToHeight,
            
            // subDescriptionLabel
            subDescriptionLabelTop,
            subDescriptionLabelLeading,
            subDescriptionLabelTrailing,
            subDescriptionLabelHeight,
            
            // joinFamilyButton
            joinFamilyButtonTop,
            joinFamilyButtonLeading,
            joinFamilyButtonTrailing,
            joinFamilyButtonHeight,
            joinFamilyButtonWidthToHeight,
            joinFamilyButtonBottom
        ])
    }

}
