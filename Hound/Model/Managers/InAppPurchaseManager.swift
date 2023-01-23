//
//  InAppPurchaseManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import KeychainSwift
import StoreKit

// This main class provides a streamlined way to perform the main two queries
final class InAppPurchaseManager {
    
    /// Initalized InternalInAppPurchaseManager.shared. This creates the InternalInAppPurchaseManager() object, and this in turn sets that object as a observer for the PaymentQueue and as a observer for the price increase consent
    static func initalizeInAppPurchaseManager() {
        _ = InternalInAppPurchaseManager.shared
    }
    
    /// When you increase the price of a subscription, the system asks your delegate’s function paymentQueueShouldShowPriceConsent() whether to immediately display the price consent sheet, or to delay displaying the sheet until later. For example, you may want to delay showing the sheet if it would interrupt a multistep user interaction, such as setting up a user account. Return false in paymentQueueShouldShowPriceConsent() to prevent the dialog from displaying immediately. To show the price consent sheet after a delay, call showPriceConsentIfNeeded(), which shows the sheet only if the user hasn’t responded to the price increase notifications.
    static func showPriceConsentIfNeeded() {
        InternalInAppPurchaseManager.shared.showPriceConsentIfNeeded()
    }
    
    /// Attempts to show the App Store manage subscriptions page. If an error occurs with that, then opens the apple.com manage subscritpions page
    static func showManageSubscriptions() {
        guard let windowScene = UIApplication.keyWindow?.windowScene else {
            guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                return
            }
            UIApplication.shared.open(url)
            return
        }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene)
            }
            catch {
                guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                    return
                }
                _ = await UIApplication.shared.open(url)
            }
        }
    }
    
    /// Query apple servers to retrieve all available products. If there is an error, ErrorManager is automatically invoked and nil is returned.
    static func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        InternalInAppPurchaseManager.shared.fetchProducts { products in
            completionHandler(products)
        }
    }
    
    /// Query apple servers to purchase a certain product. If successful, then queries Hound servers to have transaction verified and applied. If there is an error, ErrorManager is automatically invoked and nil is returned.
    static func purchaseProduct(forProduct product: SKProduct, completionHandler: @escaping (String?) -> Void) {
        InternalInAppPurchaseManager.shared.purchase(forProduct: product) { productIdentifier in
            completionHandler(productIdentifier)
        }
    }
    
    static func restorePurchases(completionHandler: @escaping (Bool) -> Void) {
        InternalInAppPurchaseManager.shared.restorePurchases { bool in
            completionHandler(bool)
        }
    }
}

// Handles the important code of InAppPurchases with Apple server communication. Segmented from main class to reduce clutter
private final class InternalInAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKPaymentQueueDelegate {
    
    // MARK: - Properties
    
    static let shared = InternalInAppPurchaseManager()
    
    /// Keeps track of if the system is asyncronously, in the background, updating the transaction records on the hound server. This can occur if there is a subscription renewal which gets added to the paymentQueue.
    var backgroundPurchaseInProgress: Bool = false
    
