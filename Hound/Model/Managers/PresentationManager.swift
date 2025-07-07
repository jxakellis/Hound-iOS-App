//
//  PresentationManager.swift
//  viewControllerPresentationQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import NotificationBannerSwift
import SwiftMessages
import UIKit

enum PresentationManager {
    
    // MARK: - Properties
    
    /// A stack of UIViewControllers that represent the globalPresenter. If a UIViewController becomes eligible to present something, it pushes itself onto the stack. If it becomes ineligible, it removes itself from the stack.
    private static var globalPresenterStack: [UIViewController] = []
    static var lastFromGlobalPresenterStack: UIViewController? {
        return globalPresenterStack.last
    }
    
    /// The UIViewController that is presented by PresentationManager
    private static var currentPresentedViewController: UIViewController? {
        didSet {
            HoundLogger.general.notice("Current Presented ViewController is now \(self.currentPresentedViewController?.self.description ?? "none") and its presented on \(lastFromGlobalPresenterStack?.description ?? "none")")
            HoundLogger.general.notice("The globalPresenterStack is \(globalPresenterStack)")
        }
    }
    
    /// UIAlertController that indicates to the user that the app is currently retrieving information.
    private static let fetchingInformationAlertController: UIAlertController = {
        let fetchingInformationAlertController = UIAlertController(title: "Fetching Information...", message: nil, preferredStyle: .alert)
        fetchingInformationAlertController.view.translatesAutoresizingMaskIntoConstraints = false
       
        let fetchingActivityIndicator = UIActivityIndicatorView(style: .medium)
        fetchingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        fetchingActivityIndicator.startAnimating()
        
        fetchingInformationAlertController.view.addSubview(fetchingActivityIndicator)
        
        NSLayoutConstraint.activate([
            fetchingInformationAlertController.view.heightAnchor.constraint(equalToConstant: 90),
            fetchingActivityIndicator.bottomAnchor.constraint(equalTo: fetchingInformationAlertController.view.bottomAnchor, constant: -20),
            fetchingActivityIndicator.centerXAnchor.constraint(equalTo: fetchingInformationAlertController.view.centerXAnchor)
        ])
        
        return fetchingInformationAlertController
    }()
    
    // MARK: Public Global Presenter Management
    
    /// The presenter used for an alert. Sometimes we need to present an alert but the alert to be shown is called from a non UIAlertController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static func addGlobalPresenterToStack(_ forViewController: UIViewController) {
        globalPresenterStack.removeAll { viewController in
            // Make sure the same instance isn't in our stack twice
            return viewController === forViewController
        }
        
        globalPresenterStack.append(forViewController)
        
