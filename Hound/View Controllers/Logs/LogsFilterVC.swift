//
//  LogsFilterViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsFilterViewController: GeneralUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // LogsFilterViewController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        /*
        // The actual size of the container view without the padding added
        let containerViewHeightWithoutPadding = containerView.frame.height - containerViewPaddingHeightConstraint.constant
        // By how much the container view without padding is smaller than the safe area of the view
        let shortFallOfSafeArea = view.safeAreaLayoutGuide.layoutFrame.height - containerViewHeightWithoutPadding
        // If the containerView itself doesn't use up the whole safe area, then we add extra padding so it does
        containerViewPaddingHeightConstraint.constant = shortFallOfSafeArea > 0.0 ? shortFallOfSafeArea : 0.0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
         */
    }
}
