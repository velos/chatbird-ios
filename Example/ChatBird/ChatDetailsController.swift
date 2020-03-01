//
//  ChatDetailsController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 1/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK
import Nuke

class ChatDetailsController: UITableViewController {
    var channel: SBDGroupChannel?
    private var members: [SBDMember] = []
    
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    
    private func rearrangeMembers() {
        self.members.removeAll()
        guard let currentUser = SBDMain.getCurrentUser(), let members = channel?.members as? [SBDMember] else { return }
        
        for member in members {
            if member.userId == currentUser.userId {
                self.members.insert(member, at: 0)
            }
            else {
                self.members.append(member)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rearrangeMembers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ProfileViewController, let member = sender as? SBDMember else { return }
        vc.member = member
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "Members" : nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? members.count + 1 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 140 : 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = channel else { return UITableViewCell() }
        
        switch indexPath.section {
        // Channel Details
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDetailsInfoCell") as? ChatDetailsInfoCell else { return UITableViewCell() }
            cell.setup(with: channel)
            return cell
        // Notifications
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDetailsNotificationCell") as? ChatDetailsNotificationCell else { return UITableViewCell() }
            cell.setup(with: channel)
            return cell
        // Members
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDetailsMemberCell", for: indexPath) as? ChatDetailsMemberCell else { return UITableViewCell() }
            let member: SBDMember? = indexPath.row > 0 ? members[indexPath.row - 1] : nil
            cell.setup(with: member)
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "ChatDetailsLeaveChannelCell")!
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section == 2 {
            if indexPath.row == 0 {
                print("Add member")
            }
            else {
                performSegue(withIdentifier: "profileSegue", sender: members[indexPath.row - 1])
                print("member profile")
            }
        }
        else if indexPath.section == 3 {
            guard let channel = channel else { return }
            
            let alert = UIAlertController(title: "Do you really want to leave this chat?", message: nil, preferredStyle: .actionSheet)
            let leaveChannelAction = UIAlertAction(title: "Leave", style: .destructive) { (action) in
                channel.leave { [weak self] (error) in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(leaveChannelAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

class ChatDetailsInfoCell: UITableViewCell {
    
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    
    func setup(with channel: SBDGroupChannel) {
        chatNameLabel.text = channel.name
        
        guard let url = URL(string: channel.coverUrl ?? "") else { return }
        Nuke.loadImage(with: ImageRequest(url: url, processors: [ImageProcessor.Circle()]), into: chatImageView)
    }
}

class ChatDetailsNotificationCell: UITableViewCell {
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var channel: SBDGroupChannel?
    
    func setup(with channel: SBDGroupChannel) {
        self.channel = channel
        self.notificationSwitch.setOn(channel.myPushTriggerOption == .all, animated: false)
    }

    @IBAction func didChangeSwitch(_ sender: Any) {
        guard let channel = self.channel else { return }
        channel.setMyPushTriggerOption(notificationSwitch.isOn ? .all : .off, completionHandler: nil)
    }
}

class ChatDetailsMemberCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!

    func setup(with member: SBDMember?) {
        guard let member = member else {
            memberLabel.text = "Add Member (TODO: implement)"
            memberImageView.image = UIImage(named: "plus.circle.fill")
            accessoryType = .none
            return
        }

        let isCurrentUser = member.userId == SBDMain.getCurrentUser()?.userId
        memberLabel.text = isCurrentUser ? "You" : (member.nickname ?? "")
        if member.isBlockedByMe {
            memberLabel.text! += " (Blocked)"
        }
        accessoryType = isCurrentUser ? .none : .disclosureIndicator
        
        if let url = URL(string: member.profileUrl ?? "") {
            Nuke.loadImage(with: ImageRequest(url: url, processors: [ImageProcessor.Circle()]), into: memberImageView)
        }
        else {
            memberImageView.image = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
        }
    }
}
