//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsPersonalInformationViewControllerDelegate {
    
    // TODO NOW make settings page cells all one cell. then, based off an enum, have the cell styleize itself 
    
    // MARK: - SettingsPersonalInformationViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var settingsPagesTableView: UITableView!
    
    // MARK: - Properties
    
    // 2 separators, 5 setting pages, 1 separator, and 5 info pages to allow for proper edge insets
    private let numberOfTableViewCells = (2 + 5 + 1 + 5)
    var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    var settingsNotificationsTableViewController: SettingsNotificationsTableViewController?
    weak var delegate: SettingsViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsPagesTableView.delegate = self
        settingsPagesTableView.dataSource = self
        settingsPagesTableView.separatorColor = .systemBackground
        // make seperator go the whole distance, then individual cells can change it.
        settingsPagesTableView.separatorInset = .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfTableViewCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure cell for about view controller setup
        var cell = UITableViewCell()
        
        let iconEdgeInset = UIEdgeInsets.init(top: 0, left: (5.0 + 35.5 + 2.5), bottom: 0, right: 0)
        switch indexPath.row {
            // we want two separators cells at the top.
            // the first cell has a separators on both the top and bottom, we hide it.
            // The second cell (and all following cells) only have separators on the bottom, therefore the second cell makes it look like a full size separator is on the top of the third cell. Meanwhile, the third cell has a partial separator to stylize it.
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithoutSeparatorTableViewCell", for: indexPath)
            cell.contentView.addConstraint(NSLayoutConstraint(item: cell.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell.separatorInset = .zero
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithSeparatorTableViewCell", for: indexPath)
            cell.contentView.addConstraint(NSLayoutConstraint(item: cell.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell.separatorInset = .zero
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsPersonalInformationViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsAppearanceViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsNotificationsTableViewController", for: indexPath)
            cell.separatorInset = .zero
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithSeparatorTableViewCell", for: indexPath)
            cell.contentView.addConstraint(NSLayoutConstraint(item: cell.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.5))
            cell.separatorInset = .zero
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsWebsiteViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 9:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsContactViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 10:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsEULAViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 11:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsPrivacyViewController", for: indexPath)
            cell.separatorInset = iconEdgeInset
        case 12:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTermsViewController", for: indexPath)
            cell.separatorInset = .zero
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsPersonalInformationViewController", for: indexPath)
            cell.separatorInset = .zero
        }
        cell.selectionStyle = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cannot select the space cells so no need to worry about them
        self.settingsPagesTableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        guard let identifier = cell?.reuseIdentifier else {
            return
        }
        
        if identifier == "SettingsSubscriptionViewController" {
            SettingsSubscriptionViewController.performSegueToSettingsSubscriptionViewController(forViewController: self)
        }
        else if identifier == "SettingsWebsiteViewController" {
            if let url = URL(string: "https://www.houndorganizer.com") {
                UIApplication.shared.open(url)
            }
        }
        else if identifier == "SettingsContactViewController" {
            if let url = URL(string: "https://www.houndorganizer.com/contact") {
                UIApplication.shared.open(url)
            }
        }
        else if identifier == "SettingsEULAViewController" {
            if let url = URL(string: "https://www.houndorganizer.com/eula") {
                UIApplication.shared.open(url)
            }
        }
        else if identifier == "SettingsPrivacyViewController" {
            if let url = URL(string: "https://www.houndorganizer.com/privacy") {
                UIApplication.shared.open(url)
            }
        }
        else if identifier == "SettingsTermsViewController" {
            if let url = URL(string: "https://www.houndorganizer.com/terms") {
                UIApplication.shared.open(url)
            }
        }
        else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: identifier)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController {
            settingsPersonalInformationViewController.delegate = self
        }
        else if let settingsSubscriptionViewController = segue.destination as? SettingsSubscriptionViewController {
            self.settingsSubscriptionViewController = settingsSubscriptionViewController
        }
        else if let settingsNotificationsTableViewController = segue.destination as? SettingsNotificationsTableViewController {
            self.settingsNotificationsTableViewController = settingsNotificationsTableViewController
        }
    }
    
}
