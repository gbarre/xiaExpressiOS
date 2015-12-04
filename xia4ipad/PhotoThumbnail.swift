//
//  PhotoThumbnail.swift
//  xia4ipad
//
//  Created by Guillaume on 05/10/15.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    let dbg = debug(enable: true)
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imgLabel: UILabel!
    
    func setThumbnailImage(thumbnailImage: UIImage, thumbnailLabel: String) {
        
        let thumb = drawOutlie(thumbnailImage, color: blueColor)
        
        self.imgView.image = thumb
        self.imgLabel.text = thumbnailLabel
        dbg.pt("\(thumbnailImage)")
    }
    
    func drawOutlie(image :UIImage, color:UIColor) -> UIImage
    {
        let border:CGFloat = 16
        
        let outlinedImageRect = CGRect(x: 0.0, y: 0.0, width: image.size.width + 2 * border, height: image.size.height + 2 * border)
        
        let imageRect = CGRect(x: border, y: border, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, 1)
        
        image.drawInRect(outlinedImageRect)
        
        let context = UIGraphicsGetCurrentContext()
        //CGContextSetBlendMode(context, kCGBlendModeSourceIn)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, outlinedImageRect)
        image.drawInRect(imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
}
