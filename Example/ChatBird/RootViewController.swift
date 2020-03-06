//
//  RootViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK

class RootViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Replace this with your SendBird app id
        let appId: String = "<INSERT YOUR APPID HERE>"
        
        // Replace this with your SendBird access token, if using
        let token: String? = nil
        
        SBDMain.initWithApplicationId(appId)
        SBDMain.setLogLevel(SBDLogLevel.info)
        print("** SendBird Initialize AppID: \(appId)")
        
        guard let sendbirdUserId = UserDefaults.standard.value(forKey: "sendbird_user_id") as? String else {
            performSegue(withIdentifier: "loginSegue", sender: nil)
            return
        }
        
        SBDMain.connect(withUserId: sendbirdUserId, accessToken: token) { [weak self] (user, error) in
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
            
            print("** Connected to SendBird")

            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "tabBarSegue", sender: nil)
            }
        }
    }
}
