//
//  SettingsAboutViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsAboutViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var version: ScaledUILabel!
    
    @IBOutlet private weak var copyright: ScaledUILabel!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.version.text = "Version \(UIApplication.appVersion)"
        self.copyright.text = "© \(Calendar.localCalendar.component(.year, from: Date())) Jonathan Xakellis"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
}
