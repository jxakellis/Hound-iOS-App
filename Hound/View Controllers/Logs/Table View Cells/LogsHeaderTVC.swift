//
//  LogsHeaderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsHeaderTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var headerLabel: ScaledUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var filterImageView: UIImageView!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(fromDate date: Date?, shouldShowFilterIndictator: Bool) {
        
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        headerLabel.font = headerLabel.font.withSize(20.0 * sizeRatio)
        headerTopConstraint.constant = 5.0 * sizeRatio
        headerBottomConstraint.constant = 5.0 * sizeRatio
        headerHeightConstraint.constant = 30.0 * sizeRatio
        
        filterImageView.isHidden = !shouldShowFilterIndictator
        
        if let date = date {
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
            // this year
            else if currentYear == dateYear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: Calendar.localCalendar.locale)
                headerLabel.text = dateFormatter.string(from: date)
            }
            // previous year or even older
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d, yyyy", options: 0, locale: Calendar.localCalendar.locale)
                headerLabel.text = dateFormatter.string(from: date)
            }
        }
        else {
            headerLabel.text = "No Logs Recorded"
        }
    }
    
}
