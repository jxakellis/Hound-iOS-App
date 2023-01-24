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
    
    @IBOutlet private weak var dogIconImageView: UIImageView!
    
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
    
    var dog: Dog! = nil
    
    // MARK: - Functions
    
    // Function used externally to setup dog
    func setup(forDog dogPassed: Dog) {
        self.dogNameLabel.adjustsFontSizeToFitWidth = true
        
        dog = dogPassed
        
        // Size Ratio Scaling
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Dog Name Label Configuration
        dogNameLabel.text = dogPassed.dogName
        dogNameLabel.font = dogNameLabel.font.withSize(40.0 * sizeRatio)
        dogNameHeightConstraint.constant = 45.0 * sizeRatio
        
        // Right Chevron Configuration
        rightChevronLeadingConstraint.constant = 10.0 * sizeRatio
        rightChevronTrailingConstraint.constant = 10.0 * sizeRatio
        rightChevronWidthConstraint.constant = 20.0 * sizeRatio
        
        // Dog Icon Configuration
        
        dogIconImageView.image = dogPassed.dogIcon ?? ClassConstant.DogConstant.defaultDogIcon
        dogIconImageView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        let dogIconWidth = 55.0 * sizeRatio
        dogIconWidthConstraint.constant = dogIconWidth
        
        dogIconLeadingConstraint.constant = 5.0 * sizeRatio
        dogIconTrailingConstraint.constant = 5.0 * sizeRatio
        dogIconTopConstraint.constant = 10.0 * sizeRatio
        dogIconBottomConstraint.constant = 10.0 * sizeRatio
        
        if dogIconImageView.image?.isEqualToImage(image: ClassConstant.DogConstant.defaultDogIcon) == false {
            dogIconImageView.layer.cornerRadius = dogIconWidth / 2
        }
        else {
            dogIconImageView.layer.cornerRadius = 0.0
        }
    }
    
}
