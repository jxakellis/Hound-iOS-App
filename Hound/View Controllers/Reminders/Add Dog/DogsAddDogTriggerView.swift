//
//  DogsAddDogTriggerView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogTriggersViewDelegate: AnyObject {
    func shouldOpenAddTriggerVC(forTrigger: Trigger?)
    func didUpdateTriggerCount()
}

final class DogsAddDogTriggersView: HoundView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Elements

    private lazy var tableView: HoundTableView = {
        let tableView = HoundTableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(DogsAddDogTriggerTVC.self, forCellReuseIdentifier: DogsAddDogTriggerTVC.reuseIdentifier)
        
        tableView.isScrollEnabled = false
        
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.emptyStateEnabled = true
        tableView.emptyStateMessage = "No automations yet..."
        
        return tableView
    }()

    private lazy var addTriggerButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Add Automation", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.thinLabelBorder)
        
        button.addTarget(self, action: #selector(didTouchUpInsideAddTrigger), for: .touchUpInside)
        
        return button
    }()
    
    @objc func didTouchUpInsideAddTrigger() {
        guard dogTriggers.dogTriggers.count < Constant.Class.Dog.maximumNumberOfTriggers else {
            PresentationManager.enqueueBanner(forTitle: Constant.Visual.BannerText.noAddMoreTriggersTitle, forSubtitle: Constant.Visual.BannerText.noAddMoreTriggersSubtitle, forStyle: .warning)
            return
        }
        
        delegate?.shouldOpenAddTriggerVC(forTrigger: nil)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddDogTriggersViewDelegate?
    /// dogTriggers is either a copy of dogToUpdate's triggers or a DogTriggerManager initialized to a default array of triggers. This is purposeful so that either, if you dont have a dogToUpdate, you can still create triggers, and if you do have a dogToUpdate, you don't directly update the dogToUpdate until save is pressed
    private(set) var dogTriggers: DogTriggerManager = DogTriggerManager(forDogTriggers: Constant.Class.Trigger.defaultTriggers)
    private(set) var initialTriggers: DogTriggerManager = DogTriggerManager(forDogTriggers: Constant.Class.Trigger.defaultTriggers)
    
    var didUpdateInitialValues: Bool {
        // if current triggers has more triggers than initial triggers, the loop below won't catch it, as the loop below just looks to see if each initial trigger is still present in current triggers.
        if initialTriggers.dogTriggers.count != dogTriggers.dogTriggers.count {
            return true
        }
        // make sure each initial trigger has a corresponding current trigger, otherwise current triggers have been updated
        for initialTrigger in initialTriggers.dogTriggers {
            let currentTrigger = dogTriggers.dogTriggers.first(where: { $0.triggerUUID == initialTrigger.triggerUUID })
            
            guard let currentTrigger = currentTrigger else {
                // no corresponding trigger
                return true
            }
            
            // if any of the corresponding triggers are different, then return true to indicate that a trigger has been updated
            if !initialTrigger.isSame(as: currentTrigger) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddDogTriggersViewDelegate, forDogTriggers: DogTriggerManager?) {
        delegate = forDelegate
        
        dogTriggers = (forDogTriggers?.copy() as? DogTriggerManager) ?? dogTriggers
        initialTriggers = (forDogTriggers?.copy() as? DogTriggerManager) ?? initialTriggers
        
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    func didAddTrigger(forTrigger: Trigger) {
        dogTriggers.addTrigger(forTrigger: forTrigger)
        delegate?.didUpdateTriggerCount()
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    func didUpdateTrigger(forTrigger: Trigger) {
        dogTriggers.addTrigger(forTrigger: forTrigger)
        delegate?.didUpdateTriggerCount()
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    func didRemoveTrigger(forTriggerUUID: UUID) {
        dogTriggers.removeTrigger(forTriggerUUID: forTriggerUUID)
        delegate?.didUpdateTriggerCount()
        // not in view so no animation
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dogTriggers.dogTriggers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Only add spacing if NOT the last section
        let lastSection = dogTriggers.dogTriggers.count - 1
        return section == lastSection ? 0 : Constant.Constraint.Spacing.contentTallIntraVert
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
        let cell = tableView.dequeueReusableCell(withIdentifier: DogsAddDogTriggerTVC.reuseIdentifier, for: indexPath)
        
        if let castedCell = cell as? DogsAddDogTriggerTVC {
            castedCell.setup(forTrigger: dogTriggers.dogTriggers[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trigger = dogTriggers.dogTriggers[indexPath.section]
        
        delegate?.shouldOpenAddTriggerVC(forTrigger: trigger)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete && dogTriggers.dogTriggers.isEmpty == false else { return }
        
        let trigger = dogTriggers.dogTriggers[indexPath.section]
        
        let removeTriggerConfirmation = UIAlertController(title: "Are you sure you want to delete this trigger?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.dogTriggers.removeTrigger(forTriggerUUID: trigger.triggerUUID)
            self.delegate?.didUpdateTriggerCount()
            
            self.tableView.deleteSections([indexPath.section], with: .fade)
            UIView.animate(withDuration: Constant.Visual.Animation.moveMultipleElements) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        removeTriggerConfirmation.addAction(removeAlertAction)
        removeTriggerConfirmation.addAction(cancelAlertAction)
        PresentationManager.enqueueAlert(removeTriggerConfirmation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dogTriggers.dogTriggers.isEmpty == false
    }

    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        addSubview(tableView)
        addSubview(addTriggerButton)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            addTriggerButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            addTriggerButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addTriggerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            addTriggerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            addTriggerButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: self),
            addTriggerButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
    }
}
