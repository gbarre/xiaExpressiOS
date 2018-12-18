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
        
    var tag: Int = 0
    var zoom: Bool = false
    var lock: Bool = false
    var detailTitle: String = emptyString
    var detailDescription: String = emptyString
    var xml: AEXMLDocument = AEXMLDocument()
    var index: Int = 0
    var fileName: String = emptyString
    weak var ViewCreateDetailsController: ViewCreateDetails?
    var currentDirs = rootDirs

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
        if let detail = xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(tag)]) {
            for d in detail {
                d.attributes[xmlZoomKey] = String(switchZoom.isOn)
                d.attributes[xmlLockedKey] = String(switchLock.isOn)
                d.attributes[xmlTitleKey] = txtTitle.text
                d.value = txtDesc.text
            }
        }
        let _ = writeXML(xml, path: currentDirs[xmlString]! + separatorString + fileName + xmlExtension)
        ViewCreateDetailsController?.details[String(tag)]?.locked = lock
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
        if self.detailDescription == emptyString {// Add placeholder
            txtDesc.text = NSLocalizedString(descriptionDotKey, comment: emptyString)
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
            textView.text = emptyString
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString(descriptionDotKey, comment: emptyString)
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtDesc.setContentOffset(CGPoint(x: 0, y: -txtDesc.contentInset.top), animated: false)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == addMediaSegueKey) {
            if let controller:ViewTableLocalDatas = segue.destination as? ViewTableLocalDatas {
                controller.ViewDetailInfosController = self
                controller.cursorPosition = txtDesc.selectedTextRange
            }
        }
     }
}
