//
//  SettingsSubscriptionCancelReasonTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsSubscriptionCancelReasonTableViewCellDelegate: AnyObject {
    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelReasonTableViewCell, forIsCustomSelected: Bool)
}

final class SettingsSubscriptionCancelReasonTableViewCell: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let cancellationReasonLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .vertical)
        label.text = "Too Expensive"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let checkmarkImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 270, compressionResistancePriority: 770)
        
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        
        return imageView
    }()
    
    // MARK: - Additional UI Elements
    private let circleBehindCheckmarkImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 260, compressionResistancePriority: 760)
        
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .label
        
        return imageView
    }()
    
    // MARK: - Properties
    
    /// The cancellation reason this cell is displaying
    private(set) var cancellationReason: SubscriptionCancellationReason?
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false
    
    private weak var delegate: SettingsSubscriptionCancelReasonTableViewCellDelegate?
    
    // MARK: - Functions
    
    func setup(forDelegate: SettingsSubscriptionCancelReasonTableViewCellDelegate, forCancellationReason: SubscriptionCancellationReason, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason
        
        containerView.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        containerView.layer.cornerCurve = .continuous
        
        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }
    
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
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
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
        contentView.addSubview(containerView)
        containerView.addSubview(cancellationReasonLabel)
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(circleBehindCheckmarkImageView)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            cancellationReasonLabel.topAnchor.constraint(equalTo: checkmarkImageView.topAnchor),
            cancellationReasonLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            cancellationReasonLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            cancellationReasonLabel.bottomAnchor.constraint(equalTo: checkmarkImageView.bottomAnchor),
            cancellationReasonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            cancellationReasonLabel.heightAnchor.constraint(equalToConstant: 25),
            
            checkmarkImageView.topAnchor.constraint(equalTo: circleBehindCheckmarkImageView.topAnchor, constant: 2.5),
            checkmarkImageView.bottomAnchor.constraint(equalTo: circleBehindCheckmarkImageView.bottomAnchor, constant: -2.5),
            checkmarkImageView.leadingAnchor.constraint(equalTo: circleBehindCheckmarkImageView.leadingAnchor, constant: 2.5),
            checkmarkImageView.leadingAnchor.constraint(equalTo: cancellationReasonLabel.trailingAnchor, constant: 10),
            checkmarkImageView.trailingAnchor.constraint(equalTo: circleBehindCheckmarkImageView.trailingAnchor, constant: -2.5),
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            checkmarkImageView.widthAnchor.constraint(equalTo: checkmarkImageView.heightAnchor, multiplier: 1 / 1),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
        
    }
}
