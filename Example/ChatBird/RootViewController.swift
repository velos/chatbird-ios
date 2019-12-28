//
//  RootViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import ChatBird

class RootViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ChatBirdManager.shared.initializeSendbird(with: "** INSERT APP ID HERE **")
        
        guard let sendbirdUserId = UserDefaults.standard.value(forKey: "sendbird_user_id") as? String else {
            performSegue(withIdentifier: "loginSegue", sender: nil)
            return
        }
        
        ChatBirdManager.shared.connectSendBird(uuid: sendbirdUserId, token: nil) { [weak self] (user, error) in
            guard error == nil else {
                print("** SendBird connection error")
                return
            }
            
            //            ChatManager.shared.updateUnreadMessageCount()
            print("** Connected to SendBird")
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "tabBarSegue", sender: nil)
            }
        }
    }
}
