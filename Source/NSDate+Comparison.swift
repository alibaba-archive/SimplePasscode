//
//  NSDate+Comparison.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import Foundation

extension NSDate {
    func minutesUntil(targetDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        let diff = calendar.components([.Minute, .Second], fromDate: self, toDate: targetDate, options: [])
        
        return diff.second > 0 ? diff.minute + 1 : diff.minute
    }
}