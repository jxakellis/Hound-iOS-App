//
//  DropDownParentDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundDropDownTableViewCell: HoundTableViewCell {

    // MARK: - Elements

    let label: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        return label
    }()

    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!

    // MARK: - Properties
    
    static let reuseIdentifier = "HoundDropDownTableViewCell"

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false

    // MARK: - Functions

    func adjustLeadingTrailing(newConstant: CGFloat) {
        leading.constant = newConstant
        trailing.constant = newConstant
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected selected: Bool, animated: Bool = true) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else { return }

        isCustomSelected = selected
        
        guard animated else {
            UIView.performWithoutAnimation {
                self.contentView.backgroundColor = selected ? UIColor.systemBlue : UIColor.systemBackground
                self.label.textColor = selected ? UIColor.white : UIColor.label
            }
            return
        }
        
        UIView.animate(withDuration: VisualConstant.AnimationConstant.selectSingleElement) {
            self.contentView.backgroundColor = selected ? UIColor.systemBlue : UIColor.systemBackground
            self.label.textColor = selected ? UIColor.white : UIColor.label
        }

    }

    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(label)
    }

    override func setupConstraints() {
        super.setupConstraints()
        leading = label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori)
        trailing = label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leading,
            trailing
        ])
    }
}
