//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntroductionViewController: GeneralUIViewController, UIScrollViewDelegate, HoundIntroductionDogNameViewDelegate, HoundIntroductionDogIconViewDelegate {

    // MARK: - HoundIntroductionDogNameViewDelegate

    func willContinue(forDogName dogName: String?) {
        self.dogNameInput = dogName
        dogIconPage?.setup(forDelegate: self, forDogName: dogName ?? dogManager.dogs.first?.dogName ?? ClassConstant.DogConstant.defaultDogName)
        goToPage(forPageDirection: .next, forAnimated: true)
    }

    // MARK: - HoundIntroductionDogIconViewDelegate

    func willFinish(forDogIcon dogIcon: UIImage?) {
        self.dogIconInput = dogIcon

        // The family already has at least one dog
        if let dog = dogManager.dogs.first {
            dog.dogIcon = self.dogIconInput

            // Normally the DogIcon persistance is taken care of by DogsRequest. However, in this case we don't contact the server about the updating the dog so have to manually update the icon.
            if let dogIcon = dog.dogIcon {
                DogIconManager.addIcon(forDogId: dog.dogId, forDogIcon: dogIcon)
            }

            // close page because updated
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarController")
        }
        // The family doesn't have any dogs, we need to create one for the family
        else {
            let dog = (try? Dog(dogName: dogNameInput ?? ClassConstant.DogConstant.defaultDogName)) ?? Dog()
            // Set dogIcon before contacting the server. If the request is successful, DogsRequest will persist the icon.
            dog.dogIcon = dogIconInput

            PresentationManager.beginFetchingInformationIndictator()
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { requestWasSuccessful, _, _ in
                PresentationManager.endFetchingInformationIndictator {
                    guard requestWasSuccessful else {
                        return
                    }

                    self.dogManager.addDog(forDog: dog)
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarController")
                }
            }
        }

    }

    // MARK: - IB

    @IBOutlet private weak var scrollView: UIScrollView!

    // MARK: - Properties

    private var didSetupCustomSubviews: Bool = false

    // Pages for the scroll view
    private var pages: [UIView] = []
    private var dogNamePage: HoundIntroductionDogNameView?
    private var dogIconPage: HoundIntroductionDogIconView?
    private var currentPageIndex: Int = 0

    private enum PageDirection {
        case next
        case previous
    }

    /// The dogName that was entered by the user on dogNamePage. nil if the family already had a dog and the user wasn't allowed to input a dogName
    private var dogNameInput: String?
    /// The dogIcon that was entered by the user on dogIconPage. nil if user didn't input a dogIcon
    private var dogIconInput: UIImage?

    // MARK: - Dog Manager

    private var dogManager: DogManager = DogManager.globalDogManager ?? DogManager()

    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    }

    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard didSetupCustomSubviews == false else {
            return
        }

        didSetupCustomSubviews = true

        pages = []
        currentPageIndex = 0

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false

        dogNamePage = HoundIntroductionDogNameView(frame: CGRect(x: 0.0 * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        dogNamePage?.setup(forDelegate: self, forDogManager: dogManager)
        if let dogNamePage = dogNamePage {
            scrollView.addSubview(dogNamePage)
            pages.append(dogNamePage)
        }

        dogIconPage = HoundIntroductionDogIconView(frame: CGRect(x: 1.0 * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        // Wait to setup dogIcon page until dogNamePage continues and we have the dogName
        if let dogIconPage = dogIconPage {
            scrollView.addSubview(dogIconPage)
            pages.append(dogIconPage)
        }

        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(pages.count), height: view.bounds.height)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
    }

    // MARK: - Functions

    private func goToPage(forPageDirection pageDirection: PageDirection, forAnimated animated: Bool) {
        let nextPage: Int = min(
            currentPageIndex + (pageDirection == .next ? 1 : -1),
            pages.count - 1
        )

        let point = CGPoint(x: scrollView.frame.size.width * CGFloat(nextPage), y: 0)
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(point, animated: animated)
        scrollView.isScrollEnabled = false
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainTabBarController: MainTabBarController = segue.destination as? MainTabBarController {
            mainTabBarController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
    }
}
