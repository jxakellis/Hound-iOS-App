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

final class HoundIntroductionDogIconView: GeneralUIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forInfo: info) {
            self.dogIconButton.setTitle(nil, for: .normal)
            self.dogIconButton.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - Elements
    
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 340, compressionResistancePriority: 340)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let dogIconTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.text = "Select an icon for Bella"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let dogIconDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "It's optional, but adding a cute picture for them is a wonderful choice"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dogIconButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.isEnabled = false
        
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 0.5
        button.borderColor = .systemGray2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    private let finishButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 290)

        button.isEnabled = false
        
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 350, compressionResistancePriority: 350)

        imageView.image = UIImage(named: "blueShorelineManThrowingStickForDog")
        
        return imageView
    }()
    
    private let boundingBoxForDogIconButton: GeneralUIView = {
        let view = GeneralUIView()
        view.clipsToBounds = true
        
        return view
    }()
    @objc private func didTouchUpInsideFinish(_ sender: Any) {
        self.dismissKeyboard()
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
        
        delegate?.willFinish(forDogIcon: dogIcon)
    }
    
    // MARK: - Properties
    
    private weak var delegate: HoundIntroductionDogIconViewDelegate?
    
    private var dogIcon: UIImage? {
        dogIconButton.imageView?.image
    }
    
    // MARK: - Setup
    
    /// Setup components of the view that do depend upon data provided by an external source
    func setup(forDelegate: HoundIntroductionDogIconViewDelegate, forDogName dogName: String) {
        delegate = forDelegate
        dogIconButton.isEnabled = true
        finishButton.isEnabled = true
        
        dogIconTitleLabel.text = "Select an icon for \(dogName)"
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        backgroundColor = .systemBackground
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        DogIconManager.didSelectDogIconController.delegate = self
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(backgroundImageView)
        addSubview(whiteBackgroundView)
        addSubview(dogIconTitleLabel)
        addSubview(dogIconDescriptionLabel)
        addSubview(boundingBoxForDogIconButton)
        boundingBoxForDogIconButton.addSubview(dogIconButton)
        addSubview(finishButton)
        
        dogIconButton.addTarget(self, action: #selector(didTouchUpInsideDogIcon), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(didTouchUpInsideFinish), for: .touchUpInside)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // backgroundImageView
        let backgroundImageViewTop = backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor)
        let backgroundImageViewLeading = backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let backgroundImageViewTrailing = backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let backgroundImageViewWidth = backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor)
        
        // whiteBackgroundView
        let whiteBackgroundViewTop = whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25)
        let whiteBackgroundViewBottom = whiteBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let whiteBackgroundViewLeading = whiteBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let whiteBackgroundViewTrailing = whiteBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        // dogIconTitleLabel
        let dogIconTitleLabelTop = dogIconTitleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25)
        let dogIconTitleLabelLeading = dogIconTitleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        let dogIconTitleLabelTrailing = dogIconTitleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        
        // dogIconDescriptionLabel
        let dogIconDescriptionLabelTop = dogIconDescriptionLabel.topAnchor.constraint(equalTo: dogIconTitleLabel.bottomAnchor, constant: 7.5)
        let dogIconDescriptionLabelLeading = dogIconDescriptionLabel.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor)
        let dogIconDescriptionLabelTrailing = dogIconDescriptionLabel.trailingAnchor.constraint(equalTo: dogIconTitleLabel.trailingAnchor)
        
        // boundingBoxForDogIconButton
        let boundingBoxForDogIconButtonTop = boundingBoxForDogIconButton.topAnchor.constraint(equalTo: dogIconDescriptionLabel.bottomAnchor, constant: 15)
        let boundingBoxForDogIconButtonLeading = boundingBoxForDogIconButton.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor)
        let boundingBoxForDogIconButtonTrailing = boundingBoxForDogIconButton.trailingAnchor.constraint(equalTo: dogIconTitleLabel.trailingAnchor)
        
        // dogIconButton (inside bounding box)
        let dogIconButtonCenterX = dogIconButton.centerXAnchor.constraint(equalTo: boundingBoxForDogIconButton.centerXAnchor)
        let dogIconButtonCenterY = dogIconButton.centerYAnchor.constraint(equalTo: boundingBoxForDogIconButton.centerYAnchor)
        let dogIconButtonWidth = dogIconButton.widthAnchor.constraint(equalTo: dogIconButton.heightAnchor)
        let dogIconButtonBoxWidth = dogIconButton.widthAnchor.constraint(equalTo: dogIconTitleLabel.widthAnchor, multiplier: 4.0 / 10.0)
        
        // finishButton
        let finishButtonTop = finishButton.topAnchor.constraint(equalTo: boundingBoxForDogIconButton.bottomAnchor, constant: 15)
        let finishButtonBottom = finishButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        let finishButtonLeading = finishButton.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor)
        let finishButtonTrailing = finishButton.trailingAnchor.constraint(equalTo: dogIconTitleLabel.trailingAnchor)
        let finishButtonWidth = finishButton.widthAnchor.constraint(equalTo: finishButton.heightAnchor, multiplier: 1 / 0.16)
        finishButtonTop.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            // backgroundImageView
            backgroundImageViewTop,
            backgroundImageViewLeading,
            backgroundImageViewTrailing,
            backgroundImageViewWidth,
            
            // whiteBackgroundView
            whiteBackgroundViewTop,
            whiteBackgroundViewBottom,
            whiteBackgroundViewLeading,
            whiteBackgroundViewTrailing,
            
            // dogIconTitleLabel
            dogIconTitleLabelTop,
            dogIconTitleLabelLeading,
            dogIconTitleLabelTrailing,
            
            // dogIconDescriptionLabel
            dogIconDescriptionLabelTop,
            dogIconDescriptionLabelLeading,
            dogIconDescriptionLabelTrailing,
            
            // boundingBoxForDogIconButton
            boundingBoxForDogIconButtonTop,
            boundingBoxForDogIconButtonLeading,
            boundingBoxForDogIconButtonTrailing,
            
            // dogIconButton
            dogIconButtonCenterX,
            dogIconButtonCenterY,
            dogIconButtonWidth,
            dogIconButtonBoxWidth,
            
            // finishButton
            finishButtonTop,
            finishButtonBottom,
            finishButtonLeading,
            finishButtonTrailing,
            finishButtonWidth
        ])
    }

}
