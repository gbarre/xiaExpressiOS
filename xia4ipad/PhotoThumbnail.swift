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
    
    let animationRotateDegres: CGFloat = 0.5
    let animationTranslateX: CGFloat = 1.0
    let animationTranslateY: CGFloat = 1.0
    let count: Int = 1

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imgLabel: UILabel!
    
    func setLabel(text: String) {
        self.imgLabel.text = text
    }
    
    func setCachedThumbnailImage(thumbnailImage: UIImage) {
        
        self.imgView.image = thumbnailImage
    }
    
    func setThumbnailImage(thumbnailImage: UIImage) -> UIImage {
        
        let thumb = cropToBounds(thumbnailImage, width: 200, height: 200)
        let borderedThumb = drawBorder(thumb, color: blueColor, border: 2)
        
        self.imgView.image = borderedThumb
        return borderedThumb
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
    
    func degreesToRadians(x: CGFloat) -> CGFloat {
        return CGFloat(M_PI) * x / 180.0
    }
    
    func wobble(enable: Bool) {
        let leftOrRight: CGFloat = (count % 2 == 0 ? 1 : -1)
        let rightOrLeft: CGFloat = (count % 2 == 0 ? -1 : 1)
        let leftWobble: CGAffineTransform = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegres * leftOrRight))
        let rightWobble: CGAffineTransform = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegres * rightOrLeft))
        let moveTransform: CGAffineTransform = CGAffineTransformTranslate(leftWobble, -animationTranslateX, -animationTranslateY)
        let conCatTransform: CGAffineTransform = CGAffineTransformConcat(leftWobble, moveTransform)
        
        transform = rightWobble // starting point
        
        if enable {
            UIView.animateWithDuration(0.1, delay: 0.08, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: { () -> Void in
                self.transform = conCatTransform
                }, completion: nil)
        }
        else {
            self.layer.removeAllAnimations()
            self.transform = CGAffineTransformMakeRotation(0)// reset to original state
        }
    }
}
