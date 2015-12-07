//
//  ViewDetailInfo.swift
//  xia4ipad
//
//  Created by Guillaume on 18/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewDetailInfo: UIViewController {
    
    var tag: Int = 0
    var zoom: Bool = false
    var detailTitle: String = ""
    var detailDescription: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var index: Int = 0
    var fileName: String = ""
    var filePath: String = ""

    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var btnZoom: UISwitch!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save the detail in xml
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                d.attributes["zoom"] = "\(btnZoom.on)"
                d.attributes["title"] = txtTitle.text
                d.value = txtDesc.text
            }
        }
        do {
            try xml.xmlString.writeToFile("\(filePath).xml", atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            print("\(error)")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border to description
        
        txtDesc.layer.borderWidth = 1
        txtDesc.layer.cornerRadius = 5
        txtDesc.layer.borderColor = UIColor.grayColor().CGColor
        
        btnZoom.setOn(self.zoom, animated: true)
        txtTitle.text = self.detailTitle
        txtDesc.text = self.detailDescription
        navbar.title = txtTitle.text
        
    }
    
}
