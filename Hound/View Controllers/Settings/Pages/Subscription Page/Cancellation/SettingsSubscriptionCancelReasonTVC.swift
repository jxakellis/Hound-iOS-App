//
//  SettingsSubscriptionCancelReasonTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsSubscriptionCancelReasonTVCDelegate: AnyObject {
    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelReasonTVC, forIsCustomSelected: Bool)
}

// TODO VERIFY UI
final class SettingsSubscriptionCancelReasonTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let cancellationReasonLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 300)
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let checkmarkImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 270, compressionResistancePriority: 270)
        
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        
        return imageView
    }()
    
    private let circleBehindCheckmarkImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 260, compressionResistancePriority: 260)
        
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .label
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsSubscriptionCancelReasonTVC"
    
    /// The cancellation reason this cell is displaying
    private(set) var cancellationReason: SubscriptionCancellationReason?
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false
    
    private weak var delegate: SettingsSubscriptionCancelReasonTVCDelegate?
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsSubscriptionCancelReasonTVCDelegate, forCancellationReason: SubscriptionCancellationReason, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
        
        containerView.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        containerView.layer.cornerCurve = .continuous
        
        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }
    
    // MARK: - Functions
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected: Bool, isAnimated: Bool) {
        isCustomSelected = forSelected
        
        delegate?.didSetCustomIsSelected(forCell: self, forIsCustomSelected: isCustomSelected)
        
        UIView.animate(withDuration: isAnimated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.checkmarkImageView.isHidden = !self.isCustomSelected
            
            self.containerView.layer.borderColor = self.isCustomSelected ? UIColor.systemGreen.cgColor : UIColor.label.cgColor
            self.containerView.layer.borderWidth = self.isCustomSelected ? 4.0 : 2.0
            
            self.setupCancellationLabel()
        }
    }
    
    /// Attempts to set the attributedText for cancellationReasonLabel given the cancellationReason and isCustomSelected
    private func setupCancellationLabel() {
        guard let cancellationReason = cancellationReason else {
            cancellationReasonLabel.text = VisualConstant.TextConstant.unknownText
            return
        }
        
        // If the cell isn't selected, all of the text is the tertiary label color
        let cancellationReasonTextAttributes: [NSAttributedString.Key: Any] = [
            .font: VisualConstant.FontConstant.secondaryHeaderLabel,
            .foregroundColor: UIColor.label
        ]
        
        cancellationReasonLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            // "" -> "6 months - $59.99"
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: cancellationReason.readableValue,
                attributes: cancellationReasonTextAttributes)
            
            return message
        }
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(cancellationReasonLabel)
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(circleBehindCheckmarkImageView)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // cancellationReasonLabel
        let cancellationReasonLabelTop = cancellationReasonLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10)
        let cancellationReasonLabelBottom = cancellationReasonLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        let cancellationReasonLabelLeading = cancellationReasonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        let cancellationReasonLabelHeight = cancellationReasonLabel.heightAnchor.constraint(equalToConstant: 25)

        // checkmarkImageView
        let checkmarkImageViewLeading = checkmarkImageView.leadingAnchor.constraint(equalTo: cancellationReasonLabel.trailingAnchor, constant: 10)
        let checkmarkImageViewTrailing = checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        let checkmarkImageViewWidth = checkmarkImageView.widthAnchor.constraint(equalTo: checkmarkImageView.heightAnchor)
        let checkmarkImageViewCenterY = checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)

        // circleBehindCheckmarkImageView
        let circleBehindCheckmarkImageViewCenterY = circleBehindCheckmarkImageView.centerYAnchor.constraint(equalTo: checkmarkImageView.centerYAnchor)
        let circleBehindCheckmarkImageViewCenterX = circleBehindCheckmarkImageView.centerXAnchor.constraint(equalTo: checkmarkImageView.centerXAnchor)
        let circleBehindCheckmarkImageViewWidth = circleBehindCheckmarkImageView.widthAnchor.constraint(equalTo: checkmarkImageView.widthAnchor, constant: 7)
        let circleBehindCheckmarkImageViewHeight = circleBehindCheckmarkImageView.heightAnchor.constraint(equalTo: checkmarkImageView.heightAnchor, constant: 7)

        // containerView
        let containerViewTop = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerViewBottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerViewLeading = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

        NSLayoutConstraint.activate([
            // cancellationReasonLabel
            cancellationReasonLabelTop,
            cancellationReasonLabelBottom,
            cancellationReasonLabelLeading,
            cancellationReasonLabelHeight,

            // checkmarkImageView
            checkmarkImageViewLeading,
            checkmarkImageViewTrailing,
            checkmarkImageViewWidth,
            checkmarkImageViewCenterY,

            // circleBehindCheckmarkImageView
            circleBehindCheckmarkImageViewCenterY,
            circleBehindCheckmarkImageViewCenterX,
            circleBehindCheckmarkImageViewWidth,
            circleBehindCheckmarkImageViewHeight,

            // containerView
            containerViewTop,
            containerViewBottom,
            containerViewLeading,
            containerViewTrailing
        ])
    }

}
