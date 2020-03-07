//
//  ConversationListTableViewCell.swift
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
