//
//  GeneralHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/20/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralHeaderView: GeneralUIView {
    
    // MARK: - Views
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(constraintBasedLayout: false)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    // MARK: - Properties
    
    private static let topConstraint = 10.0
    private static let heightConstraint = 25.0
    private static let bottomConstraint = 10.0
    
    static var cellHeight: Double {
        return topConstraint + heightConstraint + bottomConstraint
    }
    
    // MARK: - Setup
    
    func setTitle(_ title: String) {
        headerLabel.text = title
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(headerLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // Header views inside table views can't use auto layout, so we have to use frames
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftInset = CGFloat(ConstraintConstant.Global.contentInset)
        let rightInset = CGFloat(ConstraintConstant.Global.contentInset)
        let width = bounds.width - leftInset - rightInset
        
        // Position the label inside the header, respecting top/bottom insets
        headerLabel.frame = CGRect(
            x: leftInset,
            y: Self.topConstraint,
            width: width,
            height: Self.heightConstraint
        )
    }
}

