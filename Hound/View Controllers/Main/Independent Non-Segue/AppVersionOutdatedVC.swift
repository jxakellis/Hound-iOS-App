//
//  AppVersionOutdatedViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class AppVersionOutdatedViewController: GeneralUIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var pawWithHands: UIImageView!
    
    @IBAction private func didTapOpenAppStore(_ sender: Any) {
        // Open the page for hound on the user's device, don't include a localized url (e.g. with the /us/) so it localizes to a users zone
        guard let url = URL(string: "https://apps.apple.com/app/hound-family-dog-organizer/id1564604025") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands
        }
    }
}
