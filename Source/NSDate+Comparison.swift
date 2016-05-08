//
//  NSDate+Comparison.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import Foundation

func -(lhs: NSDate, rhs: NSDate) -> NSDateComponents {
    let calendar = NSCalendar.currentCalendar()
    
    return calendar.components([.Day, .Hour, .Minute, .Second], fromDate: rhs, toDate: lhs, options: [])
}