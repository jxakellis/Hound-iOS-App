//
//  ServerFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ServerFamilyViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class ServerFamilyViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // attempt to read the range they are trying to change
        guard let currentText = textField.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).uppercased()
        
        // The user can delete whatever they want. We only want to check when they add a character
        guard updatedText.count > currentText.count else {
            // if the user deleted a character, then the join button should always be disabled as code cant exceed length of 8 (therefore deletion signifies length of <8)
            familyCodeAlertControllerJoinAlertAction?.isEnabled = updatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength
            return true
        }
        
        // MARK: Verify new character is a valid character
        // a family code input can only contain the alphabet, numbers, and a dash (less 0, O, I, and L as they can be mixed up). We automatically convert lowercase to uppercase when verifying the family code, so don't worry about it at this point.
        let acceptableCharacters = "ABCDEFGHJKMNPQRSTUVWXYZ123456789-"
        var containsInvalidCharacter = false
        updatedText.forEach { character in
            if acceptableCharacters.firstIndex(of: character) == nil {
                containsInvalidCharacter = true
            }
        }
        guard containsInvalidCharacter == false else {
            return false
        }
        
        // MARK: Verify dash (-) placement and count
        // If the previous text didn't have a dash and the new text does, the user added a dash.
        if let stringIndexOfDash = updatedText.firstIndex(of: "-"), currentText.firstIndex(of: "-") == nil {
            //  Once we verify that change, make sure this dash is in position 4.
            let indexOfDash = updatedText.distance(from: updatedText.startIndex, to: stringIndexOfDash)
            if indexOfDash != 4 {
                return false
            }
        }
        // If the previous text had a dash and the user added another, reject the change. They can only have 1 dash
        else if currentText.firstIndex(of: "-") != updatedText.lastIndex(of: "-") {
            return false
        }
        
        // MARK: Verify length
        if updatedText.replacingOccurrences(of: "-", with: "").count > familyCodeWithoutDashLength {
            return false
        }
        
        // MARK: Check family code completion
        // to reach this point, the updated text only contains valid characters at valid positions. Therefore, we only need to check if its the correct length
        familyCodeAlertControllerJoinAlertAction?.isEnabled = updatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength
        
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var createFamilyButton: UIButton!
    
    @IBAction private func willCreateFamily(_ sender: Any) {
        RequestUtils.beginRequestIndictator()
        FamilyRequest.create(invokeErrorManager: true) { familyId, _ in
            RequestUtils.endRequestIndictator {
                if familyId != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBOutlet private weak var createFamilyDisclaimerLabel: ScaledUILabel!
    @IBOutlet private weak var createFamilyDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var createFamilyDisclaimerTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var joinFamilyButton: ScaledUILabel!
    
    @IBAction private func willJoinFamily(_ sender: Any) {
        
        let familyCodeAlertController = GeneralUIAlertController(title: "Join a Family", message: "The code is case-insensitive", preferredStyle: .alert)
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter Family Code..."
            textField.autocapitalizationType = .allCharacters
            textField.delegate = self
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        let alertActionJoin = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textField = familyCodeAlertController?.textFields?.first else {
                return
            }
            
            // uppercase everything then replace "-" with "" (nothing) then remove any excess whitespaces/newliens
            let familyCode = (textField.text ?? "").uppercased().replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            // code is empty
            if familyCode.isEmpty {
                ErrorConstant.FamilyRequestError.familyCodeBlank.alert()
            }
            // code isn't long enough
            else if familyCode.count != self.familyCodeWithoutDashLength {
                ErrorConstant.FamilyRequestError.familyCodeInvalid.alert()
            }
            // client side the code is okay
            else {
                RequestUtils.beginRequestIndictator()
                FamilyRequest.update(invokeErrorManager: true, body: [KeyConstant.familyCode.rawValue: familyCode]) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        // the code successfully allowed the user to join
                        guard requestWasSuccessful else {
                            return
                        }
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
            
        }
        alertActionJoin.isEnabled = false
        familyCodeAlertControllerJoinAlertAction = alertActionJoin
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        familyCodeAlertController.addAction(alertActionJoin)
        familyCodeAlertController.addAction(alertActionCancel)
        AlertManager.enqueueAlertForPresentation(familyCodeAlertController)
        
    }
    // MARK: - Properties
    
    weak var delegate: ServerFamilyViewControllerDelegate!
    
    /// Keep track of this alert action so we can later reference it to enable and disable it
    private var familyCodeAlertControllerJoinAlertAction: UIAlertAction? = nil
    
    /// A family's join code is eight characters long
    private let familyCodeWithoutDashLength = 8
    
    /// viewWillAppear can be called multiple times. Therefore, we should track if certain attributes have already been setup to avoid reconfiguring them.
    private var hasBeenSetup = false
    
    // MARK: - Main
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        // avoid executing code below multiple times
        guard hasBeenSetup == false else {
            return
        }
        hasBeenSetup = true
        
        setupCreateFamily()
        setupCreateFamilyDisclaimer()
        setupJoinFamily()
        
        func setupCreateFamily() {
            // set to made to have fully rounded corners
            createFamilyButton.layer.cornerRadius = createFamilyButton.frame.height / 2
            createFamilyButton.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
            createFamilyButton.layer.borderWidth = 1
            createFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
        
        func setupCreateFamilyDisclaimer() {
            createFamilyDisclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
            
            createFamilyDisclaimerLeadingConstraint.constant += createFamilyButton.layer.cornerRadius / 4
            createFamilyDisclaimerTrailingConstraint.constant += createFamilyButton.layer.cornerRadius / 4
        }
        
        func setupJoinFamily() {
            // set to made to have fully rounded corners
            joinFamilyButton.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
            joinFamilyButton.layer.cornerRadius = joinFamilyButton.frame.height / 2
            joinFamilyButton.layer.borderWidth = 1
            joinFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        LocalConfiguration.resetForNewFamily()
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: DogManager())
    }
}
