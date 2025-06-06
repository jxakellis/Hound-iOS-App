//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ServerSyncViewController: GeneralUIViewController, ServerFamilyViewControllerDelegate {
    
    // MARK: - ServerFamilyViewControllerDelegate
    
    func didCreateOrJoinFamily() {
        DogManager.globalDogManager = nil
    }
    
    // MARK: - Elements
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 800, compressionResistancePriority: 800)

        return imageView
    }()
    
    private let getRequestsProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.contentMode = .scaleToFill
        progressView.setContentHuggingPriority(UILayoutPriority(750), for: .vertical)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBackground
        progressView.trackTintColor = .systemGray2
        return progressView
    }()
    
    private let troubleshootLoginButton: GeneralUIButton = {
        let button = GeneralUIButton()
        button.isHidden = true
        
        button.setTitle("Go to Login Page", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTapTroubleshootLogin(_ sender: Any) {
        if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerRetryLogin {
            self.repeatableSetup()
        }
        else if troubleshootLoginButton.tag == VisualConstant.ViewTagConstant.serverSyncViewControllerGoToLoginPage {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController")
        }
    }
    
    // MARK: - Properties
    
    /// What fraction of the loading/progress bar the types request is worth when completed
    private var getGlobalTypesProgressFractionOfWhole = (0.5 / 3.0)
    @objc private dynamic var getGlobalTypesProgress: Progress?
    private var getGlobalTypesProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the user request is worth when completed
    private var getUserProgressFractionOfWhole = (0.5 / 3.0)
    @objc private dynamic var getUserProgress: Progress?
    private var getUserProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the family request is worth when completed
    private var getFamilyProgressFractionOfWhole = (0.5 / 3.0)
    @objc private dynamic var getFamilyProgress: Progress?
    private var getFamilyProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the dogs request is worth when completed
    private var getDogsProgressFractionOfWhole = 0.5
    @objc private dynamic var getDogsProgress: Progress?
    private var getDogsProgressObserver: NSKeyValueObservation?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // As soon as this view disappears, we want to halt the observers to clean up / deallocate resources.
        getGlobalTypesProgressObserver?.invalidate()
        getGlobalTypesProgressObserver = nil
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
        
        getGlobalTypesProgress = nil
        getGlobalTypesProgressObserver = nil
        getUserProgress = nil
        getUserProgressObserver = nil
        getFamilyProgress = nil
        getFamilyProgressObserver = nil
        getDogsProgress = nil
        getDogsProgressObserver = nil
        
        // Before fetching user or any other information, we need types from the server
        self.getGlobalTypes()
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
    
    private func getGlobalTypes() {
        getGlobalTypesProgress = GlobalTypesRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                self.failureResponseForRequest()
                return
            }
            
            guard GlobalTypes.shared != nil else {
                // If the user just has no internet, then show a button that lets them try again
                if responseStatus == .noResponse {
                    self.noResponseForRequest()
                }
                else {
                    self.failureResponseForRequest()
                }
                return
            }
            
            if UserInformation.userIdentifier != nil {
                self.getUser()
            }
            // placeholder userId, therefore we need to have them login to even know who they are
            else {
                
                // we have the user sign into their apple id, then attempt to first create an account then get an account (if the creates fails) then throw an error message (if the get fails too).
                // if all succeeds, then the user information and user configuration is loaded
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerLoginViewController")
            }
        }
        
        if getGlobalTypesProgress != nil {
            // We can't use if let getGlobalTypesProgress = getGlobalTypesProgress here. We need to observe the actual getUserProgress (not an if let "copy" of it) variable that is defined in this class for the KeyValueObservation to work.
            getGlobalTypesProgressObserver = observe(\.getGlobalTypesProgress?.fractionCompleted, options: [.new]) { _, change in
                self.didObserveProgressChange()
                
                // If the get request progress is complete (indicated by the fractionCompleted being 1.0), then we can invalidate the observer as it is no longer needed
                if let optionalNewValue = change.newValue, let newValue = optionalNewValue, newValue == 1.0 {
                    self.getGlobalTypesProgressObserver?.invalidate()
                }
            }
        }
        
    }
    
    private func getUser() {
        getUserProgress = UserRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                self.failureResponseForRequest()
                return
            }
            
            // This is a special case. If previousDogManagerSynchronization is nil, the user's local data was cleared. This, in conjunction with no response, would mean we would open the app up to a blank screen. This would terrify the user that their data is lost. Therefore, force them to wait for a connection
            guard responseStatus != .noResponse || LocalConfiguration.previousDogManagerSynchronization == nil else {
                self.noResponseForRequest()
                return
            }
            
            guard UserInformation.userIdentifier != nil && UserInformation.userId != nil else {
                // If the user just has no internet, then show a button that lets them try again
                if responseStatus == .noResponse {
                    self.noResponseForRequest()
                }
                // If the suer has internet and still no userId, they need to login
                else {
                    self.failureResponseForRequest()
                }
                return
            }
            
            if UserInformation.familyId != nil {
                // Continue fetching the users family information
                self.getFamilyInformation()
            }
            else {
                // User needs to join a family because they have no familyId
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "ServerFamilyViewController")
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
        getFamilyProgress = FamilyRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                self.failureResponseForRequest()
                return
            }
            
            self.getDogs()
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
        let dogManager = DogManager.globalDogManager ?? DogManager()
        // we want to use our own custom error message
        getDogsProgress = DogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogManager: dogManager) { newDogManager, responseStatus, _ in
            guard responseStatus != .failureResponse else {
                self.failureResponseForRequest()
                return
            }
            
            DogManager.globalDogManager = newDogManager
            
            // hasn't shown configuration to create/update dog
            if LocalConfiguration.localHasCompletedHoundIntroductionViewController == false {
                // Created family, no dogs present
                // OR joined family, no dogs present
                // OR joined family, dogs already present
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "HoundIntroductionViewController")
                
            }
            // has shown configuration before
            else {
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarController")
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
            let globalTypesProgress = (self.getGlobalTypesProgress?.fractionCompleted ?? 0.0) * self.getGlobalTypesProgressFractionOfWhole
            
            let userProgress = (self.getUserProgress?.fractionCompleted ?? 0.0) * self.getUserProgressFractionOfWhole
            
            let familyProgress =
            (self.getFamilyProgress?.fractionCompleted ?? 0.0) * self.getFamilyProgressFractionOfWhole
            
            let dogsProgress =
            (self.getDogsProgress?.fractionCompleted ?? 0.0) * self.getDogsProgressFractionOfWhole
            
            self.getRequestsProgressView.setProgress(Float(globalTypesProgress + userProgress + familyProgress + dogsProgress), animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let serverFamilyViewController: ServerFamilyViewController = segue.destination as? ServerFamilyViewController {
            serverFamilyViewController.delegate = self
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(pawWithHands)
        view.addSubview(getRequestsProgressView)
        view.addSubview(troubleshootLoginButton)
        troubleshootLoginButton.addTarget(self, action: #selector(didTapTroubleshootLogin), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pawWithHands.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor, multiplier: 1 / 1),
            pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 4 / 10),
            
            getRequestsProgressView.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 35),
            getRequestsProgressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            getRequestsProgressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            getRequestsProgressView.heightAnchor.constraint(equalToConstant: 5),
            
            troubleshootLoginButton.topAnchor.constraint(equalTo: getRequestsProgressView.bottomAnchor, constant: 35),
            troubleshootLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            troubleshootLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            troubleshootLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            troubleshootLoginButton.widthAnchor.constraint(equalTo: troubleshootLoginButton.heightAnchor, multiplier: 1 / 0.16)
            
        ])
        
    }
}
