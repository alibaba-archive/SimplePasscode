//
//  PasscodeField.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

@objc protocol PasscodeFieldDelegate {
    func passcodeField(_ passcodeField: PasscodeField, shouldInsertText text: String) -> Bool
    func passcodeField(_ passcodeField: PasscodeField, shouldDeleteBackwardText text: String) -> Bool
}

class PasscodeField: UIControl {
    // MARK: - Private Properties
    fileprivate let dotSize = CGSize(width: 18, height: 18)
    fileprivate let dotSpacing: CGFloat = 25
    fileprivate let lineHeight: CGFloat = 3
    fileprivate let symbolColor = UIColor.black
    
    fileprivate var _passcode = ""
    fileprivate let nonDigitRegex = try! NSRegularExpression(pattern: "[^0-9]+", options: [])
    
    // MARK: - Public Properties
    let passcodeLength: Int

    var passcode: String {
        get {
            return _passcode
        }
        
        set {
            if (newValue.count > passcodeLength) {
                _passcode = String(newValue[..<newValue.index(newValue.startIndex, offsetBy: passcodeLength)])
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
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        
        addTarget(self, action: #selector(self.didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    // MARK: - Autolayout
    override var intrinsicContentSize : CGSize {
        return CGSize(width: CGFloat(passcodeLength) * dotSize.width + (CGFloat(passcodeLength) - 1) * dotSpacing, height: dotSize.height)
    }
    
    // MARK: - UIResponder
    override var canBecomeFirstResponder : Bool {
        return self.isEnabled
    }
    
    // MARK: - Action Handlers
    @objc func didTouchUpInside(_ sender: AnyObject) {
        becomeFirstResponder()
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        let canvasSize = intrinsicContentSize
        
        let origin = CGPoint(x: rect.midX - canvasSize.width / 2, y: rect.midY - canvasSize.height / 2)
        
        var currentPoint = origin
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(symbolColor.cgColor)
        
        for i in 0..<passcodeLength {
            if i < _passcode.count {
                // Draw circle
                let circleFrame = CGRect(x: currentPoint.x, y: currentPoint.y, width: dotSize.width, height: dotSize.height)
                context.fillEllipse(in: circleFrame)
            } else {
                // Draw line
                let lineFrame = CGRect(x: currentPoint.x, y: currentPoint.y + floor((dotSize.height - lineHeight) / 2), width: dotSize.width, height: lineHeight)
                context.fill(lineFrame)
            }
            
            currentPoint.x += dotSize.width + dotSpacing
        }
    }
}

// MARK: - UIKeyInput
extension PasscodeField: UIKeyInput {
    var hasText : Bool {
        return _passcode.count > 0
    }
    
    func insertText(_ text: String) {
        let filteredtext = nonDigitRegex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "")
        
        guard isEnabled && filteredtext.count > 0 else {
            return
        }

        guard _passcode.count + filteredtext.count <= passcodeLength else {
            return
        }
        
        guard delegate?.passcodeField(self, shouldInsertText: filteredtext) ?? true else {
            return
        }
        
        passcode = _passcode + filteredtext
        
        sendActions(for: .editingChanged)
    }
    
    func deleteBackward() {
        guard isEnabled && _passcode.count > 0 else {
            return
        }
        
        guard delegate?.passcodeField(self, shouldDeleteBackwardText: _passcode) ?? true else {
            return
        }
      
        passcode = String(_passcode[..<_passcode.index(before: _passcode.endIndex)])
        
        sendActions(for: .editingChanged)
    }
    
    var keyboardType: UIKeyboardType {
        get {
            return .numberPad
        }
        set {
            // Do nothing
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType {
        get {
            return .no
        }
        set {
            // Do nothing
        }
    }
    
    var spellCheckingType: UITextSpellCheckingType {
        get {
            return .no
        }
        set {
            // Do nothing
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        get {
            return .default
        }
        set {
            // Do nothing
        }
    }
}
