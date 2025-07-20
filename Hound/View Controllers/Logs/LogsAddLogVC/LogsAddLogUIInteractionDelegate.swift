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
    func textViewDidBeginEditing(_ textView: UITextView)
    func textFieldDidBeginEditing(_ textFeild: UITextField)
}

final class LogsAddLogUIInteractionDelegate: NSObject{
    
    weak var actionsDelegate: LogsAddLogUIInteractionActionsDelegate?
    var logCustomActionNameTextField: HoundTextField?
    var logNumberOfLogUnitsTextField: HoundTextField?

    
    
   
    
    
    
}
