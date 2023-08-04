//
//  AlertCheckboxView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 1/13/20.
//  Copyright © 2020 Rayhan Nabi. All rights reserved.
//

import UIKit

final class AlertCheckboxView: UIStackView {

    var selectionAction: AlertCheckboxAction?

    private var title: String?
    private var isSelected: Bool

    override init(frame: CGRect) {
        isSelected = false
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        alignment = .center
        axis = .horizontal
        spacing = 4
    }

    required init(coder: NSCoder) {
        isSelected = false
        super.init(coder: coder)
    }

    convenience init(title: String?, isSelected: Bool) {
        self.init(frame: .zero)
        self.title = title
        self.isSelected = isSelected
        addSubviewsToStackView()
    }

}

private extension AlertCheckboxView {

    func createCheckbox() -> AlertCheckboxButton {
        let checkboxButton = AlertCheckboxButton()
        checkboxButton.isSelected = isSelected
        checkboxButton.addTarget(self, action: #selector(didTapCheckbox(_:)), for: .touchUpInside)
        return checkboxButton
    }

    func createLabel() -> AlertCheckboxLabel {
        let label = AlertCheckboxLabel(text: title)
        return label
    }

    func addSubviewsToStackView() {
        let checkbox = createCheckbox()
        let label = createLabel()
        addArrangedSubview(checkbox)
        addArrangedSubview(label)
    }

    @objc func didTapCheckbox(_ sender: UIButton) {
        sender.isSelected.toggle()
        selectionAction?(sender.isSelected)
    }

}
