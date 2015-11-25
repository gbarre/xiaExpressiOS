//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PlayXia: UIViewController {
    
    var xml: AEXMLDocument = AEXMLDocument()
    var index: Int = 0
    
    @IBOutlet weak var bkgdImage: UIImageView!
    
    override func viewDidLoad() {
        // Add gesture to go back on right swipe
        let cSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let filePath = "\(documentsDirectory)\(arrayNames[self.index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
}
