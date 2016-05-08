//
//  PasscodeField.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

@objc protocol PasscodeFieldDelegate {
    func passcodeField(passcodeField: PasscodeField, shouldInsertText text: String) -> Bool
    func passcodeField(passcodeField: PasscodeField, shouldDeleteBackwardText text: String) -> Bool
}

class PasscodeField: UIControl {
    // MARK: - Private Properties
    private let dotSize = CGSize(width: 18, height: 18)
    private let dotSpacing: CGFloat = 25
    private let lineHeight: CGFloat = 3
    private let symbolColor = UIColor.blackColor()
    
    private var _passcode = ""
    private let nonDigitRegex = try! NSRegularExpression(pattern: "[^0-9]+", options: [])
    
    // MARK: - Public Properties
    let passcodeLength: Int

    var passcode: String {
        get {
            return _passcode
        }
        
        set {
            if (newValue.characters.count > passcodeLength) {
                _passcode = newValue.substringToIndex(newValue.startIndex.advancedBy(passcodeLength))
            } else {
                _passcode = newValue
            }
            
            setNeedsDisplay()
        }
    }
    
    weak var delegate: PasscodeFieldDelegate?
    
    // MARK: - Initializers
    init(length: Int, frame: CGRect) {
        precondition(length > 0, "Passcode's lengh should be greater than zero")
        passcodeLength = length
        
        super.init(frame: frame)
        
        setup()
    }
    
    convenience override init(frame: CGRect) {
        self.init(length: 4, frame: frame)
    }
    
    convenience init() {
        self.init(length: 4, frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        passcodeLength = 4
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: - Common Initialization Logic
    private func setup() {
        backgroundColor = UIColor.clearColor()
        
        addTarget(self, action: #selector(self.didTouchUpInside(_:)), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Autolayout
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: CGFloat(passcodeLength) * dotSize.width + (CGFloat(passcodeLength) - 1) * dotSpacing, height: dotSize.height)
    }
    
    // MARK: - UIResponder
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: - Action Handlers
    func didTouchUpInside(sender: AnyObject) {
        becomeFirstResponder()
    }
    
    // MARK: - Drawing
    override func drawRect(rect: CGRect) {
        let canvasSize = intrinsicContentSize()
        
        let origin = CGPoint(x: rect.midX - canvasSize.width / 2, y: rect.midY - canvasSize.height / 2)
        
        var currentPoint = origin
        
        let context = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, symbolColor.CGColor)
        
        for i in 0..<passcodeLength {
            if i < _passcode.characters.count {
                // Draw circle
                let circleFrame = CGRect(x: currentPoint.x, y: currentPoint.y, width: dotSize.width, height: dotSize.height)
                CGContextFillEllipseInRect(context, circleFrame)
            } else {
                // Draw line
                let lineFrame = CGRect(x: currentPoint.x, y: currentPoint.y + floor((dotSize.height - lineHeight) / 2), width: dotSize.width, height: lineHeight)
                CGContextFillRect(context, lineFrame)
            }
            
            currentPoint.x += dotSize.width + dotSpacing
        }
    }
}

// MARK: - UIKeyInput
extension PasscodeField: UIKeyInput {
    func hasText() -> Bool {
        return _passcode.characters.count > 0
    }
    
    func insertText(text: String) {
        let filteredtext = nonDigitRegex.stringByReplacingMatchesInString(text, options: [], range: NSRange(location: 0, length: text.characters.count), withTemplate: "")
        
        guard enabled && filteredtext.characters.count > 0 else {
            return
        }

        guard _passcode.characters.count + filteredtext.characters.count <= passcodeLength else {
            return
        }
        
        guard delegate?.passcodeField(self, shouldInsertText: filteredtext) ?? true else {
            return
        }
        
        passcode = _passcode + filteredtext
        
        sendActionsForControlEvents(.EditingChanged)
    }
    
    func deleteBackward() {
        guard enabled && _passcode.characters.count > 0 else {
            return
        }
        
        guard delegate?.passcodeField(self, shouldDeleteBackwardText: _passcode) ?? true else {
            return
        }
        
        passcode = _passcode.substringToIndex(_passcode.endIndex.predecessor())
        
        sendActionsForControlEvents(.EditingChanged)
    }
    
    var keyboardType: UIKeyboardType {
        get {
            return .NumberPad
        }
        set {
            // Do nothing
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType {
        get {
            return .No
        }
        set {
            // Do nothing
        }
    }
    
    var spellCheckingType: UITextSpellCheckingType {
        get {
            return .No
        }
        set {
            // Do nothing
        }
    }
    
    var secureTextEntry: Bool {
        get {
            return true
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        get {
            return .Default
        }
        set {
            // Do nothing
        }
    }
}
