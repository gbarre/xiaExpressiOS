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
        switch info["UIImagePickerControllerMediaType"] as! String {
        case "public.movie":
            let path = (info["UIImagePickerControllerMediaURL"] as! NSURL).path!
            copyFile(at: path, type: "videos", ext: "MOV")
        case "public.image":
            let path = (info["UIImagePickerControllerImageURL"] as! NSURL).path!
            copyFile(at: path, type: "images", ext: "JPG")
        default:
            print("default")
        }
    }
    
    func copyFile(at: String, type: String, ext: String) {
        let controller = UIAlertController(title: "Choose FileName", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        controller.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.alphabet
            textField.placeholder = "filename"
        })
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: { action in
            if (controller.textFields![0].text! != "") {
                let fileName = controller.textFields![0].text! + "." + ext
                do {
                    try FileManager.default.copyItem(atPath: at, toPath: localDatasDirectory + "/" + type + "/" + fileName)
                } catch {
                    dbg.pt(error.localizedDescription)
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
