//
//  ViewController.swift
//  Sample Project
//
//  Created by Zhu Shengqi on 5/7/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SimplePasscode

class ViewController: UIViewController {

//    @IBOutlet weak var label: UILabel!
    
    var numPadView: NumPadView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func buttonTapped(sender: AnyObject) {
        LockScreenManager.showLockScreen(passcode: "1111") { (authenticationSuccess) in
            print(authenticationSuccess)
            LockScreenManager.hideLockScreen()
        }
    }
}

