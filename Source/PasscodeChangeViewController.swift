//
//  PasscodeChangeViewController.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

class PasscodeChangeViewController: UIViewController {
    enum ChangeStage {
        case VerifyOld
        case Input
        case Confirm
    }
    
    // MARK: - Private Properties
    private var stage: ChangeStage = .VerifyOld
    private var firstPasscode: String?
    private var secondPasscode: String?
    
    private lazy var shiftView: ShiftView<PasscodeInputView>! = {
        let verifyInputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        verifyInputView.delegate = self
        
        let firstInputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        firstInputView.delegate = self
        
        let secondInputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        secondInputView.delegate = self
        
        let viewArray = [verifyInputView, firstInputView, secondInputView]
        let shiftView = ShiftView(managedSubViews: viewArray)

        return shiftView
    }()
    
    // MARK: - Public Properties
    var oldPasscode: String! // Needs to be set by caller
    var completionHandler: ((newPasscode: String?) -> Void)?
    
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
        
        shiftView.currentView.becomeFirstResponder()
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
        title = NSLocalizedString("Change Passcode", comment: "Change Passcode")
        view.backgroundColor = UIColor.backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Plain, target: self, action: #selector(self.cancelButtonTapped))
        
        view.addSubview(shiftView)
        shiftView.snp_remakeConstraints { make in
            make.top.equalTo(view).offset(64)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    private func updateInputView() {
        let freezed = FreezeManager.freezed
        shiftView.currentView.enabled = !freezed
        
        if freezed {
            view.endEditing(true)
            
            let timeUntilUnfreezed = FreezeManager.timeUntilUnfreezed
            
            if timeUntilUnfreezed == 1 {
                shiftView.currentView.title = NSLocalizedString("Try again in 1 minute", comment: "Try again in 1 minute")
            } else {
                shiftView.currentView.title = String.localizedStringWithFormat(NSLocalizedString("Try again in %ld minutes", comment: "Try again in %ld minutes"), timeUntilUnfreezed)
            }
            
            shiftView.currentView.error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attemtps", comment: "%ld Failed Passcode Attemtps"), FreezeManager.currentPasscodeFailures)
        } else {
            shiftView.managedSubViews[0].title = NSLocalizedString("Enter your old passcode", comment: "Enter your old passcode")
            
            if FreezeManager.currentPasscodeFailures > 0 {
                shiftView.managedSubViews[0].error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attempts", comment: "%ld Failed Passcode Attempts"), FreezeManager.currentPasscodeFailures)
            }
            
            shiftView.managedSubViews[1].title = NSLocalizedString("Enter your new passcode", comment: "Enter your new passcode")
            
            if firstPasscode == oldPasscode {
                shiftView.managedSubViews[1].message = NSLocalizedString("Enter a different passcode. Cannot re-use the same passcode", comment: "Enter a different passcode. Cannot re-use the same passcode")
            } else {
                if let _ = secondPasscode {
                    shiftView.managedSubViews[1].message = NSLocalizedString("Passcode did not match.\nTry again", comment: "Passcode did not match.\nTry again")
                } else {
                    shiftView.managedSubViews[1].message = nil
                }
            }
            
            shiftView.managedSubViews[2].title = NSLocalizedString("Re-enter your passcode", comment: "Re-enter your passcode")
        }
    }
    
    // MARK: - Action Handlers
    func cancelButtonTapped() {
        completionHandler?(newPasscode: nil)
        
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
            self.shiftView.snp_remakeConstraints { make in
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
extension PasscodeChangeViewController: PasscodeInputViewDelegate {
    func passcodeInputView(inputView: PasscodeInputView, didFinishWithPasscode passcode: String) {
        if inputView == shiftView.managedSubViews[0] {
            if passcode != oldPasscode {
                inputView.passcode = ""
                
                FreezeManager.incrementPasscodeFailure { reachThreshold in
                    if reachThreshold {
                        FreezeManager.freeze()
                        view.endEditing(true)
                    }
                    
                    updateInputView()
                    inputView.passcodeField.shake(needsVibration: true, completion: nil)
                }
            } else {
                FreezeManager.clearState()
                
                shiftView.managedSubViews[1].passcode = ""
                shiftView.managedSubViews[1].becomeFirstResponder()
                
                shiftView.shift(.Forward)
            }
        } else if inputView == shiftView.managedSubViews[1] {
            firstPasscode = passcode
            
            if passcode == oldPasscode {
                inputView.passcode = ""
                updateInputView()
                inputView.passcodeField.shake(needsVibration: false, completion: nil)
            } else {
                shiftView.managedSubViews[2].passcode = ""
                shiftView.managedSubViews[2].becomeFirstResponder()
                
                shiftView.shift(.Forward)
            }
        } else {
            secondPasscode = passcode
            
            if secondPasscode != firstPasscode {
                shiftView.managedSubViews[1].passcode = ""
                updateInputView()
                shiftView.managedSubViews[1].becomeFirstResponder()
                
                shiftView.shift(.Backward)
            } else {
                FreezeManager.clearState()
                completionHandler?(newPasscode: passcode)
                
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
