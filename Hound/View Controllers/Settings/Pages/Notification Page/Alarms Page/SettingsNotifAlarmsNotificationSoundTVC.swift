//
//  SettingsNotifsAlarmsNotificationSoundTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/14/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsNotificationSoundTVC: UITableViewCell {

    // MARK: - IB

    private let notificationSoundLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "Notification Sound"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()


    // MARK: - Properties

    private static let topConstraint: CGFloat = 7.5
    private static let heightConstraint: CGFloat = 17.5
    private static let bottomConstraint: CGFloat = 7.5
    static let cellHeight: CGFloat = topConstraint + heightConstraint + bottomConstraint

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false
    
    // MARK: - Main
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
    }

    // MARK: - Functions

    func setup(forNotificationSound notificationSound: String) {
        notificationSoundLabel.text = notificationSound
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(_ selected: Bool, animated: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }

        isCustomSelected = selected

        UIView.animate(withDuration: animated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.notificationSoundLabel.textColor = selected ? .systemBackground : .label
        }
    }

}

// TODO: Dont forget to add setupViews func in init, viewDidLoad
// TODO: Incase any indentation error, use shortcut Cmd A + Ctrl I to fix
extension SettingsNotifsAlarmsNotificationSoundTVC {
    func setupGeneratedViews() {
        
        addSubViews()
        setupConstraints()
    }

    func addSubViews() {
        contentView.addSubview(notificationSoundLabel)
        
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            notificationSoundLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsNotifsAlarmsNotificationSoundTVC.topConstraint),
            notificationSoundLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -SettingsNotifsAlarmsNotificationSoundTVC.bottomConstraint),
            notificationSoundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            notificationSoundLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            notificationSoundLabel.heightAnchor.constraint(equalToConstant: SettingsNotifsAlarmsNotificationSoundTVC.heightConstraint),
        
        ])
        
    }
}
