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
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgLabel: UILabel!
    
    func setLabel(text: String) {
        self.imgLabel.text = text
    }
    
    func setThumbnail(thumbnailImage: UIImage) {
        if thumbnailImage.size.width > thumbnailImage.size.height {
            let newHeight = thumbnailImage.size.height * 200 / thumbnailImage.size.width
            self.imgViewHeight.constant = newHeight
        }
        else {
            self.imgViewHeight.constant = 200
        }
        self.imgView.image = thumbnailImage
    }
    
    func degreesToRadians(x: CGFloat) -> CGFloat {
        return CGFloat(M_PI) * x / 180.0
    }
    
    func wobble(enable: Bool) {
        let leftOrRight: CGFloat = 1
        let rightOrLeft: CGFloat = -1
        let leftWobble: CGAffineTransform = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegres * leftOrRight))
        let rightWobble: CGAffineTransform = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegres * rightOrLeft))
        
        transform = rightWobble // starting point
        
        if enable {
            let delay = Double(arc4random()) % 50 / 100
            UIView.animateWithDuration(0.12 + delay / 20, delay: delay, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: { () -> Void in
                self.transform = leftWobble
                }, completion: nil)
            UIView.animateWithDuration(0.12 - delay / 10, delay: delay, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: { () -> Void in
                self.center = CGPointMake(self.center.x, self.center.y+3)
                }, completion: nil)
        }
        else {
            self.layer.removeAllAnimations()
            self.transform = CGAffineTransformMakeRotation(0)// reset to original state
        }
    }
}