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
        
        let thumb = cropToBounds(thumbnailImage, width: 200, height: 200)
        let borderTumb = drawBorder(thumb, color: blueColor, border: 2)
        
        self.imgView.image = borderTumb
        self.imgLabel.text = thumbnailLabel
    }
    
    func drawBorder(image: UIImage, color: UIColor, border: CGFloat) -> UIImage {
        let outlineX: CGFloat = imgView.bounds.width
        let outlineY: CGFloat = imgView.bounds.width
        let outlinedImageRect = CGRect(x: 0.0, y: 0.0, width: outlineX, height: outlineY)
        let scaleX = outlineX / image.size.width
        let scaleY = outlineY / image.size.height
        let scale = max(scaleX, scaleY)
        let imageRect = CGRect(x: border, y: border, width: (image.size.width) * scale - 2 * border, height: (image.size.height) * scale - 2 * border)
        
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, 0)
        image.drawInRect(outlinedImageRect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, outlinedImageRect)
        image.drawInRect(imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}