    override init() {
        super.init()
        // Observe Price Increase Consent
        SKPaymentQueue.default().delegate = self
        // Observe Pending Transactions
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Consent To Subscription Price Increase
    
    func paymentQueueShouldShowPriceConsent(_ paymentQueue: SKPaymentQueue) -> Bool {
        // Check to make sure that mainTabBarViewController exists and is loaded.
        guard MainTabBarViewController.mainTabBarViewController != nil else {
            // The mainTabBarViewController doesn't exist yet and/or isn't loaded. Therefore we should defer until its loaded. mainTabBarViewController will call showPriceConsentIfNeeded once it loads and take care of the deferrment
            return false
        }
        
        // mainTabBarViewController exists and is loaded, so lets show the price consent
        return true
    }
    
    /// When you increase the price of a subscription, the system asks your delegate’s function paymentQueueShouldShowPriceConsent() whether to immediately display the price consent sheet, or to delay displaying the sheet until later. For example, you may want to delay showing the sheet if it would interrupt a multistep user interaction, such as setting up a user account. Return false in paymentQueueShouldShowPriceConsent() to prevent the dialog from displaying immediately. To show the price consent sheet after a delay, call showPriceConsentIfNeeded(), which shows the sheet only if the user hasn’t responded to the price increase notifications.
    func showPriceConsentIfNeeded() {
        SKPaymentQueue.default().showPriceConsentIfNeeded()
    }
    
    // MARK: - Fetch Products
    
    /// Keep track of the current request completionHandler
    private var productsRequestCompletionHandler: (([SKProduct]?) -> Void)?
    
    func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        
        guard productsRequestCompletionHandler == nil else {
            // If another request is initated while there is currently an on going request, we want to reject that request
            ErrorConstant.InAppPurchaseError.productRequestInProgress.alert()
            completionHandler(nil)
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(SubscriptionGroup20965379Product.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
        productsRequestCompletionHandler = completionHandler
    }
    
    /// Get available products from Apple Servers
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products.sorted(by: { unknownProduct1, unknownProduct2 in
            // The product with a product identifier that is closer to index 0 of the InAppPurchase enum allCases should come first. If a product identifier is unknown, the known one comes first. If both product identiifers are known, we have the <= productIdentifer come first.
            
            let product1 = SubscriptionGroup20965379Product(rawValue: unknownProduct1.productIdentifier)
            let product2 = SubscriptionGroup20965379Product(rawValue: unknownProduct2.productIdentifier)
            
            if product1 == nil && product2 == nil {
                // the product identifiers aren't known to us. Therefore we should sort based upon the product identifier strings themselves
                return unknownProduct1.productIdentifier <= unknownProduct2.productIdentifier
            }
            
            // at least one of them isn't nil
            guard let product1 = product1 else {
                // since product1 isn't known and therefore product2 is known, product2 should come first
                return false
            }
            
            guard let product2 = product2 else {
                // since product1 is known and product2 isn't, product1 should come first
                return true
            }
            
            guard let indexOfProduct1: Int = SubscriptionGroup20965379Product.allCases.firstIndex(of: product1), let indexOfProduct2: Int = SubscriptionGroup20965379Product.allCases.firstIndex(of: product2) else {
                // if we can't find their indexes, compare them based off their productIdentifiers
                return unknownProduct1.productIdentifier <= unknownProduct2.productIdentifier
            }
            
            // the product with product identifier that has the lower index in .allCases of the InAppPurchase enum comes first
            return indexOfProduct1 <= indexOfProduct2
            })
        
        DispatchQueue.main.async {
            // If we didn't retrieve any products, return an error
            if products.count >= 1 {
                self.productsRequestCompletionHandler?(products)
                
                // Send the updated products to the SettingsSubscriptionViewController. Only include products that have a subscription component
                SettingsSubscriptionViewController.subscriptionProducts = products.filter({ product in
                    return product.subscriptionPeriod != nil
                })
            }
            else {
                if self.productsRequestCompletionHandler != nil {
                    ErrorConstant.InAppPurchaseError.productRequestNotFound.alert()
                }
                self.productsRequestCompletionHandler?(nil)
            }
            // Call everything on async thread. Otherwise, productsRequestCompletionHandler will be set to nil slightly before productsRequestCompletionHandler(result, result) can be called, therefore not calling the completionHandler.
            self.productsRequestCompletionHandler = nil
        }
    }
    
    /// Observe if there was an error when retrieving the products
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            if self.productsRequestCompletionHandler != nil {
                ErrorConstant.InAppPurchaseError.productRequestFailed.alert()
            }
            self.productsRequestCompletionHandler?(nil)
            self.productsRequestCompletionHandler = nil
        }
    }
    
    // MARK: - Purchase a Product
    
    private var productPurchaseCompletionHandler: ((String?) -> Void)?
    
    // Prompt a product payment transaction
    func purchase(forProduct product: SKProduct, completionHandler: @escaping ((String?) -> Void)) {
        // Make sure the user has the Hound permissions to perform such a request
        guard FamilyInformation.isUserFamilyHead else {
            ErrorConstant.InAppPurchaseError.purchasePermission.alert()
            completionHandler(nil)
            return
        }
        
        // Make sure that the user has the correct Apple permissions to perform such a request
        guard SKPaymentQueue.canMakePayments() else {
            ErrorConstant.InAppPurchaseError.purchaseRestricted.alert()
            completionHandler(nil)
            return
        }
        
        // Make sure there isn't a purchase transaction in process
        guard productPurchaseCompletionHandler == nil else {
            ErrorConstant.InAppPurchaseError.purchaseInProgress.alert()
            completionHandler(nil)
            return
        }
        
        // Make sure there isn't a restore request in process
        guard InternalInAppPurchaseManager.shared.productRestoreCompletionHandler == nil else {
            ErrorConstant.InAppPurchaseError.restoreInProgress.alert()
            completionHandler(nil)
            return
        }
        
        // Make sure the system isn't doing anything async in the background
        guard backgroundPurchaseInProgress == false else {
            ErrorConstant.InAppPurchaseError.backgroundPurchaseInProgress.alert()
            completionHandler(nil)
            return
        }
        
        // Don't test for SKPaymentQueue.default().transactions. This could lock the code from ever executing. E.g. the user goes to buy something (so its in the payment queue) but they stop mid way (maybe leaving the transaction as .purchasing or .deferred). Then the background async processing isn't invoked to start (or it simply can't process whats in the queue) so we are left with transactions in the queue that are stuck and are locking
        productPurchaseCompletionHandler = completionHandler
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = UserInformation.userApplicationUsername
        SKPaymentQueue.default().add(payment)
    }
    
    // Observe a transaction state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // Only the family head can perform in-app purchases. This guard statement is here to stop background purchases from attempting to process. They will always fail if the user isn't the family head so no reason to even attempt them.
        guard FamilyInformation.isUserFamilyHead else {
            return
        }
        
        // If either of these are nil, there is not an ongoing manual request by a user (as there is no callback to provide information to). Therefore, we are dealing with asyncronously bought transactions (e.g. renewals, phone died while purchasing, etc.) that should be processed in the background.
        guard productPurchaseCompletionHandler != nil || productRestoreCompletionHandler != nil else {
            backgroundPurchaseInProgress = true
            
            // These are transactions that we know have completely failed. Clear them.
            let failedTransactionsInQueue = transactions.filter { transaction in
                return transaction.transactionState == .failed
            }
            
            failedTransactionsInQueue.forEach { failedTransaction in
                SKPaymentQueue.default().finishTransaction(failedTransaction)
            }
            
            // These are transactions that we know have completely succeeded. Process and clear them.
            let completedTransactionsInQueue = transactions.filter { transaction in
                return transaction.transactionState == .purchased || transaction.transactionState == .restored
            }
            
            // If we have succeeded transactions, silently contact the server in the background to let it know
            guard completedTransactionsInQueue.count >= 1 else {
                backgroundPurchaseInProgress = false
                return
            }
            
            SubscriptionRequest.create(invokeErrorManager: false) { requestWasSuccessful, _ in
                self.backgroundPurchaseInProgress = false
                guard requestWasSuccessful else {
                    return
                }
                
                // If successful, then we know ALL of the completed transactions in queue have been updated
                completedTransactionsInQueue.forEach { completedTransaction in
                    SKPaymentQueue.default().finishTransaction(completedTransaction)
                }
                
                // If the subscriptions page is loaded and onscreen, then we reload it
                if let settingsSubscriptionViewController = MainTabBarViewController.mainTabBarViewController?.settingsViewController?.settingsSubscriptionViewController, settingsSubscriptionViewController..viewIfLoaded?.window != nil {
                    settingsSubscriptionViewController.willRefreshAfterTransactionsSyncronizedInBackground()
                }
            }
            return
        }
        
        // Check if the user is attempting to purchase a product
        guard let productPurchaseCompletionHandler = productPurchaseCompletionHandler else {
            // User is restoring a transaction
            guard let productRestoreCompletionHandler = productRestoreCompletionHandler else {
                return
            }
            
            let restoredTransactionsInQueue = transactions.filter { transaction in
                return transaction.transactionState == .restored
            }
            
            // If we have restored transactions, contact the server to let it know
            guard restoredTransactionsInQueue.count >= 1 else {
                productRestoreCompletionHandler(false)
                self.productRestoreCompletionHandler = nil
                return
            }
            
            SubscriptionRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    productRestoreCompletionHandler(false)
                    self.productRestoreCompletionHandler = nil
                    return
                }
                
                // If successful, then we know ALL of the completed transactions in queue have been updated
                restoredTransactionsInQueue.forEach { restoredTransaction in
                    SKPaymentQueue.default().finishTransaction(restoredTransaction)
                }
                
                productRestoreCompletionHandler(true)
                self.productRestoreCompletionHandler = nil
            }
            return
        }
        
        // User is purchasing a product
        
        for transaction in transactions {
            // We use the main thread so completion handler is on main thread
            DispatchQueue.main.async {
                switch transaction.transactionState {
                case .purchasing:
                    // A transaction that is being processed by the App Store.
                    
                    //  Don't finish transaction, it is still in a processing state
                    break
                case .purchased:
                    // A successfully processed transaction.
                    // Your application should provide the content the user purchased.
                    // Write to the keychain if user has made a purchase
                    let keychain = KeychainSwift()
                    if SubscriptionGroup20965379Product(rawValue: transaction.payment.productIdentifier) != nil {
                        keychain.set(true, forKey: KeyConstant.userPurchasedProductFromSubscriptionGroup20965379.rawValue)
                        
                        if transaction.payment.paymentDiscount != nil {
                            keychain.set(true, forKey: KeyConstant.userPurchasedProductFromSubscriptionGroup20965379WithPaymentDiscount.rawValue)
                        }
                    }
                    keychain.set(true, forKey: KeyConstant.userPurchasedProduct.rawValue)
                    
                    SubscriptionRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            productPurchaseCompletionHandler(nil)
                            self.productPurchaseCompletionHandler = nil
                            return
                        }
                        
                        productPurchaseCompletionHandler(transaction.payment.productIdentifier)
                        self.productPurchaseCompletionHandler = nil
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .failed:
                    // A failed transaction.
                    // Check the error property to determine what happened.
                    
                    ErrorConstant.InAppPurchaseError.purchaseFailed.alert()
                    productPurchaseCompletionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .restored:
                    // if we have a productPurchaseCompletionHandler, then we lock the transaction queue from other things from interfering
                    // A transaction that restores content previously purchased by the user.
                    // Read the original property to obtain information about the original purchase.
                    
                    SubscriptionRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            productPurchaseCompletionHandler(nil)
                            self.productPurchaseCompletionHandler = nil
                            return
                        }
                        
                        productPurchaseCompletionHandler(transaction.payment.productIdentifier)
                        self.productPurchaseCompletionHandler = nil
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .deferred:
                    // A transaction that is in the queue, but its final status is pending external action such as Ask to Buy
                    // Update your UI to show the deferred state, and wait for another callback that indicates the final status.
                    
                    ErrorConstant.InAppPurchaseError.purchaseDeferred.alert()
                    productPurchaseCompletionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    //  Don't finish transaction, it is still in a processing state
                @unknown default:
                    ErrorConstant.InAppPurchaseError.purchaseUnknown.alert()
                    productPurchaseCompletionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    // Don't finish transaction, we can't confirm if it succeeded or failed
                }
                
            }
        }
    }
    
    /// This delegate method is called when the user starts an in-app purchase in the App Store, and the transaction continues in your app. Specifically, if your app is already installed, the method is called automatically. If your app is not yet installed when the user starts the in-app purchase in the App Store, the user gets a notification when the app installation is complete. This method is called when the user taps the notification. Otherwise, if the user opens the app manually, this method is called only if the app is opened soon after the purchase was started.
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        SKPaymentQueue.default().add(payment)
        return true
    }
    
    // MARK: - Restore Purchases
    
    private var productRestoreCompletionHandler: ((Bool) -> Void)?
    
    /// Checks to see if the user is eligible to perform a restore transaction request. If they are, invokes  SKPaymentQueue.default().restoreCompletedTransactions() which then will invoke  paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]).
    func restorePurchases(completionHandler: @escaping (Bool) -> Void) {
        // Make sure the user has the permissions to perform such a request
        guard FamilyInformation.isUserFamilyHead else {
            ErrorConstant.InAppPurchaseError.restorePermission.alert()
            completionHandler(false)
            return
        }
        
        // Don't check for SKPaymentQueue.canMakePayments(), as we are only restoring and not making any purchases
        
        // Make sure there isn't a restore request in process
        guard InternalInAppPurchaseManager.shared.productRestoreCompletionHandler == nil else {
            ErrorConstant.InAppPurchaseError.restoreInProgress.alert()
            completionHandler(false)
            return
        }
        
        // Make sure there is no purchase request ongoing
        guard productPurchaseCompletionHandler == nil else {
            ErrorConstant.InAppPurchaseError.purchaseInProgress.alert()
            completionHandler(false)
            return
        }
        
        // Make sure the system isn't doing anything async in the background
        guard backgroundPurchaseInProgress == false else {
            ErrorConstant.InAppPurchaseError.backgroundPurchaseInProgress.alert()
            completionHandler(false)
            return
        }
        
        let keychain = KeychainSwift()
        let userPurchasedProduct = keychain.getBool(KeyConstant.userPurchasedProduct.rawValue) ?? false
        
        guard userPurchasedProduct == true else {
            // If the user hasn't purchased a product, as indicated by our keychain which stores the value regardless if the user's device got blown up by a nuke, then don't invoke restoreCompletedTransactions().
            // This is because if "All transactions are unfinished OR The user did not purchase anything that is restorable OR You tried to restore items that are not restorable, such as a non-renewing subscription or a consumable product", this function will simply never return anything, causing the user
            
            completionHandler(true)
            return
        }
        
        // Don't test for SKPaymentQueue.default().transactions. This could lock the code from ever executing. E.g. the user goes to buy something (so its in the payment queue) but they stop mid way (maybe leaving the transaction as .purchasing or .deferred). Then the background async processing isn't invoked to start (or it simply can't process whats in the queue) so we are left with transactions in the queue that are stuck and are locking
        
        InternalInAppPurchaseManager.shared.productRestoreCompletionHandler = completionHandler
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            if self.productRestoreCompletionHandler != nil {
                ErrorConstant.InAppPurchaseError.restoreFailed.alert()
            }
            
            self.productRestoreCompletionHandler?(false)
            self.productRestoreCompletionHandler = nil
        }
    }
    
}
