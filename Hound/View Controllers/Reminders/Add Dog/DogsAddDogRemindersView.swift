//
//  DogsAddDogRemindersView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogRemindersViewDelegate: AnyObject {
    func shouldOpenAddReminderVC(forReminder: Reminder?)
}

final class DogsAddDogRemindersView: HoundView, UITableViewDataSource, UITableViewDelegate, DogsAddDogReminderTVCDelegate {
    
    // MARK: - DogsAddDogReminderTVCDelegate
    
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool) {
        dogReminders.findReminder(forReminderUUID: forReminderUUID)?.reminderIsEnabled = forReminderIsEnabled
    }
    
    // MARK: - Elements

    private lazy var tableView: HoundTableView = {
        let tableView = HoundTableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(DogsAddDogReminderTVC.self, forCellReuseIdentifier: DogsAddDogReminderTVC.reuseIdentifier)
        
        tableView.isScrollEnabled = false
        
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.emptyStateEnabled = true
        tableView.emptyStateMessage = "No reminders yet..."
        
        return tableView
    }()

    private lazy var addReminderButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Add Reminder", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.thinLabelBorder)
        
        button.addTarget(self, action: #selector(didTouchUpInsideAddReminder), for: .touchUpInside)
        
        return button
    }()
    
    @objc func didTouchUpInsideAddReminder() {
        let numNonTriggerReminders = dogReminders.dogReminders.count(where: { $0.reminderIsTriggerResult == false })
        
        guard numNonTriggerReminders < ClassConstant.DogConstant.maximumNumberOfReminders else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.noAddMoreRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.noAddMoreRemindersSubtitle, forStyle: .warning)
            return
        }
        
        delegate?.shouldOpenAddReminderVC(forReminder: nil)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddDogRemindersViewDelegate?
    /// dogReminders is either a copy of dogToUpdate's reminders or a DogReminderManager initialized to a default array of reminders. This is purposeful so that either, if you dont have a dogToUpdate, you can still create reminders, and if you do have a dogToUpdate, you don't directly update the dogToUpdate until save is pressed
    private(set) var dogReminders: DogReminderManager = DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
    private(set) var initialReminders: DogReminderManager = DogReminderManager(forReminders: ClassConstant.ReminderConstant.defaultReminders)
    
    var didUpdateInitialValues: Bool {
        // if current reminders has more reminders than initial reminders, the loop below won't catch it, as the loop below just looks to see if each initial reminder is still present in current reminders.
        if initialReminders.dogReminders.count != dogReminders.dogReminders.count {
            return true
        }
        // make sure each initial reminder has a corresponding current reminder, otherwise current reminders have been updated
        for initialReminder in initialReminders.dogReminders {
            let currentReminder = dogReminders.dogReminders.first(where: { $0.reminderUUID == initialReminder.reminderUUID })
            
            guard let currentReminder = currentReminder else {
                // no corresponding reminder
                return true
            }
            
            // if any of the corresponding reminders are different, then return true to indicate that a reminder has been updated
            if initialReminder.isSame(asReminder: currentReminder) == false {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddDogRemindersViewDelegate, forDogReminders: DogReminderManager?) {
        delegate = forDelegate
        
        dogReminders = (forDogReminders?.copy() as? DogReminderManager) ?? dogReminders
        initialReminders = (forDogReminders?.copy() as? DogReminderManager) ?? initialReminders
        
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    func didAddReminder(forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder)
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    func didUpdateReminder(forReminder: Reminder) {
        dogReminders.addReminder(forReminder: forReminder)
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    func didRemoveReminder(forReminderUUID: UUID) {
        dogReminders.removeReminder(forReminderUUID: forReminderUUID)
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dogReminders.dogReminders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Only add spacing if NOT the last section
        let lastSection = dogReminders.dogReminders.count - 1
        return section == lastSection ? 0 : ConstraintConstant.Spacing.contentTallIntraVert
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Only return a view if not the last section
        let lastSection = InAppPurchaseManager.subscriptionProducts.count - 1
        if section == lastSection {
            return nil
        }
        
        let footer = HoundHeaderFooterView()
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DogsAddDogReminderTVC.reuseIdentifier, for: indexPath)
        
        if let castedCell = cell as? DogsAddDogReminderTVC {
            castedCell.setup(forDelegate: self, forReminder: dogReminders.dogReminders[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = dogReminders.dogReminders[indexPath.section]
        
        guard reminder.reminderIsTriggerResult == false else {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.noEditTriggerResultRemindersTitle, forSubtitle: VisualConstant.BannerTextConstant.noEditTriggerResultRemindersSubtitle, forStyle: .warning)
            return
        }
        
        delegate?.shouldOpenAddReminderVC(forReminder: reminder)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete && dogReminders.dogReminders.isEmpty == false else { return }
        
        let reminder = dogReminders.dogReminders[indexPath.section]
        
        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.dogReminders.removeReminder(forReminderUUID: reminder.reminderUUID)
            
            self.tableView.deleteSections([indexPath.section], with: .automatic)
            UIView.animate(withDuration: VisualConstant.AnimationConstant.moveMultipleElements) {
                // TODO does this still work in the subview or does parent need to do this as well?
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        removeReminderConfirmation.addAction(removeAlertAction)
        removeReminderConfirmation.addAction(cancelAlertAction)
        PresentationManager.enqueueAlert(removeReminderConfirmation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dogReminders.dogReminders.isEmpty == false
    }

    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        addSubview(tableView)
        addSubview(addReminderButton)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            addReminderButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            addReminderButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addReminderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            addReminderButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: self),
            addReminderButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }
}
