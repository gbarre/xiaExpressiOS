//
//  ViewMetasTabC.swift
//  xia4ipad
//
//  Created by Guillaume on 10/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewMetasTabC: UIViewController {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    var filePath: String = ""
    
    weak var viewPhotoController: ViewPhoto?
    
    @IBOutlet var txtPublisher: UITextField!
    @IBOutlet var txtSource: UITextField!
    @IBOutlet var txtRelation: UITextField!
    @IBOutlet var txtLanguage: UITextField!
    @IBOutlet var txtKeywords: UITextField!
    @IBOutlet var txtContributors: UITextField!
     
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save metas in xml
        xml["xia"]["publisher"].value = txtPublisher.text
        xml["xia"]["source"].value = txtSource.text
        xml["xia"]["relation"].value = txtRelation.text
        xml["xia"]["language"].value = txtLanguage.text
        xml["xia"]["keywords"].value = txtKeywords.text
        xml["xia"]["contributors"].value = txtContributors.text
        
        let _ = writeXML(xml, path: "\(filePath).xml")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xml = globalXML
        filePath = globalFilePath
        
        txtPublisher.becomeFirstResponder()
        txtPublisher.text = (xml["xia"]["publisher"].value != nil) ? xml["xia"]["publisher"].value : ""
        txtPublisher.text = (xml["xia"]["source"].value != nil) ? xml["xia"]["source"].value : ""
        txtPublisher.text = (xml["xia"]["relation"].value != nil) ? xml["xia"]["relation"].value : ""
        txtPublisher.text = (xml["xia"]["language"].value != nil) ? xml["xia"]["language"].value : ""
        txtPublisher.text = (xml["xia"]["keywords"].value != nil) ? xml["xia"]["keywords"].value : ""
        txtPublisher.text = (xml["xia"]["contributors"].value != nil) ? xml["xia"]["contributors"].value : ""
    }
}
