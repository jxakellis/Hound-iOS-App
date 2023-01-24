//
//  UIViewControllerExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performSegueOnceInWindowHierarchy(segueIdentifier: String) {
        
        waitLoop()
        
        func waitLoop () {
            if self.viewIfLoaded?.window != nil {
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    waitLoop()
                }
            }
        }
    }
}
