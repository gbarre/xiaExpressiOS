//
//  ViewImageInfos.swift
//  xia4ipad
//
//  Created by Guillaume on 08/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewImageInfos: UIViewController {
    
    var dbg = debug(enable: true)
    
    var imageTitle: String = ""
    var imageAuthor: String = ""
    var imageRights: String = ""
    var imageDesc: String = ""
    var readOnlyState: Bool = false
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
    var filePath: String = ""
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtAuthor: UITextField!
    @IBOutlet weak var txtRights: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var readOnly: UISwitch!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save the image infos in xml
        
        xml["xia"]["title"].value = txtTitle.text
        xml["xia"]["author"].value = txtAuthor.text
        xml["xia"]["rights"].value = txtRights.text
        xml["xia"]["description"].value = txtDesc.text
        xml["xia"]["readonly"].value = "\(readOnly.on)"
        let _ = writeXML(xml, path: "\(filePath).xml")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border to description
        
        txtDesc.layer.borderWidth = 1
        txtDesc.layer.cornerRadius = 5
        txtDesc.layer.borderColor = UIColor.grayColor().CGColor
        
        txtTitle.text = self.imageTitle
        txtAuthor.text = self.imageAuthor
        txtRights.text = self.imageRights
        txtDesc.text = self.imageDesc
        readOnly.setOn(readOnlyState, animated: true)
        navbar.title = txtTitle.text
    }
    
}
