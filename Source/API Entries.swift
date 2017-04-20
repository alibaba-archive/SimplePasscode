//
//  SimplePasscodeManager.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/7/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import LocalAuthentication


public var globalTintColor = UIColor.customTintColor

// MARK: - Passcode Options
var passcodeLength = 4
var allowTouchID = true
var maxPasscodeFailures = 6
var firstFreezeTime = 60
var secondFreezeTime = 60 * 5

/**
 Call this method in applicationDidFinishLaunching(_:) to configure the options
 
 - parameter allowTouchID:        If this option is on, TouchID is used if possible in authentication first. User needs to provide passcode if TouchID authentication fails.
 - parameter maxTouchIDFailures:  The maximum number of times user can try during TouchID authentication.
 - parameter maxPasscodeFailures: The maximum number of times user can try during passcode authentication.
 - parameter firstFreezeTime: The first freeze time of passcode related function when user reached the maximum number of failures in unlocked state. The time duration is measured in seconds. During freeze time, user cannot create, change or delete passcode.
 - parameter secondFreezeTime: The second freeze time when user fails the authentication after the first freeze time passed. The time duration is measured in seconds. This duration should be longer than the first freeze time.
 */
public func setup(allowTouchID: Bool = true, passcodeLength: Int = 4, maxPasscodeFailures: Int = 6, firstFreezeTime: Int = 60, secondFreezeTime: Int = 60 * 5) {
    setAllowTouchID(allowTouchID)
    
    SimplePasscode.passcodeLength = passcodeLength
    SimplePasscode.maxPasscodeFailures = maxPasscodeFailures
    SimplePasscode.firstFreezeTime = firstFreezeTime
    SimplePasscode.secondFreezeTime = secondFreezeTime
}

public func setAllowTouchID(_ allowTouchID: Bool) {
    if allowTouchID {
        let authenticationContext = LAContext()
        
        SimplePasscode.allowTouchID = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    } else {
        SimplePasscode.allowTouchID = false
    }
}

public func createNewPasscode(presentingViewController: UIViewController, completion: @escaping (_ newPasscode: String?) -> Void) {
    let passcodeCreationViewController = PasscodeCreationViewController()
    passcodeCreationViewController.completionHandler = completion
    
    let navigationController = UINavigationController(rootViewController: passcodeCreationViewController)
    navigationController.modalPresentationStyle = .currentContext
    
    presentingViewController.present(navigationController, animated: true, completion: nil)
}

public func changePasscode(presentingViewController: UIViewController, currentPasscode: String, completion: @escaping (_ newPasscode: String?) -> Void) {
    let passcodeChangeViewController = PasscodeChangeViewController()
    passcodeChangeViewController.completionHandler = completion
    passcodeChangeViewController.oldPasscode = currentPasscode
    
    let navigationController = UINavigationController(rootViewController: passcodeChangeViewController)
    navigationController.modalPresentationStyle = .currentContext
    
    presentingViewController.present(navigationController, animated: true, completion: nil)
}

public func deletePasscode(presentingViewController: UIViewController, currentPasscode: String, completion: @escaping (_ success: Bool) -> Void) {
    let passcodeDeletionViewController = PasscodeDeletionViewController()
    passcodeDeletionViewController.currentPasscode = currentPasscode
    passcodeDeletionViewController.completionHandler = completion
    
    let navigationController = UINavigationController(rootViewController: passcodeDeletionViewController)
    navigationController.modalPresentationStyle = .currentContext
    
    presentingViewController.present(navigationController, animated: true, completion: nil)
}

public func clearState() {
    FreezeManager.clearState()
}
