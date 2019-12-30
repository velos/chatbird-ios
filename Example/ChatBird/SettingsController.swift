//
//  SettingsController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ChatBird

class SettingsController: UIViewController {
    
    @IBAction func logoutTapped(_ sender: Any) {
        ChatBirdManager.shared.disconnectSendBird { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
