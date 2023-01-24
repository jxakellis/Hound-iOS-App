//
//  UINavigationControllerExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/26/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UINavigationItem {
    /// Adds an activityIndicator to the left of the navigation items's title. Indicates to the user that something on the page is refreshing.
    func beginTitleViewActivity(forNavigationBarFrame: CGRect) {
        titleViewActivity(forNavigationBarFrame: forNavigationBarFrame, forIsAnimating: true)
    }
    
    /// Removes activityIndicator from the left of the navigation items's title. Indicates to the user that something on the page is done refreshing.
    func endTitleViewActivity(forNavigationBarFrame: CGRect) {
        titleViewActivity(forNavigationBarFrame: forNavigationBarFrame, forIsAnimating: false)
    }
    
    private func titleViewActivity(forNavigationBarFrame navigationBarFrame: CGRect, forIsAnimating isAnimating: Bool) {
        // can't be an extension of UINavigationController, as UINavigationController doesn't contain the proper reference to UINavigationItem that is in use on the target UIViewController
        let activityLabel = ScaledUILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: 0,
            height: 20))
        activityLabel.font = VisualConstant.FontConstant.boldEmphasizedUILabel
        activityLabel.textColor = .systemBlue
        activityLabel.text = title
        activityLabel.sizeToFit()
        
        let totalActivityItemsHeight = activityLabel.frame.height
        // activityIndicator's height and width is equal to activityLabel's height. In addition, activityIndicator sits 0.2 of its width to the left of activityLabel to create a tiny space
        // pad both sides of activityLabel so that activityLabel stays centered when activityIndicator is added
        let totalActivityItemsWidth = totalActivityItemsHeight + (totalActivityItemsHeight * 0.2) + activityLabel.frame.width + (totalActivityItemsHeight * 0.2) + totalActivityItemsHeight
        
        let activityView = UIView(frame: CGRect(
            x: -1,
            y: -1,
            width: totalActivityItemsWidth,
            height: navigationBarFrame.height))
        
        let activityIndicator = UIActivityIndicatorView(frame:
            CGRect(
            // sits left most in activityView
            x: 0,
            // find position of center of activityView by dividing activityViewHeight by 2, find top most bound by adding half the total height
            y: Int((activityView.frame.height / 2) - (totalActivityItemsHeight / 2)),
            width: Int(totalActivityItemsHeight),
            height: Int(totalActivityItemsHeight)
            )
        )
        activityIndicator.style = .medium
        if isAnimating {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        // reframe activity label
        activityLabel.frame = CGRect(
            // find position of center of activityView by dividing activityViewWidth by 2
            x: Int((activityView.frame.width / 2) - (activityLabel.frame.width / 2)),
            // find position of center of activityView by dividing activityViewHeight by 2, find top most bound by adding half the total height
            y: Int((activityView.frame.height / 2) - (totalActivityItemsHeight / 2)),
            width: Int(activityLabel.frame.width),
            height: Int(totalActivityItemsHeight)
        )
        
        activityView.addSubview(activityIndicator)
        activityView.addSubview(activityLabel)
        
        titleView = activityView
    }
}
