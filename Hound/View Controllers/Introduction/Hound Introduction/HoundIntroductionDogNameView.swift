//
//  HoundIntroductionDogNameView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/3/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogNameViewDelegate: AnyObject {
    func willContinue(forDogName: String?)
}

// UI VERIFIED 6/24/25
final class HoundIntroductionDogNameView: GeneralUIView, UITextFieldDelegate, UIGestureRecognizerDelegate {

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dogManager?.dogs.first == nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate?.willContinue(forDogName: inputDogName)
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= ClassConstant.DogConstant.dogNameCharacterLimit
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Elements

    private let introductionView = IntroductionView()

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
        button.titleLabel?.font = VisualConstant.FontConstant.screenWideButton
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        return button
    }()

    private var mainStack: UIStackView!

    // MARK: - Properties

    private weak var delegate: HoundIntroductionDogNameViewDelegate?

    private var inputDogName: String? {
        guard dogManager?.dogs.first == nil else {
            return nil
        }
        let trimmedText = dogNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedText.isEmpty ? ClassConstant.DogConstant.defaultDogName : trimmedText
    }

    private var dogManager: DogManager?

    // MARK: - Setup

    func setup(forDelegate: HoundIntroductionDogNameViewDelegate, forDogManager: DogManager) {
        delegate = forDelegate
        dogManager = forDogManager

        dogNameTextField.delegate = self
        dogNameTextField.isEnabled = forDogManager.dogs.isEmpty
        continueButton.isEnabled = true

        introductionView.backgroundImageView.image = UIImage(named: "autumnParkFamilyWithDog")

        if let dog = forDogManager.dogs.first {
            introductionView.pageHeaderLabel.text = "We see you have a pack!"
            introductionView.pageDescriptionLabel.text = "You can manage \(dog.dogName)\(forDogManager.dogs.count > 1 ? " (and other dogs)" : "") on the next page"
            dogNameTextField.placeholder = dog.dogName
        }
        else {
            introductionView.pageHeaderLabel.text = "What is your dog's name?"
            introductionView.pageDescriptionLabel.text = "We will generate a basic dog for you"
            dogNameTextField.placeholder = ClassConstant.DogConstant.defaultDogName
            dismissKeyboardOnTap(delegate: self)
        }
    }

    // MARK: - Functions

    @objc private func didTouchUpInsideContinue(_ sender: Any) {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate?.willContinue(forDogName: inputDogName)
    }

    // MARK: - Setup Elements

    override func setupGeneratedViews() {
        self.backgroundColor = .systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        addSubview(introductionView)

        mainStack = UIStackView(arrangedSubviews: [dogNameTextField, continueButton])
        mainStack.axis = .vertical
        mainStack.spacing = ConstraintConstant.Text.sectionInterVertSpacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        introductionView.contentView.addSubview(mainStack)

        continueButton.addTarget(self, action: #selector(didTouchUpInsideContinue), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            introductionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            introductionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            introductionView.topAnchor.constraint(equalTo: topAnchor),
            introductionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: introductionView.contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: introductionView.contentView.trailingAnchor),
            
            dogNameTextField.heightAnchor.constraint(equalTo: continueButton.heightAnchor),

            continueButton.heightAnchor.constraint(equalTo: continueButton.widthAnchor, multiplier: ConstraintConstant.Button.screenWideHeightMultiplier).withPriority(.defaultHigh),
            continueButton.createMaxHeightConstraint(ConstraintConstant.Button.screenWideMaxHeight)
        ])
    }
}
