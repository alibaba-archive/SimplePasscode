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
    
    private func setupUI() {
        tintColor = UIColor.customTintColor
        
        layer.cornerRadius = diameter / 2
        layer.borderWidth = 1
        layer.borderColor = tintColor.CGColor
        
        backgroundColor = UIColor.clearColor()
    }
    
    var filled: Bool {
        get {
            return backgroundColor == tintColor
        }
        set {
            backgroundColor = newValue ? tintColor : UIColor.clearColor()
        }
    }

    var diameter: CGFloat {
        if traitCollection.verticalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Regular {
            return 16
        } else {
            return 12.5
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: diameter, height: diameter)
    }
}
