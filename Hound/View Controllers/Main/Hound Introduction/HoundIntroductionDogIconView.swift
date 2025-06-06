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
    
    // MARK: - Elements
    
    private let contentView: UIView = UIView()
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.setContentHuggingPriority(UILayoutPriority(340), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(340), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(840), for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority(840), for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    
    private let dogIconTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(330), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(330), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(830), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(830), for: .vertical)
        label.text = "Select an icon for Bella"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    
    private let dogIconDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(320), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(320), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(820), for: .vertical)
        label.text = "It's optional, but adding a cute picture for them is a wonderful choice"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    private let dogIconButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 230, compressionResistancePriority: 730)
        
        button.isEnabled = false
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)
        button.titleLabelTextColor = .placeholderText
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 0.5
        button.borderColor = .systemGray2
        button.shouldRoundCorners = true
        button.shouldScaleImagePointSize = true
        return button
    }()
    
    @objc private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }
    
    private let finishButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 790)

        button.isEnabled = false
        
        
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabelTextColor = .label
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 350, compressionResistancePriority: 850)

        imageView.image = UIImage(named: "blueShorelineManThrowingStickForDog")
        
        return imageView
    }()
    
    private let boundingBoxForDogIconButton: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    @objc private func didTouchUpInsideFinish(_ sender: Any) {
        self.dismissKeyboard()
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
        
        delegate.willFinish(forDogIcon: dogIcon)
    }
    
    // MARK: - Properties
    
    private weak var delegate: HoundIntroductionDogIconViewDelegate!
    
    private var dogIcon: UIImage? {
        dogIconButton.imageView?.image
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    // MARK: - Function
    
    /// Setup components of the view that do depend upon data provided by an external source
    func setup(forDelegate: HoundIntroductionDogIconViewDelegate, forDogName dogName: String) {
        delegate = forDelegate
        dogIconButton.isEnabled = true
        finishButton.isEnabled = true
        
        dogIconTitleLabel.text = "Select an icon for \(dogName)"
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.backgroundColor = .systemBackground
        contentView.frame = bounds
        addSubview(contentView)
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        DogIconManager.didSelectDogIconController.delegate = self
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(dogIconTitleLabel)
        contentView.addSubview(dogIconDescriptionLabel)
        contentView.addSubview(finishButton)
        contentView.addSubview(boundingBoxForDogIconButton)
        boundingBoxForDogIconButton.addSubview(dogIconButton)
        
        dogIconButton.addTarget(self, action: #selector(didTouchUpInsideDogIcon), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(didTouchUpInsideFinish), for: .touchUpInside)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor, multiplier: 1/1),
            
            dogIconTitleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25),
            dogIconTitleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dogIconTitleLabel.trailingAnchor.constraint(equalTo: dogIconDescriptionLabel.trailingAnchor),
            dogIconTitleLabel.trailingAnchor.constraint(equalTo: finishButton.trailingAnchor),
            dogIconTitleLabel.trailingAnchor.constraint(equalTo: boundingBoxForDogIconButton.trailingAnchor),
            dogIconTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            dogIconDescriptionLabel.topAnchor.constraint(equalTo: dogIconTitleLabel.bottomAnchor, constant: 7.5),
            dogIconDescriptionLabel.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor),
            dogIconDescriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            
            finishButton.topAnchor.constraint(equalTo: boundingBoxForDogIconButton.bottomAnchor, constant: 15),
            finishButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            finishButton.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor),
            finishButton.widthAnchor.constraint(equalTo: finishButton.heightAnchor, multiplier: 1/0.16),
            
            dogIconButton.centerXAnchor.constraint(equalTo: boundingBoxForDogIconButton.centerXAnchor),
            dogIconButton.centerYAnchor.constraint(equalTo: boundingBoxForDogIconButton.centerYAnchor),
            dogIconButton.widthAnchor.constraint(equalTo: dogIconButton.heightAnchor, multiplier: 1/1),
            dogIconButton.widthAnchor.constraint(equalTo: dogIconTitleLabel.widthAnchor, multiplier: 4/10),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            self.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: dogIconTitleLabel.trailingAnchor, constant: 20),
            
            boundingBoxForDogIconButton.topAnchor.constraint(equalTo: dogIconDescriptionLabel.bottomAnchor, constant: 15),
            boundingBoxForDogIconButton.leadingAnchor.constraint(equalTo: dogIconTitleLabel.leadingAnchor),
            
        ])
        
    }
}
