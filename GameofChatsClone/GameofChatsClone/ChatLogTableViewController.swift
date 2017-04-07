//
//  ChatLogTableViewController.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/3/1.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogTableViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var user : User? {
        
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    lazy var activityIndicatorView : UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    private func getStartactivityIndicator() {
        
        activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 100))
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        activityIndicatorView.layer.cornerRadius = 10
        activityIndicatorView.layer.masksToBounds = true
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    private func endartactivityIndicator() {
        
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId  = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String :AnyObject] else {
                    return
                }
                //                self.messages.append(message)
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatsMessageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        //        setupInputComponents()
        setupKeyboardObservers()
    }
    
    
    
    lazy var inputContainerView : ChatinputContainerView = {
        
        let chatinputContainerView = ChatinputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatinputContainerView.chatLogTableViewController = self
        return chatinputContainerView
        
    }()
    
    override var inputAccessoryView : ChatinputContainerView? {
        
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide , object: nil)
        
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        
        if messages.count > 0 {
            
            let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
            DispatchQueue.main.async {
                
                self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
            }
            
        }
        
        
        
        
        //        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        //        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        //
        //        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        //        UIView.animate(withDuration: keyboardDuration!) {
        //            self.view.layoutIfNeeded()
        //        }
        
        
    }
    
    //    func handleKeyboardWillHide(notification: NSNotification) {
    //
    //        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    //
    //        containerViewBottomAnchor?.constant = 0
    //        UIView.animate(withDuration: keyboardDuration!) {
    //            self.view.layoutIfNeeded()
    //        }
    //    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        OperationQueue.main.cancelAllOperations()
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    //    func setupInputComponents() {
    //
    //        let containerView = UIView()
    //        containerView.backgroundColor = UIColor.darkGray
    //        containerView.translatesAutoresizingMaskIntoConstraints = false
    //        view.addSubview(containerView)
    //
    //        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    //        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    //        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    //        containerViewBottomAnchor?.isActive = true
    //        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    //
    //
    //    }
    
    func handleSend() {
        
        let Properties = ["text" : inputContainerView.inputTextField.text! as AnyObject ] as [String : AnyObject]
        //        childRef.updateChildValues(values)
        sendMessageWithProperties(Properties: Properties)
    }
    
    private func sendMessageWithImageUrl(_ imageUrl :String , image : UIImage) {
        
        
        let Properties =  ["imageUrl": imageUrl as AnyObject ,
                           "imageWidth": image.size.width as AnyObject ,
                           "imageHeight": image.size.height as AnyObject] as [String : AnyObject]
        
        sendMessageWithProperties(Properties: Properties as [String : AnyObject])
        
    }
    
    private func sendMessageWithProperties(Properties: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        var values = ["text" : inputContainerView.inputTextField.text! as AnyObject ,
                      "toId": toId! as AnyObject ,
                      "fromId": fromId! as AnyObject ,
                      "timestamp" : timestamp as AnyObject] as [String : AnyObject]
        //        childRef.updateChildValues(values)
        
        Properties.forEach({values[$0] = $1})
        
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil{
                print(error)
                self.endartactivityIndicator()
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
            
            
            self.endartactivityIndicator()
        }
        
    }
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            inputContainerView.inputTextField.endEditing(true)
            getStartactivityIndicator()
            
            handleVideoSelectedForInfo(videoUrl : videoUrl)
            
        } else {
            
            inputContainerView.inputTextField.endEditing(true)
            getStartactivityIndicator()
            
            handleImageSelectedForInfo(info: info as [String : AnyObject])
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func handleVideoSelectedForInfo(videoUrl : URL) {
        
        let fileName = NSUUID().uuidString + ".mov"
        
        let uploadTask = FIRStorage.storage().reference().child("message_movie").child(fileName).putFile(videoUrl, metadata: nil, completion: { (storageMetadata, error) in
            
            
            
            if error != nil {
                print(error)
                self.endartactivityIndicator()
                return
            }
            
            if let storageVideoUrl = storageMetadata?.downloadURL()?.absoluteString {
                
                
                
                if let thumbnailImage = self.thumbnailImageForVideoUrl(fileUrl: videoUrl) {
                    
                    //                    "imageUrl": imageUrl as AnyObject ,
                    
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        
                        
                        let Properties =  ["imageUrl": imageUrl as AnyObject ,
                                           "imageWidth": thumbnailImage.size.width as AnyObject ,
                                           "imageHeight": thumbnailImage.size.height as AnyObject,
                                           "videoUrl" : storageVideoUrl as AnyObject] as [String : AnyObject]
                        self.sendMessageWithProperties(Properties: Properties as [String : AnyObject])
                    })
                    
                    
                    
                }
                
            }
        })
        
        uploadTask.observe(.progress) { (storageTaskSnapshot) in
            
            
            if let comleteUnitCount = storageTaskSnapshot.progress?.completedUnitCount ,
                let totalUnitCount =  storageTaskSnapshot.progress?.totalUnitCount {
                let progress = String(Float(comleteUnitCount)/Float(totalUnitCount) * 100)
                
                if comleteUnitCount == 0 && totalUnitCount == 0 {
                    self.navigationItem.title = "上傳中...0 %"
                } else {
                    self.navigationItem.title = "上傳中...\(progress) %"
                }
                
                
                
                
            }
        }
        
        uploadTask.observe(.success) { (storageTaskSnapshot) in
            self.navigationItem.title = self.user?.name
            self.endartactivityIndicator()
        }
        
    }
    
    private func thumbnailImageForVideoUrl(fileUrl : URL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
        
    }
    
    private func handleImageSelectedForInfo(info: [String:AnyObject]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
            
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image : UIImage, completion: @escaping (String) -> Void) {
        
        let imageName = NSUUID().uuidString
        
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.7) {
            
            ref.put(uploadData, metadata: nil, completion: { (storageMetadata, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                if let imageUrl = storageMetadata?.downloadURL()?.absoluteString {
                    
                    completion(imageUrl)
                    //                    self.sendMessageWithImageUrl(imageUrl , image : image )
                }
                
            })
            
        }
        
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatsMessageCollectionViewCell
        
        cell.chatLogController = self
        cell.bubbleWidthAnchor?.isActive = false
        
        let message = messages[indexPath.item]
        cell.massage = message
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            
            if text == "" && message.imageUrl != nil {
                
                
                cell.bubbleWidthAnchor?.constant = 200
                cell.bubbleWidthAnchor?.isActive = true
                cell.textView.isHidden = true
            } else {
                
                cell.textView.isHidden = false
                cell.textView.text = text
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
                cell.bubbleWidthAnchor?.isActive = true
            }
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        
        return cell
    }
    
    
    
    private func setupCell(cell : ChatsMessageCollectionViewCell , message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            
            cell.profoleImageView.loadImageUsingCachWithUrlString(url: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCachWithUrlString(url: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            
            cell.messageImageView.isHidden = true
        }
        
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            cell.bubbleView.backgroundColor = UIColor.black
            cell.textView.textColor = UIColor.white
            cell.profoleImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profoleImageView.isHidden = false
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            
            if text == "" && message.imageUrl != nil {
                
                if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
                    
                    // h1/w1 = h2/w2
                    
                    //h1 = h2/w2 * w1
                    
                    height = CGFloat(imageHeight / imageWidth * 200)
                }
                
            } else {
                height = estimateFrameForText(text: text).height + 20
            }
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView : UIView?
    var startingView : UIImageView?
    
    func performZoomInForStartingImageView(startingView: UIImageView) {
        
        self.startingView = startingView
        //        self.startingView?.isHidden = true
        self.startingView?.isHidden = true
        startingFrame = startingView.superview?.convert((self.startingView?.frame)!, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            self.blackBackgroundView?.backgroundColor = UIColor.black
            self.blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed: Bool) in
                //                  do nothing
            })
            
            
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingView?.isHidden = false
            })
            
        }
    }
    
}













