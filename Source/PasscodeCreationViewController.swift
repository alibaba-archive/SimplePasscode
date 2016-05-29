//
//  PasscodeCreationViewController.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

class PasscodeCreationViewController: UIViewController {
    enum CreationStage {
        case First
        case Confirm
    }
    
    // MARK: - Private Properties
    private var stage: CreationStage = .First
    private var firstPasscode: String?
    private var secondPasscode: String?
    
    private lazy var shiftView: ShiftView<PasscodeInputView>! = {
        let firstInputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        firstInputView.delegate = self
        
        let secondInputView = PasscodeInputView(passcodeLength: SimplePasscode.passcodeLength)
        secondInputView.delegate = self
        
        let viewArray = [firstInputView, secondInputView]
        let shiftView = ShiftView(managedSubViews: viewArray)
        
        return shiftView
    }()
    
    // MARK: Public Properties
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
        title = NSLocalizedString("New Passcode", comment: "New Passcode")
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
            let timeUntilUnfreezed = FreezeManager.timeUntilUnfreezed
            
            if timeUntilUnfreezed == 1 {
                shiftView.currentView.title = NSLocalizedString("Try again in 1 minute", comment: "Try again in 1 minute")
            } else {
                shiftView.currentView.title = String.localizedStringWithFormat(NSLocalizedString("Try again in %ld minutes", comment: "Try again in %ld minutes"), timeUntilUnfreezed)
            }
            
            shiftView.currentView.error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attemtps", comment: "%ld Failed Passcode Attemtps"), FreezeManager.currentPasscodeFailures)
        } else {
            shiftView.managedSubViews.first!.title = NSLocalizedString("Enter a passcode", comment: "Enter a passcode")
            
            if let _ = secondPasscode {
                shiftView.managedSubViews.first!.message = NSLocalizedString("Passcode did not match.\nTry again", comment: "Passcode did not match.\nTry again")
            }
            shiftView.managedSubViews.last!.title = NSLocalizedString("Re-enter your passcode", comment: "Re-enter your passcode")
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
extension PasscodeCreationViewController: PasscodeInputViewDelegate {
    func passcodeInputView(inputView: PasscodeInputView, didFinishWithPasscode passcode: String) {
        if inputView == shiftView.managedSubViews.first {
            firstPasscode = passcode
            shiftView.managedSubViews.last!.passcode = ""
            shiftView.managedSubViews.last!.becomeFirstResponder()
            
            shiftView.shift(.Forward)
        } else {
            secondPasscode = passcode
            
            if secondPasscode != firstPasscode {
                shiftView.managedSubViews.first!.passcode = ""
                updateInputView()
                shiftView.managedSubViews.first!.becomeFirstResponder()
                
                shiftView.shift(.Backward)
            } else {
                FreezeManager.clearState()
                completionHandler?(newPasscode: passcode)
                
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}