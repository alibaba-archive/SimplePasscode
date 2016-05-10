//
//  UIColor+Pallette.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/9/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat = 1) {
        let red: CGFloat = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green: CGFloat = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue: CGFloat = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static var backgroundColor: UIColor {
        return UIColor(rgb: 0xF4F4F4)
    }
    
    static var customTintColor: UIColor {
        return UIColor(rgb: 0x03A9F4)
    }
}