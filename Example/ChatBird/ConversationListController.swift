//
//  ViewController.swift
//  ChatBird
//
//  Created by David Rajan on 12/05/2019.
//  Copyright (c) 2019 David Rajan. All rights reserved.
//

import UIKit
import SendBirdSDK

class ConversationListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    private var query: SBDGroupChannelListQuery?
    private var channels: [SBDGroupChannel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if SBDMain.getCurrentUser() != nil {
            loadChannels(refresh: true)
        }
    }
    
    func loadChannels(refresh: Bool) {
        if refresh {
            query = nil
        }

        if query == nil {
            query = SBDGroupChannel.createMyGroupChannelListQuery()
            query?.order = .latestLastMessage
            query?.limit = 20
            query?.includeMemberList = true
            query?.includeEmptyChannel = true
        }

        guard query?.hasNext == true else { return }

        query?.loadNextPage { [weak self ] (channels, error) in
            DispatchQueue.main.async { [weak self] in
                if refresh {
                    self?.channels.removeAll()
                }

                if let channels = channels {
                    self?.channels += channels
                }

                self?.updateConversations()

                self?.checkNoContent()
            }

            if let error = error {
                print("** Group channel query error: \(error)")
            }
        }
    }
    
    func updateConversations() {
        tableView.reloadData()
    }
    
    func checkNoContent() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationListTableViewCell", for: indexPath) as! ConversationListTableViewCell
        cell.setup(channel: channels[indexPath.row])

        if channels.count > 0 && indexPath.row == channels.count - 1 {
            loadChannels(refresh: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SBDGroupChannel {
    var membersString: String {
        let members = membersArray

        switch members.count {
        case 0:
            // no other members in chat except self
            return "Waiting for Participants..."
        case 1:
            // one other member so return full name of other participant
            return membersArray.compactMap { $0.nickname }.joined(separator: ", ")
        default:
            // return first name of members sorted by last name
            return membersArray.compactMap { $0.nickname?.components(separatedBy: " ") }
                .sorted(by: { $0.last ?? "" < $1.last ?? "" })
                .compactMap { $0.first }
                .joined(separator: ", ")
        }
    }

    var membersArray: [SBDMember] {
        let members: [SBDMember] = (self.members ?? []).compactMap { $0 as? SBDMember }
        return members.compactMap { $0.userId == SBDMain.getCurrentUser()?.userId ? nil : $0 }
    }
}
