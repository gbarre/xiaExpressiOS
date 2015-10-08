//
//  PhotoThumbnail.swift
//  xia4ipad
//
//  Created by Guillaume on 05/10/15.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imgLabel: UILabel!
    
    func setThumbnailImage(thumbnailImage: UIImage, thumbnailLabel: String) {
        self.imgView.image = thumbnailImage

        // Shadow effect, or not...
        /*self.imgView.layer.shadowOffset = CGSize(width:10, height:3)
        self.imgView.layer.shadowOpacity = 0.5
        self.imgView.layer.shadowRadius = 6*/

        self.imgLabel.text = thumbnailLabel.substringWithRange(Range<String.Index>(start: thumbnailLabel.startIndex.advancedBy(0), end: thumbnailLabel.endIndex.advancedBy(-4)))
    }
    
}
