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
    private static var currentEndTimeStamp: NSDate?
    private(set) static var currentTouchIDFailures = 0
    private(set) static var currentPasscodeFailures = 0
    
    // MARK: - Freeze
    static func clearState() {
        currentEndTimeStamp = nil
        currentTouchIDFailures = 0
        currentPasscodeFailures = 0
    }
    
    static func freeze() {
        var duration: Int
        let now = NSDate()
        
        if currentPasscodeFailures > maxPasscodeFailures {
            duration = secondFreezeTime
        } else {
            duration = firstFreezeTime
        }
        
        let endTimeStamp = now + duration.seconds
        
        if endTimeStamp > (currentEndTimeStamp ?? NSDate(timeIntervalSince1970: 0)) {
            currentEndTimeStamp = endTimeStamp
        }
    }
    
    static var freezed: Bool {
        let now = NSDate()
        
        return now < (currentEndTimeStamp ?? NSDate(timeIntervalSince1970: 0))
    }
    
        /// Measured in minutes
    static var timeUntilUnfreezed: Int {
        return NSDate().minutesUntil(currentEndTimeStamp ?? NSDate(timeIntervalSince1970: 0))
    }
    
    // MARK: - TouchID
    static func incrementTouchIDFailure(@noescape completion: (reachThreshold: Bool) -> Void) {
        currentTouchIDFailures += 1
        
        completion(reachThreshold: currentTouchIDFailures >= maxTouchIDFailures)
    }
    
    // MARK: - Passcode
    static func incrementPasscodeFailure(@noescape completion: (reachThreshold: Bool) -> Void) {
        currentPasscodeFailures += 1
        
        completion(reachThreshold: currentPasscodeFailures >= maxPasscodeFailures)
    }
}
