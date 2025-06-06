//
//  SettingsPagesTableHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsPagesTableHeaderView: UIView {

    // MARK: - IB

    private let contentView: UIView = UIView()

    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "Options"
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25)
        return label
    }()

    // MARK: - Properties

    private static let topConstraint = 10.0
    private static let heightConstraint = 25.0
    private static let bottomConstraint = 10.0

    static var cellHeight: Double {
        topConstraint + heightConstraint + bottomConstraint
    }

    // MARK: - Main

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGeneratedViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }

    // MARK: - Functions

    func setup(forTitle: String) {
        headerLabel.text = forTitle
    }
}

// TODO: Dont forget to add setupViews func in init, viewDidLoad
extension SettingsPagesTableHeaderView {
    private func setupGeneratedViews() {
        contentView.backgroundColor = .clear
        contentView.frame = bounds
        addSubview(contentView)
        
        addSubViews()
        setupConstraints()
    }

    private func addSubViews() {
        contentView.addSubview(headerLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsPagesTableHeaderView.topConstraint),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -SettingsPagesTableHeaderView.bottomConstraint),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerLabel.heightAnchor.constraint(equalToConstant: SettingsPagesTableHeaderView.heightConstraint),
        
        ])
        
    }
}
