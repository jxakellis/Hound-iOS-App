//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

protocol SettingsPagesTableViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsPagesTableViewController: UITableViewController, SettingsPersonalInformationViewControllerDelegate {
    
    // MARK: - SettingsPersonalInformationViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }
    
    // MARK: - Properties
    
    private(set) var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    private(set) var settingsNotificationsViewController: SettingsNotificationsViewController?
    weak var delegate: SettingsPagesTableViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    @objc func didDismissForSettingsPageViewController() {
        // The settingsPageViewController could have disappeared, but that doesn't necessarily mean it went back to settingsViewController. For example: We segue to settingsFamilyVC. settingsFamilyVC then presents settingFamilyIntroductionVC to encourage a user to subscription. This causes settingsFamilyVC to invoke viewDidDisappear. However, settingsFamilyVC didn't disappear back into settingsViewController, rather it went deeper into settingFamilyIntroductionVC. Therefore, we must keep this observer alive until the original settingsPageViewController disappears back into settingsFamilyVC (indicated by self.presentedViewController == nil)
        guard self.presentedViewController == nil else {
            return
        }
        
        PresentationManager.globalPresenter = self
        NotificationCenter.default.removeObserver(self, name: .didDismissForSettingsPageViewController, object: nil)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        // We have two sections of settings pages, splitting them based upon whether they are a setting inside hound or a webpage we redirect the user two
        SettingsPages.allCases.forEach { settingsPage in
            switch settingsPage {
            case .personalInformation:
                numberOfRows += (section == 0 ? 1 : 0)
            case .family:
                numberOfRows += (section == 0 ? 1 : 0)
            case .subscription:
                numberOfRows += (section == 0 ? 1 : 0)
            case .appearance:
                numberOfRows += (section == 0 ? 1 : 0)
            case .notifications:
                numberOfRows += (section == 0 ? 1 : 0)
            case .website:
                numberOfRows += (section == 1 ? 1 : 0)
            case .contact:
                numberOfRows += (section == 1 ? 1 : 0)
            case .eula:
                numberOfRows += (section == 1 ? 1 : 0)
            case .privacyPolicy:
                numberOfRows += (section == 1 ? 1 : 0)
            case .termsAndConditions:
                numberOfRows += (section == 1 ? 1 : 0)
            }
        }
        
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsHeaderView()
        
        headerView.setup(forTitle: section == 0 ? "Preferences" : "Links")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsHeaderView.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsPage = SettingsPages.allCases.safeIndex((indexPath.section * 5) + indexPath.row)
        guard let settingsPage = settingsPage else {
            return UITableViewCell()
        }
        
        let settingsPageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsPageTableViewCell", for: indexPath) as? SettingsPageTableViewCell
        
        guard let settingsPageTableViewCell = settingsPageTableViewCell else {
            return UITableViewCell()
        }
        
        settingsPageTableViewCell.setup(forPage: settingsPage)
        
        switch settingsPage {
        case .personalInformation:
            settingsPageTableViewCell.containerView.roundCorners(setCorners: .top)
        case .notifications:
            settingsPageTableViewCell.containerView.roundCorners(setCorners: .bottom)
        case .website:
            settingsPageTableViewCell.containerView.roundCorners(setCorners: .top)
        case .termsAndConditions:
            settingsPageTableViewCell.containerView.roundCorners(setCorners: .bottom)
        default:
            settingsPageTableViewCell.containerView.roundCorners(setCorners: .none)
        }
        
        return settingsPageTableViewCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsPageTableViewCell = tableView.cellForRow(at: indexPath) as? SettingsPageTableViewCell
        
        guard let settingsPageTableViewCell = settingsPageTableViewCell, let page = settingsPageTableViewCell.page else {
            return
        }
        
        switch page {
        case .personalInformation, .family, .appearance, .notifications:
            if let segueIdentifier = page.segueIdentifier {
                self.performSegueOnceInWindowHierarchy(segueIdentifier: segueIdentifier)
            }
        case .subscription:
            SettingsSubscriptionViewController.performSegueToSettingsSubscriptionViewController(forViewController: self)
        case .website, .contact, .eula, .privacyPolicy, .termsAndConditions:
            if let url = page.url {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self, name: .didDismissForSettingsPageViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissForSettingsPageViewController), name: .didDismissForSettingsPageViewController, object: segue.destination)
        
        if let settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController {
            settingsPersonalInformationViewController.delegate = self
        }
        else if let settingsSubscriptionViewController = segue.destination as? SettingsSubscriptionViewController {
            self.settingsSubscriptionViewController = settingsSubscriptionViewController
        }
        else if let settingsNotificationsViewController = segue.destination as? SettingsNotificationsViewController {
            self.settingsNotificationsViewController = settingsNotificationsViewController
        }
    }
}
