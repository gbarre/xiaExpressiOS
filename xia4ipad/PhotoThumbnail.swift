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
        self.imgLabel.text = thumbnailLabel.substringWithRange(Range<String.Index>(start: thumbnailLabel.startIndex.advancedBy(0), end: thumbnailLabel.endIndex.advancedBy(-4)))
    }
    
}
