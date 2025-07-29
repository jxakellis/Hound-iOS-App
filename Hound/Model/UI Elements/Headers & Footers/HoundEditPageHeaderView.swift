//
//  HoundEditPageHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class HoundEditPageHeaderView: HoundView {
    
    // MARK: - Elements
    
    private let titleLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 500, compressionResistancePriority: 500)
        label.textAlignment = .center
        label.text = "Default Edit Page Header"
        label.font = Constant.Visual.Font.primaryHeaderLabel
        label.textColor = UIColor.systemBlue
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let leadingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = UIColor.systemBlue
        button.isHidden = true
        return button
    }()
    
    let trailingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = UIColor.systemBlue
        button.isHidden = true
        return button
    }()
    
    // MARK: - Properties
    
    /// Controls if the leading button should be visible.
    var isLeadingButtonEnabled: Bool {
        get { !leadingButton.isHidden }
        set {
            leadingButton.isHidden = !newValue
            updateTitleLabelConstraints()
        }
    }
    
    /// Controls if the trailing button should be visible.
    var isTrailingButtonEnabled: Bool {
        get { !trailingButton.isHidden }
        set {
            trailingButton.isHidden = !newValue
            updateTitleLabelConstraints()
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(titleLabel)
        addSubview(leadingButton)
        addSubview(trailingButton)
    }
    
    private func updateTitleLabelConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            
            if leadingButton.isHidden && trailingButton.isHidden {
                make.top.equalTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
                make.leading.equalTo(self.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
                make.trailing.equalTo(self.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            }
            else {
                make.top.greaterThanOrEqualTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
                if !leadingButton.isHidden {
                    make.centerY.equalTo(leadingButton.snp.centerY)
                }
                else {
                    make.centerY.equalTo(trailingButton.snp.centerY)
                }
                make.leading.equalTo(leadingButton.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
                // this number just has to be negative. if i do .offset(Constant.Constraint.Spacing.contentIntraHori), it doesnt work at all lol
                make.trailing.equalTo(trailingButton.snp.leading).inset(-Constant.Constraint.Spacing.contentIntraHori)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        leadingButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(self.snp.leading).offset(Constant.Constraint.Spacing.absoluteCircleHoriInset)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Button.miniCircleHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.miniCircleMaxHeight)
            make.width.equalTo(leadingButton.snp.height)
        }
        
        trailingButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.trailing.equalTo(self.snp.trailing).inset(Constant.Constraint.Spacing.absoluteCircleHoriInset)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Button.miniCircleHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.miniCircleMaxHeight)
            make.width.equalTo(trailingButton.snp.height)
        }
        
        updateTitleLabelConstraints()
    }
    
    // MARK: - Functions
    
    /// Sets the header title text.
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
