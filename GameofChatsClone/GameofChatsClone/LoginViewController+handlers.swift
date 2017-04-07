//
//  LoginViewController+handlers.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/2/23.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase


extension LogoutViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    
    func handleLoginRegisterChange() {
        
        nameTextField.text = ""
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height
        
        let index = loginRegisterSegmentedControl.selectedSegmentIndex
        
        inputsContainerViewHeightAnchor?.constant = index == 0 ? 100 : 150
        
        
        nameContainerViewHeightAnchor?.isActive = false
        nameContainerViewHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 0 : 1/3)
        nameTextField.placeholder = index == 0 ? "" : "名字?"
        nameContainerViewHeightAnchor?.isActive = true
        
        emailContainerViewHeightAnchor?.isActive = false
        emailContainerViewHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)
        emailContainerViewHeightAnchor?.isActive = true
        
        passwordContainerViewHeightAnchor?.isActive = false
        passwordContainerViewHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)
        passwordContainerViewHeightAnchor?.isActive = true
        
        
    }
    
    
    
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            profileImageView.image = selectedImage
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
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
    
    
    
    func handleLoginRegister() {
        
        emailTextField.endEditing(true)
        nameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        let index = loginRegisterSegmentedControl.selectedSegmentIndex
        
        if index == 0 {
            getStartactivityIndicator()
            handleLogin()
        } else {
            getStartactivityIndicator()
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let emailString = emailTextField.text , let passwordString = passwordTextField.text else {
            
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: emailString, password: passwordString, completion: { (user, error) in
            if error != nil {
                
                let errorNsString = NSString(string: error.debugDescription)
                self.LoginOrSinginAlert(error : errorNsString)
                return
            }
            
            self.messagesViewController.fetchUserAndSetupNavBarTitle()
            self.endartactivityIndicator()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func LoginOrSinginAlert(error : NSString) {
        
        var title = "錯誤"
        var message = "更正"
        
        if error.contains("Code=17007") {
            
            title = "Email已經有人註冊了！"
            message = "請換個Email！"
            
        } else if error.contains("Code=17026") {
            
            title = "密碼需要六位數！"
            message = "請再想個密碼！"
            
        } else if error.contains("Code=17009") {
            
            title = "密碼錯誤！"
            message = "請仔細回想您的密碼！"
            
        } else if error.contains("Code=17011") {
            
            title = "沒有這個使用者！"
            message = "不如去註冊一個？！"
            
        } else if error.contains("1") {
            
            title = "請確定您的Email格式正確"
            message = ""
            
        } else if error.contains("2") {
            
            title = "請輸入您要註冊的密碼！"
            message = ""
            
        } else if error.contains("3") {
            
            title = "聊天需要一個名字"
            message = "請輸入名字"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.endartactivityIndicator()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleRegister() {
        
        
        guard let emailString = emailTextField.text,
            let passworfString = passwordTextField.text ,
            let nameString = nameTextField.text
            
            else {
                return
        }
        
        if emailTextField.text == "" {
            
            LoginOrSinginAlert(error: NSString(string : "1"))
            return
            
        } else if passwordTextField.text == "" {
            
            LoginOrSinginAlert(error: NSString(string : "2"))
            return
            
        } else if nameTextField.text == "" {
            
            LoginOrSinginAlert(error: NSString(string : "3"))
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: emailString, password: passworfString, completion: { (user :FIRUser?, error) in
            
            if error != nil {
                
                let errorNsString = NSString(string: error.debugDescription)
                self.LoginOrSinginAlert(error:errorNsString)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // success
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            
            //            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.5) {
            
            if let profileImageView = self.profileImageView.image ,let uploadData = UIImagePNGRepresentation(profileImageView) {
                
                
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        
                        print(error)
                        return
                    }
                    
                    //success
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = [ "name" : nameString , "email" : emailString , "profileImageUrl" : profileImageUrl ] as [String : Any]
                        self.registerUserIntoDataBaseWithUid(uid: uid, values: values)
                    }
                    
                })
                
            }
            
        })
        
    }
    
    private func registerUserIntoDataBaseWithUid(uid: String , values : [String: Any] ) {
        
        let refData = FIRDatabase.database().reference()
        let usersReference = refData.child("users").child(uid)
        //        let values = [ "name" : nameString , "email" : emailString , "profileImageUrl" : metadata.download() ]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, FIRDatabaseReference) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            //            self.messagesViewController.fetchUserAndSetupNavBarTitle()
            //            self.navigationItem.title = values["name"] as? String
            let user = User()
            user.setValuesForKeys(values)
            self.messagesViewController.setupNavBarWithUser(user: user)
            // success
            self.endartactivityIndicator()
            self.dismiss(animated: true, completion: nil)
            
            
        })
        
    }
    
    
    
}














