//
//  SceneDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppDelegate.lifeCycleLogger.notice("Scene Will Connect To Session")
        // Use this function to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // If UserConfiguration.interfaceStyle is updated, it will send a didUpdateUserInterfaceStyle notification, which we then recieve to overrideUserInterfaceStyle every view in our window with the new value
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateUserInterfaceStyle), name: .didUpdateUserInterfaceStyle, object: nil)
                
        // set initial interface style
        window?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        guard (scene as? UIWindowScene) != nil else { return }
    }
    
    @objc private func didUpdateUserInterfaceStyle() {
        window?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene Did Disconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene Did Become Active")
        
        // Scene must be active for synchronizeAlarmQueue to work
        AlarmManager.synchronizeAlarmQueue()
        // Called when the scene has moved from an inactive state to an active state.
        // Use this function to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene Will Resign Active")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this function to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        AppDelegate.lifeCycleLogger.notice("Scene Did Enter Background")
        PersistenceManager.didEnterBackground()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene Will Enter Foreground")
        PersistenceManager.willEnterForeground()
    }
}