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
    
    /// viewDidLayoutSubviews is called multiple times by the view controller. We want to invoke our code inside viewDidLayoutSubviews once the safe area is established. On viewDidLayoutSubviews's first call, the safe area isn't normally established. Therefore, we want to have a check in place to make sure the safe area is setup before proceeding. NOTE: Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar). Embedded views do not have safe area insets
    func didSetupSafeArea() -> Bool {
        return view.safeAreaInsets.top != 0.0 || view.safeAreaInsets.bottom != 0.0 || view.safeAreaInsets.left != 0.0 || view.safeAreaInsets.right != 0.0
    }
    
    /// Recursively iterates through parent to find the highestParentViewController that has its view added to a window (and is therefore able to present other views)
    var highestParentViewController: UIViewController {
        var highestParentViewController: UIViewController = self
        
        // Use .parent to find highestParentViewController
        while highestParentViewController.parent != nil {
            let nextHighestParentViewController = highestParentViewController.parent
            
            guard let nextHighestParentViewController = nextHighestParentViewController else {
                // The nextHighestParentViewController doesn't exist, therefore highestParentViewController is the highest level parent
                break
            }
            
            guard nextHighestParentViewController.viewIfLoaded?.window != nil else {
                // The nextHighestParentViewController's view had not been added to a window and can't present other views. Therefore, highestParentViewController is the highest level parent
                break
            }
            
            // nextHighestParentViewController is valid, continue to next iteration
            highestParentViewController = nextHighestParentViewController
        }
        
        return highestParentViewController
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
    
    func dismissToViewController(ofClass: AnyClass, animated: Bool, completionHandler: (() -> Void)?) {
        guard let presentingViewController = self.presentingViewController else {
            completionHandler?()
            return
        }
        
        if presentingViewController.isKind(of: ofClass) {
            self.dismiss(animated: animated, completion: completionHandler)
        }
        else {
            self.dismiss(animated: false) {
                presentingViewController.dismissToViewController(ofClass: ofClass, animated: animated, completionHandler: completionHandler)
            }
        }
    }
    
}
