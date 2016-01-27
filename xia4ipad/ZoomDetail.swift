//
//  ZoomDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 27/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ZoomDetail: UIViewController {
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
