//
//  NSDate+Comparison.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import Foundation

extension Date {
    func minutesUntil(_ targetDate: Date) -> Int {
        let calendar = Calendar.current
        
        let diff = (calendar as NSCalendar).components([.minute, .second], from: self, to: targetDate, options: [])
        
        return diff.second! > 0 ? diff.minute! + 1 : diff.minute!
    }
}
