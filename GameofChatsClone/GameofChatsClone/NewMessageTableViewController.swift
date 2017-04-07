//
//  NewMessageTableViewController.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/2/22.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Delete_000000_100"), style: .plain, target: self, action: #selector(handleCancel))
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(r: 25, g: 142, b: 176)
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "與更多新朋友聊天吧！"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            
            
        }, withCancel: nil)
        
    }
    
    func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        // Configure the cell...
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.profoleImageView.image = UIImage(named: "Fire Station_100")
        cell.profoleImageView.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            
                cell.profoleImageView.loadImageUsingCachWithUrlString(url: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesViewController : MessagesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true, completion: nil)
        let user = self.users[indexPath.row]
        self.messagesViewController?.showChatControllerForUser(user: user)
    }
    
}


















