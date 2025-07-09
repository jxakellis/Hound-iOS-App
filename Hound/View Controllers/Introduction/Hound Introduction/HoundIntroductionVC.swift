//
//  HoundIntroductionVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntroductionVC: HoundViewController,
                                             UIScrollViewDelegate,
                                             HoundIntroductionDogNameViewDelegate,
                                             HoundIntroductionDogIconViewDelegate {
    
    // MARK: - Elements
    
    private let scrollView: HoundScrollView = {
        let scrollView = HoundScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private let dogNamePage: HoundIntroductionDogNameView = {
        let page = HoundIntroductionDogNameView(frame: .zero)
        return page
    }()
    
    private let dogIconPage: HoundIntroductionDogIconView = {
        let page = HoundIntroductionDogIconView(frame: .zero)
        return page
    }()
    
    // MARK: - Properties
    
    private var didSetupCustomSubviews: Bool = false
    private var pages: [UIView] { [dogNamePage, dogIconPage] }
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
        dogIconPage.setup(forDelegate: self, forDogName: nameToUse)
        
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
            PresentationManager.enqueueViewController(mainTabBarController)
            
        }
        else {
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
                    PresentationManager.enqueueViewController(mainTabBarController)
                }
            }
        }
    }
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        scrollView.delegate = self
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else { return }
        
        didSetupCustomSubviews = true
        
        dogNamePage.setup(forDelegate: self, forDogManager: dogManager)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Mark the introduction as completed locally
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
    }
    
    // MARK: - Functions
    
    private func goToPage(forPageDirection pageDirection: PageDirection, forAnimated animated: Bool) {
        let delta = (pageDirection == .next ? 1 : -1)
        let targetIndex = min(max(currentPageIndex + delta, 0), pages.count - 1)
        currentPageIndex = targetIndex
        
        let offset = CGPoint(
            x: scrollView.frame.width * CGFloat(targetIndex),
            y: 0
        )
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(offset, animated: animated)
        scrollView.isScrollEnabled = false
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        pages.forEach { scrollView.addSubview($0) }
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // scrollView
        let scrollViewTop = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        let scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let scrollViewLeading = scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let scrollViewTrailing = scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        // dogNamePage
        let dogNamePageTop = dogNamePage.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor)
        let dogNamePageBottom = dogNamePage.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        let dogNamePageLeading = dogNamePage.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)
        let dogNamePageWidth = dogNamePage.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        let dogNamePageHeight = dogNamePage.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)

        // dogIconPage
        let dogIconPageTop = dogIconPage.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor)
        let dogIconPageBottom = dogIconPage.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        let dogIconPageLeading = dogIconPage.leadingAnchor.constraint(equalTo: dogNamePage.trailingAnchor)
        let dogIconPageWidth = dogIconPage.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        let dogIconPageHeight = dogIconPage.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        let dogIconPageTrailing = dogIconPage.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)

        NSLayoutConstraint.activate([
            // scrollView
            scrollViewTop,
            scrollViewBottom,
            scrollViewLeading,
            scrollViewTrailing,

            // dogNamePage
            dogNamePageTop,
            dogNamePageBottom,
            dogNamePageLeading,
            dogNamePageWidth,
            dogNamePageHeight,

            // dogIconPage
            dogIconPageTop,
            dogIconPageBottom,
            dogIconPageLeading,
            dogIconPageWidth,
            dogIconPageHeight,
            dogIconPageTrailing
        ])
    }

}
