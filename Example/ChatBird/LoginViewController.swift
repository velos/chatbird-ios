//
//  LoginViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func loginPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        SBDMain.connect(withUserId: userField.text ?? "", accessToken: nil) { [weak self] (user, error) in
            self?.activityIndicator.stopAnimating()

            guard error == nil else {
                print("** SendBird connection error")
                return
            }

            if user != nil, let pendingToken = SBDMain.getPendingPushToken() {
                print("** SendBird registering pending token: \(pendingToken)")
                SBDMain.registerDevicePushToken(pendingToken, unique: true, completionHandler: nil)
            }
            else {
                print("** SendBird no registration needed")
            }
            
            UserDefaults.standard.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
            print("** Connected to SendBird")

            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            }
        }
    }
}
