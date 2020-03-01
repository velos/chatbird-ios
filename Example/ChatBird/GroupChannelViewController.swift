//
//  GroupChannelViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 2/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ChatBird
import SendBirdSDK

/// Overridden version of ChatViewController to segue to Chat Details view.
/// Further customizations to presenters and message handlers may be perfromed here.
class GroupChannelViewController: ChatViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Details", style: .plain, target: self, action: #selector(showDetails))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ChatDetailsController else { return }
        vc.channel = channel
    }
    
    @objc func showDetails() {
        performSegue(withIdentifier: "chatDetailsSegue", sender: nil)
    }

}
