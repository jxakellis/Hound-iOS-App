//
//  HoundIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntroductionViewController: GeneralUIViewController,
                                             UIScrollViewDelegate,
                                             HoundIntroductionDogNameViewDelegate,
                                             HoundIntroductionDogIconViewDelegate {
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isMultipleTouchEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // These pages will be added dynamically in viewIsAppearing
    private var dogNamePage: HoundIntroductionDogNameView?
    private var dogIconPage: HoundIntroductionDogIconView?
    
    // MARK: - Properties
    
    private var didSetupCustomSubviews: Bool = false
    private var pages: [UIView] = []
    private var currentPageIndex: Int = 0
    
    private enum PageDirection {
        case next
        case previous
    }
    
    /// The dogName that was entered by the user on dogNamePage. nil if the family already had a dog and the user wasn't allowed to input a dogName
    private var dogNameInput: String?
    /// The dogIcon that was entered by the user on dogIconPage. nil if user didn't input a dogIcon
    private var dogIconInput: UIImage?
    
    // MARK: Dog Manager
    
    private var dogManager: DogManager = DogManager.globalDogManager ?? DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    }
    
    // MARK: - HoundIntroductionDogNameViewDelegate
    
    func willContinue(forDogName dogName: String?) {
        // Store the entered dog name
        self.dogNameInput = dogName
        
        // Configure the dogIconPage for the next step
        let defaultName = dogManager.dogs.first?.dogName ?? ClassConstant.DogConstant.defaultDogName
        let nameToUse = dogName ?? defaultName
        dogIconPage?.setup(forDelegate: self, forDogName: nameToUse)
        
        // Advance the scroll view to the next page
        goToPage(forPageDirection: .next, forAnimated: true)
    }
    
    // MARK: - HoundIntroductionDogIconViewDelegate
    
    func willFinish(forDogIcon dogIcon: UIImage?) {
        self.dogIconInput = dogIcon
        
        // If the family already has at least one dog, simply update its icon
        if let existingDog = dogManager.dogs.first {
            existingDog.dogIcon = self.dogIconInput
            
            // Persist the new dog icon locally
            if let icon = existingDog.dogIcon {
                DogIconManager.addIcon(forDogUUID: existingDog.dogUUID, forDogIcon: icon)
            }
            
            // Manually present MainTabBarController
            let mainTabBarController = MainTabBarController()
            mainTabBarController.setDogManager(sender: Sender(origin: self, localized: self),
                                               forDogManager: dogManager)
            // TODO: Use custom present method if needed
            self.present(mainTabBarController, animated: true, completion: nil)
            
        } else {
            // No dogs exist yet: create a new Dog object and send request
            let newDog = (try? Dog(forDogName: dogNameInput ?? ClassConstant.DogConstant.defaultDogName))
            ?? Dog()
            newDog.dogIcon = dogIconInput
            
            PresentationManager.beginFetchingInformationIndicator()
            DogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDog: newDog) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndicator {
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    // Add the newly created dog to our local manager
                    self.dogManager.addDog(forDog: newDog)
                    
                    // Manually present MainTabBarController
                    let mainTabBarController = MainTabBarController()
                    mainTabBarController.setDogManager(sender: Sender(origin: self, localized: self),
                                                       forDogManager: self.dogManager)
                    // TODO: Use custom present method if needed
                    self.present(mainTabBarController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        // Prepare scrollView
        pages = []
        currentPageIndex = 0
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        
        // --- Dog Name Page ---
        let namePageFrame = CGRect(x: 0.0 * view.bounds.width,
                                   y: 0,
                                   width: view.bounds.width,
                                   height: view.bounds.height)
        dogNamePage = HoundIntroductionDogNameView(frame: namePageFrame)
        dogNamePage?.setup(forDelegate: self, forDogManager: dogManager)
        if let namePage = dogNamePage {
            scrollView.addSubview(namePage)
            pages.append(namePage)
        }
        
        // --- Dog Icon Page ---
        let iconPageFrame = CGRect(x: 1.0 * view.bounds.width,
                                   y: 0,
                                   width: view.bounds.width,
                                   height: view.bounds.height)
        dogIconPage = HoundIntroductionDogIconView(frame: iconPageFrame)
        // Defer setup until dogName is known
        if let iconPage = dogIconPage {
            scrollView.addSubview(iconPage)
            pages.append(iconPage)
        }
        
        // Set scrollView contentSize for two pages
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(pages.count),
                                        height: view.bounds.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Mark the introduction as completed locally
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
    }
    
    // MARK: - Functions
    
    private func goToPage(forPageDirection pageDirection: PageDirection, forAnimated animated: Bool) {
        let nextPageIndex = min(
            max(currentPageIndex + (pageDirection == .next ? 1 : -1), 0),
            pages.count - 1
        )
        currentPageIndex = nextPageIndex
        
        let contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(nextPageIndex),
                                    y: 0)
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(contentOffset, animated: animated)
        scrollView.isScrollEnabled = false
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(scrollView)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
