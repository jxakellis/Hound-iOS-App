//
//  LogInfoBubbleTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class LogInfoBubbleCVC: UICollectionViewCell {
    
    // MARK: - Elements
    
    let label: HoundLabel = {
        let label = HoundLabel()
        label.backgroundColor = UIColor.secondarySystemBackground
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = false
        
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        
        label.shouldInsetText = true
        label.customTextInsets.left = Constant.Constraint.Spacing.contentTightIntraHori
        label.customTextInsets.right = Constant.Constraint.Spacing.contentTightIntraHori
        label.customTextInsets.top = 0
        label.customTextInsets.bottom = 0
        return label
    }()
    
    // MARK: - Properties
    
    private var maxWidthConstraint: Constraint?
    
    static let reuseIdentifier = "LogInfoBubbleCVC"
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            maxWidthConstraint = make.width.lessThanOrEqualTo(CGFloat.greatestFiniteMagnitude).priority(.required).constraint
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("XIB is not supported")
    }
    
    // MARK: - Setup
    
    func setup(text: String) {
        label.text = text
    }
    
    func setMaxWidth(_ width: CGFloat) {
        maxWidthConstraint?.update(offset: width)
    }
}
