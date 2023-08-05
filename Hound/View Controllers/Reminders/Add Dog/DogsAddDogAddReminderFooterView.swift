//
//  DogsAddDogAddReminderFooterView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogAddReminderFooterViewDelegate: AnyObject {
    func didTouchUpInsideAddReminder()
}

class DogsAddDogAddReminderFooterView: UIView {

    // MARK: - IB

    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var addReminderButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideReminder(_ sender: Any) {
        delegate.didTouchUpInsideAddReminder()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddDogAddReminderFooterViewDelegate!
    
    private static let topConstraintConstant: CGFloat = 20.0
    private static let bottomConstraintConstant: CGFloat = 20.0
    private static let leadingConstraintConstant: CGFloat = 20.0
    private static let trailingConstraintConstant: CGFloat = 20.0

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
        _ = UINib(nibName: "DogsAddDogAddReminderFooterView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }

    // MARK: - Functions

    func setup(forDelegate: DogsAddDogAddReminderFooterViewDelegate) {
        delegate = forDelegate
        addReminderButton.isEnabled = true
    }

    static func cellHeight(forTableViewWidth: CGFloat) -> CGFloat {
        return topConstraintConstant + ((forTableViewWidth - leadingConstraintConstant - trailingConstraintConstant) * 0.16) + bottomConstraintConstant
    }

}