        if let currentPresentedViewController = currentPresentedViewController, globalPresenterStack.contains(currentPresentedViewController) {
            // This fixes a logical anomoily. If a view controller is presented using PresentationManager, it will become the currentPresentedViewController. This is how we normally treated presented views. However, if this currentPresentedViewController is in the globalPresenterStack, it means it is able to present views itself and is eligible. Therefore, we should unlock the presentation stack by removing it as a currentPresentedViewController and continuing to the next item in the stack.
            self.currentPresentedViewController = nil
            presentNextViewController()
        }
    }
    
    static func removeGlobalPresenterFromStack(_ forViewController: UIViewController) {
        globalPresenterStack.removeAll { viewController in
            // Remove all matching instances of our global presenter
            return viewController === forViewController
        }
    }
    
    // MARK: - Static Public Enqueue
    
    /// Invokes enqueueAlert(fetchingInformationAlertController). This indicates to the user that the app is currently retrieving information. fetchingInformationAlertController stays until endFetchingInformationIndicator is called
    static func beginFetchingInformationIndicator() {
        enqueueAlert(fetchingInformationAlertController)
    }
    
    /// Dismisses fetchingInformationAlertController.
    static func endFetchingInformationIndicator(completionHandler: (() -> Void)?) {
        guard fetchingInformationAlertController.isBeingDismissed == false else {
            // We can't dismiss a fetchingInformationAlertController that is already being dismissed. Retry soon, so that completionHandler is invoked when fetchingInformationAlertController is fully dismissed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                endFetchingInformationIndicator(completionHandler: completionHandler)
            }
            return
        }
        
        guard fetchingInformationAlertController.isBeingPresented == false else {
            // We can't dismiss a fetchingInformationAlertController that is already being presented currently. Retry soon, so that we can dismiss the view onces its presented
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                endFetchingInformationIndicator(completionHandler: completionHandler)
            }
            return
        }
        
        guard fetchingInformationAlertController.presentingViewController != nil else {
            // fetchingInformationAlertController isn't being dismissed and it has no presentingViewController, so it is not presented at all.
            viewControllerPresentationQueue.removeAll { viewController in
                // fetchingInformationAlertController hasn't been presented but it could be in the queue to be presented. Remove it so it can't be presented
                return viewController === fetchingInformationAlertController
            }
            completionHandler?()
            return
        }
        
        fetchingInformationAlertController.dismiss(animated: true) {
            completionHandler?()
        }
    }
    
    static func enqueueViewController(_ forViewController: UIViewController) {
        enqueue(forViewController)
    }
    
    static func enqueueBanner(forTitle title: String, forSubtitle subtitle: String?, forStyle: BannerStyle, onTap: (() -> Void)? = nil) {
        // Reduce the availble styles into a smaller 3 tier group
        // Success
        // Info
        // Danger
        let style: BannerStyle = {
            switch forStyle {
            case .success:
                return .success
            case .info:
                return .info
            case .danger:
                return .danger
            default:
                return .success
            }
        }()
        
        // Create a left view image that corresponds to the style selected
        let leftViewImage: HoundImageView? = {
            var image: UIImage?
            switch style {
            case .success:
                image = UIImage.init(systemName: "checkmark.circle")
            case .info:
                image = UIImage.init(systemName: "info.circle")
            case .danger:
                image = UIImage.init(systemName: "exclamationmark.triangle")
            default:
                image = UIImage.init(systemName: "exclamationmark.triangle")
            }
            
            return image == nil ? nil : HoundImageView(image: image)
        }()
        
        leftViewImage?.tintColor = .white
        
        let banner = FloatingNotificationBanner(title: title, subtitle: subtitle, leftView: leftViewImage, style: style)
        banner.contentMode = .scaleAspectFit
        banner.onTap = onTap
        
        // Select a haptic feedback that corresponds to the style. A more important style requires a heavier haptic
        banner.haptic = {
            switch style {
            case .success:
                return .light
            case .info:
                return .medium
            case .danger:
                return .heavy
            default:
                return .light
            }
        }()
        
        // Select a banner duration that corresponds to the style. A more important style requires a longer duration
        banner.duration = {
            // This is the duration for a title-only banner
            let successDuration = 1.25
            var bannerDuration = successDuration
            switch style {
            case .success:
                bannerDuration = successDuration
            case .info:
                bannerDuration = 4.5
            case .danger:
                bannerDuration = 2.25
            default:
                bannerDuration = successDuration
            }
            
            // If a non-nil and non-blank subtitle was provided, give the user extra reading time
            if let subtitle = subtitle, subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                // The average person reads at 300 WPM, that is 5 words per second
                // The average word in one of these subtitle messages is 6 characters (excluding white spaces)
                // That the average person can read 30 non-whitespace characters a second, or 1 character per 0.033 seconds
                let subtitleCharacters = subtitle.filter { character in
                    character.isWhitespace == false
                }
                let extraSubtitleReadingTime = Double(subtitleCharacters.count) * 0.032
                
                bannerDuration += extraSubtitleReadingTime
            }
            return bannerDuration
        }()
        
        // Select a banner color that corresponds to the style
        banner.backgroundColor = {
            switch style {
            case .success:
                return .systemGreen
            case .info:
                return .systemBlue
            case .danger:
                return .systemRed
            default:
                return .systemGreen
            }
        }()
        
        banner.haptic = {
            switch style {
            case .success:
                return .medium
            case .info:
                return .light
            case .danger:
                return .heavy
            default:
                return .medium
            }
        }()
        
        guard let globalPresenter = PresentationManager.globalPresenterStack.last else {
            HoundLogger.general.error("Unable to present banner, globalPresenterStack is empty")
            return
        }
        
        banner.show(
            // using default queuePosition: ,
            // using default bannerPosition: ,
            // using default queue: ,
            on: globalPresenter,
            // safeAreaInsets of globalPresenter could be flawed, e.g. if the globalPresenter is a pageSheet, then the safeAreaInsets will be zero. Try to find the safeAreaInsets of the entire window if possible, if not fall back to nearestNonPageSheetGlobalPresenter or eventually just accept the globalPresenter
            // If the globalPresenter's top safeAreaInset is not zero, that mean we have to adjust the banner for the safe area for the notch on the top of the screen. This means we need to artifically adjust the banner further down.
            edgeInsets: UIEdgeInsets(top: globalPresenter.view.safeAreaInsets.top, left: 10.0, bottom: 10.0, right: 10.0),
            cornerRadius: VisualConstant.LayerConstant.defaultCornerRadius,
            shadowColor: UIColor.label,
            shadowOpacity: 0.5,
            shadowBlurRadius: 15.0,
            // little/no effect shadowCornerRadius: 10.0,
            // using default shadowOffset: ,
            shadowEdgeInsets: .zero
        )
    }
    
    static func enqueueAlert(_ forAlertController: UIAlertController) {
        // We are unable to change .preferredStyle and if its not .alert (and we queue the alert) then we could crash
        guard forAlertController.preferredStyle == .alert else {
            return
        }
        
        enqueue(forAlertController)
    }
    
    static func enqueueActionSheet(_ forAlertController: UIAlertController, sourceView: UIView) {
        // We are unable to change .preferredStyle and if its not .actionSheet (and we queue the alert) then we could crash
        guard forAlertController.preferredStyle == .actionSheet else {
            return
        }
        
        // This is needed for iPad, otherwise it will crash
        if UIDevice.current.userInterfaceIdiom == .pad {
            forAlertController.popoverPresentationController?.sourceView = sourceView
            forAlertController.popoverPresentationController?.sourceRect = sourceView.bounds
            forAlertController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        
        enqueue(forAlertController)
    }
    
    // MARK: - Private Internal Queue

    private static var viewControllerPresentationQueue: [UIViewController] = []
    
    private static func enqueue(_ forViewController: UIViewController) {
        // Make sure that the alertController that is being queued isn't already presented or in the queue
        guard currentPresentedViewController !== forViewController && viewControllerPresentationQueue.contains(where: { viewController in
            return viewController === forViewController
        }) == false else {
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        guard let forAlarmAlertController = forViewController as? HoundAlarmAlertController else {
            // Not dealing with an forAlarmAlertController, can append alertController to queue
            viewControllerPresentationQueue.append(forViewController)
            presentNextViewController()
            return
        }
        
        // User attempted to pass an HoundAlarmAlertController that hasn't been setup and is therefore invalid
        guard forAlarmAlertController.dogUUID != nil && forAlarmAlertController.reminders != nil else {
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        // If we are dealing with an HoundAlarmAlertController, then attempt to absorb it into the currentPresentedViewController.
        if let presentedAlarmAlertController = (currentPresentedViewController as? HoundAlarmAlertController), presentedAlarmAlertController.absorb(forAlarmAlertController) {
            // currentPresentedViewController is an HoundAlarmAlertController and we were able to absorb forAlarmAlertController into it. Therefore, discard forAlarmAlertController.
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        // forAlarmAlertController couldn't be absorbed into currentPresentedViewController, therefore try absorbing it into other items in queue.
        for viewControllerInQueue in viewControllerPresentationQueue {
            guard let alarmAlertControllerInQueue = viewControllerInQueue as? HoundAlarmAlertController else {
                // viewControllerInQueue isn't an HoundAlarmAlertController and cannot absorb anything. or it is but wasn't able to be combined with forAlarmAlertController
                continue
            }
            
            guard alarmAlertControllerInQueue.absorb(forAlarmAlertController) else {
                // alarmAlertControllerInQueue wasn't able to absorb forAlarmAlertController
                continue
            }
            
            // alarmAlertControllerInQueue was able to successfully absorb forAlarmAlertController. Discard forAlarmAlertController
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        // Couldn't absorb forAlarmAlertController with any pre-existing ViewController, therefore append it to queue
        viewControllerPresentationQueue.append(forAlarmAlertController)
        presentNextViewController()
    }
    
    private static func presentNextViewController() {
        // Check that PresentationManager itself is eligible to present another alert. This means the queue has another controller to present and there isn't a ViewController currently presented
        guard let nextPresentedViewController = viewControllerPresentationQueue.first, self.currentPresentedViewController == nil else {
            return
        }
        
        // Check that the globalPresenter can present sometime currently. If not, enter a loop until it can. These temporary conditions normally resolve themselves.
        guard let globalPresenter = PresentationManager.globalPresenterStack.last,
              globalPresenter.isBeingPresented == false,
              globalPresenter.isBeingDismissed == false,
              globalPresenter.presentedViewController == nil,
              globalPresenter.viewIfLoaded?.window != nil else {
            
            HoundLogger.general.debug("\nUnable to presentNextViewController, trying again soon")
            HoundLogger.general.debug("globalPresenter \(PresentationManager.globalPresenterStack.last.debugDescription)")
            HoundLogger.general.debug("globalPresenter.isBeingPresented \(PresentationManager.globalPresenterStack.last?.isBeingPresented == true)")
            HoundLogger.general.debug("globalPresenter.isBeingDismissed \(PresentationManager.globalPresenterStack.last?.isBeingDismissed == true)")
            HoundLogger.general.debug("globalPresenter.presentedViewController \(PresentationManager.globalPresenterStack.last?.presentedViewController.debugDescription ?? "")")
            HoundLogger.general.debug("globalPresenter.viewIfLoaded.window \(PresentationManager.globalPresenterStack.last?.viewIfLoaded?.window.debugDescription ?? "")\n")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.presentNextViewController()
            }
            return
        }
        
        viewControllerPresentationQueue.removeFirst()
        self.currentPresentedViewController = nextPresentedViewController
        
        globalPresenter.present(nextPresentedViewController, animated: true)
        
        self.observeCurrentPresentedViewControllerIsBeingDismissed(previousIsBeingDismissed: nextPresentedViewController.isBeingDismissed)
    }
    
    /// currentPresentedViewController.isBeingDismissed is not KVO compliant. Therefore, we must perform a loop that continuously checks the property. Once the previousIsBeingDismissed is true and the current is false, we know the view has completed
    private static func observeCurrentPresentedViewControllerIsBeingDismissed(previousIsBeingDismissed: Bool) {
        guard let currentPresentedViewController = currentPresentedViewController else {
            return
        }
        
        let currentIsBeingDismissed = currentPresentedViewController.isBeingDismissed
        
        guard currentPresentedViewController.isBeingPresented == false else {
            // If currentPresentedViewController is still in the process of being presented, we cannot analyze it to see if its being dismissed,
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.observeCurrentPresentedViewControllerIsBeingDismissed(previousIsBeingDismissed: currentIsBeingDismissed)
            }
            return
        }
        
        guard previousIsBeingDismissed == true && currentIsBeingDismissed == false else {
            // The currentPresentedViewController has not been dismissed. Keep rechecking until it has been.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.observeCurrentPresentedViewControllerIsBeingDismissed(previousIsBeingDismissed: currentIsBeingDismissed)
            }
            return
        }
        
        // If currentPresentedViewController was being dismissed and now its not (indicating it was dismissed), then it is no longer the currentPresentedViewController
        // If currentPresentedViewController has no presentingViewController (indicating it was never presented), then it is no longer the currentPresentedViewController
        
        // If there are any copies of the dismissed VC in the queue, remove them
        viewControllerPresentationQueue.removeAll { viewController in
            return self.currentPresentedViewController === viewController
        }
        
        self.currentPresentedViewController = nil
        presentNextViewController()
    }
}
