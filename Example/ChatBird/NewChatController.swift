//
//  NewChatController.swift
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
import SendBirdSDK
import ChatBird
import Nuke

class SelectableUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    var user: SBDUser? {
        didSet {
            nicknameLabel.text = user?.displayName
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
            nicknameLabel.text = user?.displayName
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

    var userListQuery: SBDApplicationUserListQuery?
    var userQueryViewModel = UserQueryViewModel()
    var searchController: UISearchController?
    
    private var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.delegate = self
        searchController?.searchBar.placeholder = "Search"
        searchController?.searchBar.autocapitalizationType = .none

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
        if !isLoading {
            isLoading = true
            userQueryViewModel.queryUserList(refresh: refresh) { [weak self] (didRefresh) in
                DispatchQueue.main.async {
                    if didRefresh {
                        self?.tableView.reloadData()
                    }
                    self?.isLoading = false
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func updateViews() {
        let usersSelected = selectedUsers.count > 0
        nextButton.isEnabled = usersSelected
        selectedUserHeight.constant = usersSelected ? 70 : 0
        selectedUserView.isHidden = !usersSelected
    }
}

extension NewChatController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userQueryViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableUserTableViewCell.cellReuseIdentifier()) as! SelectableUserTableViewCell

        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        cell.selectedBackgroundView = backgroundView

        cell.user = userQueryViewModel.users[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers.append(userQueryViewModel.users[indexPath.row])

        updateViews()
        selectedUserView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedUsers.firstIndex(of: userQueryViewModel.users[indexPath.row]) {
            selectedUsers.remove(at: index)
        }
        
        updateViews()
        selectedUserView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.selectedUsers.contains(userQueryViewModel.users[indexPath.row]) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            loadUserList(refresh: false)
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
        userQueryViewModel.queryUserList(searchText: searchText) { (didLoadData) in
            if didLoadData {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
