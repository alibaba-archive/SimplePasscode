//
//  PasscodeInputView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol PasscodeInputViewDelegate {
    func passcodeInputView(inputView: PasscodeInputView, didFinishWithPasscode passcode: String)
}

class PasscodeInputView: UIView {
    // MARK: - Private Properties
    private let passcodeLength = 4

    private(set) lazy var passcodeField: PasscodeField! = {
        let passcodeField = PasscodeField(length: self.passcodeLength, frame: .zero)
        
        passcodeField.delegate = self
        passcodeField.addTarget(self, action: #selector(self.passcodeFieldEditingChanged(_:)), forControlEvents: .EditingChanged)
        
        return passcodeField
    }()
    
    private lazy var titleLabel: UILabel! = {
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont.boldSystemFontOfSize(15)
        titleLabel.textAlignment = .Center
        
        return titleLabel
    }()
    
    private lazy var messageLabel: UILabel! = {
        let messageLabel = UILabel()
        
        messageLabel.font = UIFont.systemFontOfSize(15)
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .ByWordWrapping
        
        messageLabel.hidden = true
        
        return messageLabel
    }()
    
    private lazy var errorLabel: UILabel! = {
        let errorLabel = UILabel()
        
        errorLabel.font = UIFont.systemFontOfSize(15)
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.backgroundColor = UIColor(red: 0.63, green: 0.2, blue: 0.13, alpha: 1)
        errorLabel.textAlignment = .Center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .ByWordWrapping
        
        errorLabel.layer.cornerRadius = 10.0
        errorLabel.clipsToBounds = true
        
        errorLabel.hidden = true
        
        return errorLabel
    }()
    
    // MARK: - Public Properties
    weak var delegate: PasscodeInputViewDelegate?
    var enabled = true
    
    var passcode: String {
        get {
            return passcodeField.passcode
        }
        
        set {
            passcodeField.passcode = newValue
        }
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var message: String? {
        get {
            return messageLabel.text
        }
        set {
            messageLabel.text = newValue
            
            messageLabel.hidden = false
            errorLabel.hidden = true
        }
    }
    
    var error: String? {
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
            
            errorLabel.hidden = false
            messageLabel.hidden = true
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: - Common Initialization Logic
    private func setup() {
        addSubview(passcodeField)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(errorLabel)
    }
    
    // MARK: - Autolayout
    override func updateConstraints() {
        // TODO:
        passcodeField.snp_remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        titleLabel.snp_remakeConstraints { make in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.bottom.equalTo(passcodeField.snp_top).offset(-30)
        }
        
        messageLabel.snp_remakeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(passcodeField.snp_bottom).offset(30)
        }
        
        errorLabel.snp_remakeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(passcodeField.snp_bottom).offset(30)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UIResponder
    override func canBecomeFirstResponder() -> Bool {
        return enabled && passcodeField.canBecomeFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        return enabled && passcodeField.becomeFirstResponder()
    }
    
    override func canResignFirstResponder() -> Bool {
        return passcodeField.canResignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        passcodeField.becomeFirstResponder()
    }
    
    // MARK: - Action Handlers
    func passcodeFieldEditingChanged(sender: AnyObject) {
        if passcodeField.passcode.characters.count == passcodeField.passcodeLength {
            delegate?.passcodeInputView(self, didFinishWithPasscode: passcodeField.passcode)
        }
    }
}

// MARK: - PasscodeField Delegate
extension PasscodeInputView: PasscodeFieldDelegate {
    func passcodeField(passcodeField: PasscodeField, shouldInsertText text: String) -> Bool {
        return enabled
    }
    
    func passcodeField(passcodeField: PasscodeField, shouldDeleteBackwardText text: String) -> Bool {
        return enabled
    }
}