//
//  ViewDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 17/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewDetail: UIViewController {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    //var zoom: Bool = false
    var xml: AEXMLDocument = AEXMLDocument()
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var imgArea: UIView!
    @IBOutlet var detailTitle: UITextView!
    @IBOutlet var txtDesc: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                detailTitle.text = d.attributes["title"]
                txtDesc.text = d.value
            }
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
}
