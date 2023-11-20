//
//  LogsTableHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsTableHeaderView: UIView {

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
        return topConstraint + heightConstraint + bottomConstraint
    }

    // MARK: - Main

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeSubviews()
    }

    /// Setup components of the view that don't depend upon data provided by an external source
    private func initializeSubviews() {
        _ = UINib(nibName: "LogsTableHeaderView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }

    // MARK: - Functions

    func setup(fromDate date: Date) {
        headerLabel.font = headerLabel.font.withSize(25.0)
        headerTopConstraint.constant = LogsTableHeaderView.topConstraint
        headerHeightConstraint.constant = LogsTableHeaderView.heightConstraint
        headerBottomConstraint.constant = LogsTableHeaderView.bottomConstraint

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

}
