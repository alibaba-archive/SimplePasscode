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
    fileprivate lazy var passcodeInputView: PasscodeInputView! = {
        let inputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        inputView.delegate = self
        
        return inputView
    }()
    
    // MARK: - Public Properties
    var currentPasscode: String! // Needs to be set by caller
    var completionHandler: ((_ success: Bool) -> Void)?
    
    // MARK: Init & Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        registerNotificationObservers()
        updateInputView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let _ = passcodeInputView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK: - Register Notification Observers
    fileprivate func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - UI Config
    fileprivate func setupUI() {
        title = NSLocalizedString("Remove Passcode", bundle: Bundle(for: type(of: self)), comment: "Remove Passcode")
        view.backgroundColor = UIColor.backgroundColor
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: Bundle(for: type(of: self)), comment: "Cancel"), style: .plain, target: self, action: #selector(self.cancelButtonTapped))
        
        view.addSubview(passcodeInputView)
        passcodeInputView.snp.remakeConstraints { make in
            make.top.equalTo(view).offset(64)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    fileprivate func updateInputView() {
        let freezed = FreezeManager.freezed
        passcodeInputView.enabled = !freezed
        
        if freezed {
            view.endEditing(true)
            
            let timeUntilUnfreezed = FreezeManager.timeUntilUnfreezed
            
            if timeUntilUnfreezed == 1 {
                passcodeInputView.title = NSLocalizedString("Try again in 1 minute", bundle: Bundle(for: type(of: self)), comment: "Try again in 1 minute")
            } else {
                passcodeInputView.title = String.localizedStringWithFormat(NSLocalizedString("Try again in %ld minutes", bundle: Bundle(for: type(of: self)), comment: "Try again in %ld minutes"), timeUntilUnfreezed)
            }
        } else {
            passcodeInputView.title = NSLocalizedString("Enter your passcode", bundle: Bundle(for: type(of: self)), comment: "Enter your passcode")
            
            if FreezeManager.currentPasscodeFailures > 0 {
                passcodeInputView.error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attempts", bundle: Bundle(for: type(of: self)), comment: "%ld Failed Passcode Attempts"), FreezeManager.currentPasscodeFailures)

            }
        }
    }
    
    // MARK: - Action Handlers
    func cancelButtonTapped() {
        completionHandler?(false)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Notification Handlers
    func keyboardWillChange(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        
        guard let keyboardFrameInScreen = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        
        guard let keyboardFrameInWindow = view.window?.convert(keyboardFrameInScreen, from: nil) else {
            return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrameInWindow, from: nil)
        let bottomOffset = max(view.bounds.height - keyboardFrameInView.origin.y, 0)
        
        guard let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
            return
        }
        
        guard let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).uintValue else {
            return
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: animationCurve << 16), animations: {
            self.passcodeInputView.snp.remakeConstraints { make in
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-bottomOffset)
            }
            
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func appDidEnterBackground(_ notification: Notification) {
        cancelButtonTapped()
    }
}

// MARK: - PasscodeInputView Delegate
extension PasscodeDeletionViewController: PasscodeInputViewDelegate {
    func passcodeInputView(_ inputView: PasscodeInputView, didFinishWithPasscode passcode: String) {
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
            completionHandler?(true)
            
            dismiss(animated: true, completion: nil)
        }
    }
}
