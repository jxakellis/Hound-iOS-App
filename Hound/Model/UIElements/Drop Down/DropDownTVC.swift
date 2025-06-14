//
//  DropDownParentDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DropDownTVC: GeneralUITableViewCell {

    // MARK: - Elements

    let label: GeneralUILabel = {
        let label = GeneralUILabel()
        label.font = .systemFont(ofSize: 17.5)
        return label
    }()

    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!

    // MARK: - Properties
    
    static let reuseIdentifier = "DropDownTVC"

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false

    // MARK: - Functions

    func adjustLeadingTrailing(newConstant: CGFloat) {
        leading.constant = newConstant
        trailing.constant = newConstant
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected selected: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }

        isCustomSelected = selected
        UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.label.textColor = selected ? .white : .label
        }

    }

    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        contentView.addSubview(label)
        
    }

    override func setupConstraints() {
        leading = label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        trailing = label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leading,
            trailing
        ])
        
    }
}
