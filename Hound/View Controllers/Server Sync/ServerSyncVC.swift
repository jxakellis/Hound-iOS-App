//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ServerSyncViewController: UIViewController, ServerFamilyViewControllerDelegate {
    
    // MARK: - ServerFamilyViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var getRequestsProgressView: UIProgressView!
    
    @IBOutlet private weak var troubleshootLoginButton: UIButton!
    @IBAction private func didClickTroubleshootLogin(_ sender: Any) {
        if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerRetryLogin {
            self.repeatableSetup()
        }
        else if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerGoToLoginPage {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController")
        }
    }
    
    // MARK: - Dog Manager
    
    static var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        ServerSyncViewController.dogManager = forDogManager
    }
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        repeatableSetup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        troubleshootLoginButton.layer.cornerRadius = troubleshootLoginButton.frame.height / 2
        troubleshootLoginButton.layer.masksToBounds = true
        troubleshootLoginButton.layer.borderWidth = 1
        troubleshootLoginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // As soon as this view disappears, we want to halt the observers to clean up / deallocate resources.
        getUserProgressObserver?.invalidate()
        getUserProgressObserver = nil
        getFamilyProgressObserver?.invalidate()
        getFamilyProgressObserver = nil
        getDogsProgressObserver?.invalidate()
        getDogsProgressObserver = nil
    }
    
    // MARK: - Properties
    
    /// What fraction of the loading/progress bar the user request is worth when completed
    private var getUserProgressFractionOfWhole = 0.2
    @objc dynamic private var getUserProgress: Progress?
    private var getUserProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the family request is worth when completed
    private var getFamilyProgressFractionOfWhole = 0.2
    @objc dynamic private var getFamilyProgress: Progress?
    private var getFamilyProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the dogs request is worth when completed
    private var getDogsProgressFractionOfWhole = 0.6
    @objc dynamic private var getDogsProgress: Progress?
    private var getDogsProgressObserver: NSKeyValueObservation?
    
    // MARK: - Functions
    
    private func repeatableSetup() {
        // reset troubleshootLoginButton incase it is needed again for another issue
        troubleshootLoginButton.tag = 0
        troubleshootLoginButton.isHidden = true
        
        getUserProgress = nil
        getUserProgressObserver = nil
        getFamilyProgress = nil
        getFamilyProgressObserver = nil
        getDogsProgress = nil
        getDogsProgressObserver = nil
        
        // has userId, possibly has familyId, will check inside getUser
        if let userId = UserInformation.userId, userId != Hash.defaultSHA256Hash {
            self.getUser()
        }
        // placeholder userId, therefore we need to have them login to even know who they are
        else {
            
            // we have the user sign into their apple id, then attempt to first create an account then get an account (if the creates fails) then throw an error message (if the get fails too).
            // if all succeeds, then the user information and user configuration is loaded
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController")
        }
    }
    
    /// If we recieved a failure response from a request, redirect the user to the login page in an attempt to recover
    private func failureResponseForRequest() {
        troubleshootLoginButton.tag = VisualConstant.ViewTagConstant.serverSyncViewControllerGoToLoginPage
        troubleshootLoginButton.setTitle("Go to Login Page", for: .normal)
        troubleshootLoginButton.isHidden = false
    }
    
    private func noResponseForRequest() {
        troubleshootLoginButton.tag = VisualConstant.ViewTagConstant.serverSyncViewControllerRetryLogin
        troubleshootLoginButton.setTitle("Retry Login", for: .normal)
        troubleshootLoginButton.isHidden = false
    }
    
    // MARK: - Get Functions
    
    private func getUser() {
        getUserProgress = UserRequest.get(invokeErrorManager: true) { _, familyId, responseStatus in
            switch responseStatus {
            case .successResponse:
                // we got the user information back and have setup the user config based off of that info
                // user has family
                if familyId != nil {
                    self.getFamilyInformation()
                }
                // no family for user
                else {
                    // We failed to retrieve a familyId for the user so that means they have no family. Segue to page to make them create/join one.
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerFamilyViewController")
                }
            case .failureResponse:
                self.failureResponseForRequest()
            case .noResponse:
                self.noResponseForRequest()
            }
        }
        
        if getUserProgress != nil {
            // We can't use if let getUserProgress = getUserProgress here. We need to observe the actual getUserProgress (not an if let "copy" of it) variable that is defined in this class for the KeyValueObservation to work.
            getUserProgressObserver = observe(\.getUserProgress?.fractionCompleted, options: [.new]) { _, change in
                self.didObserveProgressChange()
                
                // If the get request progress is complete (indicated by the fractionCompleted being 1.0), then we can invalidate the observer as it is no longer needed
                if let optionalNewValue = change.newValue, let newValue = optionalNewValue, newValue == 1.0 {
                    self.getUserProgressObserver?.invalidate()
                }
            }
        }
        
    }
    
    private func getFamilyInformation() {
        getFamilyProgress = FamilyRequest.get(invokeErrorManager: true) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                self.getDogs()
            case .failureResponse:
                self.failureResponseForRequest()
            case .noResponse:
                self.noResponseForRequest()
            }
        }
        
        if getFamilyProgress != nil {
            // We can't use if let getFamilyProgress = getFamilyProgress here. We need to observe the actual getFamilyProgress (not an if let "copy" of it) variable that is defined in this class for the KeyValueObservation to work.
            getFamilyProgressObserver = observe(\.getFamilyProgress?.fractionCompleted, options: [.new]) { _, change in
                self.didObserveProgressChange()
                
                // If the get request progress is complete (indicated by the fractionCompleted being 1.0), then we can invalidate the observer as it is no longer needed
                if let optionalNewValue = change.newValue, let newValue = optionalNewValue, newValue == 1.0 {
                    self.getFamilyProgressObserver?.invalidate()
                }
            }
        }
    }
    
    private func getDogs() {
        // we want to use our own custom error message
        getDogsProgress = DogsRequest.get(invokeErrorManager: true, dogManager: ServerSyncViewController.dogManager) { newDogManager, responseStatus in
            switch responseStatus {
            case .successResponse:
                guard let newDogManager = newDogManager else {
                    self.failureResponseForRequest()
                    return
                }
                
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
                
                // hasn't shown configuration to create/update dog
                if LocalConfiguration.localHasCompletedHoundIntroductionViewController == false {
                    // Created family, no dogs present
                    // OR joined family, no dogs present
                    // OR joined family, dogs already present
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "HoundIntroductionViewController")
                    
                }
                // has shown configuration before
                else {
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarViewController")
                }
            case .failureResponse:
                self.failureResponseForRequest()
            case .noResponse:
                self.noResponseForRequest()
            }
        }
        
        if getDogsProgress != nil {
            // We can't use if let getDogsProgress = getDogsProgress here. We need to observe the actual getDogsProgress (not an if let "copy" of it) variable that is defined in this class for the KeyValueObservation to work.
            getDogsProgressObserver = observe(\.getDogsProgress?.fractionCompleted, options: [.new]) { _, change in
                self.didObserveProgressChange()
                
                // If the get request progress is complete (indicated by the fractionCompleted being 1.0), then we can invalidate the observer as it is no longer needed
                if let optionalNewValue = change.newValue, let newValue = optionalNewValue, newValue == 1.0 {
                    self.getDogsProgressObserver?.invalidate()
                }
            }
        }
        
    }
    
    // The .fractionCompleted variable on one of the progress objects was updated. Therefore, we must update our loading bar
    private func didObserveProgressChange() {
        DispatchQueue.main.async {
            let userProgress = (self.getUserProgress?.fractionCompleted ?? 0.0) * self.getUserProgressFractionOfWhole
            
            let familyProgress =
            (self.getFamilyProgress?.fractionCompleted ?? 0.0) * self.getFamilyProgressFractionOfWhole
            
            let dogsProgress =
            (self.getDogsProgress?.fractionCompleted ?? 0.0) * self.getDogsProgressFractionOfWhole
            
            self.getRequestsProgressView.setProgress(Float(userProgress + familyProgress + dogsProgress), animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let mainTabBarViewController: MainTabBarViewController = segue.destination as? MainTabBarViewController {
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: ServerSyncViewController.dogManager)
        }
        else if let houndIntroductionViewController: HoundIntroductionViewController = segue.destination as? HoundIntroductionViewController {
            houndIntroductionViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: ServerSyncViewController.dogManager)
        }
        else if let serverFamilyViewController: ServerFamilyViewController = segue.destination as? ServerFamilyViewController {
            serverFamilyViewController.delegate = self
        }
    }
    
}
