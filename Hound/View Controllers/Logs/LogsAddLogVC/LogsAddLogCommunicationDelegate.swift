//
//  LogsAddLogCommunicationDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/15/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol LogsAddLogCommunicationDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}
