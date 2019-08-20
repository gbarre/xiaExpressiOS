//
//  ViewMenuAddResource.swift
//  xia
//
//  Created by Guillaume on 02/05/2016.
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

class ViewMenuAddResource: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc weak var ViewCollection: ViewCollectionController?
    var currentDirs = rootDirs
    
    @objc var newMedia: Bool = false
    @objc let imagePicker = UIImagePickerController() // Needed to show the imagePicker in the Container View
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            //load the camera interface
            let picker:UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
            self.newMedia = true
        }
        else{
            //no camera available
            let alert = UIAlertController(title: NSLocalizedString(errorKey, comment: emptyString), message: NSLocalizedString(noCameraKey, comment: emptyString), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        let now: Int = Int(Date().timeIntervalSince1970)
        let imageData = image!.jpegData(compressionQuality: 85)
        ((try? imageData?.write(to: URL(fileURLWithPath: currentDirs[imagesString]! + separatorString + String(now) + jpgExtension), options: [.atomic])) as ()??)
        
        // Create associated xml
        let xml = AEXMLDocument()
        let xmlAsString = xml.createXML(String(now))
        do {
            try xmlAsString.write(toFile: currentDirs[xmlString]! + separatorString + String(now) + xmlExtension, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            debugPrint(error.localizedDescription)
        }
        ViewCollection!.arrayNames.append(String(now))
        
        // copy the image in the library
        if newMedia {
            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        }
        self.dismiss(animated: true, completion: nil)
        ViewCollection!.CollectionView.reloadData()
        
        // Hide the popover after adding the photo in the library
        if newMedia {
            self.dismiss(animated: true, completion: nil)
            newMedia = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let picker = segue.destination as! UIImagePickerController
            picker.delegate = self
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
