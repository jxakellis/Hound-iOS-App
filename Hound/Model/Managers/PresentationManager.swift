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
import UIKit

final class PresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    /// Function invoked by presentedViewController when the presentation transitions have ended, i.e., the presentedViewController is dismissed
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed == self.presentedViewController else {
            return nil
        }
        
        self.presentedViewController?.transitioningDelegate = nil
        self.presentedViewController = nil
        self.presentNextViewController()
        return nil
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
        
        let height = 95.0
        let centerXAnchorOffset = 0.0
        let bottomAnchorOffset = -20.0
        
        let fetchingActivityIndicator = UIActivityIndicatorView(style: .medium)
        fetchingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        fetchingActivityIndicator.isUserInteractionEnabled = false
        fetchingActivityIndicator.startAnimating()
        fetchingInformationAlertController.view.addSubview(fetchingActivityIndicator)
        
        fetchingInformationAlertController.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        fetchingActivityIndicator.centerXAnchor.constraint(equalTo: fetchingInformationAlertController.view.centerXAnchor, constant: centerXAnchorOffset).isActive = true
        fetchingActivityIndicator.bottomAnchor.constraint(equalTo: fetchingInformationAlertController.view.bottomAnchor, constant: bottomAnchorOffset).isActive = true
    }
    
    // MARK: - Properties
    
    // MARK: static
    
    static private var shared = PresentationManager()
    
    // MARK: instance
    
    private var storedGlobalPresenter: UIViewController?
    /// Default sender used to present, this is necessary if an alert to be shown is called from a non UIAlertController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var globalPresenter: UIViewController? {
        get {
            return shared.storedGlobalPresenter
        }
        set (newGlobalPresenter) {
            shared.storedGlobalPresenter = newGlobalPresenter?.findHighestParent()
        }
    }
    
    /// The UIViewController that is presented by PresentationManager
    private var presentedViewController: UIViewController?
    
    /// UIAlertController that indicates to the user that the app is currently retrieving information.
    private let fetchingInformationAlertController = UIAlertController(title: "Fetching Information...", message: nil, preferredStyle: .alert)
    
    // MARK: - Static Public Enqueue
    
    /// Invokes enqueueAlert(shared.fetchingInformationAlertController). This indicates to the user that the app is currently retrieving information. fetchingInformationAlertController stays until endFetchingInformationIndictator is called
    static func beginFetchingInformationIndictator() {
        enqueueAlert(shared.fetchingInformationAlertController)
    }
    
    /// Dismisses fetchingInformationAlertController.
    static func endFetchingInformationIndictator(completionHandler: (() -> Void)?) {
        guard shared.fetchingInformationAlertController.isBeingDismissed == false else {
            // We can't dismiss a fetchingInformationAlertController that is already being dismissed
            completionHandler?()
            return
        }
        
        guard shared.fetchingInformationAlertController.presentingViewController != nil else {
            // fetchingInformationAlertController isn't being dismissed and it has no presentingViewController, so it is not presented at all.
            completionHandler?()
            return
        }
        
        shared.fetchingInformationAlertController.dismiss(animated: true) {
            completionHandler?()
        }
    }
    
    static func enqueueViewController(_ forViewController: UIViewController) {
        shared.enqueue(forViewController)
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
        let leftViewImage: UIImageView? = {
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
            return image == nil ? nil : UIImageView(image: image)
        }()
        
        leftViewImage?.translatesAutoresizingMaskIntoConstraints = false
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
            if let subtitle = subtitle, subtitle.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                // The average person reads at 300 WPM, that is 5 words per second
                // The average word in one of these subtitle messages is 6 characters (excluding white spaces)
                // That the average person can read 30 non-whitespace characters a second, or 1 character per 0.033 seconds
                let subtitleCharacters = subtitle.filter { character in
                    return character.isWhitespace == false
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
        
        print("banner for", PresentationManager.globalPresenter)
        print("modalPresentationStyle", PresentationManager.globalPresenter?.modalPresentationStyle.rawValue)
        print("parent", PresentationManager.globalPresenter?.parent)
        print("safeAreaInsets", PresentationManager.globalPresenter?.view.safeAreaInsets)
        banner.show(
            // using default queuePosition: ,
            // using default bannerPosition: ,
            // using default queue: ,
            on: PresentationManager.globalPresenter,
            // Case 1: View is a pageSheet or embedded. The banner has its topOffset compensated 30.0 for the notch, but these views don't touch the notch. We undo this offset
            // Case 2: View is not a pageSheet or embedded. Proceed as normal and add some extra offset
            edgeInsets: PresentationManager.globalPresenter?.modalPresentationStyle == .pageSheet || PresentationManager.globalPresenter?.parent != nil
            ? UIEdgeInsets(top: -15.0, left: 10.0, bottom: 10.0, right: 10.0)
            : UIEdgeInsets(top: 15.0, left: 10.0, bottom: 10.0, right: 10.0) ,
            cornerRadius: VisualConstant.LayerConstant.defaultCornerRadius,
            shadowColor: UIColor.black,
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
        
        shared.enqueue(forAlertController)
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
        
        shared.enqueue(forAlertController)
    }
    
    // MARK: - Private Internal Queue
    
    private var viewControllerPresentationQueue: [UIViewController] = []
    
    private func enqueue(_ forViewController: UIViewController) {
        // Make sure that the alertController that is being queued isn't already presented or in the queue
        guard presentedViewController != forViewController && viewControllerPresentationQueue.contains(forViewController) == false else {
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        guard let forAlarmAlertController = forViewController as? AlarmUIAlertController else {
            // Not dealing with an forAlarmAlertController, can append alertController to queue
            viewControllerPresentationQueue.append(forViewController)
            presentNextViewController()
            return
        }
        
        // User attempted to pass an AlarmUIAlertController that hasn't been setup and is therefore invalid
        guard forAlarmAlertController.dogId != nil && forAlarmAlertController.reminders != nil else {
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        // If we are dealing with an AlarmUIAlertController, then attempt to absorb it into the presentedViewController.
        if let presentedAlarmAlertController = (presentedViewController as? AlarmUIAlertController), presentedAlarmAlertController.absorb(forAlarmAlertController) {
            // presentedViewController is an AlarmUIAlertController and we were able to absorb forAlarmAlertController into it. Therefore, discard forAlarmAlertController.
            // Don't call presentNextViewController() as queue didn't change
            return
        }
        
        // forAlarmAlertController couldn't be absorbed into presentedViewController, therefore try absorbing it into other items in queue.
        for viewControllerInQueue in viewControllerPresentationQueue {
            guard let alarmAlertControllerInQueue = viewControllerInQueue as? AlarmUIAlertController else {
                // viewControllerInQueue isn't an AlarmUIAlertController and cannot absorb anything. or it is but wasn't able to be combined with forAlarmAlertController
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
    
    private func presentNextViewController() {
        // Check that PresentationManager itself is eligible to present another alert. This means the queue has another controller to present and there isn't a ViewController currently presented
        guard let nextPresentedViewController = viewControllerPresentationQueue.first, self.presentedViewController == nil else {
            return
        }
        
        // Check that the globalPresenter can present sometime currently. If not, enter a loop until it can. These temporary conditions normally resolve themselves.
        guard let globalPresenter = PresentationManager.globalPresenter,
        globalPresenter.isBeingPresented == false,
        globalPresenter.isBeingDismissed == false,
        globalPresenter.presentedViewController == nil,
        globalPresenter.isViewLoaded == true,
        globalPresenter.view.window != nil else {
            AppDelegate.generalLogger.info("Unable to presentNextViewController, trying again soon")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.presentNextViewController()
            }
            return
        }
        
        nextPresentedViewController.transitioningDelegate = self
        viewControllerPresentationQueue.removeFirst()
        self.presentedViewController = nextPresentedViewController
        
        globalPresenter.present(nextPresentedViewController, animated: true)
    }
}
