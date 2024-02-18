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

        // add their newString in the newRange to the previousText and uppercase it all, giving us our uppercasedUpdatedText
        var uppercasedUpdatedText = previousText.replacingCharacters(in: newStringRange, with: newString).uppercased()

        // The user can delete whatever they want. We only want to check when they add a character
        guard uppercasedUpdatedText.count > previousText.count else {
            // The user deleted a character. Therefore, the join button should always be disabled as code cant exceed length of 8 (therefore deletion signifies length of <8)
            familyCodeAlertControllerJoinAlertAction?.isEnabled = uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength
            return true
        }

        // MARK: Verify new character is a valid character
        // a family code input can only contain the alphabet, numbers, and a dash (less 0, O, I, and L as they can be mixed up). We automatically convert lowercase to uppercase when verifying the family code, so don't worry about it at this point.
        let acceptableCharacters = "ABCDEFGHJKMNPQRSTUVWXYZ123456789-"
        var containsInvalidCharacter = false
        uppercasedUpdatedText.forEach { character in
            if acceptableCharacters.firstIndex(of: character) == nil {
                containsInvalidCharacter = true
            }
        }
        guard containsInvalidCharacter == false else {
            return false
        }

        // MARK: Verify dash (-) placement and count
        // If uppercasedUpdatedText has a dash and previousText doesn't have a dash, the user added a dash.
        if let stringIndexOfAddedDash = uppercasedUpdatedText.firstIndex(of: "-"), previousText.firstIndex(of: "-") == nil {
            //  Once we verify that change, make sure this dash is in position 4.
            let indexOfAddedDash = uppercasedUpdatedText.distance(from: uppercasedUpdatedText.startIndex, to: stringIndexOfAddedDash)
            // If the dash isn't exactly in index 4, reject the change
            if indexOfAddedDash != 4 {
                return false
            }
        }
        // If the previousText's first dash and uppercasedUpdatedText's last dash are in different indicies, then that means the user is trying to add another dash, reject the change. They can only have 1 dash
        else if previousText.firstIndex(of: "-") != uppercasedUpdatedText.lastIndex(of: "-") {
            return false
        }
        // If uppercasedUpdatedText doesn't have a dash and it's length is equal to or longer than where the dash should be, we should to insert a dash manually for the user. NOTE: We can set uppercasedUpdatedText.count >= 4 or 5.
        else if uppercasedUpdatedText.firstIndex(of: "-") == nil && uppercasedUpdatedText.count >= 4 {
            let dashIndex = uppercasedUpdatedText.index(uppercasedUpdatedText.startIndex, offsetBy: 4)
            uppercasedUpdatedText.insert("-", at: dashIndex)
        }

        // MARK: Verify length
        if uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count > familyCodeWithoutDashLength {
            return false
        }

        // MARK: Check family code completion
        // to reach this point, the updated text only contains valid characters at valid positions. Therefore, we only need to check if its the correct length
        familyCodeAlertControllerJoinAlertAction?.isEnabled = uppercasedUpdatedText.replacingOccurrences(of: "-", with: "").count == familyCodeWithoutDashLength

        // At the end of the function, update the text field's text to the updated text
        textField.text = uppercasedUpdatedText

        // Return false because we manually set the text field's text
        return false
    }

    // MARK: - IB

    @IBOutlet private weak var whiteBackgroundView: UIView!

    @IBAction private func willCreateFamily(_ sender: Any) {
        PresentationManager.beginFetchingInformationIndictator()
        FamilyRequest.create(forErrorAlert: .automaticallyAlertForNone) { responseStatus, houndError in
            PresentationManager.endFetchingInformationIndictator {
                // The user is already in a family so can't create a new one
                guard houndError?.name != ErrorConstant.FamilyResponseError.joinInFamilyAlready(forRequestId: -1, forResponseId: -1).name else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                guard responseStatus == .successResponse else {
                    // Manually alert because the we want to intercept the possible joinInFamilyAlready error
                    houndError?.alert()
                    return
                }
                
                self.delegate.didCreateOrJoinFamily()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

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
                FamilyRequest.update(
                    forErrorAlert: .automaticallyAlertForNone,
                    forBody: [KeyConstant.familyCode.rawValue: familyCode]
                ) { responseStatus, houndError in
                    PresentationManager.endFetchingInformationIndictator {
                        // The user is already in a family so can't join a new one
                        guard houndError?.name != ErrorConstant.FamilyResponseError.joinInFamilyAlready(forRequestId: -1, forResponseId: -1).name else {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        
                        guard houndError?.name != ErrorConstant.FamilyResponseError.limitFamilyMemberTooLow(forRequestId: -1, forResponseId: -1).name else {
                            // Display an easy to comprehend error if they try to join the family here
                            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerFamilyLimitTooLowViewController")
                            return
                        }
                        
                        guard responseStatus == .successResponse else {
                            // Manually alert because the we want to intercept the possible joinInFamilyAlready or limitFamilyMemberTooLow error
                            houndError?.alert()
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
        self.eligibleForGlobalPresenter = true

        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.cornerCurve = .continuous
    }
}
