//
//  ChatinputContainerView.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/3/9.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import Foundation
import UIKit

class ChatinputContainerView: UIView , UITextFieldDelegate {
    
    var chatLogTableViewController : ChatLogTableViewController? {
        
        didSet {
            
            sendButton.addTarget(chatLogTableViewController, action: #selector(ChatLogTableViewController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogTableViewController, action: #selector(ChatLogTableViewController.handleUploadTap)))
        }
    }
    
    lazy var inputTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "請輸入訊息..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor.black
        textField.delegate = self
        return textField
    }()
    
    let sendButton = UIButton(type: .system)
    
    let uploadImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(imageLiteralResourceName: "Google Photos_000000_100")
        return imageView
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.image = UIImage(imageLiteralResourceName: "Google Photos_000000_100")
        
        
        
        addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        sendButton.backgroundColor = UIColor.darkGray
        sendButton.setTitle("發送", for: .normal)
        sendButton.tintColor = UIColor.cyan
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(self.sendButton)
        self.sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        self.sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor , constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        chatLogTableViewController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
