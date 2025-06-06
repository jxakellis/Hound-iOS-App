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

final class HoundIntroductionDogNameView: UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
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
        delegate.willContinue(forDogName: inputDogName)
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
    
    // MARK: - IB
    
    private let contentView: UIView = UIView()
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.setContentHuggingPriority(UILayoutPriority(340), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(340), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(840), for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority(840), for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let dogNameTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(330), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(330), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(830), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(830), for: .vertical)
        label.text = "What is your dog's name?"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let dogNameDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(320), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(320), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .vertical)
        label.text = "We will generate a basic dog for you"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dogNameTextField: GeneralUITextField = {
        let textField = GeneralUITextField(
            forText: nil,
            forPlaceholder: "Bella",
            forTextAlignment: .center,
            huggingPriority: 200, compressionResistencePriority: 700
        )
        
        return textField
    }()
    
    private let continueButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 790)

        button.isEnabled = false
        
        
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabelTextColor = .label
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(350), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(350), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(850), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(850), for: .vertical)
        imageView.image = UIImage(named: "autumnParkFamilyWithDog")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let boundingBoxForDogNameTextField: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    @objc private func didTouchUpInsideContinue(_ sender: Any) {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate.willContinue(forDogName: inputDogName)
    }
    
    // MARK: - Properties
    
    private weak var delegate: HoundIntroductionDogNameViewDelegate!
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
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    // MARK: - Function
    
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
    
}

extension HoundIntroductionDogNameView {
    func setupGeneratedViews() {
        contentView.frame = bounds
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)
        
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(dogNameTitleLabel)
        contentView.addSubview(dogNameDescriptionLabel)
        contentView.addSubview(continueButton)
        contentView.addSubview(boundingBoxForDogNameTextField)
        boundingBoxForDogNameTextField.addSubview(dogNameTextField)
        
        continueButton.addTarget(self, action: #selector(didTouchUpInsideContinue), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor, multiplier: 1),
            
            dogNameTitleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25),
            dogNameTitleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dogNameTitleLabel.leadingAnchor.constraint(equalTo: boundingBoxForDogNameTextField.leadingAnchor),
            dogNameTitleLabel.trailingAnchor.constraint(equalTo: dogNameDescriptionLabel.trailingAnchor),
            dogNameTitleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            dogNameTitleLabel.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor),
            dogNameTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            dogNameDescriptionLabel.topAnchor.constraint(equalTo: dogNameTitleLabel.bottomAnchor, constant: 7.5),
            dogNameDescriptionLabel.leadingAnchor.constraint(equalTo: dogNameTitleLabel.leadingAnchor),
            dogNameDescriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            
            continueButton.topAnchor.constraint(equalTo: boundingBoxForDogNameTextField.bottomAnchor, constant: 15),
            continueButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            continueButton.leadingAnchor.constraint(equalTo: dogNameTitleLabel.leadingAnchor),
            continueButton.widthAnchor.constraint(equalTo: continueButton.heightAnchor, multiplier: 1 / 0.16),
            
            dogNameTextField.leadingAnchor.constraint(equalTo: boundingBoxForDogNameTextField.leadingAnchor),
            dogNameTextField.trailingAnchor.constraint(equalTo: boundingBoxForDogNameTextField.trailingAnchor),
            dogNameTextField.centerYAnchor.constraint(equalTo: boundingBoxForDogNameTextField.centerYAnchor),
            dogNameTextField.widthAnchor.constraint(equalTo: dogNameTextField.heightAnchor, multiplier: 1 / 0.16),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            boundingBoxForDogNameTextField.topAnchor.constraint(equalTo: dogNameDescriptionLabel.bottomAnchor, constant: 15),
            boundingBoxForDogNameTextField.trailingAnchor.constraint(equalTo: dogNameTitleLabel.trailingAnchor)
        ])
        
    }
}
