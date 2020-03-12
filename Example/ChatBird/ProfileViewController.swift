//
//  ProfileViewController.swift
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
