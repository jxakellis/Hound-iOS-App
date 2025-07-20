//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

protocol SettingsPagesTableVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsPagesTableVC: HoundTableViewController, SettingsAccountVCDelegate, FamilyUpgradeIntroductionVCDelegate {
    
    // MARK: - SettingsAccountVCDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate?.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }
    
    // MARK: - FamilyUpgradeIntroductionVCDelegate
    
    func didTouchUpInsideUpgrade() {
        SettingsSubscriptionVC.fetchProductsThenGetViewController { vc in
            guard let vc = vc else {
                // Error message automatically handled
                return
            }
            
            PresentationManager.enqueueViewController(vc)
        }
    }
    
    // MARK: - Properties
    
    private weak var delegate: SettingsPagesTableVCDelegate?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.tableView.register(SettingsPagesTVC.self, forCellReuseIdentifier: SettingsPagesTVC.reuseIdentifier)
        self.tableView.onlyScrollIfBigger()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Introduction Page
        
        if LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController == false && FamilyInformation.familyActiveSubscription.productId == Constant.Class.Subscription.defaultSubscription.productId {
            let vc = FamilyUpgradeIntroductionVC()
            vc.setup(forDelegate: self)
            PresentationManager.enqueueViewController(vc)
        }
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsPagesTableVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        // We have two sections of settings pages, splitting them based upon whether they are a setting inside hound or a webpage we redirect the user two
        SettingsPages.allCases.forEach { settingsPage in
            switch settingsPage {
            case .account, .family, .subscription, .appearance, .notifications:
                numberOfRows += (section == 0 ? 1 : 0)
            case .website, .feedback, .support, .eula, .privacyPolicy, .termsAndConditions:
                numberOfRows += (section == 1 ? 1 : 0)
            }
        }
        
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HoundTableHeaderFooterView()
        
        headerView.setTitle(section == 0 ? "Preferences" : "Links")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsPage = SettingsPages.allCases[safe: (indexPath.section * 5) + indexPath.row]
        guard let settingsPage = settingsPage else {
            return HoundTableViewCell()
        }
        
        let settingsPagesTableViewCell = tableView.dequeueReusableCell(withIdentifier: SettingsPagesTVC.reuseIdentifier, for: indexPath) as? SettingsPagesTVC
        
        guard let settingsPagesTableViewCell = settingsPagesTableViewCell else {
            return HoundTableViewCell()
        }
        
        settingsPagesTableViewCell.setup(forPage: settingsPage)
        
        switch settingsPage {
        case .account:
            settingsPagesTableViewCell.containerView.roundCorners(setCorners: .top)
        case .notifications:
            settingsPagesTableViewCell.containerView.roundCorners(setCorners: .bottom)
        case .website:
            settingsPagesTableViewCell.containerView.roundCorners(setCorners: .top)
        case .termsAndConditions:
            settingsPagesTableViewCell.containerView.roundCorners(setCorners: .bottom)
        default:
            settingsPagesTableViewCell.containerView.roundCorners(setCorners: .none)
        }
        
        return settingsPagesTableViewCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsPagesTableViewCell = tableView.cellForRow(at: indexPath) as? SettingsPagesTVC
        
        guard let settingsPagesTableViewCell = settingsPagesTableViewCell, let page = settingsPagesTableViewCell.page else { return }
        
        switch page {
        case .account:
            let vc = SettingsAccountVC()
            vc.setup(forDelegate: self)
            PresentationManager.enqueueViewController(vc)
        case .family:
            let vc = SettingsFamilyVC()
            PresentationManager.enqueueViewController(vc)
        case .subscription:
            SettingsSubscriptionVC.fetchProductsThenGetViewController { vc in
                guard let vc = vc else {
                    // Error message automatically handled
                    return
                }
                
                PresentationManager.enqueueViewController(vc)
            }
        case .appearance:
            let vc = SettingsAppearanceVC()
            PresentationManager.enqueueViewController(vc)
        case .notifications:
            let vc = SettingsNotifsVC()
            PresentationManager.enqueueViewController(vc)
        case .website, .support, .eula, .privacyPolicy, .termsAndConditions:
            if let url = page.url {
                UIApplication.shared.open(url)
            }
        case .feedback:
            let vc = SurveyAppExperienceVC()
            PresentationManager.enqueueViewController(vc)
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        tableView.backgroundColor = UIColor.secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    }
}
