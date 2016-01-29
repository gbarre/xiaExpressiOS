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
