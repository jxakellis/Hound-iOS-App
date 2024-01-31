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

final class SettingsPagesTableViewController: GeneralUITableViewController, SettingsAccountViewControllerDelegate {

    // MARK: - SettingsAccountViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }

    // MARK: - Properties

    private var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    private var settingsNotificationsTableViewController: SettingsNotificationsTableViewController?
    weak var delegate: SettingsPagesTableViewControllerDelegate!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
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
            StoryboardViewControllerManager.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
                guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                    // Error message automatically handled
                    return
                }
                
                PresentationManager.enqueueViewController(settingsSubscriptionViewController)
            }
        case .website, .contact, .eula, .privacyPolicy, .termsAndConditions:
            if let url = page.url {
                UIApplication.shared.open(url)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
