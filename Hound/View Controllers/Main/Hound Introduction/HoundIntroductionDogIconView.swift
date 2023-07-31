//
//  HoundIntroductionDogIconView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogIconViewDelegate: AnyObject {
    /// Invoked either by didTouchUpInsideFinish. Returns nil if no dogIcon is required, otherwise returns the current dogIcon selected. If this function is invoked, this view has completed
    func willFinish(forDogIcon: UIImage?)
}

final class HoundIntroductionDogIconView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forInfo: info) {
            self.dogIconButton.setTitle(nil, for: .normal)
            self.dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - IB
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var whiteBackgroundView: UIView!
    
    @IBOutlet private weak var dogIconTitleLabel: GeneralUILabel!
    
    @IBOutlet private weak var dogIconDescriptionLabel: GeneralUILabel!
    
    @IBOutlet private weak var dogIconButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    @IBOutlet private weak var finishButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideFinish(_ sender: Any) {
        self.dismissKeyboard()
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
        
        delegate.willFinish(forDogIcon: dogIcon)
    }
    
    // MARK: - Properties
    
    private weak var delegate: HoundIntroductionDogIconViewDelegate!
    
    private var dogIcon: UIImage? {
        return dogIconButton.imageView?.image
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeSubviews()
    }
    
    /// Setup components of the view that don't depend upon data provided by an external source
    private func initalizeSubviews() {
        _ = UINib(nibName: "HoundIntroductionDogIconView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
        
        whiteBackgroundView.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        whiteBackgroundView.layer.masksToBounds = true
        whiteBackgroundView.layer.cornerCurve = .continuous
        
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
        
        dogIconDescriptionLabel.text = "It's optional, but adding a cute picture for them is a wonderful choice"
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        DogIconManager.didSelectDogIconController.delegate = self
    }
    
    // MARK: - Function
    
    /// Setup components of the view that do depend upon data provided by an external source
    func setupDynamic(forDelegate: HoundIntroductionDogIconViewDelegate, forDogName dogName: String) {
        delegate = forDelegate
        dogIconButton.isEnabled = true
        finishButton.isEnabled = true
         
        dogIconTitleLabel.text = "Select an icon for \(dogName)"
    }

}
