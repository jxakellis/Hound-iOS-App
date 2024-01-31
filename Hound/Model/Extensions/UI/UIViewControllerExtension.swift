//
//  UIViewControllerExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIViewController {

    @objc func dismissKeyboard() {
        self.view.dismissKeyboard()
    }

    /// Performs recursive dismisses without animation until the next presentingViewController is the same class as ofClass, then performs a dismiss with animation to that viewController of equal ofClass and invokes completionHandler once that finishes. If we run out of presentingViewController without finding one of ofClass, then completionHandler is not include
    func dismissToViewController(ofClass: AnyClass, completionHandler: (() -> Void)?) {
        // If we want to dismiss the self, we must make sure its presentedViewController is dismised
        self.presentedViewController?.dismiss(animated: false)
        
        guard self.isKind(of: ofClass) == false else {
            // We already have dismissed to that viewController of ofClass
            completionHandler?()
            return
        }

        // With a UITabBarController and UINavigationStack, self.presentingViewController is not a solely reliable way to iterate backwards through the "stack" of presents, segues, modal presentations, etc. Instead, we rely upon the fact that globalPresenter is set by viewDidAppear, which is invoked after a dismiss is complete

        if self.presentingViewController?.isKind(of: ofClass) == true {
            // presentingViewController is ofClass, so perform animations as this is the final dismiss
            self.dismiss(animated: true, completion: completionHandler)
        }
        else if self.isBeingPresented == true || self.presentingViewController != nil {
            // self.presentingViewController before dismiss and PresentationManager.globalPresenter can be the same, or they can be different. viewDidAppear of views that appear after dismiss can change PresentationManager.globalPresenter.
            // This view controller is being presented, so calling dismiss(animated:completion:) will actually dismiss something.
            self.dismiss(animated: false) {
                PresentationManager.lastFromGlobalPresenterStack?.dismissToViewController(ofClass: ofClass, completionHandler: completionHandler)
            }
        }
        else {
            // This view controller is NOT being presented, so calling dismiss(animated:completion:) won't do anything. Therefore, we ran out of places to dismiss to and didn't reach ofClass.
            completionHandler?()
        }

    }

    /// Recursively waits until self.viewIfLoaded?.window is not nil. Once it is not nil, performs the indicated segue
    func performSegueOnceInWindowHierarchy(segueIdentifier: String) {
        guard self.viewIfLoaded?.window != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.performSegueOnceInWindowHierarchy(segueIdentifier: segueIdentifier)
            }
            return
        }

        self.performSegue(withIdentifier: segueIdentifier, sender: self)
    }

}
