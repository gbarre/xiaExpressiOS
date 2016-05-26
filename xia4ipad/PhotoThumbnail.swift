//
//  PhotoThumbnail.swift
//  xia4ipad
//
//  Created by Guillaume on 05/10/15.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
        
    let animationRotateDegres: CGFloat = 0.5
    
    @IBOutlet var imgBkgd: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgLabel: UILabel!
    @IBOutlet var roIcon: UIImageView!
    
    func setLabel(text: String) {
        self.imgLabel.text = text
    }
    
    func setLabelBkgColor(color: UIColor) {
        //self.backgroundColor = color
        imgBkgd.hidden = (color == UIColor.clearColor()) ? true : false
        imgLabel.textColor = (color == UIColor.clearColor()) ? blueColor : UIColor.whiteColor()
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
    
    func showRoIcon(roState: Bool = false) {
        roIcon.hidden = !roState
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