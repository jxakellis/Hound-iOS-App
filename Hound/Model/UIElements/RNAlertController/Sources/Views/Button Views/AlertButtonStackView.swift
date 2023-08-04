//
//  AlertButtonStackView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 4/24/19.
//  Copyright © 2019 Rayhan. All rights reserved.
//

import UIKit

final class AlertButtonStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fillEqually
        alignment = .fill
        axis = .horizontal
        spacing = 0.25
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(alertButtons: [ActionButton]) {
        self.init(frame: .zero)
        let stackItems = createButtonCollection(from: alertButtons)
        let shouldUseVerticalAxis = adjustForOversizedText(buttonCollection: stackItems)
        axis = (alertButtons.count == 2 && !shouldUseVerticalAxis) ? .horizontal : .vertical
        for button in stackItems {
            addArrangedSubview(button)
        }
    }

    fileprivate func createButtonCollection(from alertButtons: [ActionButton]) -> [UIView] {
        var stackItems = [UIView]()
        for index in 0..<alertButtons.count {
            let alertButton = alertButtons[index]
            let button = AlertButton()
            button.setTitle(alertButton.text, for: alertButton.type)
            button.addAction(for: .touchUpInside, action: alertButton.action)
            stackItems.append(button)
        }
        return stackItems
    }

    fileprivate func adjustForOversizedText(buttonCollection: [UIView]) -> Bool {
        let widthFactor = getDeviceWidthOrHeight(multiplier: 0.35)
        var shouldUseVerticalAxis = false
        if buttonCollection.count >= 2 {
            for view in buttonCollection {
                if let textIntrinsicSize = (view as? UIButton)?.titleLabel?.intrinsicContentSize {
                    if textIntrinsicSize.width > widthFactor - 8 {
                        shouldUseVerticalAxis = true
                    }
                }
            }
        }
        return shouldUseVerticalAxis
    }

    fileprivate func getDeviceWidthOrHeight(multiplier: CGFloat = 1.0) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        if screenWidth < screenHeight {
            return screenWidth * multiplier
        }
        else {
            return screenHeight * multiplier
        }
    }

}
