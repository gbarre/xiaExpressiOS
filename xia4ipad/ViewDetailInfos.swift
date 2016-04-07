//
//  ViewDetailInfo.swift
//  xia4ipad
//
//  Created by Guillaume on 18/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
import Foundation

class ViewDetailInfos: UIViewController, UITextViewDelegate {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    var zoom: Bool = false
    var lock: Bool = false
    var detailTitle: String = ""
    var detailSubtitle: String = ""
    var detailDescription: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var index: Int = 0
    var fileName: String = ""
    var filePath: String = ""
    weak var ViewCreateDetailsController: ViewCreateDetails?

    @IBOutlet weak var btnZoom: UIButton!
    @IBAction func btnZoomAction(sender: AnyObject) {
        zoom = !zoom
        let btnImgZoom = (zoom) ? UIImage(named: "checkedbox") : UIImage(named: "uncheckedbox")
        btnZoom.setImage(btnImgZoom, forState: .Normal)
    }
    @IBOutlet weak var btnLock: UIButton!
    @IBAction func btnLockAction(sender: AnyObject) {
        lock = !lock
        let btnImgLock = (lock) ? UIImage(named: "checkedbox") : UIImage(named: "uncheckedbox")
        btnLock.setImage(btnImgLock, forState: .Normal)
    }
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet var txtSubtitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save the detail in xml
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                d.attributes["zoom"] = (zoom) ? "true" : "false" //"\(btnZoom.on)"
                d.attributes["locked"] = (lock) ? "true" : "false" //"\(btnLock.on)"
                d.attributes["title"] = txtTitle.text
                d.attributes["subtitle"] = txtSubtitle.text
                //d.value = attributedString2pikipiki(txtDesc.attributedText)
                d.value = txtDesc.text
            }
        }
        let _ = writeXML(xml, path: "\(filePath).xml")
        ViewCreateDetailsController?.details["\(tag)"]?.locked = lock
        btnLock.resignFirstResponder()
        ViewCreateDetailsController!.changeDetailColor(tag)
        ViewCreateDetailsController?.setBtnsIcons()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDesc.layer.cornerRadius = 5
        
        let btnImgZoom = (zoom) ? UIImage(named: "checkedbox") : UIImage(named: "uncheckedbox")
        btnZoom.setImage(btnImgZoom, forState: .Normal)
        let btnImgLock = (lock) ? UIImage(named: "checkedbox") : UIImage(named: "uncheckedbox")
        btnLock.setImage(btnImgLock, forState: .Normal)
        txtTitle.text = self.detailTitle
        txtSubtitle.text = self.detailSubtitle
        
        txtDesc.delegate = self
        if self.detailDescription == "" {// Add placeholder
            txtDesc.text = NSLocalizedString("DESCRIPTION...", comment: "")
            txtDesc.textColor = UIColor.lightGrayColor()
        }
        else {
            txtDesc.text = self.detailDescription
        }
        //txtDesc.attributedText = pikipiki2AttributedString(self.detailDescription)
        
        
        //txtDesc.allowsEditingTextAttributes = true
        
        // autofocus
        txtTitle.becomeFirstResponder()
        txtTitle.backgroundColor = UIColor.clearColor()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("DESCRIPTION...", comment: "")
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        txtDesc.setContentOffset(CGPointMake(0, -txtDesc.contentInset.top), animated: false)
    }
    
    func attributedString2pikipiki(attrString: NSAttributedString) -> String {
        let descText = NSMutableString()
        descText.appendString(attrString.string)
        //var text = String()
        var offset: Int = 0
        var bold: Bool = false
        var italic: Bool = false
        
        attrString.enumerateAttribute(NSFontAttributeName, inRange: NSMakeRange(0, attrString.length), options:[]) {value,r,_ in
            if (value != nil) {
                var startIndex: Int = r.location
                var endIndex: Int = r.location+r.length
                let tmpAttr = "\(value!)"
                if (tmpAttr.rangeOfString("bold") != nil && tmpAttr.rangeOfString("italic") != nil) {
                    startIndex += offset
                    descText.insertString("*****", atIndex: startIndex)
                    offset += 5
                    endIndex += offset
                    descText.insertString("*****", atIndex: endIndex)
                    offset += 5
                    bold = true
                    italic = true
                }
                else {
                    if (tmpAttr.rangeOfString("bold") != nil) {
                        startIndex += offset
                        descText.insertString("***", atIndex: startIndex)
                        offset += 3
                        endIndex += offset
                        descText.insertString("***", atIndex: endIndex)
                        offset += 3
                        bold = true
                    }
                    else {
                        bold = false
                    }
                    if (tmpAttr.rangeOfString("italic") != nil) {
                        startIndex += offset
                        descText.insertString("**", atIndex: startIndex)
                        offset += 2
                        endIndex += offset
                        descText.insertString("**", atIndex: endIndex)
                        offset += 2
                        italic = true
                    }
                    else {
                        italic = false
                    }
                }
            }
            //text = "\(descText)"
        }
        
        attrString.enumerateAttribute(NSUnderlineStyleAttributeName, inRange: NSMakeRange(0, attrString.length), options:[]) {value,r,_ in
            if (value != nil) {
                print(r)
                print(descText)
                var startIndex: Int = r.location
                var endIndex: Int = r.location+r.length
                if bold {
                    offset -= 3
                }
                if italic {
                    offset -= 2
                }
                startIndex += offset
                descText.insertString("__", atIndex: startIndex)
                print(descText)
                offset += 2
                endIndex += offset
                descText.insertString("__", atIndex: endIndex)
                offset += 2
            }
        }
        
        return "\(descText)"
    }
    
    func pikipiki2AttributedString(text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let size = [NSFontAttributeName : UIFont.systemFontOfSize(15.0)]
        attributedText.addAttributes(size, range: NSRange(location: 0, length: attributedText.length))
        
        let attributeBold = [NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]
        try! attributedText.addAttributes(attributeBold, delimiter: "***")
        
        let attributeItalic = [NSFontAttributeName: UIFont.italicSystemFontOfSize(15)]
        try! attributedText.addAttributes(attributeItalic, delimiter: "**")
        
        //let attributeUnderline = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        //try! attributedText.addAttributes(attributeUnderline, delimiter: "__")
        
        //print(attributedText)
        
        
        return attributedText
    }
    
}

public extension NSMutableAttributedString {
    func addAttributes(attrs: [String : AnyObject], delimiter: String) throws {
        let escaped = NSRegularExpression.escapedPatternForString(delimiter)
        let regex = try NSRegularExpression(pattern:"\(escaped)(.*?)\(escaped)", options: [])
        
        var offset = 0
        regex.enumerateMatchesInString(string, options: [], range: NSRange(location: 0, length: string.characters.count)) { (result, flags, stop) -> Void in
            guard let result = result else {
                return
            }
            
            let range = NSRange(location: result.range.location + offset, length: result.range.length)
            self.addAttributes(attrs, range: range)
            let replacement = regex.replacementStringForResult(result, inString: self.string, offset: offset, template: "$1")
            self.replaceCharactersInRange(range, withString: replacement)
            offset -= (2 * delimiter.characters.count)
        }
    }
}
