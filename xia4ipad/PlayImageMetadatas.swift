//
//  PlayImageMetadatas.swift
//  xia4ipad
//
//  Created by Guillaume on 12/12/2015.
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

class PlayImageMetadatas: UIViewController, UIWebViewDelegate {
    
    var xml: AEXMLDocument!
    let xmlElementsDict: [String: String!] = [
        "license" : NSLocalizedString("LICENSE", comment: ""),
        "title" : NSLocalizedString("TITLE", comment: ""),
        "date" : NSLocalizedString("DATE", comment: ""),
        "creator" : NSLocalizedString("CREATOR", comment: ""),
        "rights" : NSLocalizedString("RIGHTS", comment: ""),
        "publisher" : NSLocalizedString("PUBLISHER", comment: ""),
        "identifier" : NSLocalizedString("IDENTIFIER", comment: ""),
        "source" : NSLocalizedString("SOURCE", comment: ""),
        "relation" : NSLocalizedString("RELATION", comment: ""),
        "language" : NSLocalizedString("LANGUAGES", comment: ""),
        "keywords" : NSLocalizedString("KEYWORDS", comment: ""),
        "coverage" : NSLocalizedString("COVERAGE", comment: ""),
        "contributors" : NSLocalizedString("CONTRIBUTORS", comment: ""),
        "description" : NSLocalizedString("DESCRIPTION", comment: "")
    ]
    
    var landscape: Bool = true
    let converter: TextConverter = TextConverter(videoWidth: 480, videoHeight: 270)
    
    @IBAction func Hide(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var documentLicense: UILabel!
    @IBOutlet var documentTitle: UILabel!
    @IBOutlet var documentDate: UILabel!
    @IBOutlet var documentCreator: UILabel!
    @IBOutlet var documentRights: UILabel!
    @IBOutlet var documentPublisher: UILabel!
    @IBOutlet var documentIdentifier: UILabel!
    @IBOutlet var documentSource: UILabel!
    @IBOutlet var documentRelation: UILabel!
    @IBOutlet var documentLanguage: UILabel!
    @IBOutlet var documentKeywords: UILabel!
    @IBOutlet var documentCoverage: UILabel!
    @IBOutlet var documentContributors: UILabel!
    @IBOutlet var documentDescription: UIWebView!
    
    override func viewDidLoad() {
        
        documentLicense.attributedText = getLicense()
        documentTitle.text = (xml["xia"]["title"].value != nil && xml["xia"]["title"].value != "element <title> not found") ? xml["xia"]["title"].value! : ""
        documentDate.attributedText = getElementValue("date")
        documentCreator.text = (xml["xia"]["creator"].value != nil && xml["xia"]["creator"].value != "element <creator> not found") ? xml["xia"]["creator"].value! : ""
        documentRights.attributedText = getElementValue("rights")
        documentPublisher.attributedText = getElementValue("publisher")
        documentIdentifier.attributedText = getElementValue("identifier")
        documentSource.attributedText = getElementValue("source")
        documentRelation.attributedText = getElementValue("relation")
        documentLanguage.attributedText = getElementValue("language")
        documentKeywords.attributedText = getElementValue("keywords")
        documentCoverage.attributedText = getElementValue("coverage")
        documentContributors.attributedText = getElementValue("contributors")
        
        var htmlString = (xml["xia"]["description"].value != nil && xml["xia"]["description"].value != "element <description> not found") ? xml["xia"]["description"].value! : ""
        // Build the webView
        if !landscape {
            converter.videoWidth = 360
            converter.videoHeight = 210
        }
        htmlString = converter._text2html(htmlString)
        
        documentDescription.loadHTMLString(htmlString, baseURL: nil)
        documentDescription.allowsInlineMediaPlayback = true
        documentDescription.delegate = self
        
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func getElementValue(element: String) -> NSAttributedString! {
        let key = xmlElementsDict[element]
        let keyWidth = key?.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!)
        let txtSize: CGFloat = 14
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(txtSize)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"][element].value != nil && xml["xia"][element].value != "element <\(element)> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml["xia"][element].value!)
            attributedText.appendAttributedString(attributedValue)
        }
        
        return attributedText
    }
    
    func getDescriptionValue() -> NSAttributedString! {
        let key = xmlElementsDict["description"]
        let keyWidth = key?.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!)
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"]["description"].value != nil && xml["xia"]["description"].value != "element <description> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml["xia"]["description"].value!)
            attributedText.appendAttributedString(attributedValue)
            let descWidth = xml["xia"]["description"].value!.characters.count
            attributedText.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16)], range: NSRange(location: keyWidth!, length: descWidth))

        }
        
        return attributedText
    }
    
    func getLicense() -> NSAttributedString! {
        let key = xmlElementsDict["license"]
        let keyWidth = key!.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!)
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(17)], range: NSRange(location: 0, length: keyWidth))
        
        if (xml["xia"]["license"].value != nil && xml["xia"]["license"].value != "element <license> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: " \(xml["xia"]["license"].value!)")
            attributedText.appendAttributedString(attributedValue)
        }
        else {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: " None")
            attributedText.appendAttributedString(attributedValue)
        }
        
        return attributedText
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
    
}
