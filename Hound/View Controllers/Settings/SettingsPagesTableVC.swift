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

final class SettingsPagesTableViewController: UITableViewController, SettingsAccountViewControllerDelegate {

    // MARK: - SettingsAccountViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }

    // MARK: - Properties

    private(set) var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    private(set) var settingsNotificationsTableViewController: SettingsNotificationsTableViewController?
    weak var delegate: SettingsPagesTableViewControllerDelegate!

    // MARK: - Main

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }

    // MARK: - Functions

    @objc func didDismissForSettingsPagesTableViewController() {
        // Keep this observer alive until the original segue view disappear back into settingsPagesTableVC (indicated by self.presentedViewController == nil). For example: We segue to settingsFamilyVC. settingsFamilyVC then presents settingFamilyIntroductionVC to encourage a user to subscription. This causes settingsFamilyVC to invoke viewDidDisappear. However, settingsFamilyVC didn't disappear back into settingsPagesTableVC, rather it went deeper into settingFamilyIntroductionVC. Therefore, we must keep this observer alive until the original settingsFamilyVC disappears back into settingsPagesTableVC
        guard self.presentedViewController == nil else {
            return
        }

        PresentationManager.globalPresenter = self
        NotificationCenter.default.removeObserver(self, name: .didDismissForSettingsPagesTableViewController, object: nil)
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
            case .account:
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
        let headerView = SettingsPagesTableHeaderView()

        headerView.setup(forTitle: section == 0 ? "Preferences" : "Links")

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SettingsPagesTableHeaderView.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsPage = SettingsPages.allCases.safeIndex((indexPath.section * 5) + indexPath.row)
        guard let settingsPage = settingsPage else {
            return UITableViewCell()
        }

        let settingsPagesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsPagesTableViewCell", for: indexPath) as? SettingsPagesTableViewCell

        guard let settingsPagesTableViewCell = settingsPagesTableViewCell else {
            return UITableViewCell()
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
        let settingsPagesTableViewCell = tableView.cellForRow(at: indexPath) as? SettingsPagesTableViewCell

        guard let settingsPagesTableViewCell = settingsPagesTableViewCell, let page = settingsPagesTableViewCell.page else {
            return
        }

        switch page {
        case .account, .family, .appearance, .notifications:
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
        NotificationCenter.default.removeObserver(self, name: .didDismissForSettingsPagesTableViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissForSettingsPagesTableViewController), name: .didDismissForSettingsPagesTableViewController, object: segue.destination)

        if let settingsAccountViewController = segue.destination as? SettingsAccountViewController {
            settingsAccountViewController.delegate = self
        }
        else if let settingsSubscriptionViewController = segue.destination as? SettingsSubscriptionViewController {
            self.settingsSubscriptionViewController = settingsSubscriptionViewController
        }
        else if let settingsNotificationsTableViewController = segue.destination as? SettingsNotificationsTableViewController {
            self.settingsNotificationsTableViewController = settingsNotificationsTableViewController
        }
    }
}
