//
//  AuthenticationViewController.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    // MARK: - Private Properties
    private lazy var promptLabel: UILabel! = {
        let promptLabel = UILabel()
        
        if self.traitCollection.horizontalSizeClass == .Regular && self.traitCollection.verticalSizeClass == .Regular {
            promptLabel.font = UIFont.systemFontOfSize(22)
        } else {
            promptLabel.font = UIFont.systemFontOfSize(18)
        }
        
        promptLabel.text = NSLocalizedString("Enter Passcode", comment: "Enter Passcode")
        promptLabel.textAlignment = .Center
        
        return promptLabel
    }()
    
    private lazy var inputCirclesView: InputCirclesView! = {
        let inputCirclesView = InputCirclesView(passcodeLength: SimplePasscode.passcodeLength)
        
        return inputCirclesView
    }()
    
    private lazy var numPadView: NumPadView! = {
        let numPadView = NumPadView()
        
        numPadView.delegate = self
        
        return numPadView
    }()
    
    private lazy var deleteButton: UIButton! = {
        let deleteButton = UIButton(type: .System)
        
        deleteButton.setTitle(NSLocalizedString("Delete", comment: "Delete"), forState: .Normal)
        deleteButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped), forControlEvents: .TouchUpInside)
        
        return deleteButton
    }()
    
    private var firstAppear = true
    
    // MARK: - Public Properties
    var currentPasscode: String!
    var inputtedPasscode = ""
    var completionHandler: ((success: Bool) -> Void)?
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppear {
            firstAppear = false
            authenticateUsingTouchID()
        }
    }
    
    // MARK: - UI Config
    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        view.tintColor = UIColor.customTintColor
        
        let canvasView = UIView()
        view.addSubview(canvasView)
        canvasView.snp_makeConstraints { (make) in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        let containerView = UIView()
        canvasView.addSubview(containerView)
        containerView.snp_makeConstraints { make in
            make.center.equalTo(canvasView)
        }
        
        do {
            containerView.addSubview(promptLabel)
            promptLabel.textColor = promptLabel.tintColor
            promptLabel.snp_makeConstraints { make in
                make.top.equalTo(containerView)
                make.left.equalTo(containerView)
                make.right.equalTo(containerView)
            }
            
            containerView.addSubview(inputCirclesView)
            inputCirclesView.snp_makeConstraints { make in
                make.top.equalTo(promptLabel.snp_bottom).offset(20)
                make.centerX.equalTo(containerView)
            }
            
            containerView.addSubview(numPadView)
            numPadView.snp_makeConstraints { make in
                make.top.equalTo(inputCirclesView.snp_bottom).offset(20)
                make.left.equalTo(containerView)
                make.right.equalTo(containerView)
            }
            
            containerView.addSubview(deleteButton)
            deleteButton.snp_makeConstraints { make in
                make.top.equalTo(numPadView.snp_bottom)
                make.right.equalTo(containerView)
                make.bottom.equalTo(containerView)
            }
        }
    }
    
    // MARK: - Action Handlers
    func deleteButtonTapped() {
        if inputtedPasscode.characters.count > 0 {
            inputtedPasscode.removeAtIndex(inputtedPasscode.endIndex.predecessor())
            inputCirclesView.setFilled(false, atIndex: inputtedPasscode.characters.count)
        }
        
        print(inputtedPasscode)
    }
    
    func authenticateUsingTouchID() {
        if allowTouchID {
            let authenticationContext = LAContext()
            let authenticationReason = NSLocalizedString("Verify your identity to continue", comment: "Verify your identity to continue")
            
            authenticationContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: { (success, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        self.authenticationComplete(success: true)
                    }
                }
            })
        }
    }
    
    // MARK: - Authentication Result
    private func authenticationComplete(success success: Bool) {
        if success {
            FreezeManager.clearState()
            completionHandler?(success: true)
        } else {
            // User should be forced to sign out when authentication fails
            completionHandler?(success: false)
        }
    }
}

extension AuthenticationViewController: NumPadViewDelegate {
    func numPadView(view: NumPadView, didTapDigit digit: Int) {
        guard inputtedPasscode.characters.count < currentPasscode.characters.count else {
            return
        }
        
        inputtedPasscode += "\(digit)"
        inputCirclesView.setFilled(true, atIndex: inputtedPasscode.characters.count - 1)
        
        if inputtedPasscode.characters.count == currentPasscode.characters.count {
            if inputtedPasscode != currentPasscode {
                FreezeManager.incrementPasscodeFailure({ (reachThreshold) in
                    if reachThreshold {
                        authenticationComplete(success: false)
                    } else {
                        inputtedPasscode = ""
                        inputCirclesView.unfillAllCircles()
                        inputCirclesView.shake(needsVibration: true, completion: nil)
                    }
                })
            } else {
                authenticationComplete(success: true)
            }
        }
    }
}
