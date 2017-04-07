//
//  NewMessageTableViewCell.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/3/6.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message : Message? {
        
        didSet {
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss MM/dd"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
            

        }
    }
    
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        
                        self.profoleImageView.loadImageUsingCachWithUrlString(url: profileImageUrl)
                    }
                    
                    
                    
                }
            })
        }

    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    
    let profoleImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Fire Station_100")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel : UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor  = UIColor.darkGray
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle , reuseIdentifier: reuseIdentifier)
        
        addSubview(profoleImageView)
        addSubview(timeLabel)
        
        profoleImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profoleImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profoleImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profoleImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
