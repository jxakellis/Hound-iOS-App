//
//  OfflineModeManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol OfflineModeManagerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class OfflineModeManager: NSObject, NSCoding, UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    // TODO BUG two phantom dogs appear when starting the app in offline mode (no data at all saved) then when get dog manager all the info comes in but still two blank bella dogs with no logs/reminders
    
    static func persist(toUserDefaults: UserDefaults) {
        if let dataShared = try? NSKeyedArchiver.archivedData(withRootObject: shared, requiringSecureCoding: false) {
            toUserDefaults.set(dataShared, forKey: KeyConstant.offlineModeManagerShared.rawValue)
        }
    }
    
    static func load(fromUserDefaults: UserDefaults) {
        if let dataShared: Data = UserDefaults.standard.data(forKey: KeyConstant.offlineModeManagerShared.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataShared) {
            unarchiver.requiresSecureCoding = false
            if let shared = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? OfflineModeManager {
                OfflineModeManager.shared = shared
            }
        }
    }
    
    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        shouldUpdateUser = aDecoder.decodeBool(forKey: KeyConstant.offlineModeManagerShouldUpdateUser.rawValue)
        shouldGetUser = aDecoder.decodeBool(forKey: KeyConstant.offlineModeManagerShouldGetUser.rawValue)
        shouldGetFamily = aDecoder.decodeBool(forKey: KeyConstant.offlineModeManagerShouldGetFamily.rawValue)
        shouldGetDogManager = aDecoder.decodeBool(forKey: KeyConstant.offlineModeManagerShouldGetDogManager.rawValue)
        offlineModeDeletedObjects = aDecoder.decodeObject(forKey: KeyConstant.offlineModeManagerOfflineModeDeletedObjects.rawValue) as? [OfflineModeDeletedObject] ?? offlineModeDeletedObjects
        // isWaitingForInternetConnection is false when the object is created; changed when startMonitoring is invoked
        // isSyncInProgress is false when the object is created; changed when startMonitoring is invoked
        // hasDisplayedOfflineModeBanner is false when the object is created; changed when we enter offline mode
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        aCoder.encode(shouldUpdateUser, forKey: KeyConstant.offlineModeManagerShouldUpdateUser.rawValue)
        aCoder.encode(shouldGetUser, forKey: KeyConstant.offlineModeManagerShouldGetUser.rawValue)
        aCoder.encode(shouldGetFamily, forKey: KeyConstant.offlineModeManagerShouldGetFamily.rawValue)
        aCoder.encode(shouldGetDogManager, forKey: KeyConstant.offlineModeManagerShouldGetDogManager.rawValue)
        aCoder.encode(offlineModeDeletedObjects, forKey: KeyConstant.offlineModeManagerOfflineModeDeletedObjects.rawValue)
        // isWaitingForInternetConnection is false when the object is created; changed when startMonitoring is invoked
        // isSyncInProgress is false when the object is created; changed when startMonitoring is invoked
    }
    
    // MARK: - Properties
    
    private(set) static var shared: OfflineModeManager = OfflineModeManager()
    
    // MARK: Sync-able Variables
    /// If true, a updateUser request got no response. The user's local data is updated and needs to be synced with the server. This is set to true if a update request for a user request receives no response from the Hound server
    private var shouldUpdateUser: Bool = false {
        didSet {
            print("set shouldUpdateUser", shouldUpdateUser)
        }
    }
    /// If true, a getUser request got no response. The user's data is outdated and needs to be fetched from the server. This is set to true if a get request for a user request receives no response from the Hound server
    private var shouldGetUser: Bool = false {
        didSet {
            print("set shouldGetUser", shouldGetUser)
        }
    }
    /// If true, a getFamily request got no response. The user's family data is outdated and needs to be fetched from the server. This is set to true if a get request for a family request receives no response from the Hound server
    private var shouldGetFamily: Bool = false {
        didSet {
            print("set shouldGetFamily", shouldGetFamily)
        }
    }
    /// If true, the first invocation of sync from startMonitoring requires that the dogManager be synced. This is set to true if a get request for a dog manager, dog, reminder, or log request receives no response from the Hound server
    private var shouldGetDogManager: Bool = false {
        didSet {
            print("set shouldGetDogManager", shouldGetDogManager)
        }
    }
    /// Dogs, reminders, or logs that were deleted in offline mode and need their deletion synced with the Hound server
    private var offlineModeDeletedObjects: [OfflineModeDeletedObject] = []
    
    // MARK: Pre-Sync Variables
    private var internetConnectionObserver: NSKeyValueObservation?
    /// If true, OfflineModeManager is currently observing and waiting for the user's device to get internet so that it can start resyncing.
    private var isWaitingForInternetConnection: Bool = false {
        didSet {
            print("isWaitingForInternetConnection ", isWaitingForInternetConnection)
            if isWaitingForInternetConnection == true && internetConnectionObserver == nil {
                // If we are going to be waiting for an internet connection and have nothing to monitor for that, start monitoring
                internetConnectionObserver = NetworkManager.shared.observe(\.isConnected, options: [.new]) { _, change in
                    // If isConnected did update and its new value is true, we are now connected to internet
                    if let newValue = change.newValue, newValue == true {
                        print("Network connectivity changed. isConnected now \(newValue)")
                        self.isWaitingForInternetConnection = false
                    }
                }
            }
            
            if isWaitingForInternetConnection == false && internetConnectionObserver != nil {
                // No longer waiting for an internet connection so destroy
                internetConnectionObserver?.invalidate()
                internetConnectionObserver = nil
                // isWaitingForInternetConnection can only be changed by startMonitoring and internetConnectionObserver. If it was set to false and internetConnectionObserver is not nil, then the observer just observed the user getting internet connection again.
                startMonitoring()
            }
        }
    }
    
    // MARK: Syncing Variables
    /// True if the process of either determining if a sync is needed or actual syncing is in progress. False if there is no active syncing.
    private(set) var isSyncInProgress: Bool = false {
        didSet {
            // When isSyncInProgress gets turned off, meaning the syncing has completed, then reset hasDisplayedOfflineModeBanner so that if offline mode is entered again, the banner will display again
            if oldValue == true && isSyncInProgress == false {
                hasDisplayedOfflineModeBanner = false
            }
        }
    }
    /// When Hound first enters offline mode, display a banner that it has done so.
    private var hasDisplayedOfflineModeBanner: Bool = false
    /// The delay that OfflineModeManger waits before attempting to sync again after receiving not response from the Hound server
    private let delayBeforeAttemptingToSyncAgain: Double = 15.0
    /// Sends updates when OfflineModeManager syncs any dog, reminder, or log objects
    weak var delegate: OfflineModeManagerDelegate?
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    // MARK: - Computed Properties
    
    /// Returns true upon finding the first dog, reminder, or log which has needsSyncedWithHoundServer set to true. Returns false if no dog, reminder, or log needs synced.
    private var isDogManagerSyncNeeded: Bool {
        for dog in DogManager.globalDogManager?.dogs ?? [] {
            if dog.offlineModeComponents.needsSyncedWithHoundServer == true {
                return true
            }
            
            for reminder in dog.dogReminders.reminders where reminder.offlineModeComponents.needsSyncedWithHoundServer == true {
                return true
            }
            
            for log in dog.dogLogs.logs where log.offlineModeComponents.needsSyncedWithHoundServer == true {
                return true
            }
        }
        
        return false
    }
    
    /// Returns true if any of the following need synced: getUser, getFamily, getDogManager, deletedObjects, dogManager. Returns false if nothing needs synced.
    private var isSyncNeeded: Bool {
        if shouldUpdateUser == true {
            return true
        }
        if shouldGetUser == true {
            return true
        }
        if shouldGetFamily == true {
            return true
        }
        if shouldGetDogManager == true {
            return true
        }
        if offlineModeDeletedObjects.isEmpty == false {
            return true
        }
        if isDogManagerSyncNeeded == true {
            return true
        }
        
        return false
    }
    
    // MARK: - Functions
    
    // MARK: Sync Queue Management
    
    enum OfflineModeGetNoResponseTypes {
        case userRequestUpdate
        case userRequestGet
        case familyRequestGet
        case dogManagerGet
    }
    
    /// Invoke this function with the corresponding OfflineModeGetNoResponseTypes if a get user, family, dog manager, dog, reminder, or log request received no response from the server.
    func didGetNoResponse(forType: OfflineModeGetNoResponseTypes) {
        switch forType {
        case .userRequestUpdate:
            shouldUpdateUser = true
        case .userRequestGet:
            shouldGetUser = true
        case .familyRequestGet:
            shouldGetFamily = true
        case .dogManagerGet:
            shouldGetDogManager = true
        }
    }
    
    /// Invoke this function if a dog, reminder, or log was attempted to be deleted, however it failed due to no response from the Hound server
    func addDeletedObjectToQueue(forObject: OfflineModeDeletedObject) {
        // Ensure that the queue doesn't already have the deleted object waiting in it.
        guard offlineModeDeletedObjects.contains(where: { object in
            return object == forObject
        }) == false else {
            return
        }
        print("actually adding addDeletedObjectToQueue", forObject)
        
        offlineModeDeletedObjects.append(forObject)
        
        offlineModeDeletedObjects.sort { objectOne, objectTwo in
            guard type(of: objectOne) !== type(of: objectTwo) else {
                // Both objectOne and objectTwo are the same type, so the object that was deleted first comes first
                return objectOne.deletedDate <= objectTwo.deletedDate
            }
            
            // objectOne and objectTwo are different types
            
            if objectOne is OfflineModeDeletedDog {
                // objectOne is a dog and objectTwo is not a dog, so objectOne comes first
                return true
            }
            else if objectOne is OfflineModeDeletedReminder {
                if objectTwo is OfflineModeDeletedDog {
                    // objectOne is a reminder and objectTwo is a dog, so objectTwo comes first
                    return false
                }
                
                // objectOne is a reminder and objectTwo must be a log, so objectOne comes first
                return true
            }
            
            // objectOne is a log and objectTwo is a reminder or dog, so objectTwo comes first
            return false
        }
    }
    
    // MARK: Monitoring and Syncing
    
    /// Invoke this function when there is an indication of lost connectivity to either the internet as a whole or the Hound server. OfflineModeManager will attempt to start syncing its data with the Hound server once connection is re-established.
    func startMonitoring() {
        
        print("startMonitoring isSyncInProgress", isSyncInProgress, "isWaitingForInternetConnection", isWaitingForInternetConnection)
        // Avoid invoking the code below unless a sync is not in progress
        guard isSyncInProgress == false else {
            // Already syncing
            return
        }
        
        // Perform the isSyncNeeded check second as it is slightly resource intensive. If we can avert it by checking isSyncInProgress first, then that is good.
        guard isSyncNeeded == true else {
            print("isSyncNeeded is false, no need to sync anything")
            return
        }
        
        if hasDisplayedOfflineModeBanner == false {
            hasDisplayedOfflineModeBanner = true
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.infoEnteredOfflineModeTitle, forSubtitle: VisualConstant.BannerTextConstant.infoEnteredOfflineModeSubtitle, forStyle: .info)
        }
        
        guard isWaitingForInternetConnection == false && NetworkManager.shared.isConnected == true else {
            // OfflineModeManager can't do anything until its connected to the internet. We wait until we get a signal that internet connection is restored
            isWaitingForInternetConnection = true
            return
        }
        
        // The sync begins now that a connection is established
        isSyncInProgress = true
        
        syncNextObject()
    }
    
    /// Invoke if an OfflineModeManager request to the Hound server from syncNextObject() received no response. This invoke a delay before the client will restart the syncing process.
    private func noResponseForSync() {
        print("noResponseForSync")
        // Stop all syncing and wait for a delay until we try again to sync. This should begin again from startMonitoring so it goes through the same network checks to see if the user still has connection.
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeAttemptingToSyncAgain) {
            self.isSyncInProgress = false
            self.startMonitoring()
        }
    }
    
    /// Helper function for sync. Attempts to sync getUser. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncGetUser() {
        print("helperSyncGetUser")
        UserRequest.get(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            // If we got a response for this request, set this flag to false as we no longer need to perform the request. If the request failed, then we ignore it as it will most likely fail again.
            self.shouldGetUser = false
            
            // Continue to sync more upon successful completion
            self.syncNextObject()
        }
    }
    
    /// Helper function for sync. Attempts to sync updateUser. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncUpdateUser() {
        print("helperSyncUpdateUser")
        UserRequest.update(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager,
            forBody: UserConfiguration.createBody(addingOntoBody: [:])) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            // If we got a response for this request, set this flag to false as we no longer need to perform the request. If the request failed, then we ignore it as it will most likely fail again.
            self.shouldUpdateUser = false
            
            // Continue to sync more upon successful completion
            self.syncNextObject()
        }
    }
    
    /// Helper function for sync. Attempts to sync getFamily. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncGetFamily() {
        print("helperSyncGetFamily")
        FamilyRequest.get(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            // If we got a response for this request, set this flag to false as we no longer need to perform the request. If the request failed, then we ignore it as it will most likely fail again.
            self.shouldGetFamily = false
            
            // Continue to sync more upon successful completion
            self.syncNextObject()
        }
    }
    
    /// Helper function for sync. Attempts to sync getDogManager. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncGetDogManager() {
        print("helperSyncGetDogManager")
        guard let globalDogManager = DogManager.globalDogManager else {
            // Unable to retrieve a dogManager to use to sync from.
            shouldGetDogManager = false
            syncNextObject()
            return
        }
        
        globalDogManager.dogs.forEach { dog in
            print("dog ", dog.dogName, dog.dogId, dog.dogUUID)
        }
        DogsRequest.get(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager,
            forDogManager: globalDogManager
        ) { dogManager, responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            // If we got a response for this request, set this flag to false as we no longer need to perform the request. If the request failed, then we ignore it as it will most likely fail again.
            self.shouldGetDogManager = false
            
            if let dogManager = dogManager {
                print("finished retrieving dogManager")
                dogManager.dogs.forEach { dog in
                    print("dog ", dog.dogName, dog.dogId, dog.dogUUID)
                }
                self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
            }
            
            // Continue to sync more upon successful completion
            self.syncNextObject()
        }
    }
    
    /// Helper function for sync. Attempts to sync a deleted object. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDeletedObject() {
        print("helperSyncDeletedObject")
        // offlineModeDeletedObjects is already be sorted
        // Primary sort / grouping: dog then reminders then logs
        // Secondary sort within primary group: deletedDate
        
        guard let offlineModeDeletedObject = offlineModeDeletedObjects.first else {
            // No more offlineModeDeletedObjects to sync
            syncNextObject()
            return
        }
        
        // Attempt to cast offlineModeDeletedObject as the three possible different objects. If the cast is successful, then try to sync that object
        if let deletedDog = offlineModeDeletedObject as? OfflineModeDeletedDog {
            print("offlineModeDeletedDog", deletedDog)
            DogsRequest.delete(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDogUUID: deletedDog.dogUUID
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { object in
                    return object == deletedDog
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.removeDog(forDogUUID: deletedDog.dogUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
        else if let deletedReminder = offlineModeDeletedObject as? OfflineModeDeletedReminder {
            print("offlineModeDeletedReminder", deletedReminder)
            RemindersRequest.delete(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDogUUID: deletedReminder.dogUUID,
                forReminderUUIDs: [deletedReminder.reminderUUID]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { object in
                    return object == deletedReminder
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.findDog(forDogUUID: deletedReminder.dogUUID)?.dogReminders.removeReminder(forReminderUUID: deletedReminder.reminderUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
        else if let deletedLog = offlineModeDeletedObject as? OfflineModeDeletedLog {
            print("deletedLog", deletedLog)
            LogsRequest.delete(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDogUUID: deletedLog.dogUUID,
                forLogUUID: deletedLog.logUUID
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { object in
                    return object == deletedLog
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.findDog(forDogUUID: deletedLog.dogUUID)?.dogLogs.removeLog(forLogUUID: deletedLog.logUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced dogs. Recursively invokes itself until all forSyncNeededDogs have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDogs(forSyncNeededDogs: [Dog]) {
        print("helperSyncDogs", forSyncNeededDogs)
        // Create a copy so that we can remove elements
        var syncNeededDogs = forSyncNeededDogs
        
        // Get the first dog, which has the more priority, and attempt to sync it
        guard let syncNeededDog = syncNeededDogs.first else {
            // There are no more dogs that need synced
            syncNextObject()
            return
        }
        
        // syncNeededDog exists so its safe to remove the first element from syncNeededDogs
        syncNeededDogs.removeFirst()
        
        guard syncNeededDog.offlineModeComponents.needsSyncedWithHoundServer == true else {
            // Reinvoke helperSyncDogs, except with syncNeededDogs which has this current syncNeededDog removed
            helperSyncDogs(forSyncNeededDogs: syncNeededDogs)
            return
        }
        
        guard syncNeededDog.dogId != nil else {
            // offlineModeDog doesn't have a dogId, so it hasn't been created on the server
            DogsRequest.create(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDog: syncNeededDog
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncDogs, except with syncNeededDogs which has this current syncNeededDog removed
                self.helperSyncDogs(forSyncNeededDogs: syncNeededDogs)
            }
            return
        }
        
        // offlineModeDog has a dogId, so its already been created on the server
        DogsRequest.update(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager,
            forDog: syncNeededDog
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncDogs, except with syncNeededDogs which has this current syncNeededDog removed
            self.helperSyncDogs(forSyncNeededDogs: syncNeededDogs)
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced reminders. Recursively invokes itself until all forSyncNeededReminders have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncReminders(forSyncNeededReminders: [(UUID, Reminder)]) {
        print("helperSyncReminders", forSyncNeededReminders)
        // Create a copy so that we can remove elements
        var syncNeededReminders = forSyncNeededReminders
        
        // Get the first reminder, which has the more priority, and attempt to sync it
        guard let syncNeededReminder = syncNeededReminders.first else {
            // There are no more reminders that need synced
            syncNextObject()
            return
        }
        
        // syncNeededReminder exists so its safe to remove the first element from syncNeededReminders
        syncNeededReminders.removeFirst()
        
        guard syncNeededReminder.1.offlineModeComponents.needsSyncedWithHoundServer == true else {
            // Reinvoke helperSyncReminders, except with syncNeededReminders which has this current syncNeededReminder removed
            helperSyncReminders(forSyncNeededReminders: syncNeededReminders)
            return
        }
        
        guard syncNeededReminder.1.reminderId != nil else {
            // offlineModeReminder doesn't have a dogId, so it hasn't been created on the server
            RemindersRequest.create(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDogUUID: syncNeededReminder.0,
                forReminders: [syncNeededReminder.1]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncReminders, except with syncNeededReminders which has this current syncNeededReminder removed
                self.helperSyncReminders(forSyncNeededReminders: syncNeededReminders)
            }
            return
        }
        
        // offlineModeReminder has a reminderId, so its already been created on the server
        RemindersRequest.update(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager,
            forDogUUID: syncNeededReminder.0,
            forReminders: [syncNeededReminder.1]
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncReminders, except with syncNeededReminders which has this current syncNeededReminder removed
            self.helperSyncReminders(forSyncNeededReminders: syncNeededReminders)
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced logs. Recursively invokes itself until all forSyncNeededLogs have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncLogs(forSyncNeededLogs: [(UUID, Log)]) {
        print("helperSyncLogs", forSyncNeededLogs)
        // Create a copy so that we can remove elements
        var syncNeededLogs = forSyncNeededLogs
        
        // Get the first log, which has the more priority, and attempt to sync it
        guard let syncNeededLog = syncNeededLogs.first else {
            // There are no more logs that need synced
            syncNextObject()
            return
        }
        
        // syncNeededLog exists so its safe to remove the first element from syncNeededLogs
        syncNeededLogs.removeFirst()
        
        guard syncNeededLog.1.offlineModeComponents.needsSyncedWithHoundServer == true else {
            // Reinvoke helperSyncLogs, except with syncNeededLogs which has this current syncNeededLog removed
            helperSyncLogs(forSyncNeededLogs: syncNeededLogs)
            return
        }
        
        guard syncNeededLog.1.logId != nil else {
            // offlineModeLog doesn't have a dogId, so it hasn't been created on the server
            LogsRequest.create(
                forErrorAlert: .automaticallyAlertForNone,
                forSourceFunction: .offlineModeManager,
                forDogUUID: syncNeededLog.0,
                forLog: syncNeededLog.1
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncLogs, except with syncNeededLogs which has this current syncNeededLog removed
                self.helperSyncLogs(forSyncNeededLogs: syncNeededLogs)
            }
            return
        }
        
        // offlineModeLog has a logId, so its already been created on the server
        LogsRequest.update(
            forErrorAlert: .automaticallyAlertForNone,
            forSourceFunction: .offlineModeManager,
            forDogUUID: syncNeededLog.0,
            forLog: syncNeededLog.1
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncLogs, except with syncNeededLogs which has this current syncNeededLog removed
            self.helperSyncLogs(forSyncNeededLogs: syncNeededLogs)
        }
    }
    
    /// Helper function for sync. Attempts to sync, in order of priority, unsynced dogs, reminders, and logs. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDogsRemindersLogs() {
        print("helperSyncDogsRemindersLogs")
        guard let globalDogManager = DogManager.globalDogManager else {
            syncNextObject()
            return
        }
        
        // Find all dogs that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededDogs = globalDogManager.dogs.filter { dog in
            return dog.offlineModeComponents.needsSyncedWithHoundServer
        }
            .sorted { dog1, dog2 in
            // If a dog is in this array, needsSyncedWithHoundServer is true, which means that initialAttemptedSyncDate should not be nil.
            return (dog1.offlineModeComponents.initialAttemptedSyncDate ?? dog1.offlineModeComponents.initialCreationDate) <= (dog2.offlineModeComponents.initialAttemptedSyncDate ?? dog2.offlineModeComponents.initialCreationDate)
            }
        
        // If we have dogs to sync, sync them first before the reminders and logs
        guard syncNeededDogs.isEmpty == true else {
            helperSyncDogs(forSyncNeededDogs: syncNeededDogs)
            return
        }
        
        // Find all reminders that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededReminders = globalDogManager.dogs.flatMap { dog -> [(UUID, Reminder)] in
            return dog.dogReminders.reminders
                .filter { $0.offlineModeComponents.needsSyncedWithHoundServer }
                .map { (dog.dogUUID, $0) } // Create a tuple of dogUUID and reminder
        }
        .sorted { tuple1, tuple2 in
            let reminder1 = tuple1.1
            let reminder2 = tuple2.1
            // If a reminder is in this array, needsSyncedWithHoundServer is true, which means that initialAttemptedSyncDate should not be nil.
            return (reminder1.offlineModeComponents.initialAttemptedSyncDate ?? reminder1.offlineModeComponents.initialCreationDate) <= (reminder2.offlineModeComponents.initialAttemptedSyncDate ?? reminder2.offlineModeComponents.initialCreationDate)
        }
        
        // If we have reminders to sync, sync them first before the logs
        guard syncNeededReminders.isEmpty == true else {
            helperSyncReminders(forSyncNeededReminders: syncNeededReminders)
            return
        }
        
        // Find all logs that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededLogs = globalDogManager.dogs.flatMap { dog -> [(UUID, Log)] in
            return dog.dogLogs.logs
                .filter { $0.offlineModeComponents.needsSyncedWithHoundServer }
                .map { (dog.dogUUID, $0) } // Create a tuple of dogUUID and reminder
        }
        .sorted { tuple1, tuple2 in
            let log1 = tuple1.1
            let log2 = tuple2.1
            // If a log is in this array, needsSyncedWithHoundServer is true, which means that initialAttemptedSyncDate should not be nil.
            return (log1.offlineModeComponents.initialAttemptedSyncDate ?? log1.offlineModeComponents.initialCreationDate) <= (log2.offlineModeComponents.initialAttemptedSyncDate ?? log2.offlineModeComponents.initialCreationDate)
        }
        
        // If we have logs to sync, sync them
        guard syncNeededLogs.isEmpty == true else {
            helperSyncLogs(forSyncNeededLogs: syncNeededLogs)
            return
        }
        
        // We have synced all the dogs, reminders, and logs
        syncNextObject()
    }
    
    /// In order of a heirarchy of priority, begins to perform requests to the Hound server to progressively re-sync the users data with the server. Waits for a single network call to finish before that request's completionHandler invokes syncNextObject()
    private func syncNextObject() {
        print("syncNextObject")
        
        // shouldUpdateUser should come before shouldGetUser otherwise shouldGetUser would overwrite the local changes to UserConfiguration
        guard shouldUpdateUser == false else {
            helperSyncUpdateUser()
            return
        }
        
        guard shouldGetUser == false else {
            helperSyncGetUser()
            return
        }
        
        guard shouldGetFamily == false else {
            helperSyncGetFamily()
            return
        }
        
        guard shouldGetDogManager == false else {
            helperSyncGetDogManager()
            return
        }
        
        // Start sync-ing updates according to priority:
        //      1. deleted dogs
        //      2. deleted reminders/logs
        //      3. dogs
        //      4. reminders/logs
        
        guard offlineModeDeletedObjects.isEmpty == true else {
            helperSyncDeletedObject()
            return
        }
        
        guard isDogManagerSyncNeeded == false else {
            helperSyncDogsRemindersLogs()
            return
        }
        
        // We have finished syncing everything. Push an update to the MainTabBarVC with the update dogManager
        if let globalDogManager = DogManager.globalDogManager {
            delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: globalDogManager)
        }
        
        print("ended syncing")
        
        isSyncInProgress = false
    }
}
