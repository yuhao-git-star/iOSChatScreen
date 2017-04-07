//
//  Message.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/3/6.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId : String?
    var text : String?
    var timestamp : NSNumber?
    var toId : String?
    var imageUrl : String?
    var imageWidth : NSNumber?
    var imageHeight : NSNumber?
    var videoUrl : String?
    
    func chatPartnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary : [String : AnyObject]) {
        
        super.init()
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
    }
}
