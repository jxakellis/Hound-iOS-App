/*

 The MIT License (MIT)
 Copyright (c) 2017-2018 Dalton Hinterscher

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

import UIKit

@objc
public enum QueuePosition: Int {
    case back
    case front
}

@objcMembers
open class NotificationBannerQueue: NSObject {

    /// The default instance of the NotificationBannerQueue
    public static let `default` = NotificationBannerQueue()

    /// The notification banners currently placed on the queue
    private(set) var banners: [BaseNotificationBanner] = []

    /// The notification banners currently placed on the queue
    private(set) var maxBannersOnScreenSimultaneously: Int = 1

    /// The current number of notification banners on the queue
    public var numberOfBanners: Int {
        return banners.count
    }

    public init(maxBannersOnScreenSimultaneously: Int = 1) {
        self.maxBannersOnScreenSimultaneously = maxBannersOnScreenSimultaneously
    }

    /**
        Adds a banner to the queue
        -parameter banner: The notification banner to add to the queue
        -parameter queuePosition: The position to show the notification banner. If the position is .front, the
        banner will be displayed immediately
    */
    func addBanner(
        _ banner: BaseNotificationBanner,
        bannerPosition: BannerPosition,
        queuePosition: QueuePosition
    ) {
        
        // If the banners queue contains an existing banner with the same title and subtitle as banner that is attempting to be added, we do not add that new banner. If we did, that would mean we would end up displaying 2+ banners with the same content
        guard banners.contains(where: { existingBanner in
            // First make sure title labels are equal before trying to compare subtitles. If title labels aren't equal then the banners can't contain the same content, so return false
            guard banner.titleLabel?.text == existingBanner.titleLabel?.text else {
                return false
            }
            
            let bannerSubtitle: String? = {
                if let banner = banner as? GrowingNotificationBanner {
                    return banner.subtitleLabel?.text
                }
                else if let banner = banner as? FloatingNotificationBanner {
                    return banner.subtitleLabel?.text
                }
                else {
                    return nil
                }
            }()
            
            let existingBannerSubtitle: String? = {
                if let existingBanner = existingBanner as? GrowingNotificationBanner {
                    return existingBanner.subtitleLabel?.text
                }
                else if let existingBanner = existingBanner as? FloatingNotificationBanner {
                    return existingBanner.subtitleLabel?.text
                }
                else {
                    return nil
                }
            }()
            
            // The title labels are verified as the same, therefore, now check if the subtitles are the same. If they are the same, then the two labels contain the same content
            return bannerSubtitle == existingBannerSubtitle
        }) == false else {
            return
        }

        if queuePosition == .back {
            banners.append(banner)

            let bannersCount =  banners.filter { $0.isDisplaying }.count
            if bannersCount < maxBannersOnScreenSimultaneously {
                banner.show(placeOnQueue: false, bannerPosition: banner.bannerPosition)
            }

        } else {
            banner.show(placeOnQueue: false, bannerPosition: bannerPosition)

            if let firstBanner = firstNotDisplayedBanner() {
                firstBanner.suspend()
            }

            banners.insert(banner, at: 0)
        }

    }

    /**
        Removes a banner from the queue
        -parameter banner: A notification banner to remove from the queue.
     */
    func removeBanner(_ banner: BaseNotificationBanner) {

        if let index = banners.firstIndex(of: banner) {
            banners.remove(at: index)
        }

        banners.forEach {
            $0.updateBannerPositionFrames()
            if $0.isDisplaying {
                $0.animateUpdatedBannerPositionFrames()
            }
        }
    }

    /**
        Shows the next notificaiton banner on the queue if one exists
        -parameter callback: The closure to execute after a banner is shown or when the queue is empty
    */
    func showNext(callback: ((_ isEmpty: Bool) -> Void)) {

        if let banner = firstNotDisplayedBanner() {

            if banner.isSuspended {
                banner.resume()
            } else {
                banner.show(placeOnQueue: false, bannerPosition: banner.bannerPosition)
            }

            callback(false)
        }
        else {
            callback(true)
            return
        }
    }

    func firstNotDisplayedBanner() -> BaseNotificationBanner? {
        return banners.filter { !$0.isDisplaying }.first
    }

    /**
        Removes all notification banners from the queue
    */
    public func removeAll() {
        banners.removeAll()
    }

    /**
     Forced dissmiss all notification banners from the queue
     */
    public func dismissAllForced() {
        banners.forEach { $0.dismiss(forced: true) }
        banners.removeAll()
    }

}

