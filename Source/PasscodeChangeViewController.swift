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
        case verifyOld
        case input
        case confirm
    }
    
    // MARK: - Private Properties
    fileprivate var stage: ChangeStage = .verifyOld
    fileprivate var firstPasscode: String?
    fileprivate var secondPasscode: String?
    
    fileprivate lazy var shiftView: ShiftView<PasscodeInputView>! = {
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
    var completionHandler: ((_ newPasscode: String?) -> Void)?
    
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
        
        let _ = shiftView.currentView.becomeFirstResponder()
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
        title = NSLocalizedString("Change Passcode", bundle: Bundle(for: type(of: self)), comment: "Change Passcode")
        view.backgroundColor = UIColor.backgroundColor
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: Bundle(for: type(of: self)), comment: "Cancel"), style: .plain, target: self, action: #selector(self.cancelButtonTapped))
        
        view.addSubview(shiftView)
        shiftView.snp.remakeConstraints { make in
            make.top.equalTo(view).offset(64)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    fileprivate func updateInputView() {
        let freezed = FreezeManager.freezed
        shiftView.currentView.enabled = !freezed
        
        if freezed {
            view.endEditing(true)
            
            let timeUntilUnfreezed = FreezeManager.timeUntilUnfreezed
            
            if timeUntilUnfreezed == 1 {
                shiftView.currentView.title = NSLocalizedString("Try again in 1 minute", bundle: Bundle(for: type(of: self)), comment: "Try again in 1 minute")
            } else {
                shiftView.currentView.title = String.localizedStringWithFormat(NSLocalizedString("Try again in %ld minutes", bundle: Bundle(for: type(of: self)), comment: "Try again in %ld minutes"), timeUntilUnfreezed)
            }
            
            shiftView.currentView.error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attempts", bundle: Bundle(for: type(of: self)), comment: "%ld Failed Passcode Attempts"), FreezeManager.currentPasscodeFailures)
        } else {
            shiftView.managedSubViews[0].title = NSLocalizedString("Enter your old passcode", bundle: Bundle(for: type(of: self)), comment: "Enter your old passcode")
            
            if FreezeManager.currentPasscodeFailures > 0 {
                shiftView.managedSubViews[0].error = String.localizedStringWithFormat(NSLocalizedString("%ld Failed Passcode Attempts", bundle: Bundle(for: type(of: self)), comment: "%ld Failed Passcode Attempts"), FreezeManager.currentPasscodeFailures)
            }
            
            shiftView.managedSubViews[1].title = NSLocalizedString("Enter your new passcode", bundle: Bundle(for: type(of: self)), comment: "Enter your new passcode")
            
            if firstPasscode == oldPasscode {
                shiftView.managedSubViews[1].message = NSLocalizedString("Enter a different passcode. Cannot re-use the same passcode", bundle: Bundle(for: type(of: self)), comment: "Enter a different passcode. Cannot re-use the same passcode")
            } else {
                if let _ = secondPasscode {
                    shiftView.managedSubViews[1].message = NSLocalizedString("Passcode did not match.\nTry again", bundle: Bundle(for: type(of: self)), comment: "Passcode did not match.\nTry again")
                } else {
                    shiftView.managedSubViews[1].message = nil
                }
            }
            
            shiftView.managedSubViews[2].title = NSLocalizedString("Re-enter your passcode", bundle: Bundle(for: type(of: self)), comment: "Re-enter your passcode")
        }
    }
    
    // MARK: - Action Handlers
    func cancelButtonTapped() {
        completionHandler?(nil)
        
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
            self.shiftView.snp.remakeConstraints { make in
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
extension PasscodeChangeViewController: PasscodeInputViewDelegate {
    func passcodeInputView(_ inputView: PasscodeInputView, didFinishWithPasscode passcode: String) {
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
                let _ = shiftView.managedSubViews[1].becomeFirstResponder()
                
                shiftView.shift(.forward)
            }
        } else if inputView == shiftView.managedSubViews[1] {
            firstPasscode = passcode
            
            if passcode == oldPasscode {
                inputView.passcode = ""
                updateInputView()
                inputView.passcodeField.shake(needsVibration: false, completion: nil)
            } else {
                shiftView.managedSubViews[2].passcode = ""
                let _ = shiftView.managedSubViews[2].becomeFirstResponder()
                
                shiftView.shift(.forward)
            }
        } else {
            secondPasscode = passcode
            
            if secondPasscode != firstPasscode {
                shiftView.managedSubViews[1].passcode = ""
                updateInputView()
                let _ = shiftView.managedSubViews[1].becomeFirstResponder()
                
                shiftView.shift(.backward)
            } else {
                FreezeManager.clearState()
                completionHandler?(passcode)
                
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
