//
//  PlayImageMetadatas.swift
//  xia4ipad
//
//  Created by Guillaume on 12/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PlayImageMetadatas: UIViewController {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument!
    var imageTitle: String = ""
    var imageAuthor: String = ""
    var imageRights: String = ""
    var imageDesc: String = ""
    
    @IBAction func Hide(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        
        
        content.text = xml.xmlString
        
    }
    
}
