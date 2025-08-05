//
//  OfflineModeManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/8/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol OfflineModeManagerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
}

final class OfflineModeManager: NSObject, NSCoding, UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    static func persist(toUserDefaults: UserDefaults) {
        if let dataShared = try? NSKeyedArchiver.archivedData(withRootObject: shared, requiringSecureCoding: false) {
            toUserDefaults.set(dataShared, forKey: Constant.Key.offlineModeManagerShared.rawValue)
        }
    }
    
    static func load(fromUserDefaults: UserDefaults) {
        if let dataShared: Data = UserDefaults.standard.data(forKey: Constant.Key.offlineModeManagerShared.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataShared) {
            unarchiver.requiresSecureCoding = false
            if let shared = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? OfflineModeManager {
                OfflineModeManager.shared = shared
            }
        }
    }
    
    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        shouldUpdateUser = aDecoder.decodeOptionalBool(forKey: Constant.Key.offlineModeManagerShouldUpdateUser.rawValue) ?? shouldUpdateUser
        shouldGetUser = aDecoder.decodeOptionalBool(forKey: Constant.Key.offlineModeManagerShouldGetUser.rawValue) ?? shouldGetUser
        shouldGetFamily = aDecoder.decodeOptionalBool(forKey: Constant.Key.offlineModeManagerShouldGetFamily.rawValue) ?? shouldGetFamily
        shouldGetDogManager = aDecoder.decodeOptionalBool(forKey: Constant.Key.offlineModeManagerShouldGetDogManager.rawValue) ?? shouldGetDogManager
        offlineModeDeletedObjects = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeManagerOfflineModeDeletedObjects.rawValue) ?? offlineModeDeletedObjects
        // isWaitingForInternetConnection is false when the object is created; changed when startMonitoring is invoked
        // isSyncInProgress is false when the object is created; changed when startMonitoring is invoked
        // hasDisplayedOfflineModeBanner is false when the object is created; changed when we enter offline mode
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(shouldUpdateUser, forKey: Constant.Key.offlineModeManagerShouldUpdateUser.rawValue)
        aCoder.encode(shouldGetUser, forKey: Constant.Key.offlineModeManagerShouldGetUser.rawValue)
        aCoder.encode(shouldGetFamily, forKey: Constant.Key.offlineModeManagerShouldGetFamily.rawValue)
        aCoder.encode(shouldGetDogManager, forKey: Constant.Key.offlineModeManagerShouldGetDogManager.rawValue)
        aCoder.encode(offlineModeDeletedObjects, forKey: Constant.Key.offlineModeManagerOfflineModeDeletedObjects.rawValue)
        // isWaitingForInternetConnection is false when the object is created; changed when startMonitoring is invoked
        // isSyncInProgress is false when the object is created; changed when startMonitoring is invoked
    }
    
    // MARK: - Properties
    
    static var shared: OfflineModeManager = OfflineModeManager()
    
    // MARK: Sync-able Variables
    /// If true, a updateUser request got no response. The user's local data is updated and needs to be synced with the server. This is set to true if a update request for a user request receives no response from the Hound server
    private(set) var shouldUpdateUser: Bool = false
    /// If true, a getUser request got no response. The user's data is outdated and needs to be fetched from the server. This is set to true if a get request for a user request receives no response from the Hound server
    private var shouldGetUser: Bool = false
    /// If true, a getFamily request got no response. The user's family data is outdated and needs to be fetched from the server. This is set to true if a get request for a family request receives no response from the Hound server
    private var shouldGetFamily: Bool = false
    /// If true, the first invocation of sync from startMonitoring requires that the dogManager be synced. This is set to true if a get request for a dog manager, dog, reminder, or log request receives no response from the Hound server
    private var shouldGetDogManager: Bool = false
    /// Dogs, reminders, or logs that were deleted in offline mode and need their deletion synced with the Hound server
    private var offlineModeDeletedObjects: [OfflineModeDeletedObject] = []
    
    // MARK: Pre-Sync Variables
    private var internetConnectionObserver: NSKeyValueObservation?
    /// If true, OfflineModeManager is currently observing and waiting for the user's device to get internet so that it can start resyncing.
    private var isWaitingForInternetConnection: Bool = false {
        didSet {
            if isWaitingForInternetConnection == true && internetConnectionObserver == nil {
                // If we are going to be waiting for an internet connection and have nothing to monitor for that, start monitoring
                internetConnectionObserver = NetworkManager.shared.observe(\.isConnected, options: [.new]) { _, change in
                    // If isConnected did update and its new value is true, we are now connected to internet
                    if let newValue = change.newValue, newValue == true {
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
            if oldValue == true && isSyncInProgress == false && isSyncNeeded == false {
                hasDisplayedOfflineModeBanner = false
            }
        }
    }
    /// When Hound first enters offline mode, display a banner that it has done so.
    private(set) var hasDisplayedOfflineModeBanner: Bool = false
    /// The delay that OfflineModeManger waits before attempting to sync again after receiving not response from the Hound server
    private let delayBeforeAttemptingToSyncAgain: Double = 15.0
    /// Sends updates when OfflineModeManager syncs any dog, reminder, or log objects
    weak var delegate: OfflineModeManagerDelegate!
    
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
            
            for reminder in dog.dogReminders.dogReminders where reminder.offlineModeComponents.needsSyncedWithHoundServer == true {
                return true
            }
            
            for trigger in dog.dogTriggers.dogTriggers where trigger.offlineModeComponents.needsSyncedWithHoundServer == true {
                return true
            }
            
            for log in dog.dogLogs.dogLogs where log.offlineModeComponents.needsSyncedWithHoundServer == true {
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
    func didGetNoResponse(type: OfflineModeGetNoResponseTypes) {
        switch type {
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
    func addDeletedObjectToQueue(object: OfflineModeDeletedObject) {
        // Ensure that the queue doesn't already have the deleted object waiting in it.
        guard offlineModeDeletedObjects.contains(where: { o in
            return o == object
        }) == false else { return }
        
        offlineModeDeletedObjects.append(object)
        
        offlineModeDeletedObjects.sort { objectOne, objectTwo in
            // If both objects are the same type, compare by deletedDate
            if type(of: objectOne) == type(of: objectTwo) {
                return objectOne.deletedDate <= objectTwo.deletedDate
            }
            
            // OfflineModeDeletedDog always comes first
            if objectOne is OfflineModeDeletedDog { return true }
            if objectTwo is OfflineModeDeletedDog { return false }
            
            // OfflineModeDeletedReminder comes next (after dogs)
            if objectOne is OfflineModeDeletedReminder { return true }
            if objectTwo is OfflineModeDeletedReminder { return false }
            
            // OfflineModeDeletedLog comes after reminders
            if objectOne is OfflineModeDeletedLog { return true }
            if objectTwo is OfflineModeDeletedLog { return false }
            
            // Remaining case: OfflineModeDeletedTrigger (all others fall here)
            return true
        }
    }
    
    // MARK: Monitoring and Syncing
    
    /// Invoke this function when there is an indication of lost connectivity to either the internet as a whole or the Hound server. OfflineModeManager will attempt to start syncing its data with the Hound server once connection is re-established.
    func startMonitoring() {
        
        // Avoid invoking the code below unless a sync is not in progress
        guard isSyncInProgress == false else {
            // Already syncing
            return
        }
        
        // Perform the isSyncNeeded check second as it is slightly resource intensive. If we can avert it by checking isSyncInProgress first, then that is good.
        guard isSyncNeeded == true else { return }
        
        if hasDisplayedOfflineModeBanner == false {
            hasDisplayedOfflineModeBanner = true
            PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.infoEnteredOfflineModeTitle, subtitle: Constant.Visual.BannerText.infoEnteredOfflineModeSubtitle, style: .info)
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
        // Stop all syncing and wait for a delay until we try again to sync. This should begin again from startMonitoring so it goes through the same network checks to see if the user still has connection.
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeAttemptingToSyncAgain) {
            self.isSyncInProgress = false
            self.startMonitoring()
        }
    }
    
    /// Helper function for sync. Attempts to sync getUser. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncGetUser() {
        UserRequest.get(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager
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
        UserRequest.update(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            body: UserConfiguration.createBody(addingOntoBody: [:])) { responseStatus, _ in
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
        FamilyRequest.get(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager
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
        guard let globalDogManager = DogManager.globalDogManager else {
            // Unable to retrieve a dogManager to use to sync from.
            shouldGetDogManager = false
            syncNextObject()
            return
        }
        
        DogsRequest.get(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            dogManager: globalDogManager
        ) { dogManager, responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            // If we got a response for this request, set this flag to false as we no longer need to perform the request. If the request failed, then we ignore it as it will most likely fail again.
            self.shouldGetDogManager = false
            
            if let dogManager = dogManager {
                self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: dogManager)
            }
            
            // Continue to sync more upon successful completion
            self.syncNextObject()
        }
    }
    
    /// Helper function for sync. Attempts to sync a deleted object. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDeletedObject() {
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
            DogsRequest.delete(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: deletedDog.dogUUID
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { o in
                    return o == deletedDog
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.removeDog(dogUUID: deletedDog.dogUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
        else if let deletedReminder = offlineModeDeletedObject as? OfflineModeDeletedReminder {
            RemindersRequest.delete(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: deletedReminder.dogUUID,
                reminderUUIDs: [deletedReminder.reminderUUID]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { o in
                    return o == deletedReminder
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.findDog(dogUUID: deletedReminder.dogUUID)?.dogReminders.removeReminder(reminderUUID: deletedReminder.reminderUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
        else if let deletedLog = offlineModeDeletedObject as? OfflineModeDeletedLog {
            LogsRequest.delete(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: deletedLog.dogUUID,
                logUUID: deletedLog.logUUID
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { o in
                    return o == deletedLog
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.findDog(dogUUID: deletedLog.dogUUID)?.dogLogs.removeLog(logUUID: deletedLog.logUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
        else if let deletedTrigger = offlineModeDeletedObject as? OfflineModeDeletedTrigger {
            TriggersRequest.delete(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: deletedTrigger.dogUUID,
                triggerUUIDs: [deletedTrigger.triggerUUID]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // Got a response for this request. Whether it was successful or a failure, clear this object from being sync'd
                self.offlineModeDeletedObjects.removeAll { o in
                    return o == deletedTrigger
                }
                
                // If the dog got added back into the dogManager, remove it again and then push the change to everything else
                if let globalDogManager = DogManager.globalDogManager, globalDogManager.findDog(dogUUID: deletedTrigger.dogUUID)?.dogTriggers.removeTrigger(triggerUUID: deletedTrigger.triggerUUID) == true {
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: globalDogManager)
                }
                
                self.syncNextObject()
            }
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced dogs. Recursively invokes itself until all syncNeededDogs have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDogs(syncNeededDogs: [Dog]) {
        // Create a copy so that we can remove elements
        var syncNeededDogs = syncNeededDogs
        
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
            helperSyncDogs(syncNeededDogs: syncNeededDogs)
            return
        }
        
        guard syncNeededDog.dogId != nil else {
            // offlineModeDog doesn't have a dogId, so it hasn't been created on the server
            DogsRequest.create(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dog: syncNeededDog
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncDogs, except with syncNeededDogs which has this current syncNeededDog removed
                self.helperSyncDogs(syncNeededDogs: syncNeededDogs)
            }
            return
        }
        
        // offlineModeDog has a dogId, so its already been created on the server
        DogsRequest.update(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            dog: syncNeededDog
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncDogs, except with syncNeededDogs which has this current syncNeededDog removed
            self.helperSyncDogs(syncNeededDogs: syncNeededDogs)
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced reminders. Recursively invokes itself until all syncNeededReminders have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncReminders(syncNeededReminders: [(UUID, Reminder)]) {
        // Create a copy so that we can remove elements
        var syncNeededReminders = syncNeededReminders
        
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
            helperSyncReminders(syncNeededReminders: syncNeededReminders)
            return
        }
        
        guard syncNeededReminder.1.reminderId != nil else {
            // offlineModeReminder doesn't have a dogId, so it hasn't been created on the server
            RemindersRequest.create(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: syncNeededReminder.0,
                reminders: [syncNeededReminder.1]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncReminders, except with syncNeededReminders which has this current syncNeededReminder removed
                self.helperSyncReminders(syncNeededReminders: syncNeededReminders)
            }
            return
        }
        
        // offlineModeReminder has a reminderId, so its already been created on the server
        RemindersRequest.update(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            dogUUID: syncNeededReminder.0,
            reminders: [syncNeededReminder.1]
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncReminders, except with syncNeededReminders which has this current syncNeededReminder removed
            self.helperSyncReminders(syncNeededReminders: syncNeededReminders)
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced logs. Recursively invokes itself until all syncNeededLogs have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncLogs(syncNeededLogs: [(UUID, Log)]) {
        // Create a copy so that we can remove elements
        var syncNeededLogs = syncNeededLogs
        
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
            helperSyncLogs(syncNeededLogs: syncNeededLogs)
            return
        }
        
        guard syncNeededLog.1.logId != nil else {
            // offlineModeLog doesn't have a dogId, so it hasn't been created on the server
            LogsRequest.create(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: syncNeededLog.0,
                log: syncNeededLog.1
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncLogs, except with syncNeededLogs which has this current syncNeededLog removed
                self.helperSyncLogs(syncNeededLogs: syncNeededLogs)
            }
            return
        }
        
        // offlineModeLog has a logId, so its already been created on the server
        LogsRequest.update(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            dogUUID: syncNeededLog.0,
            log: syncNeededLog.1
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncLogs, except with syncNeededLogs which has this current syncNeededLog removed
            self.helperSyncLogs(syncNeededLogs: syncNeededLogs)
        }
    }
    
    /// Helper function for sync. Attempts to sync all of the unsynced triggers. Recursively invokes itself until all syncNeededTriggers have been synced. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncTriggers(syncNeededTriggers: [(UUID, Trigger)]) {
        // Create a copy so that we can remove elements
        var syncNeededTriggers = syncNeededTriggers
        
        // Get the first trigger, which has the more priority, and attempt to sync it
        guard let syncNeededTrigger = syncNeededTriggers.first else {
            // There are no more triggers that need synced
            syncNextObject()
            return
        }
        
        // syncNeededTrigger exists so its safe to remove the first element from syncNeededTriggers
        syncNeededTriggers.removeFirst()
        
        guard syncNeededTrigger.1.offlineModeComponents.needsSyncedWithHoundServer == true else {
            // Reinvoke helperSyncTriggers, except with syncNeededTriggers which has this current syncNeededTrigger removed
            helperSyncTriggers(syncNeededTriggers: syncNeededTriggers)
            return
        }
        
        guard syncNeededTrigger.1.triggerId != nil else {
            // offlineModeTrigger doesn't have a dogId, so it hasn't been created on the server
            TriggersRequest.create(
                errorAlert: .automaticallyAlertForNone,
                sourceFunction: .offlineModeManager,
                dogUUID: syncNeededTrigger.0,
                dogTriggers: [syncNeededTrigger.1]
            ) { responseStatus, _ in
                guard responseStatus != .noResponse else {
                    self.noResponseForSync()
                    return
                }
                
                // No need to call the delegate. Object's id is automatically assigned to the value from the server, initialAttemptedSyncDate is automatically set to nil, and we locally have all the information about this object
                
                // Reinvoke helperSyncTriggers, except with syncNeededTriggers which has this current syncNeededTrigger removed
                self.helperSyncTriggers(syncNeededTriggers: syncNeededTriggers)
            }
            return
        }
        
        // offlineModeTrigger has a triggerId, so its already been created on the server
        TriggersRequest.update(
            errorAlert: .automaticallyAlertForNone,
            sourceFunction: .offlineModeManager,
            dogUUID: syncNeededTrigger.0,
            dogTriggers: [syncNeededTrigger.1]
        ) { responseStatus, _ in
            guard responseStatus != .noResponse else {
                self.noResponseForSync()
                return
            }
            
            // No need to call the delegate. initialAttemptedSyncDate is automatically set to nil and we locally have all the information about this object
            
            // Reinvoke helperSyncTriggers, except with syncNeededTriggers which has this current syncNeededTrigger removed
            self.helperSyncTriggers(syncNeededTriggers: syncNeededTriggers)
        }
    }

    /// Helper function for sync. Attempts to sync, in order of priority, unsynced dogs, reminders, and logs. Invokes sync or noResponseForSync depending upon its result when it completes.
    private func helperSyncDogsRemindersLogsTriggers() {
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
            helperSyncDogs(syncNeededDogs: syncNeededDogs)
            return
        }
        
        // Find all reminders that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededReminders = globalDogManager.dogs.flatMap { dog -> [(UUID, Reminder)] in
            return dog.dogReminders.dogReminders
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
            helperSyncReminders(syncNeededReminders: syncNeededReminders)
            return
        }
        
        // Find all logs that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededLogs = globalDogManager.dogs.flatMap { dog -> [(UUID, Log)] in
            return dog.dogLogs.dogLogs
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
            helperSyncLogs(syncNeededLogs: syncNeededLogs)
            return
        }
        
        // Find all triggers that need to be synced and order them by oldest initialAttemptedSyncDate (index 0) to newest (index end)
        let syncNeededTriggers = globalDogManager.dogs.flatMap { dog -> [(UUID, Trigger)] in
            return dog.dogTriggers.dogTriggers
                .filter { $0.offlineModeComponents.needsSyncedWithHoundServer }
                .map { (dog.dogUUID, $0) } // Create a tuple of dogUUID and trigger
        }
        .sorted { tuple1, tuple2 in
            let trigger1 = tuple1.1
            let trigger2 = tuple2.1
            // If a trigger is in this array, needsSyncedWithHoundServer is true, which means that initialAttemptedSyncDate should not be nil.
            return (trigger1.offlineModeComponents.initialAttemptedSyncDate ?? trigger1.offlineModeComponents.initialCreationDate) <= (trigger2.offlineModeComponents.initialAttemptedSyncDate ?? trigger2.offlineModeComponents.initialCreationDate)
        }

        // If we have triggers to sync, sync them first before the logs
        guard syncNeededTriggers.isEmpty == true else {
            helperSyncTriggers(syncNeededTriggers: syncNeededTriggers)
            return
        }
        
        // We have synced all the dogs, reminders, and logs
        syncNextObject()
    }
    
    /// In order of a heirarchy of priority, begins to perform requests to the Hound server to progressively re-sync the users data with the server. Waits for a single network call to finish before that request's completionHandler invokes syncNextObject()
    private func syncNextObject() {
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
            helperSyncDogsRemindersLogsTriggers()
            return
        }
        
        // We have finished syncing everything. Push an update to the MainTabBarVC with the update dogManager
        if let globalDogManager = DogManager.globalDogManager {
            delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), dogManager: globalDogManager)
        }
        
        isSyncInProgress = false
    }
}
