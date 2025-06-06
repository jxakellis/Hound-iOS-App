//
//  DogsAddDogAddReminderFooterView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogAddReminderFooterViewDelegate: AnyObject {
    func didTouchUpInsideAddReminder()
}

class DogsAddDogAddReminderFooterView: GeneralUIView {
    
    // MARK: - Elements
    
    private let contentView: GeneralUIView = GeneralUIView()
    
    private let addReminderButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.isEnabled = false
        
        button.setTitle("Add Reminder", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderColor = .label
        button.borderWidth = 2
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTouchUpInsideReminder(_ sender: Any) {
        delegate.didTouchUpInsideAddReminder()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddDogAddReminderFooterViewDelegate!
    
    private static let topConstraintConstant: CGFloat = 20.0
    private static let bottomConstraintConstant: CGFloat = 20.0
    private static let leadingConstraintConstant: CGFloat = 20.0
    private static let trailingConstraintConstant: CGFloat = 20.0
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsAddDogAddReminderFooterViewDelegate) {
        delegate = forDelegate
        addReminderButton.isEnabled = true
    }
    
    static func cellHeight(forTableViewWidth: CGFloat) -> CGFloat {
        return topConstraintConstant + ((forTableViewWidth - leadingConstraintConstant - trailingConstraintConstant) * 0.16) + bottomConstraintConstant
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.frame = bounds
        addSubview(contentView)
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        contentView.addSubview(addReminderButton)
        addReminderButton.addTarget(self, action: #selector(didTouchUpInsideReminder), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            addReminderButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DogsAddDogAddReminderFooterView.topConstraintConstant),
            addReminderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DogsAddDogAddReminderFooterView.bottomConstraintConstant),
            addReminderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DogsAddDogAddReminderFooterView.leadingConstraintConstant),
            addReminderButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DogsAddDogAddReminderFooterView.trailingConstraintConstant),
            addReminderButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addReminderButton.widthAnchor.constraint(equalTo: addReminderButton.heightAnchor, multiplier: 1 / 0.16)
            
        ])
        
    }
}
