//
//  ConversationListTableViewCell.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ChatBird
import SendBirdSDK

class ConversationListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    
    let bgView = UIView()
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .white
        backgroundView = bgView
        dateFormatter.timeZone = TimeZone.current
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            bgView.backgroundColor = UIColor.clear
        }
        else {
            bgView.backgroundColor = .white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            bgView.backgroundColor = UIColor.clear
        }
        else {
            bgView.backgroundColor = .white
        }
    }
    
    func setup(channel: SBDGroupChannel) {
        titleLabel.text = channel.name.count > 0 ? channel.name : channel.membersString
        
        let lastDate: Date
        if let lastMessage = channel.lastMessage {
            if let adminMessage = lastMessage as? SBDAdminMessage {
                messageLabel.text = adminMessage.message ?? ""
            }
            else if let userMessage = lastMessage as? SBDUserMessage {
                messageLabel.text = userMessage.message ?? ""
            }
            else if let fileMessage = lastMessage as? SBDFileMessage {
                if fileMessage.type.hasPrefix("image") {
                    messageLabel.text = "📷 Photo"
                }
                else if fileMessage.type.hasPrefix("video") {
                    messageLabel.text = "🎥 Video"
                }
                else if fileMessage.type.hasPrefix("audio") {
                    messageLabel.text = "🔈 Audio"
                }
                else {
                    messageLabel.text = "📄 File"
                }
            }
            lastDate = Date(timeIntervalSince1970: Double(lastMessage.createdAt) / 1000.0)
        }
        else {
            messageLabel.text = ""
            lastDate = Date(timeIntervalSince1970: Double(channel.createdAt) / 1000.0)
        }
        
        timestampLabel.text = stringForTime(lastDate)
        
        avatarView.backgroundColor = .clear
        avatarView.setup(with: channel.otherMembersArray)
    }

    func stringForTime(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        let current = Date()

        if calendar.isDateInToday(date) {
            dateFormatter.doesRelativeDateFormatting = false
            dateFormatter.setLocalizedDateFormatFromTemplate("jj:mm")
        }
        else if calendar.isDateInYesterday(date) {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
        }
        else if calendar.dateComponents([.day], from: date, to: current).day ?? 0 < 7 {
            dateFormatter.doesRelativeDateFormatting = false
            dateFormatter.setLocalizedDateFormatFromTemplate("E")
        }
        else if calendar.dateComponents([.year], from: date, to: current).year ?? 0 < 1 {
            dateFormatter.doesRelativeDateFormatting = false
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")
        }
        else {
            dateFormatter.doesRelativeDateFormatting = false
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }
        return dateFormatter.string(from: date)
    }
}
