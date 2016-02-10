//
//  ViewMetasTabA.swift
//  xia4ipad
//
//  Created by Guillaume on 20/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewMetasTabA: UIViewController {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    var filePath: String = ""
    
    weak var viewPhotoController: ViewPhoto?
    
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtCreator: UITextField!
    @IBOutlet var date: UIDatePicker!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save metas in xml
        xml["xia"]["title"].value = txtTitle.text
        xml["xia"]["creator"].value = txtCreator.text
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        xml["xia"]["date"].value = dateFormatter.stringFromDate(date.date)
        
        let _ = writeXML(xml, path: "\(filePath).xml")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        xml = globalXML
        filePath = globalFilePath
        
        txtTitle.becomeFirstResponder()
        if (xml["xia"]["title"].value != nil) {
            txtTitle.text = xml["xia"]["title"].value
        }
        else {
            txtTitle.placeholder = "Title"
        }
        
        txtCreator.text = (xml["xia"]["creator"].value != nil) ? xml["xia"]["creator"].value : ""
        
        var detailDate = NSDate(timeIntervalSinceNow: NSTimeInterval(0))
        if ( xml["xia"]["date"].value != nil && xml["xia"]["date"].value! != "element <date> not found"){
            let mydateFormatter = NSDateFormatter()
            mydateFormatter.dateStyle = .ShortStyle
            detailDate = mydateFormatter.dateFromString(xml["xia"]["date"].value!)!
        }
        date.setDate(detailDate, animated: false)
    }
}
