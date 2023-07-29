//
//  LogsHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsHeaderView: UIView {
    
    // MARK: - IB
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var headerLabel: GeneralUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private static let topConstraint = 10.0
    private static let heightConstraint = 30.0
    private static let bottomConstraint = 10.0
    
    static var cellHeight: Double {
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        return (topConstraint + heightConstraint + bottomConstraint) * sizeRatio
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeSubviews()
    }
    
    /// Setup components of the view that don't depend upon data provided by an external source
    private func initalizeSubviews() {
        _ = UINib(nibName: "LogsHeaderView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    // MARK: - Functions
    
    func setup(fromDate date: Date) {
        
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        headerLabel.font = headerLabel.font.withSize(25.0 * sizeRatio)
        headerTopConstraint.constant = LogsHeaderView.topConstraint * sizeRatio
        headerHeightConstraint.constant = LogsHeaderView.heightConstraint * sizeRatio
        headerBottomConstraint.constant = LogsHeaderView.bottomConstraint * sizeRatio
        
        let currentYear = Calendar.localCalendar.component(.year, from: Date())
        let dateYear = Calendar.localCalendar.component(.year, from: date)
        
        // today
        if Calendar.localCalendar.isDateInToday(date) {
            headerLabel.text = "Today"
        }
        // yesterday
        else if Calendar.localCalendar.isDateInYesterday(date) {
            headerLabel.text = "Yesterday"
        }
        else if Calendar.localCalendar.isDateInTomorrow(date) {
            headerLabel.text = "Tomorrow"
        }
        else {
            // Wednesday, January 25
            // Wednesday, January 25, 2023
            let template = currentYear == dateYear ? "EEEE, MMMM d" : "EEEE, MMMM d, yyyy"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Calendar.localCalendar.locale)
            headerLabel.text = dateFormatter.string(from: date)
        }
    }

}
