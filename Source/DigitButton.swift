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
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 82
        } else {
            return 75
        }
    }
    
    var digitFont: UIFont {
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            return UIFont.systemFont(ofSize: 41)
        } else {
            return UIFont.systemFont(ofSize: 36)
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
    fileprivate func setupUI() {
        tintColor = UIColor.customTintColor
        
        layer.cornerRadius = diameter / 2
        layer.borderWidth = 1
        layer.borderColor = tintColor.cgColor
        
        digitLabel = UILabel()
        digitLabel.text = "\(digit)"
        digitLabel.textAlignment = .center
        digitLabel.font = digitFont
        digitLabel.textColor = tintColor
        
        addSubview(digitLabel)
        digitLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = tintColor
                digitLabel.textColor = UIColor.white
            } else {
                backgroundColor = UIColor.clear
                digitLabel.textColor = tintColor
            }
        }
    }
    
    // MARK: - AutoLayout
    override var intrinsicContentSize : CGSize {
        return CGSize(width: diameter, height: diameter)
    } 
}
