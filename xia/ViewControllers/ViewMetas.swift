//
//  ViewMetas.swift
//  xia
//
//  Created by Guillaume on 19/02/2016.
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

class ViewMetas: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var readOnlyState: Bool = false
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = emptyString
    var selectedSegment: Int = 0
    weak var ViewCollection: ViewCollectionController?
    weak var ViewCreateDetailsController: ViewCreateDetails?
    
    var pass: String = emptyString
    var selectedLicense: String = emptyString
    var showKbd: Bool = true
    var iPadPro: Bool = false
    
    var currentDirs = rootDirs
    
    let availableLicenses = [
        svgLicenseProprietaryKey,
        svgLicenseCCBYKey,
        svgLicenseCCBYSAKey,
        svgLicenseCCBYNDKey,
        svgLicenseCCBYNCKey,
        svgLicenseCCBYNCSAKey,
        svgLicenseCCBYNCNDKey,
        svgLicenceCC0Key,
        svgLicenceFreeArtKey,
        svgLicenseOFLKey,
        svgLicenseOtherKey
    ]
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDone(_ sender: AnyObject) {
        prepareToWriteXML()
        
        let _ = writeXML(xml, path: currentDirs[xmlString]! + separatorString + fileName + xmlExtension)
        ViewCreateDetailsController?.fileTitle = (txtTitle.text == nil) ? fileName : txtTitle.text!
        ViewCreateDetailsController?.setBtnsIcons()
        ViewCollection?.buildLeftNavbarItems()
        ViewCollection?.endEdit()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func changeSegment(_ sender: AnyObject) {
        showSegmentView(segment.selectedSegmentIndex)
    }
    
    // First subview
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var roSwitch: UISwitch!
    @IBAction func roBtnAction(_ sender: AnyObject) {
        let passTitle = (readOnlyState) ? NSLocalizedString(enterCodeKey, comment: emptyString) : NSLocalizedString(createCodeKey, comment: emptyString)
        let controller = UIAlertController(title: passTitle, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        controller.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = NSLocalizedString(passwordKey, comment: emptyString)
            textField.isSecureTextEntry = true  // setting the secured text for using password
            textField.keyboardType = UIKeyboardType.decimalPad
        })
        controller.addAction(UIAlertAction(title: NSLocalizedString(cancelKey, comment: emptyString), style: UIAlertAction.Style.cancel, handler: { action in
            self.roSwitch.isOn = self.readOnlyState
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertAction.Style.default, handler: { action in
            self.pass = (self.xml[xmlXiaKey][xmlreadonlyKey].attributes[xmlCodeKey] == nil) ? emptyString : self.xml[xmlXiaKey][xmlreadonlyKey].attributes[xmlCodeKey]!
            let currentPass = controller.textFields!.first!.text
            
            if self.readOnlyState {
                if currentPass != nil && currentPass! == self.pass {
                    self.readOnlyState = !self.readOnlyState
                }
                else {
                    let alert = UIAlertController(title: NSLocalizedString(errorKey, comment: emptyString), message: NSLocalizedString(tryAgainKey, comment: emptyString), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertAction.Style.destructive, handler: { action in
                        self.present(controller, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else { // create password
                // double check
                let check = UIAlertController(title: NSLocalizedString(doubleCheckKey, comment: emptyString), message: nil, preferredStyle: UIAlertController.Style.alert)
                
                check.addTextField(configurationHandler: {(checkPass: UITextField!) in
                    checkPass.placeholder = NSLocalizedString(passwordKey, comment: emptyString)
                    checkPass.isSecureTextEntry = true  // setting the secured text for using password
                    checkPass.keyboardType = UIKeyboardType.decimalPad
                })
                check.addAction(UIAlertAction(title: NSLocalizedString(cancelKey, comment: emptyString), style: UIAlertAction.Style.cancel, handler: { action in
                    self.roSwitch.isOn = self.readOnlyState
                }))
                check.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertAction.Style.default, handler: { action in
                    let doubleCheck = check.textFields!.first!.text
                    if currentPass == doubleCheck {
                        self.pass = (currentPass == nil) ? emptyString : currentPass!
                        self.readOnlyState = !self.readOnlyState
                        
                        // save to xml
                        self.prepareToWriteXML()
                        let _ = writeXML(self.xml, path: self.currentDirs[xmlString]! + separatorString + self.fileName + xmlExtension)
                        
                    }
                    else {
                        let alert = UIAlertController(title: NSLocalizedString(errorKey, comment: emptyString), message: NSLocalizedString(tryAgainKey, comment: emptyString), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertAction.Style.destructive, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }))
                
                self.present(check, animated: true, completion: nil)
            }
        }))
        
        present(controller, animated: true, completion: nil)
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
    @IBAction func showDatePicker(_ sender: AnyObject) {
        if UIDevice.current.orientation.isLandscape && !iPadPro {
            if showKbd {
                txtCreator.resignFirstResponder()
                datePicker.isHidden = false
            }
            else {
                datePicker.isHidden = true
                txtCreator.becomeFirstResponder()
            }
        }
    }
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBAction func datePicker(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        let strDate = dateFormatter.string(from: datePicker.date)
        txtDate.setTitle(strDate, for: UIControl.State())
    }
    
    // Third subview
    @IBOutlet var txtLanguages: UITextField!
    @IBOutlet var txtKeywords: UITextField!
    
    @IBOutlet var txtContributors: UITextField!
    @IBOutlet var txtRelation: UITextField!
    @IBOutlet var txtCoverage: UITextField!
    @IBOutlet var txtLicense: UIButton!
    @IBAction func showLicensePicker(_ sender: AnyObject) {
        if UIDevice.current.orientation.isLandscape && !iPadPro {
            if showKbd {
                txtLanguages.resignFirstResponder()
                licensePicker.isHidden = false
            }
            else {
                licensePicker.isHidden = true
                txtLanguages.becomeFirstResponder()
            }
        }
    }
    
    @IBOutlet var licensePicker: UIPickerView!
    
    // Fourth subbiew
    @IBOutlet var imgTitle: UITextField!
    @IBOutlet var imgDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSegmentView(selectedSegment)
        segment.selectedSegmentIndex = selectedSegment
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewMetas.keybShow(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewMetas.keybHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Get the device model identifier
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineString = machineMirror.children.reduce(emptyString) { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        iPadPro = (machineString == iPad67String || machineString == iPad68String) ? true : false
        
        // First subview
        if selectedSegment == 0 {
            txtTitle.becomeFirstResponder()
        }
        txtTitle.text = (xml[xmlXiaKey][xmlTitleKey].value != nil) ? xml[xmlXiaKey][xmlTitleKey].value : emptyString
        navBar.topItem?.title = (txtTitle.text == emptyString) ? fileName : txtTitle.text
        readOnlyState = (xml[xmlXiaKey][xmlreadonlyKey].value == trueString ) ? true : false
        roSwitch.isOn = readOnlyState
        showDetailSwitch.isOn = (xml[xmlXiaKey][xmlDetailsKey].attributes[xmlShowKey] == trueString) ? true : false
        
        txtDescription.text = (xml[xmlXiaKey][xmlDescriptionKey].value != nil) ? xml[xmlXiaKey][xmlDescriptionKey].value! : emptyString
        txtDescription.layer.cornerRadius = 5        

        // Second subview
        txtCreator.text = (xml[xmlXiaKey][creatorKey].value != nil) ? xml[xmlXiaKey][creatorKey].value : emptyString
        txtRights.text = (xml[xmlXiaKey][rightsKey].value != nil) ? xml[xmlXiaKey][rightsKey].value : emptyString
        txtPublisher.text = (xml[xmlXiaKey][publisherKey].value != nil) ? xml[xmlXiaKey][publisherKey].value : emptyString
        txtIdentifier.text = (xml[xmlXiaKey][identifierKey].value != nil) ? xml[xmlXiaKey][identifierKey].value : emptyString
        txtSource.text = (xml[xmlXiaKey][sourceKey].value != nil) ? xml[xmlXiaKey][sourceKey].value : emptyString
        
        var detailDate = Date(timeIntervalSinceNow: TimeInterval(0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none
        if ( xml[xmlXiaKey][dateKey].value != nil && xml[xmlXiaKey][dateKey].value! != String(format: xmlElementNotFound, dateKey) ){
            detailDate = (dateFormatter.date(from: xml[xmlXiaKey][dateKey].value!) != nil) ? dateFormatter.date(from: xml[xmlXiaKey][dateKey].value!)! : detailDate
            txtDate.setTitle(xml[xmlXiaKey][dateKey].value!, for: UIControl.State())
        }
        else {
            let stringDate: String = dateFormatter.string(from: detailDate)
            txtDate.setTitle(stringDate, for: UIControl.State())
            
        }
        datePicker.setDate(detailDate, animated: false)
        
        // Third subview
        txtLanguages.text = (xml[xmlXiaKey][languageKey].value != nil) ? xml[xmlXiaKey][languageKey].value : emptyString
        txtKeywords.text = (xml[xmlXiaKey][keywordsKey].value != nil) ? xml[xmlXiaKey][keywordsKey].value : emptyString
        txtContributors.text = (xml[xmlXiaKey][contributorsKey].value != nil) ? xml[xmlXiaKey][contributorsKey].value : emptyString
        txtRelation.text = (xml[xmlXiaKey][relationKey].value != nil) ? xml[xmlXiaKey][relationKey].value : emptyString
        txtCoverage.text = (xml[xmlXiaKey][coverageKey].value != nil) ? xml[xmlXiaKey][coverageKey].value : emptyString
        
        let xmlLicense = (xml[xmlXiaKey][licenseKey].value != nil) ? xml[xmlXiaKey][licenseKey].value! : svgLicenseCCBYNCKey
        licensePicker.dataSource = self
        licensePicker.delegate = self
        for (index, namedLicense) in availableLicenses.enumerated()
        {
            if namedLicense == xmlLicense
            {
                licensePicker.selectRow(index, inComponent: 0, animated: true)
            }
        }
        txtLicense.setTitle(xmlLicense, for: UIControl.State())
        selectedLicense = xmlLicense
        
        // Fourth subview
        imgTitle.text = (xml[xmlXiaKey][xmlImageKey].attributes[xmlTitleKey] != nil) ? xml[xmlXiaKey][xmlImageKey].attributes[xmlTitleKey]! : emptyString
        imgDescription.text = (xml[xmlXiaKey][xmlImageKey].attributes[xmlDescriptionKey] != nil) ? xml[xmlXiaKey][xmlImageKey].attributes[xmlDescriptionKey]! : emptyString
        imgDescription.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtDescription.setContentOffset(CGPoint(x: 0, y: -txtDescription.contentInset.top), animated: false)
    }
    
    @objc func keybShow(_ notification: Notification) {
        showKbd = true
    }
    
    
    @objc func keybHide(_ notification: Notification) {
        showKbd = false
    }

    func showSegmentView(_ index: Int) {
        for subview in stackView.subviews {
            if subview.tag > 9 {
                if subview.tag == index + 10 {
                    subview.isHidden = false
                }
                else {
                    subview.isHidden = true
                }
            }
        }
        if index == 1 {
            txtCreator.becomeFirstResponder()
            datePicker.isHidden = (UIDevice.current.orientation.isLandscape && !iPadPro) ? true : false
        }
        if index == 2 {
            txtLanguages.becomeFirstResponder()
            licensePicker.isHidden = (UIDevice.current.orientation.isLandscape && !iPadPro) ? true : false
        }
        if index == 3 {
            imgTitle.becomeFirstResponder()
        }
    }
    
    func prepareToWriteXML() {
        // Save metas in xml
        xml[xmlXiaKey][xmlTitleKey].value = txtTitle.text
        xml[xmlXiaKey][xmlreadonlyKey].value = String(roSwitch.isOn)
        xml[xmlXiaKey][xmlreadonlyKey].attributes[xmlCodeKey] = pass
        xml[xmlXiaKey][xmlDetailsKey].attributes[xmlShowKey] = String(showDetailSwitch.isOn)
        xml[xmlXiaKey][xmlDescriptionKey].value = txtDescription.text
        
        xml[xmlXiaKey][creatorKey].value = txtCreator.text
        xml[xmlXiaKey][rightsKey].value = txtRights.text
        xml[xmlXiaKey][publisherKey].value = txtPublisher.text
        xml[xmlXiaKey][identifierKey].value = txtIdentifier.text
        xml[xmlXiaKey][sourceKey].value = txtSource.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none
        xml[xmlXiaKey][dateKey].value = dateFormatter.string(from: datePicker.date)
        
        xml[xmlXiaKey][languageKey].value = txtLanguages.text
        xml[xmlXiaKey][keywordsKey].value = txtKeywords.text
        xml[xmlXiaKey][contributorsKey].value = txtContributors.text
        xml[xmlXiaKey][relationKey].value = txtRelation.text
        xml[xmlXiaKey][coverageKey].value = txtCoverage.text
        xml[xmlXiaKey][licenseKey].value = selectedLicense
        
        xml[xmlXiaKey][xmlImageKey].attributes[xmlTitleKey] = imgTitle.text
        xml[xmlXiaKey][xmlImageKey].attributes[xmlDescriptionKey] = imgDescription.text
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableLicenses.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableLicenses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLicense = availableLicenses[row]
        txtLicense.setTitle(selectedLicense, for: UIControl.State())
    }
    
}
