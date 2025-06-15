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
    
    private let contentView: GeneralUIView = GeneralUIView()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
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
        contentView.frame = bounds
        addSubview(contentView)
        
        contentView.addSubview(headerLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LogsTableHeaderV.topConstraint),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LogsTableHeaderV.bottomConstraint),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerLabel.heightAnchor.constraint(equalToConstant: LogsTableHeaderV.heightConstraint)
            
        ])
        
    }
}
