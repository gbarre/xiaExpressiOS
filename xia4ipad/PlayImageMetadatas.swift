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
    let xmlElements: [String: String!] = [
        "license" : "License: ",
        "title" : "Title: ",
        "date" : "Date: ",
        "creator" : "Creator: ",
        "rights" : "Rights: ",
        "publisher" : "Publisher: ",
        "identifier" : "Identifier: ",
        "source" : "Source: ",
        "relation" : "Relation: ",
        "language" : "Language: ",
        "keywords" : "Keywords: ",
        "coverage" : "Coverage: ",
        "contributors" : "Contributors: ",
        "description" : "Description: "
    ]
    
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
    @IBOutlet weak var documentDescription: UITextView!
    
    override func viewDidLoad() {
        
        documentLicense.attributedText = getLicense()
        documentTitle.attributedText = getElementValue("title")
        documentDate.attributedText = getElementValue("date")
        documentCreator.attributedText = getElementValue("creator")
        documentRights.attributedText = getElementValue("rights")
        documentPublisher.attributedText = getElementValue("publisher")
        documentIdentifier.attributedText = getElementValue("identifier")
        documentSource.attributedText = getElementValue("source")
        documentRelation.attributedText = getElementValue("relation")
        documentLanguage.attributedText = getElementValue("language")
        documentKeywords.attributedText = getElementValue("keywords")
        documentCoverage.attributedText = getElementValue("coverage")
        documentContributors.attributedText = getElementValue("contributors")
        documentDescription.attributedText = getDescriptionValue()
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func getElementValue(element: String) -> NSAttributedString! {
        let key = xmlElements[element]
        let keyWidth = key?.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!)
        let txtSize: CGFloat = (element == "description") ? 17 : 14
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(txtSize)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"][element].value != nil && xml["xia"][element].value != "element <\(element)> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml["xia"][element].value!)
            attributedText.appendAttributedString(attributedValue)
        }
        
        return attributedText
    }
    
    func getDescriptionValue() -> NSAttributedString! {
        let key = xmlElements["description"]
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
        let key = xmlElements["license"]
        let keyWidth = key!.characters.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!)
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(28)], range: NSRange(location: 0, length: keyWidth))
        
        if (xml["xia"]["license"].value != nil && xml["xia"]["license"].value != "element <license> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: "\n\(xml["xia"]["license"].value!)")
            attributedText.appendAttributedString(attributedValue)
        }
        else {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: "\nNone")
            attributedText.appendAttributedString(attributedValue)
        }
        
        return attributedText
    }
    
}
