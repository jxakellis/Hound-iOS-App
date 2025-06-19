//
//  LogsTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsTableHeaderV: GeneralUIView {
    
    // MARK: - Views
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(constraintBasedLayout: false)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    // MARK: - Properties
    
    private static let topConstraint = 10.0
    private static let heightConstraint = 30.0
    private static let bottomConstraint = 10.0
    
    static var cellHeight: Double {
        return topConstraint + heightConstraint + bottomConstraint
    }
    
    // MARK: - Setup
    
    func setup(fromDate date: Date) {
        headerLabel.font = headerLabel.font.withSize(25.0)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateYear = Calendar.current.component(.year, from: date)
        
        // today
        if Calendar.current.isDateInToday(date) {
            headerLabel.text = "Today"
        }
        // yesterday
        else if Calendar.current.isDateInYesterday(date) {
            headerLabel.text = "Yesterday"
        }
        else if Calendar.current.isDateInTomorrow(date) {
            headerLabel.text = "Tomorrow"
        }
        else {
            let dateFormatter = DateFormatter()
            // Wednesday, January 25 or Wednesday, January 25 2023
            dateFormatter.setLocalizedDateFormatFromTemplate( dateYear == currentYear ? "EEEEMMMMd" : "EEEEMMMMdyyyy")
            
            headerLabel.text = dateFormatter.string(from: date)
        }
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
