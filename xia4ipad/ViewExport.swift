//
//  ViewExport.swift
//  xia
//
//  Created by Guillaume on 24/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewExport: UIViewController {
    var docController:UIDocumentInteractionController!
    
    let dbg = debug(enable: true)
    
    var filePath: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var imgView: UIImageView!
    
    var xmlSimpleXML: AEXMLDocument = AEXMLDocument()
    var tmpFilePath: String = ""

    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportSimpleXML(sender: AnyObject) {
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(imgView.image!, 85)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        let trimmedBase64String = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        // prepare xml
        xmlSimpleXML.addChild(name: "XiaiPad")
        xmlSimpleXML["XiaiPad"].addChild(xml["xia"])
        xmlSimpleXML["XiaiPad"].addChild(name: "image", value: trimmedBase64String, attributes: nil)
        
        // write xml to temp directory
        let now:Int = Int(NSDate().timeIntervalSince1970)
        tmpFilePath = NSHomeDirectory() + "/tmp/\(now).xml"
        do {
            try xmlSimpleXML.xmlString.writeToFile(tmpFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        
        // Show native export controller
        docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: tmpFilePath))
        docController.presentOptionsMenuFromRect(sender.frame, inView:self.view, animated:true)
    }
    @IBAction func exportSVG(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
