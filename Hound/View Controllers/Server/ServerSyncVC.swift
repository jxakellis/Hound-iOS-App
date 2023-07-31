//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ServerSyncViewController: UIViewController, ServerFamilyViewControllerDelegate {
    
    // MARK: - ServerFamilyViewControllerDelegate
    
    func didCreateOrJoinFamily() {
        ServerSyncViewController.dogManager = DogManager()
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var pawWithHands: UIImageView!
    
    @IBOutlet private weak var getRequestsProgressView: UIProgressView!
    
    @IBOutlet private weak var troubleshootLoginButton: GeneralUIButton!
    @IBAction private func didTapTroubleshootLogin(_ sender: Any) {
        if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerRetryLogin {
            self.repeatableSetup()
        }
        else if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerGoToLoginPage {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController", completionHandler: nil)
        }
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
    
    // MARK: - Dog Manager
    
    static var dogManager = DogManager()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands
        }
    }
    
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
        
        if UserInformation.userIdentifier != nil {
            self.getUser()
        }
        // placeholder userId, therefore we need to have them login to even know who they are
        else {
            
            // we have the user sign into their apple id, then attempt to first create an account then get an account (if the creates fails) then throw an error message (if the get fails too).
            // if all succeeds, then the user information and user configuration is loaded
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController", completionHandler: nil)
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
    
    // MARK: Get Functions
    
    private func getUser() {
        getUserProgress = UserRequest.get(invokeErrorManager: true) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // UserInformation.familyId automatically configured for us
                // user has family
                if UserInformation.familyId != nil {
                    self.getFamilyInformation()
                }
                // no family for user
                else {
                    // We failed to retrieve a familyId for the user so that means they have no family. Segue to page to make them create/join one.
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerFamilyViewController", completionHandler: nil)
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
                
                ServerSyncViewController.dogManager = newDogManager
                
                // hasn't shown configuration to create/update dog
                if LocalConfiguration.localHasCompletedHoundIntroductionViewController == false {
                    // Created family, no dogs present
                    // OR joined family, no dogs present
                    // OR joined family, dogs already present
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "HoundIntroductionViewController", completionHandler: nil)
                    
                }
                // has shown configuration before
                else {
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarController", completionHandler: nil)
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
        if let mainTabBarController: MainTabBarController = segue.destination as? MainTabBarController {
            mainTabBarController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: ServerSyncViewController.dogManager)
        }
        else if let houndIntroductionViewController: HoundIntroductionViewController = segue.destination as? HoundIntroductionViewController {
            houndIntroductionViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: ServerSyncViewController.dogManager)
        }
        else if let serverFamilyViewController: ServerFamilyViewController = segue.destination as? ServerFamilyViewController {
            serverFamilyViewController.delegate = self
        }
    }
    
}
