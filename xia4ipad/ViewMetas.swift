//
//  ViewMetas.swift
//  xia4ipad
//
//  Created by Guillaume on 19/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewMetas: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let dbg = debug(enable: true)
    
    var readOnlyState: Bool = false
    var xml: AEXMLDocument = AEXMLDocument()
    var filePath: String = ""
    var landscape: Bool = false
    var selectedSegment: Int = 0
    weak var ViewCreateDetailsController: ViewCreateDetails?
    
    var pass: String = ""
    var selectedLicense: String = ""
    var showPicker: Bool = true
    
    
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
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save metas in xml
        xml["xia"]["title"].value = txtTitle.text
        xml["xia"]["readonly"].value = "\(roSwitch.on)"
        xml["xia"]["readonly"].attributes["code"] = pass
        xml["xia"]["details"].attributes["show"] = "\(showDetailSwitch.on)"
        xml["xia"]["description"].value = txtDescription.text
        
        xml["xia"]["creator"].value = txtCreator.text
        xml["xia"]["rights"].value = txtRights.text
        xml["xia"]["publisher"].value = txtPublisher.text
        xml["xia"]["identifier"].value = txtIdentifier.text
        xml["xia"]["source"].value = txtSource.text
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        xml["xia"]["date"].value = dateFormatter.stringFromDate(datePicker.date)
        
        xml["xia"]["language"].value = txtLanguages.text
        xml["xia"]["keywords"].value = txtKeywords.text
        xml["xia"]["contributors"].value = txtContributors.text
        xml["xia"]["relation"].value = txtRelation.text
        xml["xia"]["coverage"].value = txtCoverage.text
        xml["xia"]["license"].value = selectedLicense
        
        xml["xia"]["image"].attributes["title"] = imgTitle.text
        xml["xia"]["image"].attributes["description"] = imgDescription.text
        
        let _ = writeXML(xml, path: "\(filePath).xml")
        ViewCreateDetailsController?.fileTitle = (txtTitle.text == nil) ? " " : txtTitle.text!
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var segment: UISegmentedControl!
    
    @IBAction func changeSegment(sender: AnyObject) {
        showSegmentView(segment.selectedSegmentIndex)
    }
    
    // First subview
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var roSwitch: UISwitch!
    @IBAction func roBtnAction(sender: AnyObject) {
        let passTitle = (readOnlyState) ? NSLocalizedString("ENTER_CODE", comment: "") : NSLocalizedString("CREATE_CODE", comment: "")
        let controller = UIAlertController(title: passTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = NSLocalizedString("PASSWORD", comment: "")
            textField.secureTextEntry = true  // setting the secured text for using password
            textField.keyboardType = UIKeyboardType.DecimalPad
        })
        controller.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: UIAlertActionStyle.Cancel, handler: { action in
            self.roSwitch.on = self.readOnlyState
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: { action in
            self.pass = (self.xml["xia"]["readonly"].attributes["code"] == nil) ? "" : self.xml["xia"]["readonly"].attributes["code"]!
            let currentPass = controller.textFields!.first!.text
            
            if self.readOnlyState {
                if currentPass != nil && currentPass! == self.pass {
                    self.readOnlyState = !self.readOnlyState
                }
                else {
                    let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("TRY_AGAIN", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Destructive, handler: { action in
                        self.presentViewController(controller, animated: true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else { // create password
                // double check
                let check = UIAlertController(title: NSLocalizedString("DOUBLE_CHECK", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
                check.addTextFieldWithConfigurationHandler({(checkPass: UITextField!) in
                    checkPass.placeholder = NSLocalizedString("PASSWORD", comment: "")
                    checkPass.secureTextEntry = true  // setting the secured text for using password
                    checkPass.keyboardType = UIKeyboardType.DecimalPad
                })
                check.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: UIAlertActionStyle.Cancel, handler: { action in
                    self.roSwitch.on = self.readOnlyState
                }))
                check.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: { action in
                    let doubleCheck = check.textFields!.first!.text
                    if currentPass == doubleCheck {
                        self.pass = (currentPass == nil) ? "" : currentPass!
                        self.readOnlyState = !self.readOnlyState
                    }
                    else {
                        let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("TRY_AGAIN", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Destructive, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }))
                
                self.presentViewController(check, animated: true, completion: nil)
            }
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBOutlet var showDetailSwitch: UISwitch!
    
    @IBOutlet var txtDescription: UITextView!
    
    // Second subview
    @IBOutlet var txtCreator: UITextField!
    @IBOutlet var txtRights: UITextField!
    @IBOutlet var txtPublisher: UITextField!
    @IBOutlet var txtIdentifier: UITextField!
    @IBOutlet var txtSource: UITextField!
    @IBOutlet var txtDate: UIButton!
    @IBAction func showDatePicker(sender: AnyObject) {
        if showPicker {
            if landscape {
                txtCreator.becomeFirstResponder()
                txtCreator.resignFirstResponder()
            }
            datePicker.hidden = false
        }
        else {
            datePicker.hidden = true
            txtCreator.becomeFirstResponder()
        }
        showPicker = !showPicker
    }
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBAction func datePicker(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        txtDate.setTitle(strDate, forState: .Normal)
    }
    
    // Third subview
    @IBOutlet var txtLanguages: UITextField!
    @IBOutlet var txtKeywords: UITextField!
    
    @IBOutlet var txtContributors: UITextField!
    @IBOutlet var txtRelation: UITextField!
    @IBOutlet var txtCoverage: UITextField!
    @IBOutlet var txtLicense: UIButton!
    @IBAction func showLicensePicker(sender: AnyObject) {
        if showPicker {
            if landscape {
                txtLanguages.becomeFirstResponder()
                txtLanguages.resignFirstResponder()
            }
            licensePicker.hidden = false
        }
        else {
            licensePicker.hidden = true
            txtLanguages.becomeFirstResponder()
        }
        showPicker = !showPicker
    }
    
    @IBOutlet var licensePicker: UIPickerView!
    
    // Fourth subbiew
    @IBOutlet var imgTitle: UITextField!
    @IBOutlet var imgDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSegmentView(selectedSegment)
        segment.selectedSegmentIndex = selectedSegment
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewMetas.keybShow(_:)),
            name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewMetas.keybHide(_:)),
            name: UIKeyboardWillHideNotification, object: nil)
        
        // First subview
        if selectedSegment == 0 {
            txtTitle.becomeFirstResponder()
        }
        txtTitle.text = (xml["xia"]["title"].value != nil) ? xml["xia"]["title"].value : ""
        navBar.topItem?.title = txtTitle.text
        readOnlyState = (xml["xia"]["readonly"].value == "true" ) ? true : false
        roSwitch.on = readOnlyState
        showDetailSwitch.on = (xml["xia"]["details"].attributes["show"] == "true") ? true : false
        
        txtDescription.text = (xml["xia"]["description"].value != nil) ? xml["xia"]["description"].value! : ""
        txtDescription.layer.cornerRadius = 5        

        // Second subview
        txtCreator.text = (xml["xia"]["creator"].value != nil) ? xml["xia"]["creator"].value : ""
        txtRights.text = (xml["xia"]["rights"].value != nil) ? xml["xia"]["rights"].value : ""
        txtPublisher.text = (xml["xia"]["publisher"].value != nil) ? xml["xia"]["publisher"].value : ""
        txtIdentifier.text = (xml["xia"]["identifier"].value != nil) ? xml["xia"]["identifier"].value : ""
        txtSource.text = (xml["xia"]["source"].value != nil) ? xml["xia"]["source"].value : ""
        
        var detailDate = NSDate(timeIntervalSinceNow: NSTimeInterval(0))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        if ( xml["xia"]["date"].value != nil && xml["xia"]["date"].value! != "element <date> not found"){
            detailDate = (dateFormatter.dateFromString(xml["xia"]["date"].value!) != nil) ? dateFormatter.dateFromString(xml["xia"]["date"].value!)! : detailDate
            txtDate.setTitle(xml["xia"]["date"].value!, forState: .Normal)
        }
        else {
            let stringDate: String = dateFormatter.stringFromDate(detailDate)
            txtDate.setTitle(stringDate, forState: .Normal)
            
        }
        datePicker.setDate(detailDate, animated: false)
        
        // Third subview
        txtLanguages.text = (xml["xia"]["language"].value != nil) ? xml["xia"]["language"].value : ""
        txtKeywords.text = (xml["xia"]["keywords"].value != nil) ? xml["xia"]["keywords"].value : ""
        txtContributors.text = (xml["xia"]["contributors"].value != nil) ? xml["xia"]["contributors"].value : ""
        txtRelation.text = (xml["xia"]["relation"].value != nil) ? xml["xia"]["relation"].value : ""
        txtCoverage.text = (xml["xia"]["coverage"].value != nil) ? xml["xia"]["coverage"].value : ""
        
        let xmlLicense = (xml["xia"]["license"].value != nil) ? xml["xia"]["license"].value! : "CC Attribution-NonCommercial - CC-BY-NC"
        licensePicker.dataSource = self
        licensePicker.delegate = self
        for (index, namedLicense) in availableLicenses.enumerate()
        {
            if namedLicense == xmlLicense
            {
                licensePicker.selectRow(index, inComponent: 0, animated: true)
            }
        }
        txtLicense.setTitle(xmlLicense, forState: .Normal)
        selectedLicense = xmlLicense
        
        // Fourth subview
        imgTitle.text = (xml["xia"]["image"].attributes["title"] != nil) ? xml["xia"]["image"].attributes["title"]! : ""
        imgDescription.text = (xml["xia"]["image"].attributes["description"] != nil) ? xml["xia"]["image"].attributes["description"]! : ""
        imgDescription.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(animated: Bool) {
        txtDescription.setContentOffset(CGPointMake(0, -txtDescription.contentInset.top), animated: false)
    }
    
    func keybShow(notification: NSNotification) {
        showPicker = true
    }
    
    
    func keybHide(notification: NSNotification) {
        showPicker = false
    }

    func showSegmentView(index: Int) {
        for subview in view.subviews {
            if subview.tag > 9 {
                if subview.tag == index + 10 {
                    subview.hidden = false
                }
                else {
                    subview.hidden = true
                }
            }
        }
        if index == 1 {
            txtCreator.becomeFirstResponder()
            datePicker.hidden = true
        }
        if index == 2 {
            txtLanguages.becomeFirstResponder()
            licensePicker.hidden = true
        }
        if index == 3 {
            imgTitle.becomeFirstResponder()
        }
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
        txtLicense.setTitle(selectedLicense, forState: .Normal)
    }
    
}
