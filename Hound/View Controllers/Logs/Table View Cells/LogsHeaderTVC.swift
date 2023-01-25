//
//  LogsHeaderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/19/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsHeaderTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var headerLabel: ScaledUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var filterImageView: UIImageView!
    
    // MARK: - Functions
    
    func setup(fromDate date: Date, shouldShowFilterIndictator: Bool) {
        
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        headerLabel.font = headerLabel.font.withSize(20.0 * sizeRatio)
        headerTopConstraint.constant = 5.0 * sizeRatio
        headerBottomConstraint.constant = 5.0 * sizeRatio
        headerHeightConstraint.constant = 30.0 * sizeRatio
        
        filterImageView.isHidden = !shouldShowFilterIndictator
        
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
        
        // Wednesday, January 25
        // Wednesday, January 25, 2023
        let template = currentYear == dateYear ? "EEEE, MMMM d" : "EEEE, MMMM d, yyyy"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Calendar.localCalendar.locale)
        headerLabel.text = dateFormatter.string(from: date)
    }
    
}
