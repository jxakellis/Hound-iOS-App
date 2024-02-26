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

final class SettingsPagesTableViewController: GeneralUITableViewController, SettingsAccountViewControllerDelegate, SettingsFamilyIntroductionViewControllerDelegate {

    // MARK: - SettingsAccountViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }
    
    // MARK: - SettingsFamilyIntroductionViewControllerDelegate

    func didTouchUpInsideUpgrade() {
        StoryboardViewControllerManager.SettingsViewControllers.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
            guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                // Error message automatically handled
                return
            }
            
            PresentationManager.enqueueViewController(settingsSubscriptionViewController)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Introduction Page

        if LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController == false && FamilyInformation.familyActiveSubscription.productId == ClassConstant.SubscriptionConstant.defaultSubscription.productId {
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.IntroductionViewControllers.getSettingsFamilyIntroductionViewController(forDelegate: self))
        }
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
        case .account:
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.SettingsViewControllers.getSettingsAccountViewController(forDelegate: self))
        case .family:
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.SettingsViewControllers.getSettingsFamilyViewController())
        case .subscription:
            StoryboardViewControllerManager.SettingsViewControllers.getSettingsSubscriptionViewController { settingsSubscriptionViewController in
                guard let settingsSubscriptionViewController = settingsSubscriptionViewController else {
                    // Error message automatically handled
                    return
                }
                
                self.settingsSubscriptionViewController = settingsSubscriptionViewController
                PresentationManager.enqueueViewController(settingsSubscriptionViewController)
            }
        case .appearance:
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.SettingsViewControllers.getSettingsAppearanceViewController())
        case .notifications:
            let viewController = StoryboardViewControllerManager.SettingsViewControllers.getSettingsNotificationsTableViewController()
            self.settingsNotificationsTableViewController = viewController
            PresentationManager.enqueueViewController(viewController)
        case .website, .support, .eula, .privacyPolicy, .termsAndConditions:
            if let url = page.url {
                UIApplication.shared.open(url)
            }
        case .feedback:
            PresentationManager.enqueueViewController(StoryboardViewControllerManager.getSurveyFeedbackAppExperienceViewController())
        }
    }
}
