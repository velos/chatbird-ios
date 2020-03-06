//
//  ProfileViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ChatBird
import SendBirdSDK
import Nuke

class ProfileViewController: UITableViewController {

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var blockUserButton: UIButton!
    
    var member: SBDMember?
    
    private var isUserBlocked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let member = member else { return }

        avatarView.setup(with: [member])
        nicknameLabel.text = (member.nickname?.isEmpty ?? true) ? "(No nickname set)" : member.nickname
        userIDLabel.text = member.userId
        
        isUserBlocked = member.isBlockedByMe
        let blockUserButtonTitle = isUserBlocked ? "Unblock User" : "Block User"
        blockUserButton.setTitle(blockUserButtonTitle, for: .normal)
    }
    
    @IBAction func blockTapped(_ sender: Any) {
        guard let member = member else { return }
        let blockActionTitle = isUserBlocked ? "unblock" : "block"
        let alert = UIAlertController(title: "Do you really want to \(blockActionTitle) this user?", message: nil, preferredStyle: .actionSheet)
        let blockUserAction = UIAlertAction(title: "Block", style: .destructive) { action in
            if self.isUserBlocked {
                SBDMain.unblockUser(member) { [weak self] (member) in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            else {
                SBDMain.blockUser(member) { [weak self] (member, error) in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(blockUserAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
}
