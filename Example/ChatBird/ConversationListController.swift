//
//  ViewController.swift
//  ChatBird
//
//  Created by David Rajan on 12/05/2019.
//  Copyright (c) 2019 David Rajan. All rights reserved.
//

import UIKit
import SendBirdSDK

class ChatListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var query: SBDGroupChannelListQuery?
    private var channels: [SBDGroupChannel] = []
    private var tableView = UITableView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
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
                print("error: \(error)")
            }
        }
    }
    
    func updateConversations() {
        
    }
    
    func checkNoContent() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
