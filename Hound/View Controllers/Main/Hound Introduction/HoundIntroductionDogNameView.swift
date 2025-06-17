//
//  TranslationHoundIntroductionDogNameView.swift.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/3/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogNameViewDelegate: AnyObject {
    /// Invoked either by textFieldShouldReturn or didTouchUpInsideContinue. Returns nil if no dogName is required, otherwise returns the current dogName selected (or resorts to a default). If this function is invoked, this view has completed
    func willContinue(forDogName: String?)
}

final class HoundIntroductionDogNameView: GeneralUIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UITextFieldDelegate
    
    /// Before becoming the first responder, the text field calls its delegate’s textFieldShouldBeginEditing() function. Use that function to allow or prevent the editing of the text field’s contents.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dogManager?.dogs.first == nil
    }
    
    /// The text field calls this function whenever the user taps the return button. You can use this function to implement any custom behavior when the button is tapped. For example, if you want to dismiss the keyboard when the user taps the return button, your implementation can call the resignFirstResponder() function.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate?.willContinue(forDogName: inputDogName)
        return false
    }
    
    /// The text field calls this function whenever user actions cause its text to change. Use this function to validate text as it is typed by the user. For example, you could use this function to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // attempt to read the range they are trying to change
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is dogNameCharacterLimit
        return updatedText.count <= ClassConstant.DogConstant.dogNameCharacterLimit
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Elements
    
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 340, compressionResistancePriority: 340)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let dogNameTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.text = "What is your dog's name?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let dogNameDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "We will generate a basic dog for you"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dogNameTextField: GeneralUITextField = {
        let textField = GeneralUITextField(huggingPriority: 350, compressionResistencePriority: 350)
        
        textField.placeholder = "Bella"
        textField.textAlignment = .center
        
        textField.backgroundColor = .systemBackground
        
        textField.borderWidth = 0.5
        textField.borderColor = .systemGray2
        textField.shouldRoundCorners = true
        
        return textField
    }()
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 290)

        button.isEnabled = false
        
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 350, compressionResistancePriority: 350)

        imageView.image = UIImage(named: "autumnParkFamilyWithDog")
        
        return imageView
    }()
    
    private let boundingBoxForDogNameTextField: GeneralUIView = {
        let view = GeneralUIView()
        view.clipsToBounds = true
        
        return view
    }()
    @objc private func didTouchUpInsideContinue(_ sender: Any) {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate?.willContinue(forDogName: inputDogName)
    }
    
    // MARK: - Properties
    
    private weak var delegate: HoundIntroductionDogNameViewDelegate?
    private var inputDogName: String? {
        // If the family already has its first dog then we don't need to add a dogName
        guard dogManager?.dogs.first == nil else {
            return nil
        }
        // Extract the input dogName
        let trimmedText: String = dogNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // If no dogName was input, go back to the default dogName
        let dogName = trimmedText.isEmpty ? ClassConstant.DogConstant.defaultDogName : trimmedText
        
        return dogName
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager?
    
    // MARK: - Setup
    
    /// Setup components of the view that do depend upon data provided by an external source
    func setup(forDelegate: HoundIntroductionDogNameViewDelegate, forDogManager: DogManager) {
        delegate = forDelegate
        dogManager = forDogManager
        
        // We only let the user edit the dogNameTextField if they don't already have a dog. We don't want a user that joins a family to accidentily edit an existing dog or add a new one
        dogNameTextField.delegate = self
        dogNameTextField.isEnabled = forDogManager.dogs.isEmpty
        
        continueButton.isEnabled = true
        
        if let dog = forDogManager.dogs.first {
            // User has a dog already. This page will basically be a NO-OP
            dogNameTitleLabel.text = "We see you have a pack!"
            dogNameDescriptionLabel.text = "You can manage \(dog.dogName)\(forDogManager.dogs.count > 1 ? " (and other dogs)" : "") on the next page"
            dogNameTextField.placeholder = dog.dogName
        }
        else {
            // User doesn't have a dog. This page will get the user to input a dogName
            dogNameTitleLabel.text = "What is your dog's name?"
            dogNameDescriptionLabel.text = "We will generate a basic dog for you"
            dogNameTextField.placeholder = ClassConstant.DogConstant.defaultDogName
            dismissKeyboardOnTap(delegate: self)
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        self.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(backgroundImageView)
        addSubview(whiteBackgroundView)
        addSubview(dogNameTitleLabel)
        addSubview(dogNameDescriptionLabel)
        addSubview(continueButton)
        addSubview(boundingBoxForDogNameTextField)
        boundingBoxForDogNameTextField.addSubview(dogNameTextField)
        
        continueButton.addTarget(self, action: #selector(didTouchUpInsideContinue), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // backgroundImageView
        let backgroundImageViewTop = backgroundImageView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor)
        let backgroundImageViewBottom = backgroundImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.centerYAnchor)
        backgroundImageViewBottom.priority = .defaultHigh
        let backgroundImageViewLeading = backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let backgroundImageViewTrailing = backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let backgroundImageViewHeight = backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor)
        
        // whiteBackgroundView
        let whiteBackgroundViewTop = whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25)
        let whiteBackgroundViewBottom = whiteBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let whiteBackgroundViewLeading = whiteBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let whiteBackgroundViewTrailing = whiteBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        // dogNameTitleLabel
        let dogNameTitleLabelTop = dogNameTitleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25)
        let dogNameTitleLabelLeading = dogNameTitleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        let dogNameTitleLabelTrailing = dogNameTitleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        
        // dogNameDescriptionLabel
        let dogNameDescriptionLabelTop = dogNameDescriptionLabel.topAnchor.constraint(equalTo: dogNameTitleLabel.bottomAnchor, constant: 7.5)
        let dogNameDescriptionLabelLeading = dogNameDescriptionLabel.leadingAnchor.constraint(equalTo: dogNameTitleLabel.leadingAnchor)
        let dogNameDescriptionLabelTrailing = dogNameDescriptionLabel.trailingAnchor.constraint(equalTo: dogNameTitleLabel.trailingAnchor)
        
        // boundingBoxForDogNameTextField
        let boundingBoxForDogNameTextFieldTop = boundingBoxForDogNameTextField.topAnchor.constraint(equalTo: dogNameDescriptionLabel.bottomAnchor, constant: 15)
        let boundingBoxForDogNameTextFieldLeading = boundingBoxForDogNameTextField.leadingAnchor.constraint(equalTo: dogNameTitleLabel.leadingAnchor)
        let boundingBoxForDogNameTextFieldTrailing = boundingBoxForDogNameTextField.trailingAnchor.constraint(equalTo: dogNameTitleLabel.trailingAnchor)
        
        // dogNameTextField (inside bounding box, always centered and fixed height)
        let dogNameTextFieldLeading = dogNameTextField.leadingAnchor.constraint(equalTo: boundingBoxForDogNameTextField.leadingAnchor)
        let dogNameTextFieldTrailing = dogNameTextField.trailingAnchor.constraint(equalTo: boundingBoxForDogNameTextField.trailingAnchor)
        let dogNameTextFieldCenterY = dogNameTextField.centerYAnchor.constraint(equalTo: boundingBoxForDogNameTextField.centerYAnchor)
        let dogNameTextFieldHeight = dogNameTextField.heightAnchor.constraint(equalTo: continueButton.heightAnchor)
        
        // continueButton
        let continueButtonTop = continueButton.topAnchor.constraint(equalTo: boundingBoxForDogNameTextField.bottomAnchor, constant: 15)
        let continueButtonBottom = continueButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        let continueButtonLeading = continueButton.leadingAnchor.constraint(equalTo: dogNameTitleLabel.leadingAnchor)
        let continueButtonTrailing = continueButton.trailingAnchor.constraint(equalTo: dogNameTitleLabel.trailingAnchor)
        let continueButtonHeightRatio = continueButton.heightAnchor.constraint(equalTo: continueButton.widthAnchor, multiplier: 0.16)
        continueButtonHeightRatio.priority = .defaultHigh
        let continueButtonMaxHeight = continueButton.heightAnchor.constraint(lessThanOrEqualToConstant: 75)
        
        NSLayoutConstraint.activate([
            // backgroundImageView
            backgroundImageViewTop,
            backgroundImageViewBottom,
            backgroundImageViewLeading,
            backgroundImageViewTrailing,
            backgroundImageViewHeight,
            
            // whiteBackgroundView
            whiteBackgroundViewTop,
            whiteBackgroundViewBottom,
            whiteBackgroundViewLeading,
            whiteBackgroundViewTrailing,
            
            // dogNameTitleLabel
            dogNameTitleLabelTop,
            dogNameTitleLabelLeading,
            dogNameTitleLabelTrailing,
            
            // dogNameDescriptionLabel
            dogNameDescriptionLabelTop,
            dogNameDescriptionLabelLeading,
            dogNameDescriptionLabelTrailing,
            
            // boundingBoxForDogNameTextField
            boundingBoxForDogNameTextFieldTop,
            boundingBoxForDogNameTextFieldLeading,
            boundingBoxForDogNameTextFieldTrailing,
            
            // dogNameTextField
            dogNameTextFieldLeading,
            dogNameTextFieldTrailing,
            dogNameTextFieldCenterY,
            dogNameTextFieldHeight,
            
            // continueButton
            continueButtonTop,
            continueButtonBottom,
            continueButtonLeading,
            continueButtonTrailing,
            continueButtonHeightRatio,
            continueButtonMaxHeight
        ])
    }

}
