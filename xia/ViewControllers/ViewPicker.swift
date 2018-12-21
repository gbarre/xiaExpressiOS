//
//  ViewPicker.swift
//  xia
//
//  Created by Guillaume on 26/01/2018.
//  Copyright © 2018 Dane Versailles. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewPicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var tableLocalDatas: ViewTableLocalDatas?
    @objc let imagePicker = UIImagePickerController() // Needed to show the imagePicker in the Container View
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let path = (info[IPCImageURLKey] as! NSURL).path!
        copyFile(at: path, type: imagesString, ext: jpgString.uppercased())
    }
    
    func copyFile(at: String, type: String, ext: String) {
        let controller = UIAlertController(title: NSLocalizedString(chooseFileNameKey, comment: emptyString), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        controller.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.alphabet
        })
        controller.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: { action in
            if (controller.textFields![0].text! != emptyString) {
                let fileName = controller.textFields![0].text! + dotString + ext
                do {
                    try FileManager.default.copyItem(atPath: at, toPath: localDatasDirectory + separatorString + type + separatorString + fileName)
                } catch {
                    debugPrint(error.localizedDescription)
                }
                self.dismiss(animated: true, completion: nil)
                self.tableLocalDatas?.tableView.reloadData()
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let picker = segue.destination as! UIImagePickerController
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
    }

}
