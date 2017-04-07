//
//  ChatsMessageCollectionViewCell.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/3/7.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import AVFoundation

class ChatsMessageCollectionViewCell: UICollectionViewCell {
    
    var chatLogController : ChatLogTableViewController?
    var massage : Message?
    
    let activityIndicatorView : UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    lazy var playButton : UIButton = {
        
        let button = UIButton(type : .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(imageLiteralResourceName: "Next_000000_100")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    var playerLayer : AVPlayerLayer?
    var player : AVPlayer?
    
    func handlePlay() {
        
        if let videoUrlString = massage?.videoUrl , let url = URL(string: videoUrlString) {
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView : UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profoleImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Fire Station_100")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    
    func handleZoomTap(tapGesture : UITapGestureRecognizer) {
        
        if massage?.videoUrl != nil {
            return
        }
        
            let imageView = tapGesture.view as? UIImageView
            
            self.chatLogController?.performZoomInForStartingImageView(startingView: imageView!)
        
    }
    
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(profoleImageView)
        addSubview(textView)
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        profoleImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profoleImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profoleImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profoleImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor , constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profoleImageView.rightAnchor, constant: 8)
        //        bubbleViewLeftAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 0)
        //        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
