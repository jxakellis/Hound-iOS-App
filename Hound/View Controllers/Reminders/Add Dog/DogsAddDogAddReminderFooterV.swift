//
//  DogsAddDogAddReminderFooterV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogAddReminderFooterVDelegate: AnyObject {
    func didTouchUpInsideAddReminder()
}

class DogsAddDogAddReminderFooterV: HoundView {
    
    // MARK: - Elements
    
    private let contentView: HoundView = HoundView()
    
    private let addReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.isEnabled = false
        
        button.setTitle("Add Reminder", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.applyStyle(.thinLabelBorder)
        
        return button
    }()
    
    @objc private func didTouchUpInsideReminder(_ sender: Any) {
        delegate?.didTouchUpInsideAddReminder()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddDogAddReminderFooterVDelegate?
    
    private static let topConstraintConstant: CGFloat = 20.0
    private static let bottomConstraintConstant: CGFloat = 20.0
    private static let leadingConstraintConstant: CGFloat = 20.0
    private static let trailingConstraintConstant: CGFloat = 20.0
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddDogAddReminderFooterVDelegate) {
        delegate = forDelegate
        addReminderButton.isEnabled = true
    }
    
    // MARK: - Functions
    
    static func cellHeight(forTableViewWidth: CGFloat) -> CGFloat {
        return topConstraintConstant + ((forTableViewWidth - leadingConstraintConstant - trailingConstraintConstant) * ConstraintConstant.Button.wideHeightMultiplier) + bottomConstraintConstant
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.frame = bounds
        addSubview(contentView)
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(addReminderButton)
        addReminderButton.addTarget(self, action: #selector(didTouchUpInsideReminder), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // addReminderButton
        let addReminderButtonTop = addReminderButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DogsAddDogAddReminderFooterV.topConstraintConstant)
        let addReminderButtonBottom = addReminderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DogsAddDogAddReminderFooterV.bottomConstraintConstant)
        let addReminderButtonLeading = addReminderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DogsAddDogAddReminderFooterV.leadingConstraintConstant)
        let addReminderButtonTrailing = addReminderButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DogsAddDogAddReminderFooterV.trailingConstraintConstant)
        let addReminderButtonCenterX = addReminderButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let addReminderButtonWidthToHeight = addReminderButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: contentView)
        
        NSLayoutConstraint.activate([
            addReminderButtonTop,
            addReminderButtonBottom,
            addReminderButtonLeading,
            addReminderButtonTrailing,
            addReminderButtonCenterX,
            addReminderButtonWidthToHeight
        ])
    }

}
