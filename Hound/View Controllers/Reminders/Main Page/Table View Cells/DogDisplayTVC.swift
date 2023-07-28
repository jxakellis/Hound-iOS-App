//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogDisplayTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var dogIconButton: GeneralUIButton!
    
    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var dog: Dog?
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    // MARK: - Functions
    
    // Function used externally to setup dog
    func setup(forDog: Dog) {
        self.dogNameLabel.adjustsFontSizeToFitWidth = true
        self.dogIconButton.setImage(UITraitCollection.current.userInterfaceStyle == .dark
                                    ? ClassConstant.DogConstant.blackPawWithHands
                                    : ClassConstant.DogConstant.whitePawWithHands, for: .normal)
        
        dog = forDog
        
        // Size Ratio Scaling
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Dog Name Label Configuration
        dogNameLabel.text = forDog.dogName
        dogNameLabel.font = dogNameLabel.font.withSize(40.0 * sizeRatio)
        dogNameHeightConstraint.constant = 45.0 * sizeRatio
        
        // Right Chevron Configuration
        rightChevronLeadingConstraint.constant = 10.0 * sizeRatio
        rightChevronTrailingConstraint.constant = 20.0 * sizeRatio
        rightChevronWidthConstraint.constant = 20.0 * sizeRatio
        
        // Dog Icon Configuration
        
        if let dogIcon = forDog.dogIcon {
            dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        dogIconButton.shouldRoundCorners = forDog.dogIcon != nil
        
        let dogIconWidth = forDog.dogIcon == nil
        ? 45.0 * sizeRatio
        : 50.0 * sizeRatio
        dogIconWidthConstraint.constant = dogIconWidth
        
        let leadingTrailingTopBottomConstraintConstant = forDog.dogIcon == nil
        ? 10.0 * sizeRatio
        : 7.5 * sizeRatio
        dogIconLeadingConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconTrailingConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconTopConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconBottomConstraint.constant = leadingTrailingTopBottomConstraintConstant
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.dogIconButton.setImage(
                dog?.dogIcon ?? (
                    UITraitCollection.current.userInterfaceStyle == .dark
                    ? ClassConstant.DogConstant.blackPawWithHands
                    : ClassConstant.DogConstant.whitePawWithHands
                ),
                for: .normal)
        }
    }
    
}
