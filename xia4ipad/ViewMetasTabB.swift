//
//  ViewMetasTabB.swift
//  xia4ipad
//
//  Created by Guillaume on 10/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewMetasTabB: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    var filePath: String = ""
    var selectedLicense: String = ""
    
    let availableLicenses = [
        "Proprietary - CC-Zero",
        "CC Attribution - CC-BY",
        "CC Attribution-ShareALike - CC-BY-SA",
        "CC Attribution-NoDerivs - CC-BY-ND",
        "CC Attribution-NonCommercial - CC-BY-NC",
        "CC Attribution-NonCommercial-ShareALike - CC-BY-NC-SA",
        "CC Attribution-NonCommercial-NoDerivs - CC-BY-NC-ND",
        "CC0 Public Domain Dedication",
        "Free Art",
        "Open Font License",
        "Other"
    ]
    
    weak var viewPhotoController: ViewPhoto?
    
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var license: UIPickerView!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save metas in xml
        xml["xia"]["description"].value = txtDescription.text
        xml["xia"]["license"].value = selectedLicense
        
        let _ = writeXML(xml, path: "\(filePath).xml")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xml = globalXML
        filePath = globalFilePath
        
        let xmlLicense = (xml["xia"]["license"].value != nil) ? xml["xia"]["license"].value! : "CC Attribution-NonCommercial - CC-BY-NC"
        license.dataSource = self
        license.delegate = self
        for (index, namedLicense) in availableLicenses.enumerate()
        {
            if namedLicense == xmlLicense
            {
                license.selectRow(index, inComponent: 0, animated: true)
            }
        }
        
        txtDescription.becomeFirstResponder()
        txtDescription.text = (xml["xia"]["description"].value != nil) ? xml["xia"]["description"].value! : ""
        
        
        
        
        //        documentLicense.attributedText = getLicense(xml, xmlElements: xmlElements)
        
        /*        documentRights.attributedText = getElementValue("rights", xml: xml, xmlElements: xmlElements)
        documentPublisher.attributedText = getElementValue("publisher", xml: xml, xmlElements: xmlElements)
        documentIdentifier.attributedText = getElementValue("identifier", xml: xml, xmlElements: xmlElements)
        documentSource.attributedText = getElementValue("source", xml: xml, xmlElements: xmlElements)
        documentRelation.attributedText = getElementValue("relation", xml: xml, xmlElements: xmlElements)
        documentLanguage.attributedText = getElementValue("language", xml: xml, xmlElements: xmlElements)
        documentKeywords.attributedText = getElementValue("keywords", xml: xml, xmlElements: xmlElements)
        documentCoverage.attributedText = getElementValue("coverage", xml: xml, xmlElements: xmlElements)
        documentContributors.attributedText = getElementValue("contributors", xml: xml, xmlElements: xmlElements)
        documentDescription.attributedText = getElementValue("description", xml: xml, xmlElements: xmlElements)
        */
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableLicenses.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableLicenses[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLicense = availableLicenses[row]
    }
}
