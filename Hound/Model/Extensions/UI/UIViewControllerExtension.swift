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
    
    func dismissIntoServerSyncViewController() {
        // Invoke dismissIntoServerSyncViewController on any presented viewcontrollers, so those can be properly dismissed.
        if let presentedViewController = presentedViewController {
            guard (presentedViewController is ServerSyncViewController) == false else {
                return
            }
            
            // Let the user see this animation, then once complete invoke this function again
            presentedViewController.dismissIntoServerSyncViewController()
            return
        }
        
        // presentingViewController pointer will turn to nil once self is dismissed, so store this in a variable.
        let presentingViewController = presentingViewController
        
        self.dismiss(animated: true) {
            // If the ViewController that is one level above MainTabBarViewController isn't the ServerSyncViewController, we want to dismiss that view controller directly so we get to the ServerSyncViewController.
            // This could happen if the FamilyIntroductionViewController was presented earlier on, when transitioning from ServerSyncViewController to FamilyIntroductionViewController to MainTabBarViewController
            if (presentingViewController is ServerSyncViewController) == false {
                // leave this step as animated, otherwise the user can see a jump
                presentingViewController?.dismiss(animated: true)
            }
        }
    }
    
}
