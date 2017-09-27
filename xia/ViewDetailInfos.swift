//
//  ViewDetailInfo.swift
//  xia
//
//  Created by Guillaume on 18/11/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit
import Foundation

class ViewDetailInfos: UIViewController, UITextViewDelegate {
        
    @objc var tag: Int = 0
    @objc var zoom: Bool = false
    @objc var lock: Bool = false
    @objc var detailTitle: String = ""
    @objc var detailDescription: String = ""
    @objc var xml: AEXMLDocument = AEXMLDocument()
    @objc var index: Int = 0
    @objc var fileName: String = ""
    @objc weak var ViewCreateDetailsController: ViewCreateDetails?

    @IBOutlet var switchZoom: UISwitch!
    @IBAction func btnZoomAction(_ sender: AnyObject) {
        zoom = !zoom
        switchZoom.isOn = zoom
    }
    @IBOutlet var switchLock: UISwitch!
    @IBAction func btnLockAction(_ sender: AnyObject) {
        lock = !lock
        switchLock.isOn = lock
    }
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDone(_ sender: AnyObject) {
        // Save the detail in xml
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                d.attributes["zoom"] = "\(switchZoom.isOn)"
                d.attributes["locked"] = "\(switchLock.isOn)"
                d.attributes["title"] = txtTitle.text
                //d.value = attributedString2pikipiki(txtDesc.attributedText)
                d.value = txtDesc.text
            }
        }
        let _ = writeXML(xml, path: xmlDirectory + "/\(fileName).xml")
        ViewCreateDetailsController?.details["\(tag)"]?.locked = lock
        ViewCreateDetailsController!.changeDetailColor(tag)
        ViewCreateDetailsController?.setBtnsIcons()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDesc.layer.cornerRadius = 5
        switchZoom.isOn = zoom
        switchLock.isOn = lock
        txtTitle.text = self.detailTitle
        
        txtDesc.delegate = self
        if self.detailDescription == "" {// Add placeholder
            txtDesc.text = NSLocalizedString("DESCRIPTION...", comment: "")
            txtDesc.textColor = UIColor.lightGray
        }
        else {
            txtDesc.text = self.detailDescription
        }
        
        // autofocus
        txtTitle.becomeFirstResponder()
        txtTitle.backgroundColor = UIColor.clear
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("DESCRIPTION...", comment: "")
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtDesc.setContentOffset(CGPoint(x: 0, y: -txtDesc.contentInset.top), animated: false)
    }
    
    @objc func attributedString2pikipiki(_ attrString: NSAttributedString) -> String {
        let descText = NSMutableString()
        descText.append(attrString.string)
        //var text = String()
        var offset: Int = 0
        var bold: Bool = false
        var italic: Bool = false
        
        attrString.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, attrString.length), options:[]) {value,r,_ in
            if (value != nil) {
                var startIndex: Int = r.location
                var endIndex: Int = r.location+r.length
                let tmpAttr = "\(value!)"
                if (tmpAttr.range(of: "bold") != nil && tmpAttr.range(of: "italic") != nil) {
                    startIndex += offset
                    descText.insert("*****", at: startIndex)
                    offset += 5
                    endIndex += offset
                    descText.insert("*****", at: endIndex)
                    offset += 5
                    bold = true
                    italic = true
                }
                else {
                    if (tmpAttr.range(of: "bold") != nil) {
                        startIndex += offset
                        descText.insert("***", at: startIndex)
                        offset += 3
                        endIndex += offset
                        descText.insert("***", at: endIndex)
                        offset += 3
                        bold = true
                    }
                    else {
                        bold = false
                    }
                    if (tmpAttr.range(of: "italic") != nil) {
                        startIndex += offset
                        descText.insert("**", at: startIndex)
                        offset += 2
                        endIndex += offset
                        descText.insert("**", at: endIndex)
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
        
        attrString.enumerateAttribute(NSAttributedStringKey.underlineStyle, in: NSMakeRange(0, attrString.length), options:[]) {value,r,_ in
            if (value != nil) {
                dbg.pt("\(r)")
                dbg.pt(descText as String)
                var startIndex: Int = r.location
                var endIndex: Int = r.location+r.length
                if bold {
                    offset -= 3
                }
                if italic {
                    offset -= 2
                }
                startIndex += offset
                descText.insert("__", at: startIndex)
                dbg.pt(descText as String)
                offset += 2
                endIndex += offset
                descText.insert("__", at: endIndex)
                offset += 2
            }
        }
        
        return "\(descText)"
    }
    
    /*@objc func pikipiki2AttributedString(_ text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let size = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0)]
        attributedText.addAttributes(size, range: NSRange(location: 0, length: attributedText.length))
        
        let attributeBold = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)]
        try! attributedText.addAttributes(attributeBold, delimiter: "***")
        
        let attributeItalic = [NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 15)]
        try! attributedText.addAttributes(attributeItalic, delimiter: "**")
        
        //let attributeUnderline = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        //try! attributedText.addAttributes(attributeUnderline, delimiter: "__")
        
        //dbg.pt(attributedText)
        
        
        return attributedText
    }*/
    
}

public extension NSMutableAttributedString {
    @objc func addAttributes(_ attrs: [NSAttributedStringKey : Any], delimiter: String) throws {
        let escaped = NSRegularExpression.escapedPattern(for: delimiter)
        let regex = try NSRegularExpression(pattern:"\(escaped)(.*?)\(escaped)", options: [])
        
        var offset = 0
        regex.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count)) { (result, flags, stop) -> Void in
            guard let result = result else {
                return
            }
            
            let range = NSRange(location: result.range.location + offset, length: result.range.length)
            self.addAttributes(attrs, range: range)
            let replacement = regex.replacementString(for: result, in: self.string, offset: offset, template: "$1")
            self.replaceCharacters(in: range, with: replacement)
            offset -= (2 * delimiter.characters.count)
        }
    }
}
