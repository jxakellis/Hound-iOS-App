//
//  DogsAddReminderOneTimeViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderOneTimeViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderOneTimeViewController: GeneralUIViewController {

    // MARK: - Elements

    private let oneTimeDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.contentMode = .scaleToFill
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        datePicker.contentHorizontalAlignment = .center
        datePicker.contentVerticalAlignment = .center
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let oneTimeDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "A single-use reminder sounds one alarm and then automatically deletes"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        return label
    }()

    @objc private func didUpdateOneTimeDatePicker(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderOneTimeViewControllerDelegate!

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

    // MARK: - Functions

    func setup(forDelegate: DogsAddReminderOneTimeViewControllerDelegate, forOneTimeDate: Date?) {
        delegate = forDelegate
        initialOneTimeDate = forOneTimeDate
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        view.addSubview(oneTimeDatePicker)
        oneTimeDatePicker.addTarget(self, action: #selector(didUpdateOneTimeDatePicker), for: .valueChanged)
        view.addSubview(oneTimeDescriptionLabel)
        
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            oneTimeDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            oneTimeDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            oneTimeDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
            oneTimeDatePicker.topAnchor.constraint(equalTo: oneTimeDescriptionLabel.bottomAnchor),
            oneTimeDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            oneTimeDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            oneTimeDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
        ])
        
    }
}
