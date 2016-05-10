//
//  NumButton.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/10/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

class DigitButton: UIButton {
    // MARK: - Properties
    let digit: Int
    var digitLabel: UILabel!
    
    var diameter: CGFloat {
        if traitCollection.verticalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Regular {
            return 82
        } else {
            return 75
        }
    }
    
    var digitFont: UIFont {
        if traitCollection.verticalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Regular {
            return UIFont.systemFontOfSize(41)
        } else {
            return UIFont.systemFontOfSize(36)
        }
    }
    
    // MARK: - Init & Deinit
    init(digit: Int) {
        precondition((0...9).contains(digit), "Invalid digit")
        
        self.digit = digit
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        fatalError("Call init(passcodeLength:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Config
    private func setupUI() {
        tintColor = UIColor.customTintColor
        
        layer.cornerRadius = diameter / 2
        layer.borderWidth = 1
        layer.borderColor = tintColor.CGColor
        
        digitLabel = UILabel()
        digitLabel.text = "\(digit)"
        digitLabel.textAlignment = .Center
        digitLabel.font = digitFont
        digitLabel.textColor = tintColor
        
        addSubview(digitLabel)
        digitLabel.snp_makeConstraints { make in
            make.center.equalTo(self)
        }
        
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = tintColor
                digitLabel.textColor = UIColor.whiteColor()
            } else {
                backgroundColor = UIColor.clearColor()
                digitLabel.textColor = tintColor
            }
        }
    }
    
    // MARK: - AutoLayout
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: diameter, height: diameter)
    }
    
}
