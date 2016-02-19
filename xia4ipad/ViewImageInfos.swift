//
//  ViewImageInfos.swift
//  xia4ipad
//
//  Created by Guillaume on 08/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewImageInfos: UIViewController {
    
    var dbg = debug(enable: true)
    
    var imageTitle: String = ""
    var imageCreator: String = ""
    var imageRights: String = ""
    var imageDesc: String = ""
    var readOnlyState: Bool = false
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
    var filePath: String = ""
    var pass: String = ""
    weak var ViewCreateDetailsController: ViewCreateDetails?
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtCreator: UITextField!
    @IBOutlet weak var txtRights: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var readOnly: UISwitch!
    @IBAction func askPass(sender: AnyObject) {
        let passTitle = (readOnlyState) ? "Enter code" : "Create code"
        let controller = UIAlertController(title: passTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true  // setting the secured text for using password
            textField.keyboardType = UIKeyboardType.DecimalPad
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            self.readOnly.on = self.readOnlyState
        }))
        controller.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            self.pass = (self.xml["xia"]["readonly"].attributes["code"] == nil) ? "" : self.xml["xia"]["readonly"].attributes["code"]!
            let currentPass = controller.textFields!.first!.text
            
            if self.readOnlyState {
                if currentPass != nil && currentPass! == self.pass {
                    self.readOnly.on = !self.readOnlyState
                    self.readOnlyState = !self.readOnlyState
                }
                else {
                    let alert = UIAlertController(title: "Wrong code", message: "Please, try again or cancel...", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { action in
                        self.presentViewController(controller, animated: true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else { // create password
                // double check
                let check = UIAlertController(title: "Again please...", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
                check.addTextFieldWithConfigurationHandler({(checkPass: UITextField!) in
                    checkPass.placeholder = "Password"
                    checkPass.secureTextEntry = true  // setting the secured text for using password
                    checkPass.keyboardType = UIKeyboardType.DecimalPad
                })
                check.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                    self.readOnly.on = self.readOnlyState
                }))
                check.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                    let doubleCheck = check.textFields!.first!.text
                    if currentPass == doubleCheck {
                        self.pass = (currentPass == nil) ? "" : currentPass!
                        self.readOnly.on = !self.readOnlyState
                        self.readOnlyState = !self.readOnlyState
                    }
                    else {
                        let alert = UIAlertController(title: "Code error", message: "Please, try again...", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.readOnly.on = self.readOnlyState
                    }
                    
                }))
                
                self.presentViewController(check, animated: true, completion: nil)
                
                
            }
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save the image infos in xml
        
        xml["xia"]["title"].value = txtTitle.text
        xml["xia"]["creator"].value = txtCreator.text
        xml["xia"]["rights"].value = txtRights.text
        xml["xia"]["description"].value = txtDesc.text
        xml["xia"]["readonly"].value = "\(readOnly.on)"
        xml["xia"]["readonly"].attributes["code"] = pass
        let _ = writeXML(xml, path: "\(filePath).xml")
        ViewCreateDetailsController?.btnTitleLabel.title = txtTitle.text
        txtTitle.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border to description
        
        txtDesc.layer.borderWidth = 1
        txtDesc.layer.cornerRadius = 5
        txtDesc.layer.borderColor = UIColor.grayColor().CGColor
        
        txtTitle.text = self.imageTitle
        txtCreator.text = self.imageCreator
        txtRights.text = self.imageRights
        txtDesc.text = self.imageDesc
        readOnly.setOn(readOnlyState, animated: true)
        
        // autofocus
        txtTitle.becomeFirstResponder()
        txtTitle.backgroundColor = UIColor.clearColor()
        
        // Avoid keyboard to mask bottom
        let width: CGFloat = UIScreen.mainScreen().bounds.width - 100
        var height: CGFloat = UIScreen.mainScreen().bounds.height / 2
        height -= (UIDevice.currentDevice().orientation.rawValue < 2) ? 100 : 20
        self.preferredContentSize = CGSizeMake(width, height)
    }
    
}
