//
//  CircleView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/9/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

class CircleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        tintColor = globalTintColor
        
        layer.cornerRadius = diameter / 2
        layer.borderWidth = 1
        layer.borderColor = tintColor.cgColor
        
        backgroundColor = UIColor.clear
    }
    
    var filled: Bool {
        get {
            return backgroundColor == tintColor
        }
        set {
            backgroundColor = newValue ? tintColor : UIColor.clear
        }
    }

    var diameter: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 16
        } else {
            return 12.5
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: diameter, height: diameter)
    }
}
