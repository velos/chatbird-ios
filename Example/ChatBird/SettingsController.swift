//
//  SettingsController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK
import Nuke

class SettingsController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = SBDMain.getCurrentUser() {
            if let url = URL(string: user.profileUrl ?? "") {
                Nuke.loadImage(with: ImageRequest(url: url, processors: [ImageProcessor.Circle()]), into: profileImageView)
            }
            else {
                profileImageView.image = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
            }
            nicknameLabel.text = (user.nickname?.isEmpty ?? true) ? "(No nickname set)" : user.nickname
            userIDLabel.text = user.userId
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        SBDMain.disconnect { [weak self] in
            SBDMain.unregisterAllPushToken(completionHandler: nil)
            print("** SendBird Unregistering Push Token")

            UserDefaults.standard.removeObject(forKey: "sendbird_user_id")
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
