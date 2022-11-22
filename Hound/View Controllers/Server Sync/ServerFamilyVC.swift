//
//  ServerFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ServerFamilyViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class ServerFamilyViewController: UIViewController {
    
    // MARK: IB
    
    @IBOutlet private weak var createFamilyButton: UIButton!
    
    @IBAction private func willCreateFamily(_ sender: Any) {
        RequestUtils.beginRequestIndictator()
        FamilyRequest.create(invokeErrorManager: true) { familyId, _ in
            RequestUtils.endRequestIndictator {
                if familyId != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBOutlet private weak var createFamilyDisclaimerLabel: ScaledUILabel!
    @IBOutlet private weak var createFamilyDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var createFamilyDisclaimerTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var joinFamilyButton: ScaledUILabel!
    
    @IBAction private func willJoinFamily(_ sender: Any) {
        
        let familyCodeAlertController = GeneralUIAlertController(title: "Join a Family", message: "The code is case-insensitive", preferredStyle: .alert)
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter Family Code..."
            textField.autocapitalizationType = .allCharacters
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        let alertActionJoin = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textFields = familyCodeAlertController?.textFields else {
                return
            }
            // uppercase everything then replace "-" with "" (nothing) then remove any excess whitespaces/newliens
            let familyCode = (textFields[0].text ?? "").uppercased().replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            // code is empty
            if familyCode.isEmpty {
                ErrorConstant.FamilyRequestError.familyCodeBlank.alert()
            }
            // code isn't long enough
            else if familyCode.count != 8 {
                ErrorConstant.FamilyRequestError.familyCodeInvalid.alert()
            }
            // client side the code is okay
            else {
                RequestUtils.beginRequestIndictator()
                FamilyRequest.update(invokeErrorManager: true, body: [KeyConstant.familyCode.rawValue: familyCode]) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        // the code successfully allowed the user to join
                        guard requestWasSuccessful else {
                            return
                        }
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
            
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        familyCodeAlertController.addAction(alertActionJoin)
        familyCodeAlertController.addAction(alertActionCancel)
        AlertManager.enqueueAlertForPresentation(familyCodeAlertController)
        
    }
    // MARK: Properties
    
    weak var delegate: ServerFamilyViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCreateFamily()
        setupCreateFamilyDisclaimer()
        setupJoinFamily()
        
        func setupCreateFamily() {
            // set to made to have fully rounded corners
            createFamilyButton.layer.cornerRadius = createFamilyButton.frame.height / 2
            createFamilyButton.layer.masksToBounds = true
            createFamilyButton.layer.borderWidth = 1
            createFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
        
        func setupCreateFamilyDisclaimer() {
            createFamilyDisclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
            
            createFamilyDisclaimerLeadingConstraint.constant += (createFamilyButton.frame.height / 6)
            createFamilyDisclaimerTrailingConstraint.constant += (createFamilyButton.frame.height / 6)
        }
        
        func setupJoinFamily() {
            // set to made to have fully rounded corners
            joinFamilyButton.layer.cornerRadius = joinFamilyButton.frame.height / 2
            joinFamilyButton.layer.masksToBounds = true
            joinFamilyButton.layer.borderWidth = 1
            joinFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        LocalConfiguration.resetForNewFamily()
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: DogManager())
    }
}
