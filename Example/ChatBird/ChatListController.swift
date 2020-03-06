//
//  ChatController.swift
//  ChatBird
//
//  Created by David Rajan on 12/05/2019.
//  Copyright (c) 2019 David Rajan. All rights reserved.
//

import UIKit
import SendBirdSDK
import ChatBird

/// Basic implementation of chat list view
class ChatListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    deinit {
        if let messageObserver = messageToken {
            SBDMain.remove(observer: messageObserver)
        }
        if let userObserver = userToken {
            SBDMain.remove(observer: userObserver)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentView: UIView!

    private var query: SBDGroupChannelListQuery?
    private var channels: [SBDGroupChannel] = []
    private var messageToken: ChannelObservervation?
    private var userToken: ChannelObservervation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard SBDMain.getCurrentUser() != nil else { return }
        
        loadChannels(refresh: true)
        addMessageObserver()
        addUserObserver()
    }

    /// Creates new chat on SendBird
    @IBAction func createChat() {
        performSegue(withIdentifier: "newChatSegue", sender: nil)
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
    
    /// Updates channel when callback received
    private func updateChannel(_ channel: SBDBaseChannel) {
        guard let channel = channel as? SBDGroupChannel else { return }
        DispatchQueue.main.async { [weak self] in
            if let index = self?.channels.firstIndex(where: { $0.channelUrl == channel.channelUrl }) {
                self?.channels.swapAt(0, index)
            }
            else {
                self?.channels.insert(channel, at: 0)
            }

            self?.updateConversations()
        }
    }
    
    func checkNoContent() {
        noContentView.isHidden = channels.count > 0
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
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: "groupChannelSegue", sender: channel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? GroupChannelViewController, let channel = sender as? SBDGroupChannel else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.setup(with: channel)
    }
    
    /// Listens for message event callback
    func addMessageObserver() {
        messageToken = SBDMain.addMessage(observer: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .received(let channel, _):
                self.updateChannel(channel)
            case .updated(let channel, _):
                self.updateChannel(channel)
            case .deleted(let channel, _):
                self.updateChannel(channel)
            }
        })
    }

    /// Listens for user event callback
    func addUserObserver() {
        userToken = SBDMain.addUser(observer: { [weak self] (channel, _) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.channels.firstIndex(of: channel) == nil {
                    self.channels.insert(channel, at: 0)
                }
                self.updateConversations()
            }
        })
    }
}
