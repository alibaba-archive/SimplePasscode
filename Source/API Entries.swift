//
//  SimplePasscodeManager.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/7/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import LocalAuthentication


// MARK: - Passcode Options
var allowTouchID = false
var maxTouchIDFailures = 3
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
public func setup(allowTouchID allowTouchID: Bool = true, maxTouchIDFailures: Int = 3, maxPasscodeFailures: Int = 6, firstFreezeTime: Int = 60, secondFreezeTime: Int = 60 * 5) {
    if allowTouchID {
        let authenticationContext = LAContext()
        
        if authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            SimplePasscode.allowTouchID = true
        } else {
            SimplePasscode.allowTouchID = false
        }
    } else {
        SimplePasscode.allowTouchID = false
    }
    
    SimplePasscode.maxTouchIDFailures = maxTouchIDFailures
    SimplePasscode.maxPasscodeFailures = maxPasscodeFailures
    SimplePasscode.firstFreezeTime = firstFreezeTime
    SimplePasscode.secondFreezeTime = secondFreezeTime
}

public func createNewPasscode(presentingViewController presentingViewController: UIViewController, completion: (newPasscode: String?) -> Void) {
    let passcodeCreationViewController = PasscodeCreationViewController()
    passcodeCreationViewController.completionHandler = completion
    
    let navigationController = UINavigationController(rootViewController: passcodeCreationViewController)
    navigationController.modalPresentationStyle = .CurrentContext
    
    presentingViewController.presentViewController(navigationController, animated: true, completion: nil)
}

public func changePasscode(presentingViewController presentingViewController: UIViewController, currentPasscode: String, completion: (newPasscode: String?) -> Void) {
    let passcodeChangeViewController = PasscodeChangeViewController()
    passcodeChangeViewController.completionHandler = completion
    passcodeChangeViewController.oldPasscode = currentPasscode
    
    let navigationController = UINavigationController(rootViewController: passcodeChangeViewController)
    navigationController.modalPresentationStyle = .CurrentContext
    
    presentingViewController.presentViewController(navigationController, animated: true, completion: nil)
}

public func deletePasscode(presentingViewController presentingViewController: UIViewController, currentPasscode: String, completion: (success: Bool) -> Void) {
    
}

public func clearState() {
    FreezeManager.clearState()
}

public func authenticateIdentity(passcode: String, completion: (success: Bool) -> Void) {
    
}



public func test() {
    let authenticationContext = LAContext()
    let authenticationReason = "Verify your identify to continue"
    
    if authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
        authenticationContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: { (success, error) in
            if success {
                print("Authenticated")
            } else {
                print("Faile to authenticate")
            }
        })
    }
}