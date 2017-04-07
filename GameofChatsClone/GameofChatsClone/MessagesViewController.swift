//
//  ViewController.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/2/21.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearUserInfo()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Exit_000000_100"), style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Speech Bubble_000000_100"), style: .plain, target: self, action: #selector(handNewmessage))
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(r: 25, g: 142, b: 176)
        navigationController?.navigationBar.barStyle = .black
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //        observeMessages()
        observeUserMessages()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        
        tableView.layoutMargins = UIEdgeInsetsMake(0, 8, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, databaseReference) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attrmpReloadOfTable()
                
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                
            })
        }

        
        
    }
    
    private func clearUserInfo() {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
    }
    
    func observeUserMessages() {
        
        clearUserInfo()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fechMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attrmpReloadOfTable()
            
        }, withCancel: nil)
        
    }
    
    private func fechMessageWithMessageId(messageId :String) {
        
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value , with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let message = Message(dictionary : dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                
                self.attrmpReloadOfTable()
                
            }
            
        }, withCancel: nil)
    }
    
    func attrmpReloadOfTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer : Timer?
    
    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        tableView.autoAddLineToCell(cell: cell, indexPath: indexPath as NSIndexPath, lineColor: UIColor.lightGray)
    

        let message = messages[indexPath.row]
        //        cell.textLabel?.text = message.toId
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let messgae = messages[indexPath.row]
        
        
        guard let chatPartnerId = messgae.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
        
    }
    
    func handNewmessage() {
        
        let newMessageTableViewController = NewMessageTableViewController()
        newMessageTableViewController.messagesViewController = self
        let navController = UINavigationController(rootViewController: newMessageTableViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                DispatchQueue.main.async {
                    
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.setupNavBarWithUser(user: user)
                }
            }
            
        }, withCancel: { (error) in
            print(error)
        })
        
        
    }
    
    func setupNavBarWithUser(user: User) {
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage()
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        if let profileImageUrl = user.profileImageUrl {
            
            profileImageView.loadImageUsingCachWithUrlString(url: profileImageUrl)
        }
        
        let userNameLabel : UILabel = {
            
            let label = UILabel()
            label.text = user.name
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.white
            return label
        }()
        
        titleView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(userNameLabel)
        
        profileImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor , constant: -16).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatControllerForUser)))
    }
    
    func showChatControllerForUser(user: User) {
        
        let chatLogTableViewController = ChatLogTableViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogTableViewController.user = user
        navigationController?.pushViewController(chatLogTableViewController, animated: true)
    }
    
    
    
    func handleLogout() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
            
        } catch let logoutError {
            
            print(logoutError)
        }
        
        let logoutViewController = LogoutViewController()
        logoutViewController.messagesViewController = self
        clearUserInfo()
        present(logoutViewController, animated: true, completion: nil)
        
    }
    
    
}

//    func observeMessages() {
//
//        let ref = FIRDatabase.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String : AnyObject] {
//
//                let message = Message()
//                message.setValuesForKeys(dictionary)
//                //                self.messages.append(message)
//
//                if let toId = message.toId {
//
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort(by: { (message1, message2) -> Bool in
//
//                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
//                    })
//                }
//
//
//
//            }
//
//
//        })
//    }

