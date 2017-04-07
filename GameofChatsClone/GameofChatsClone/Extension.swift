//
//  File.swift
//  GameofChatsClone
//
//  Created by 陳囿豪 on 2017/2/23.
//  Copyright © 2017年 yasuoyuhao. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSURL, UIImage>()


extension UIImageView {
    
    func loadImageUsingCachWithUrlString(url : String) {
        
        self.image = UIImage()
        //check
        guard let urlforCache = URL(string: url) else {
            
            print("URL錯誤")
            return
        }
        
        if let cachedImage = imageCache.object(forKey:  urlforCache as NSURL) {
            
            self.image = cachedImage
            
        } else {
            
            let task = URLSession.shared.dataTask(with: urlforCache, completionHandler: { (data, response, error) in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    //success
                    
                    if let profileImage = data {
                        
                        if let downloadImage = UIImage(data: profileImage) {
                            
                            DispatchQueue.main.async {
                                
                                imageCache.setObject(downloadImage, forKey: urlforCache as NSURL )
                                self.image = UIImage(data: profileImage)
                            }
                        }
                        
                    }
                    
                    
                }
            })
            
            task.resume()
        }
    }
    
}


extension UITableView {
    
    private var FLAG_TABLE_VIEW_CELL_LINE: Int {
        get { return 977322 }
    }
    
    //自动添加线条
    func autoAddLineToCell(cell: UITableViewCell, indexPath: NSIndexPath, lineColor: UIColor) {
        
        let lineView = cell.viewWithTag(FLAG_TABLE_VIEW_CELL_LINE)
        if self.isNeedShow(indexPath: indexPath) {
            if lineView == nil {
                self.addLineToCell(cell: cell, lineColor: lineColor)
            }
        } else {
            lineView?.removeFromSuperview()
        }
        
    }
    
    private func addLineToCell(cell: UITableViewCell, lineColor: UIColor) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.5))
        view.tag = FLAG_TABLE_VIEW_CELL_LINE
        view.backgroundColor = lineColor
        cell.contentView.addSubview(view)
    }
    
    private func isNeedShow(indexPath: NSIndexPath) -> Bool {
        let countCell = self.countCell(atSection: indexPath.section)
        if countCell == 0 || countCell == 1 {
            return false
        }
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    
    
    private func countCell(atSection: Int) -> Int {
        return self.numberOfRows(inSection: atSection)
    }
    
}
