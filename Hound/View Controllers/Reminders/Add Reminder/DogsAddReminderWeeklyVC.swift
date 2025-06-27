//
//  DogsAddReminderWeeklyVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderWeeklyVCDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderWeeklyVC: GeneralUIViewController {

    // MARK: - Elements

    private var interDayOfWeekConstraints: [NSLayoutConstraint]!

    private let sundayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setImage(UIImage(systemName: "s.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let mondayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "m.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let tuesdayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "t.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let wednesdayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "w.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let thursdayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "t.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let fridayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "f.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    private let saturdayButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "s.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        button.tintColor = UIColor.systemGray4
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        
        return button
    }()

    @objc private func didToggleWeekdayButton(_ sender: Any) {
        delegate?.willDismissKeyboard()

        guard let senderButton = sender as? GeneralUIButton else {
            return
        }
        var targetColor: UIColor!

        if senderButton.tag == VisualConstant.ViewTagConstant.weekdayEnabled {
            targetColor = UIColor.systemGray4
            senderButton.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        }
        else {
            targetColor = UIColor.systemBlue
            senderButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
        }

        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
            senderButton.tintColor = targetColor
        } completion: { _ in
            senderButton.isUserInteractionEnabled = true
        }

    }

    private let timeOfDayDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.preferredDatePickerStyle = .wheels
       
        return datePicker
    }()

    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderWeeklyVCDelegate?

    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var currentWeekdays: [Int]? {
        var days: [Int] = []
        let dayOfWeekButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]

        for dayOfWeekIndex in 0..<dayOfWeekButtons.count where dayOfWeekButtons[dayOfWeekIndex].tag == VisualConstant.ViewTagConstant.weekdayEnabled {
            days.append(dayOfWeekIndex + 1)
        }

        if days.isEmpty == true {
            return nil
        }
        else {
            return days
        }
    }
    /// timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }

    private var initialWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7]
    private var initialTimeOfDayDate: Date?
    var didUpdateInitialValues: Bool {
        if currentWeekdays != initialWeekdays {
            return true
        }
        if timeOfDayDatePicker.date != initialTimeOfDayDate {
            return true
        }

        return false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make all the dayOfWeekButtons look enabled (if they are in the array)
        for dayOfWeek in initialWeekdays {
            switch dayOfWeek {
            case 1:
                sundayButton.tintColor = .systemBlue
                sundayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 2:
                mondayButton.tintColor = .systemBlue
                mondayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 3:
                tuesdayButton.tintColor = .systemBlue
                tuesdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 4:
                wednesdayButton.tintColor = .systemBlue
                wednesdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 5:
                thursdayButton.tintColor = .systemBlue
                thursdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 6:
                fridayButton.tintColor = .systemBlue
                fridayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            case 7:
                saturdayButton.tintColor = .systemBlue
                saturdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
            default:
                break
            }
        }
        initialWeekdays = currentWeekdays ?? initialWeekdays

        timeOfDayDatePicker.date = initialTimeOfDayDate ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
        initialTimeOfDayDate = timeOfDayDatePicker.date

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }
    }

    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }

        didSetupCustomSubviews = true

        // TODO GPT What is the best way to this?
        for constraint in interDayOfWeekConstraints {
            // the distance between week day buttons should be 8 points on a 414 point screen, so this adjusts that ratio to fit any width of screen
            constraint.constant = (8.0 / 414.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        }
    }

    // MARK: - Setup

    func setup(forDelegate: DogsAddReminderWeeklyVCDelegate, forTimeOfDay: Date?, forWeekdays: [Int]?) {
        delegate = forDelegate
        initialTimeOfDayDate = forTimeOfDay
        initialWeekdays = forWeekdays ?? initialWeekdays
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(timeOfDayDatePicker)
        timeOfDayDatePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        view.addSubview(sundayButton)
        sundayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(mondayButton)
        mondayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(tuesdayButton)
        tuesdayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(wednesdayButton)
        wednesdayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(thursdayButton)
        thursdayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(fridayButton)
        fridayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        view.addSubview(saturdayButton)
        saturdayButton.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
        
    }

    override func setupConstraints() {
        super.setupConstraints()

        // sundayButton
        let sundayButtonTop = sundayButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        let sundayButtonBottomToWednesday = sundayButton.bottomAnchor.constraint(equalTo: wednesdayButton.bottomAnchor)
        let sundayButtonBottomToTuesday = sundayButton.bottomAnchor.constraint(equalTo: tuesdayButton.bottomAnchor)
        let sundayButtonBottomToMonday = sundayButton.bottomAnchor.constraint(equalTo: mondayButton.bottomAnchor)
        let sundayButtonBottomToSaturday = sundayButton.bottomAnchor.constraint(equalTo: saturdayButton.bottomAnchor)
        let sundayButtonBottomToFriday = sundayButton.bottomAnchor.constraint(equalTo: fridayButton.bottomAnchor)
        let sundayButtonBottomToThursday = sundayButton.bottomAnchor.constraint(equalTo: thursdayButton.bottomAnchor)
        let sundayButtonLeading = sundayButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let sundayButtonWidthToHeight = sundayButton.widthAnchor.constraint(equalTo: sundayButton.heightAnchor)

        // mondayButton
        let mondayButtonTop = mondayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let mondayButtonWidthToHeight = mondayButton.widthAnchor.constraint(equalTo: mondayButton.heightAnchor)
        let mondayButtonWidthToSunday = mondayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)
        
        // tuesdayButton
        let tuesdayButtonTop = tuesdayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let tuesdayButtonWidthToHeight = tuesdayButton.widthAnchor.constraint(equalTo: tuesdayButton.heightAnchor)
        let tuesdayButtonWidthToSunday = tuesdayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)

        // wednesdayButton
        let wednesdayButtonTop = wednesdayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let wednesdayButtonWidthToHeight = wednesdayButton.widthAnchor.constraint(equalTo: wednesdayButton.heightAnchor)
        let wednesdayButtonWidthToSunday = wednesdayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)

        // thursdayButton
        let thursdayButtonTop = thursdayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let thursdayButtonWidthToHeight = thursdayButton.widthAnchor.constraint(equalTo: thursdayButton.heightAnchor)
        let thursdayButtonWidthToSunday = thursdayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)

        // fridayButton
        let fridayButtonTop = fridayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let fridayButtonWidthToHeight = fridayButton.widthAnchor.constraint(equalTo: fridayButton.heightAnchor)
        let fridayButtonWidthToSunday = fridayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)

        // saturdayButton
        let saturdayButtonTop = saturdayButton.topAnchor.constraint(equalTo: sundayButton.topAnchor)
        let saturdayButtonTrailing = saturdayButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        let saturdayButtonWidthToHeight = saturdayButton.widthAnchor.constraint(equalTo: saturdayButton.heightAnchor)
        let saturdayButtonWidthToSunday = saturdayButton.widthAnchor.constraint(equalTo: sundayButton.widthAnchor)
        
        // interDayOfWeekConstraints
        interDayOfWeekConstraints = [
            mondayButton.leadingAnchor.constraint(equalTo: sundayButton.trailingAnchor, constant: 8),
            tuesdayButton.leadingAnchor.constraint(equalTo: mondayButton.trailingAnchor, constant: 8),
            wednesdayButton.leadingAnchor.constraint(equalTo: tuesdayButton.trailingAnchor, constant: 8),
            thursdayButton.leadingAnchor.constraint(equalTo: wednesdayButton.trailingAnchor, constant: 8),
            fridayButton.leadingAnchor.constraint(equalTo: thursdayButton.trailingAnchor, constant: 8),
            saturdayButton.leadingAnchor.constraint(equalTo: fridayButton.trailingAnchor, constant: 8)
        ]

        // timeOfDayDatePicker
        let timeOfDayDatePickerTop = timeOfDayDatePicker.topAnchor.constraint(equalTo: sundayButton.bottomAnchor, constant: 10)
        let timeOfDayDatePickerBottom = timeOfDayDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let timeOfDayDatePickerLeading = timeOfDayDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let timeOfDayDatePickerTrailing = timeOfDayDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        NSLayoutConstraint.activate([
            // sundayButton
            sundayButtonTop,
            sundayButtonBottomToWednesday,
            sundayButtonBottomToTuesday,
            sundayButtonBottomToMonday,
            sundayButtonBottomToSaturday,
            sundayButtonBottomToFriday,
            sundayButtonBottomToThursday,
            sundayButtonLeading,
            sundayButtonWidthToHeight,

            // mondayButton
            mondayButtonTop,
            mondayButtonWidthToHeight,
            mondayButtonWidthToSunday,

            // tuesdayButton
            tuesdayButtonTop,
            tuesdayButtonWidthToHeight,
            tuesdayButtonWidthToSunday,

            // wednesdayButton
            wednesdayButtonTop,
            wednesdayButtonWidthToHeight,
            wednesdayButtonWidthToSunday,

            // thursdayButton
            thursdayButtonTop,
            thursdayButtonWidthToHeight,
            thursdayButtonWidthToSunday,

            // fridayButton
            fridayButtonTop,
            fridayButtonWidthToHeight,
            fridayButtonWidthToSunday,

            // saturdayButton
            saturdayButtonTop,
            saturdayButtonTrailing,
            saturdayButtonWidthToHeight,
            saturdayButtonWidthToSunday,

            // timeOfDayDatePicker
            timeOfDayDatePickerTop,
            timeOfDayDatePickerBottom,
            timeOfDayDatePickerLeading,
            timeOfDayDatePickerTrailing
        ] + interDayOfWeekConstraints)
    }

}
