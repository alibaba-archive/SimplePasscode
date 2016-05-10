//
//  LockscreenManager.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

public class LockScreenManager {
    private static var isShowingLockScreen = false
    private static var authenticationViewController: AuthenticationViewController!
    
    public static func showLockScreen(passcode passcode: String, completion: (authenticationSuccess: Bool) -> Void) {
        guard !isShowingLockScreen else {
            return
        }
        
        authenticationViewController = AuthenticationViewController()
        authenticationViewController.currentPasscode = passcode
        authenticationViewController.completionHandler = completion
        
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(authenticationViewController, animated: true, completion: nil)
        
        isShowingLockScreen = true
    }
    
    public static func hideLockScreen() {
        guard isShowingLockScreen else {
            return
        }
        
        
                UIApplication.sharedApplication().keyWindow!.rootViewController!.dismissViewControllerAnimated(false, completion: {
                    authenticationViewController = nil
                    isShowingLockScreen = false
                })

    }
}
