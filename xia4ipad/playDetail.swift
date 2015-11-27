//
//  playDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 27/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class playDetail: UIViewController {
    
    var detailTitle: String = ""
    var detailDescription: String = ""
    var detailImg: UIImageView!
    var detailPath: UIBezierPath!
    var croppedImage: UIImageView!
    
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var croppedImg: UIImageView!
    
    override func viewDidLoad() {
        // Add gesture to go back on right swipe
        let cSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        croppedImg.image = croppedImage.image
        
//        croppedImg.image = croppedImage
 
        // Load detail's infos
        let titleWidth = detailTitle.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: detailTitle)
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(14)], range: NSRange(location: 0, length: titleWidth))
        
        let attributedDescription: NSMutableAttributedString = NSMutableAttributedString(string: "\n\n\(detailDescription)")
        attributedText.appendAttributedString(attributedDescription)
        
        detailText.attributedText = attributedText
        
    }
    
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
}
