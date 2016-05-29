//
//  PasscodeDeletionViewController.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

class PasscodeDeletionViewController: UIViewController {
    // MARK: - Private Properties
    private lazy var passcodeInputView: PasscodeInputView! = {
        let inputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        inputView.delegate = self
        
        return inputView
    }()
    
    // MARK: - Public Properties
    var currentPasscode: String! // Needs to be set by caller
    var completionHandler: ((success: Bool) -> Void)?
    
    // MARK: Init & Deinit
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        registerNotificationObservers()
        updateInputView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        passcodeInputView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK: - Register Notification Observers
    private func registerNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appDidEnterBackground(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    // MARK: - UI Config
    private func setupUI() {
        title = NSLocalizedString("Remove Passcode", comment: "Remove Passcode")
        view.backgroundColor = UIColor.backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Plain, target: self, action: #selector(self.cancelButtonTapped))
        
        view.addSubview(passcodeInputView)
        passcodeInputView.snp_remakeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    private func updateInputView() {
        let freezed = FreezeManager.freezed
        passcodeInputView.enabled = !freezed
        
        if freezed {
            view.endEditing(true)
            
            let timeUntilUnfreezed = FreezeManager.timeUntilUnfreezed
            
            if timeUntilUnfreezed == 1 {
                passcodeInputView.title = NSLocalizedString("Try again in 1 minute", comment: "Try again in 1 minute")
            } else {
                passcodeInputView.title = String.localizedStringWithFormat(NSLocalizedString("Try again in %ld minutes", comment: "Try again in %ld minutes"), timeUntilUnfreezed)
            }
        } else {
            passcodeInputView.title = NSLocalizedString("Enter your passcode", comment: "Enter your passcode")
            
            if FreezeManager.currentPasscodeFailures > 0 {
                passcodeInputView.error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attempts", comment: "%ld Failed Passcode Attempts"), FreezeManager.currentPasscodeFailures)

            }
        }
    }
    
    // MARK: - Action Handlers
    func cancelButtonTapped() {
        completionHandler?(success: false)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Notification Handlers
    func keyboardWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardFrameInScreen = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else {
            return
        }
        
        guard let keyboardFrameInWindow = view.window?.convertRect(keyboardFrameInScreen, fromWindow: nil) else {
            return
        }
        
        let keyboardFrameInView = view.convertRect(keyboardFrameInWindow, fromView: nil)
        let bottomOffset = max(view.bounds.height - keyboardFrameInView.origin.y, 0)
        
        guard let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {
            return
        }
        
        guard let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedIntegerValue else {
            return
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: animationCurve << 16), animations: {
            self.passcodeInputView.snp_remakeConstraints { make in
                make.top.equalTo(self.snp_topLayoutGuideBottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-bottomOffset)
            }
            
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func appDidEnterBackground(notification: NSNotification) {
        cancelButtonTapped()
    }
}

// MARK: - PasscodeInputView Delegate
extension PasscodeDeletionViewController: PasscodeInputViewDelegate {
    func passcodeInputView(inputView: PasscodeInputView, didFinishWithPasscode passcode: String) {
        if passcode != currentPasscode {
            inputView.passcode = ""
            
            FreezeManager.incrementPasscodeFailure({ (reachThreshold) in
                if reachThreshold {
                    FreezeManager.freeze()
                    view.endEditing(true)
                }
                
                updateInputView()
                inputView.passcodeField.shake(needsVibration: true, completion: nil)
            })
        } else {
            FreezeManager.clearState()
            completionHandler?(success: true)
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}