//
//  SettingsNotifsAlarmsNotificationSoundsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsNotificationSoundsTVC: HoundTableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Alarm Sound"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private lazy var tableView: HoundTableView = {
        let tableView = HoundTableView(huggingPriority: 260, compressionResistancePriority: 260)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsNotifsAlarmsNotificationSoundTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsNotificationSoundTVC.reuseIdentifier)
        
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.systemBackground
        tableView.separatorColor = UIColor.systemGray2
        
        tableView.applyStyle(.thinLabelBorder)
        
        return tableView
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Changes the sound your alarms play. Tap on one of them to hear what it sounds like!"
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsNotificationSoundsTVC"
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
        
        // NEEDs to called after being added to view heirarchy (if you call in constructor then youre attempting to layout visible cells when not in view hierarchy)
        tableView.shouldAutomaticallyAdjustHeight = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    private func synchronizeValues(animated: Bool) {
        tableView.isUserInteractionEnabled = UserConfiguration.isNotificationEnabled
        
        // set all cells to unselected
        for cellRow in 0..<NotificationSound.allCases.count {
            let cellIndexPath = IndexPath(row: cellRow, section: 0)
            let cell = tableView.cellForRow(at: cellIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
            cell?.setCustomSelectedTableViewCell(false, animated: true)
        }
        
        // set user configuration notification sound cell to selected
        guard let currentNotificationSoundCellRow = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            return
        }
        let currentNotificationSoundCellIndexPath = IndexPath(row: currentNotificationSoundCellRow, section: 0)
        let currentNotificationSoundCell = tableView.cellForRow(at: currentNotificationSoundCellIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(true, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationSound.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsNotifsAlarmsNotificationSoundTVC.reuseIdentifier, for: indexPath) as? SettingsNotifsAlarmsNotificationSoundTVC else {
            return HoundTableViewCell()
        }
        
        let notificationSound = NotificationSound.allCases[indexPath.row]
        
        cell.setup(forNotificationSound: notificationSound == NotificationSound.radar ? "Radar (Default)" : notificationSound.rawValue)
        cell.setCustomSelectedTableViewCell(notificationSound == UserConfiguration.notificationSound, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsNotifsAlarmsNotificationSoundTVC,
              let currentNotificationSoundIndex = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            // we need the selected cell and current notification sound index before we proceed
            AudioManager.stopAudio()
            return
        }
        
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        guard selectedNotificationSound != UserConfiguration.notificationSound else {
            // cell selected is the same as the current sound saved, toggle the audio
            if AudioManager.isPlaying {
                AudioManager.stopAudio()
            }
            else {
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
            }
            
            return
        }
        
        // the new cell selected is different that the current sound saved
        
        // find the current notification sound cell and unselect it, as the user just selected a new one
        let currentNotificationSoundIndexPath = IndexPath(row: currentNotificationSoundIndex, section: 0)
        let currentNotificationSoundCell = tableView.cellForRow(at: currentNotificationSoundIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(false, animated: true)
        
        // highlight the new selected cell
        selectedCell.setCustomSelectedTableViewCell(true, animated: true)
        
        // leave this code right here, don't move below or its value will be incorrect
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        
        // assign user configuration to new value and play its audio
        UserConfiguration.notificationSound = selectedNotificationSound
        AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
        
        // contact server to attempt to persist change
        let body = [KeyConstant.userConfigurationNotificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.notificationSound = beforeUpdateNotificationSound
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(descriptionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset)
        ])
    }

}
