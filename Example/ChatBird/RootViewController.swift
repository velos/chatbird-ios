//
//  RootViewController.swift
//  ChatBird
//
//  The MIT License (MIT)
//
//  Copyright (c) 2020 Velos Mobile LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
