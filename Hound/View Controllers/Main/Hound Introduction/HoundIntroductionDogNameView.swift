//
//  HoundIntroductionDogNameView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogNameViewDelegate: AnyObject {
    /// Invoked either by textFieldShouldReturn or didTouchUpInsideContinue. Returns nil if no dogName is required, otherwise returns the current dogName selected (or resorts to a default). If this function is invoked, this view has completed
    func willContinue(forDogName: String?)
}

final class HoundIntroductionDogNameView: UIView, UITextFieldDelegate {

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
        delegate.willContinue(forDogName: dogName)
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

    // MARK: - IB

    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var whiteBackgroundView: UIView!

    @IBOutlet private weak var dogNameTitleLabel: GeneralUILabel!
    @IBOutlet private weak var dogNameDescriptionLabel: GeneralUILabel!
    @IBOutlet private weak var dogNameTextField: GeneralUITextField!

    @IBOutlet private weak var continueButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideContinue(_ sender: Any) {
        self.dismissKeyboard()
        dogNameTextField.isEnabled = false
        continueButton.isEnabled = false
        delegate.willContinue(forDogName: dogName)
    }

    // MARK: - Properties

    private weak var delegate: HoundIntroductionDogNameViewDelegate!
    private var dogName: String? {
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
        initializeSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeSubviews()
    }

    /// Setup components of the view that don't depend upon data provided by an external source
    private func initializeSubviews() {
        _ = UINib(nibName: "HoundIntroductionDogNameView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)

        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous
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
            dogNameDescriptionLabel.text = "You can proceed to manage \(dog.dogName) on the next page"
            dogNameTextField.placeholder = dog.dogName
        }
        else {
            // User doesn't have a dog. This page will get the user to input a dogName
            dogNameTitleLabel.text = "What is your dog's name?"
            dogNameDescriptionLabel.text = "We will generate a basic dog for you"
            dogNameTextField.placeholder = ClassConstant.DogConstant.defaultDogName
            setupDismissKeyboardOnTap()
        }
    }

}
