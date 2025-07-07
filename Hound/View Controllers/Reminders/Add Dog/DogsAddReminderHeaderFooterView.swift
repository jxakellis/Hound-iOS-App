//
//  DogsAddReminderHeaderFooterView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderHeaderFooterViewDelegate: AnyObject {
    func didTouchUpInsideAddReminder()
}

class DogsAddReminderHeaderFooterView: HoundHeaderFooterView {
    
    // MARK: - Elements
    
    private lazy var addReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Add Reminder", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.applyStyle(.thinLabelBorder)
        
        button.addTarget(self, action: #selector(didTouchUpInsideReminder), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func didTouchUpInsideReminder(_ sender: Any) {
        delegate?.didTouchUpInsideAddReminder()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderHeaderFooterViewDelegate?
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderHeaderFooterViewDelegate) {
        delegate = forDelegate
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(addReminderButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // addReminderButton
        NSLayoutConstraint.activate([
            addReminderButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            addReminderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset).withPriority(.defaultHigh),
            addReminderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: contentView),
            addReminderButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }

}
