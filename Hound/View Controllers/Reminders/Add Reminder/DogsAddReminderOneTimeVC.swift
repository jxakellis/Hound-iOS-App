//
//  DogsAddReminderOneTimeVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderOneTimeVCDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderOneTimeVC: HoundViewController {

    // MARK: - Elements

    private let oneTimeDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 260)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        return datePicker
    }()
    
    private let oneTimeDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "A single-use reminder sounds one alarm and then automatically deletes"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemGray
        return label
    }()

    @objc private func didUpdateOneTimeDatePicker(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderOneTimeVCDelegate?

    var oneTimeDate: Date? {
        oneTimeDatePicker.date
    }

    private var initialOneTimeDate: Date?
    var didUpdateInitialValues: Bool {
        if oneTimeDate != initialOneTimeDate {
            return true
        }

        return oneTimeDate != initialOneTimeDate
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        oneTimeDatePicker.date = initialOneTimeDate ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * oneTimeDatePicker.minuteInterval), roundingMethod: .up)
        initialOneTimeDate = oneTimeDatePicker.date

        // they can't choose a one time alarm that isn't in the future, otherwise there is no point
        oneTimeDatePicker.minimumDate = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * oneTimeDatePicker.minuteInterval), roundingMethod: .up)
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.oneTimeDatePicker.date = self.oneTimeDatePicker.date
        }
    }

    // MARK: - Setup

    func setup(forDelegate: DogsAddReminderOneTimeVCDelegate, forOneTimeDate: Date?) {
        delegate = forDelegate
        initialOneTimeDate = forOneTimeDate
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(oneTimeDatePicker)
        oneTimeDatePicker.addTarget(self, action: #selector(didUpdateOneTimeDatePicker), for: .valueChanged)
        view.addSubview(oneTimeDescriptionLabel)
        
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // oneTimeDescriptionLabel
        let oneTimeDescriptionLabelTop = oneTimeDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        let oneTimeDescriptionLabelLeading = oneTimeDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let oneTimeDescriptionLabelTrailing = oneTimeDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        // oneTimeDatePicker
        let oneTimeDatePickerTop = oneTimeDatePicker.topAnchor.constraint(equalTo: oneTimeDescriptionLabel.bottomAnchor)
        let oneTimeDatePickerBottom = oneTimeDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let oneTimeDatePickerLeading = oneTimeDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let oneTimeDatePickerTrailing = oneTimeDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            // oneTimeDescriptionLabel
            oneTimeDescriptionLabelTop,
            oneTimeDescriptionLabelLeading,
            oneTimeDescriptionLabelTrailing,
            
            // oneTimeDatePicker
            oneTimeDatePickerTop,
            oneTimeDatePickerBottom,
            oneTimeDatePickerLeading,
            oneTimeDatePickerTrailing
        ])
    }

}
