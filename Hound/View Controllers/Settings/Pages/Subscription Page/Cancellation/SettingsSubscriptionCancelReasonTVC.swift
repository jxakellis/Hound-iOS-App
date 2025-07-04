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

final class SettingsSubscriptionCancelReasonTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let cancellationReasonLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        // attributes set in setupCancellationLabel
        return label
    }()
    
    private let checkmarkButton: HoundButton = {
        let button = HoundButton(huggingPriority: 250, compressionResistancePriority: 250)
        
        button.isUserInteractionEnabled = false
        
        button.isHidden = true
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.tintColor = .systemGreen
        
        button.backgroundCircleTintColor = .systemBackground
        
        return button
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
        
        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }
    
    // MARK: - Functions
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected: Bool, isAnimated: Bool) {
        isCustomSelected = forSelected
        
        delegate?.didSetCustomIsSelected(forCell: self, forIsCustomSelected: isCustomSelected)
        
        UIView.animate(withDuration: isAnimated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.checkmarkButton.isHidden = !self.isCustomSelected
            
            self.containerView.applyStyle(self.isCustomSelected ? .greenSelectionBorder : .labelBorder)
            
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
            .font: VisualConstant.FontConstant.emphasizedPrimaryRegularLabel,
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
        containerView.addSubview(checkmarkButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // cancellationReasonLabel
        NSLayoutConstraint.activate([
            cancellationReasonLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            cancellationReasonLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset),
            cancellationReasonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori)
        ])
        
        // checkmarkButton
        NSLayoutConstraint.activate([
            checkmarkButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset / 2.0),
            checkmarkButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(ConstraintConstant.Spacing.absoluteVerticalInset / 2.0)),
            checkmarkButton.leadingAnchor.constraint(greaterThanOrEqualTo: cancellationReasonLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            checkmarkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentIntraHori),
            checkmarkButton.createSquareAspectRatio()
        ])
    }

}
