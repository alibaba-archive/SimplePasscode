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
    func passcodeInputView(_ inputView: PasscodeInputView, didFinishWithPasscode passcode: String)
}

class PasscodeInputView: UIView {
    // MARK: - Private Properties
    let passcodeLength: Int
    
    fileprivate(set) lazy var passcodeField: PasscodeField! = {
        let passcodeField = PasscodeField(length: self.passcodeLength, frame: .zero)
        
        passcodeField.delegate = self
        passcodeField.addTarget(self, action: #selector(self.passcodeFieldEditingChanged(_:)), for: .editingChanged)
        
        return passcodeField
    }()
    
    fileprivate lazy var titleLabel: UILabel! = {
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    fileprivate lazy var messageLabel: UILabel! = {
        let messageLabel = UILabel()
        
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        messageLabel.isHidden = true
        
        return messageLabel
    }()
    
    fileprivate lazy var errorLabel: PaddingLabel! = {
        let errorLabel = PaddingLabel(padding: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
        
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.textColor = UIColor.white
        errorLabel.backgroundColor = UIColor(red: 0.63, green: 0.2, blue: 0.13, alpha: 1)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        
        errorLabel.layer.cornerRadius = 10.0
        errorLabel.clipsToBounds = true
        
        errorLabel.isHidden = true
        
        return errorLabel
    }()
    
    // MARK: - Public Properties
    weak var delegate: PasscodeInputViewDelegate?
    var enabled = true {
        didSet {
            passcodeField.isEnabled = enabled
        }
    }
    
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
            
            messageLabel.isHidden = false
            errorLabel.isHidden = true
        }
    }
    
    var error: String? {
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
            
            errorLabel.isHidden = false
            messageLabel.isHidden = true
        }
    }
    
    // MARK: - Initializers
    init(passcodeLength: Int) {
        precondition(passcodeLength > 0, "Passcode's length should be positive")
        
        self.passcodeLength = passcodeLength
        
        super.init(frame: .zero)
        
        setup()
    }
    
    override init(frame: CGRect) {
        fatalError("Call init(passcodeLength:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Common Initialization Logic
    fileprivate func setup() {
        addSubview(passcodeField)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(errorLabel)
    }
    
    // MARK: - Autolayout
    override func updateConstraints() {
        passcodeField.snp.remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        titleLabel.snp.remakeConstraints { make in
            make.left.greaterThanOrEqualTo(self).offset(15)
            make.right.lessThanOrEqualTo(self).offset(-15)
            make.centerX.equalTo(self)
            make.bottom.equalTo(passcodeField.snp.top).offset(-30)
        }
        
        messageLabel.snp.remakeConstraints { make in
            make.left.greaterThanOrEqualTo(self).offset(15)
            make.right.lessThanOrEqualTo(self).offset(-15)
            make.centerX.equalTo(self)
            make.top.equalTo(passcodeField.snp.bottom).offset(30)
        }
        
        errorLabel.snp.remakeConstraints { make in
            make.left.greaterThanOrEqualTo(self).offset(15)
            make.right.lessThanOrEqualTo(self).offset(-15)
            make.centerX.equalTo(self)
            make.top.equalTo(passcodeField.snp.bottom).offset(30)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UIResponder
    override var canBecomeFirstResponder : Bool {
        return enabled && passcodeField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return enabled && passcodeField.becomeFirstResponder()
    }
    
    override var canResignFirstResponder : Bool {
        return passcodeField.canResignFirstResponder
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        passcodeField.becomeFirstResponder()
    }
    
    // MARK: - Action Handlers
    @objc func passcodeFieldEditingChanged(_ sender: AnyObject) {
        if passcodeField.passcode.count == passcodeField.passcodeLength {
            delegate?.passcodeInputView(self, didFinishWithPasscode: passcodeField.passcode)
        }
    }
}

// MARK: - PasscodeField Delegate
extension PasscodeInputView: PasscodeFieldDelegate {
    func passcodeField(_ passcodeField: PasscodeField, shouldInsertText text: String) -> Bool {
        return enabled
    }
    
    func passcodeField(_ passcodeField: PasscodeField, shouldDeleteBackwardText text: String) -> Bool {
        return enabled
    }
}
