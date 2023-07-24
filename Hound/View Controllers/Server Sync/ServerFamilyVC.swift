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
    
    @IBOutlet private weak var whiteBackgroundView: UIView!
    
    @IBOutlet private weak var createFamilyButton: SemiboldUIButton!
    @IBAction private func willCreateFamily(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndictator()
        FamilyRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
            PresentationManager.endFetchingInformationIndictator {
                guard requestWasSuccessful else {
                    return
                }
                
                self.delegate.didCreateOrJoinFamily()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBOutlet private weak var joinFamilyButton: SemiboldUIButton!
    @IBAction private func willJoinFamily(_ sender: Any) {
        
        let familyCodeAlertController = UIAlertController(title: "Join a Family", message: "The code is case-insensitive", preferredStyle: .alert)
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter a family code..."
            textField.autocapitalizationType = .allCharacters
            textField.delegate = self
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        let joinAlertAction = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textField = familyCodeAlertController?.textFields?.first else {
                return
            }
            
            // uppercase everything then replace "-" with "" (nothing) then remove any excess whitespaces/newliens
            let familyCode = (textField.text ?? "").uppercased().replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            // code is empty
            if familyCode.isEmpty {
                ErrorConstant.FamilyRequestError.familyCodeBlank().alert()
            }
            // code isn't long enough
            else if familyCode.count != self.familyCodeWithoutDashLength {
                ErrorConstant.FamilyRequestError.familyCodeInvalid().alert()
            }
            // client side the code is okay
            else {
                PresentationManager.beginFetchingInformationIndictator()
                FamilyRequest.update(invokeErrorManager: true, body: [KeyConstant.familyCode.rawValue: familyCode]) { requestWasSuccessful, _ in
                    PresentationManager.endFetchingInformationIndictator {
                        // the code successfully allowed the user to join
                        guard requestWasSuccessful else {
                            return
                        }
                        
                        self.delegate.didCreateOrJoinFamily()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
        joinAlertAction.isEnabled = false
        familyCodeAlertControllerJoinAlertAction = joinAlertAction
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        familyCodeAlertController.addAction(joinAlertAction)
        familyCodeAlertController.addAction(cancelAlertAction)
        PresentationManager.enqueueAlert(familyCodeAlertController)
        
    }
    
    // MARK: - Properties
    
    weak var delegate: ServerFamilyViewControllerDelegate!
    
    /// Keep track of this alert action so we can later reference it to enable and disable it
    private var familyCodeAlertControllerJoinAlertAction: UIAlertAction?
    
    /// A family's join code is eight characters long
    private let familyCodeWithoutDashLength = 8
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFamilyButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
        joinFamilyButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
        
        whiteBackgroundView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This page should be light. Elements do not transfer well to dark mode
        self.overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
}
