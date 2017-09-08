//
//  Freeze.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import Foundation
import SwiftDate

class FreezeManager {
    fileprivate static var currentEndTimeStamp: Date?
    
    private static let currentPasscodeFailuresKey = "currentPasscodeFailuresKey"
    fileprivate(set) static var currentPasscodeFailures =  UserDefaults.standard.integer(forKey: FreezeManager.currentPasscodeFailuresKey) {
        didSet {
            UserDefaults.standard.set(currentPasscodeFailures, forKey: FreezeManager.currentPasscodeFailuresKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Freeze
    static func clearState() {
        currentEndTimeStamp = nil
        currentPasscodeFailures = 0
    }
    
    static func freeze() {
        var duration: Int
        let now = Date()
        
        if currentPasscodeFailures > maxPasscodeFailures {
            duration = secondFreezeTime
        } else {
            duration = firstFreezeTime
        }
        
        let endTimeStamp = now + duration.seconds
        
        if endTimeStamp > (currentEndTimeStamp ?? Date(timeIntervalSince1970: 0)) {
            currentEndTimeStamp = endTimeStamp
        }
    }
    
    static var freezed: Bool {
        let now = Date()
        
        return now < (currentEndTimeStamp ?? Date(timeIntervalSince1970: 0))
    }
    
    static var chancesRemained: Int {
        return maxPasscodeFailures - currentPasscodeFailures
    }
    
        /// Measured in minutes
    static var timeUntilUnfreezed: Int {
        return Date().minutesUntil(currentEndTimeStamp ?? Date(timeIntervalSince1970: 0))
    }
    
    // MARK: - Passcode
    static func incrementPasscodeFailure(_ completion: (_ reachThreshold: Bool) -> Void) {
        currentPasscodeFailures += 1
        
        completion(currentPasscodeFailures >= maxPasscodeFailures)
    }
}
