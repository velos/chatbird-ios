//
//  NewChatController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SendBirdSDK
import Nuke

class SelectableUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    var user: SBDUser? {
        didSet {
            nicknameLabel.text = (user?.nickname?.isEmpty ?? true) ? user?.userId : user?.nickname
            guard let url = URL(string: user?.profileUrl ?? "") else {
                profileView.image = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
                return
            }
            Nuke.loadImage(with: url, into: profileView)
        }
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileView.layer.cornerRadius = profileView.frame.width / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}

class SelectedUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    var user: SBDUser? {
        didSet {
            nicknameLabel.text = (user?.nickname?.isEmpty ?? true) ? user?.userId : user?.nickname
            guard let url = URL(string: user?.profileUrl ?? "") else {
                profileView.image = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
                return
            }
            Nuke.loadImage(with: url, into: profileView)
        }
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
}

class NewChatController: UIViewController {
    var selectedUsers: [SBDUser] = []
    
    @IBOutlet weak var selectedUserView: UICollectionView!
    @IBOutlet weak var selectedUserHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    var users: [SBDUser] = []
    var userListQuery: SBDApplicationUserListQuery?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.delegate = self
        searchController?.searchBar.placeholder = "Search"
        searchController?.searchBar.searchTextField.clearButtonMode = .always
        searchController?.searchBar.searchTextField.autocapitalizationType = .none

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        selectedUserView.contentInset = UIEdgeInsets(top: 0, left: 14.0, bottom: 0, right: 14.0)
        selectedUserHeight.constant = 0
        
        nextButton.isEnabled = selectedUsers.count > 0
        
        loadUserList()
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "setupChat", sender: self)
    }

    @objc func handleRefreshControl() {
        loadUserList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SetupChatController else { return }
        vc.members = selectedUsers
    }
    
    func loadUserList(refresh: Bool = true) {
        if refresh {
            userListQuery = nil
        }
        
        if self.userListQuery == nil {
            userListQuery = SBDMain.createApplicationUserListQuery()
            userListQuery?.limit = 20
        }
        
        guard userListQuery?.hasNext == true else { return }
        
        userListQuery?.loadNextPage(completionHandler: { [weak self] (users, error) in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
            
            guard error == nil else {
                print("error loading user list: \(error?.localizedDescription ?? "")")
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self?.users.removeAll()
                }
                
                for user in users! {
                    if user.userId == SBDMain.getCurrentUser()!.userId {
                        continue
                    }
                    self?.users.append(user)
                }
                
                self?.tableView.reloadData()
            }
        })
    }
    
    func updateViews() {
        let usersSelected = selectedUsers.count > 0
        nextButton.isEnabled = usersSelected
        selectedUserHeight.constant = usersSelected ? 70 : 0
        selectedUserView.isHidden = !usersSelected
    }
}

extension NewChatController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableUserTableViewCell.cellReuseIdentifier()) as! SelectableUserTableViewCell

        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        cell.selectedBackgroundView = backgroundView

        cell.user = self.users[indexPath.row]
        
        if self.users.count > 0 && indexPath.row == self.users.count - 1 {
            loadUserList(refresh: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers.append(users[indexPath.row])

        updateViews()
        selectedUserView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedUsers.firstIndex(of: users[indexPath.row]) {
            selectedUsers.remove(at: index)
        }
        
        updateViews()
        selectedUserView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.selectedUsers.contains(self.users[indexPath.row]) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

extension NewChatController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedUserCollectionViewCell
        
        cell.user = selectedUsers[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedUsers.remove(at: indexPath.row)
        
        updateViews()
        tableView.reloadData()
        selectedUserView.reloadData()
    }
}

extension NewChatController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUserList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userListQuery = SBDMain.createApplicationUserListQuery()
        userListQuery?.userIdsFilter = [searchText]
        userListQuery?.loadNextPage(completionHandler: { [weak self] (users, error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
                self?.users.removeAll()
                for user in users ?? [] {
                    if user.userId == SBDMain.getCurrentUser()!.userId {
                        continue
                    }
                    self?.users.append(user)
                }
                
                self?.tableView.reloadData()
            }
        })
    }
}
