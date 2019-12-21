//
//  ConversationListTableViewCell.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK

class ConversationListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
    
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateFormatter.timeZone = TimeZone.current
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(channel: SBDGroupChannel) {
        titleLabel.text = channel.membersString
        
        let lastDate: Date
        if let lastMessage = channel.lastMessage {
            messageLabel.text = (lastMessage as? SBDUserMessage)?.message ?? "(Media)"
            lastDate = Date(timeIntervalSince1970: Double(lastMessage.createdAt) / 1000.0)
        }
        else {
            messageLabel.text = ""
            lastDate = Date(timeIntervalSince1970: Double(channel.createdAt) / 1000.0)
        }
        
        timestampLabel.text = stringForTime(lastDate)
    }

    func stringForTime(_ date: Date) -> String {
        guard let utc = TimeZone(identifier: "UTC") else { return "" }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
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
