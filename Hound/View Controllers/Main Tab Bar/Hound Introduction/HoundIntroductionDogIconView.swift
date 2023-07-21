//
//  HoundIntroductionDogIconView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogIconViewDelegate: AnyObject {
    /// TO DO NOW redo Invoked either by textFieldShouldReturn or didTouchUpInsideContinue. Returns nil if no dogName is required, otherwise returns the current dogName (or resorts to a default). If this function is invoked, this view has completed
    func willFinish(forDogIcon: UIImage?)
}

class HoundIntroductionDogIconView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forDogIconButton: dogIconButton, forInfo: info) {
            self.dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var dogIconTitleLabel: ScaledUILabel!
    
    @IBOutlet private weak var dogIconDescriptionLabel: ScaledUILabel!
    
    @IBOutlet private weak var dogIconButton: ScaledImageUIButton!
    @IBAction private func didTouchUpInsideDogIcon(_ sender: Any) {
        // TO DO NOW after a user selects an image, we should clear the text and stuff out of the button so its only the image
        if let imagePickMethodAlertController = imagePickMethodAlertController {
            PresentationManager.enqueueActionSheet(imagePickMethodAlertController, sourceView: dogIconButton)
        }
    }
    
    @IBOutlet private weak var finishButton: SemiboldUIButton!
    @IBAction private func didTouchUpInsideFinish(_ sender: Any) {
        self.endEditing(true)
        delegate?.willFinish(forDogIcon: nil)
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
    }
    
    // MARK: - Properties
    
    private var delegate: HoundIntroductionDogIconViewDelegate?
    
    private var imagePickMethodAlertController: UIAlertController?
    
    private var dogIcon: UIImage? {
        return dogIconButton.imageView?.image
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStatic()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStatic()
    }
    
    // MARK: - Function
    
    /// Setup components of the view that don't depend upon data provided by an external source
    private func setupStatic() {
        containerView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        containerView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        containerView.layer.borderColor = VisualConstant.LayerConstant.whiteBackgroundBorderColor
        containerView.layer.borderWidth = VisualConstant.LayerConstant.boldBorderWidth
        
        dogIconButton.isEnabled = false
        dogIconButton.shouldRoundCorners = true
        dogIconButton.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        dogIconButton.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        dogIconButton.layer.borderColor = VisualConstant.LayerConstant.defaultBorderColor
        dogIconButton.layer.borderWidth = VisualConstant.LayerConstant.defaultBorderWidth
        
        finishButton.isEnabled = false
        finishButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
    }
    
    /// Setup components of the view that do depend upon data provided by an external source
    func setupDynamic(forDelegate delegate: HoundIntroductionDogIconViewDelegate, forDogName dogName: String) {
        self.delegate = delegate
         
        dogIconTitleLabel.text = "Select an icon for \(dogName)"
        dogIconDescriptionLabel.text = "It's optional, but adding a cute picture for them is a wonderful choice"
        
        dogIconButton.isEnabled = true
        
        finishButton.isEnabled = true
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = DogIconManager.setupDogIconImagePicker()
        picker.delegate = self
        imagePickMethodAlertController = viewController
    }

}
