//
//  LogsAddLogUIInteractionDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/15/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogUIInteractionActionsDelegate: AnyObject {
    func dismissKeyboard()
    func logCustomActionNameTextFieldDidReturn()
    func didUpdateLogNumberOfLogUnits()
}

final class LogsAddLogUIInteractionDelegate: NSObject, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    weak var actionsDelegate: LogsAddLogUIInteractionActionsDelegate?
    var logCustomActionNameTextField: GeneralUITextField?
    var logNumberOfLogUnitsTextField: GeneralUITextField?

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(logCustomActionNameTextField) {
            actionsDelegate?.logCustomActionNameTextFieldDidReturn()
        }
        actionsDelegate?.dismissKeyboard()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isEqual(logCustomActionNameTextField) {
            return processLogCustomActionNameTextField(shouldChangeCharactersIn: range, replacementString: string)
        }
        else if textField.isEqual(logNumberOfLogUnitsTextField) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                // Delay the call to delegate ever so slightly. This is because we want to return the value from processLogNumberOfLogUnitsTextField before the delegate is called, so that the value of logNumberOfLogUnitsTextField is updated before updateDynamicUIElements() is called. This delay allows enough time for this to happen
                self.actionsDelegate?.didUpdateLogNumberOfLogUnits()
            }
            return processLogNumberOfLogUnitsTextField(shouldChangeCharactersIn: range, replacementString: string)
        }
        
        return false
    }
    
    private func processLogCustomActionNameTextField(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // attempt to read the range they are trying to change
        guard let currentText = logCustomActionNameTextField?.text, let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is logCustomActionNameCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logCustomActionNameCharacterLimit
    }
    
    private func processLogNumberOfLogUnitsTextField(shouldChangeCharactersIn newRange: NSRange, replacementString newString: String) -> Bool {
        // attempt to read the range they are trying to change
        guard let previousText = logNumberOfLogUnitsTextField?.text, let newStringRange = Range(newRange, in: previousText) else {
            return true
        }

        // add their newString in the newRange to the previousText and uppercase it all, giving us our uppercasedUpdatedText
        var updatedText = previousText.replacingCharacters(in: newStringRange, with: newString)

        // The user can delete whatever they want. We only want to check when they add a character
        guard updatedText.count > previousText.count else {
            return true
        }
        
        // MARK: Remove invalid grouping separator
        // when a user inputs number of logs, it should not have a grouping separator, e.g. 12,345.67 should just be 12345.67
        updatedText = updatedText.replacingOccurrences(of: Locale.current.groupingSeparator ?? ",", with: "")

        // MARK: Verify new character is a valid character
        // number of logs units is a decimal so it can only contain 0-9 and a period (also technically a , for countries that use that instead of a .)
        let decimalSeparator: Character = Locale.current.decimalSeparator?.first ?? "."
        
        var acceptableCharacters = "0123456789"
        acceptableCharacters.append(decimalSeparator)
        
        var containsInvalidCharacter = false
        updatedText.forEach { character in
            if acceptableCharacters.firstIndex(of: character) == nil {
                containsInvalidCharacter = true
            }
        }
        guard containsInvalidCharacter == false else {
            return false
        }

        // MARK: Verify period/command count
        let occurancesOfDecimalSeparator = {
            var count = 0
            updatedText.forEach { char in
                if char == decimalSeparator {
                    count += 1
                }
            }
            return count
        }()
        
        if occurancesOfDecimalSeparator > 1 {
            // If updated text has more than one period/comma, it will be an invalid decimal number
            return false
        }
        
        // MARK: Verify number of digits after period or comma
        // "123.456"
        if let componentBeforeDecimalSeparator = updatedText.split(separator: decimalSeparator)[safe: 0] {
            // "123"
            // We only want to allow five numbers before the decimal place
            if componentBeforeDecimalSeparator.count > 5 {
                return false
            }
        }
        if let componentAfterDecimalSeparator = updatedText.split(separator: decimalSeparator)[safe: 1] {
            // "456"
            // We only want to allow two decimals after the decimal place
            if componentAfterDecimalSeparator.count > 2 {
                return false
            }
        }
        
        // At the end of the function, update the text field's text to the updated text
        logNumberOfLogUnitsTextField?.text = updatedText
        // Return false because we manually set the text field's text
        return false
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't allow the user to add a new line. If they do, we interpret that as the user hitting the done button.
        guard text != "\n" else {
            actionsDelegate?.dismissKeyboard()
            return false
        }
        
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under logNoteCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logNoteCharacterLimit
    }
    
    // if extra space is added, removes it and ends editing, makes done button function like done instead of adding new line
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            actionsDelegate?.dismissKeyboard()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
