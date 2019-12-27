//
//  LoginViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ChatBird

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func loginPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        ChatBirdManager.shared.connectSendBird(uuid: userField.text ?? "", token: nil) { [weak self] (user, error) in
            
            self?.activityIndicator.stopAnimating()
            
            guard error == nil else {
                print("** SendBird connection error")
                return
            }
            
            //            ChatManager.shared.updateUnreadMessageCount()
            print("** Connected to SendBird")
            UserDefaults.standard.set(ChatBirdManager.shared.currentUserId(), forKey: "sendbird_user_id")
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            }
        }
    }
}
