//
//  RNAlertController+API.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/8/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

public extension RNAlertController {

    // MARK: - Static Initializer

    /// Initializes the alert.
    /// - Parameters:
    ///   - title: Title for the alert.
    ///   - message: Message body of the alert.
    /// - Returns: `RNAlertController` instance.
    static func alertController(title: String?, message: String?) -> RNAlertController {
        return RNAlertController(title: title, message: message)
    }

    // MARK: - Presentation

    /// Presents the alert on the specified view controller.
    ///
    /// Use this method to present `RNAlertController` alert on a specific view controller.
    /// - Parameters:
    ///   - viewController: `UIViewController` where the alert is to be presented.
    ///   - completion: Block to run after presenting the alert.
    func present(on viewController: UIViewController, completion: (() -> Void)? = nil) {
        presentOnViewController(viewController, completion: completion)
    }

    /// Presents the alert on its own window.
    /// - Parameter completion: Block to run after presenting the alert.
    func present(_ completion: (() -> Void)? = nil) {
        presentOnWindow(completion: completion)
    }

    /// Dismisses the alert.
    /// - Parameter completion: Block to run after dismissing the alert.
    func dismiss(_ completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    // MARK: - Alert Components

    /// Adds a button to the alert.
    ///
    /// - Parameters:
    ///   - title: Title for the button.
    ///   - type: Button style for the alert.
    ///   - action: Block to run when the button is pressed (i.e. touchUpInside: action).
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func addButton(title: String, type: AlertButtonType = .default, action: AlertAction? = nil) -> RNAlertController {
        let action = {
            self.dismiss(animated: true, completion: action)
        }
        let button = ActionButton(text: title, type: type, action: action)
        buttons?.append(button)

        return self
    }

    /// Adds an **OK** button to the alert.
    ///
    /// - Parameter action: Block to run when the button is pressed (i.e. touchUpInside event).
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func addOkButton(action: AlertAction? = nil) -> RNAlertController {
        return addButton(title: "OK", type: .default, action: action)
    }

    /// Adds a **Cancel** button to the alert.
    ///
    /// - Parameter action: Block to run when the button is pressed (i.e. touchUpInside event).
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func addCancelButton(action: AlertAction? = nil) -> RNAlertController {
        return addButton(title: "Cancel", type: .cancel, action: action)
    }

    /// Sets attributed text for the message.
    ///
    /// When set, message text will use attributed text instead of regular text.
    /// - Parameter attributedText: Attributed string to set.
    @discardableResult
    func setAttributedMessageText(_ attributedText: NSAttributedString?) -> RNAlertController {
        self.attributedMessage = attributedText
        return self
    }

    /// Sets the banner image for the alert.
    ///
    /// Banner image is displayed under the message body or at the very top of the body.
    /// Consequent calls of this method will result in replacement of previously set image.
    /// - Parameters:
    ///     - image: image to use in the alert.
    ///     - position: determines the position of the image.
    /// - Returns: RNAlertController` instance.
    @discardableResult
    func setBannerImage(_ image: UIImage, position: AlertBannerPosition = .afterBody) -> RNAlertController {
        self.image = image
        self.imagePosition = position
        return self
    }

    /// Sets picker view data for the alert.
    ///
    /// - Note: Consequent calls of this method will result in replacement of previously set picker data.
    /// - Parameters:
    ///   - items: An array of `String` to represent picker data collection.
    ///   - selectedRow: Row to be selected. The default value is 0 (zero)
    ///     indicating the first item in the collection.
    ///   - selectionAction: Block to execute when an item is selected.
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func setPickerData(items: [String], selectedRow: Int = 0, selectionAction: AlertPickerAction?) -> RNAlertController {
        pickerData = items
        pickerAction = selectionAction
        selectedPickerRow = selectedRow
        return self
    }

    /// Sets a button with an URL.
    ///
    /// A button is placed under the message body. Consequent calls of this method will result in
    /// replacement of previously set URL.
    /// - Parameters:
    ///   - urlString: `String` representation of the URL.
    ///   - text: Placeholder for the URL. If `nil` is passed, original URL will be used.
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func setURL(urlString: String, text: String? = nil) -> RNAlertController {
        let url = URL(string: urlString)
        let altText = text != nil ? text! : urlString
        alertURL = AlertURL(url: url, text: altText)
        return self
    }

    /// Sets a date picker with a selected date.
    ///
    /// A date picker is placed under the message body.
    /// - Parameters:
    ///     - mode: `UIDatePicker.Mode` describing the mode displayed the date picker.
    ///     - selectedDate: `Date` to set. If passed `nil`, current date is used.
    ///     - maximumDate: Maximum date that a date picker can show.
    ///     - minimumDate: Minimum date that a date picker can show.
    ///     - selectionAction: Block to execute when date is selected.
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func setDatePicker(mode: UIDatePicker.Mode,
                       selectedDate: Date? = nil,
                       maximumDate: Date? = nil,
                       minimumDate: Date? = nil,
                       selectionAction: AlertDatePickerAction? = nil) -> RNAlertController {
        alertDatePicker = AlertDatePicker(datePickerMode: mode, selectedDate: selectedDate)
        alertDatePicker?.maximumDate = maximumDate
        alertDatePicker?.minimumDate = minimumDate
        alertDatePicker?.action = selectionAction
        return self
    }

    /// Sets a checkbox with a title below the message body.
    /// - Parameters:
    ///   - title: A message that is shown on the right of the checkbox.
    ///   - isSelected: Boolean value indicating the primary state of the checkbox.
    ///   - action: Block to execute the checkbox is toggled.
    /// - Returns: `RNAlertController` instance.
    @discardableResult
    func setCheckboxView(title: String?,
                         isSelected: Bool,
                         action: AlertCheckboxAction?) -> RNAlertController {
        checkboxView = AlertCheckboxView(title: title, isSelected: isSelected)
        checkboxView?.selectionAction = action
        return self
    }

}
