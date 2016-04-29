//
//  MenuAddResources.swift
//  xia
//
//  Created by Guillaume on 27/04/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class MenuAddResources: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dbg = debug(enable: true)
    weak var ViewCollection: ViewCollectionController?
    
    var newMedia: Bool = false
    let imagePicker = UIImagePickerController() // Needed to show the imagePicker in the Container View
    
    @IBAction func takePhoto(sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            let picker:UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
            self.newMedia = true
        }
        else{
            //no camera available
            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("NO_CAMERA", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let now: Int = Int(NSDate().timeIntervalSince1970)
        let imageData = UIImageJPEGRepresentation(image, 85)
        imageData?.writeToFile(ViewCollection!.documentsDirectory + "/\(now).jpg", atomically: true)
        
        // Create associated xml
        let xml = AEXMLDocument()
        let xmlString = xml.createXML("\(now)")
        do {
            try xmlString.writeToFile(ViewCollection!.documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        ViewCollection!.arrayNames.append("\(now)")
        
        // copy the image in the library
        if newMedia {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(MenuAddResources.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        ViewCollection!.CollectionView.reloadData()
        
        // Hide the popover after adding the photo in the library
        if newMedia {
            self.dismissViewControllerAnimated(true, completion: nil)
            newMedia = false
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("IMAGE_SAVE_FAILED", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(UIImagePickerController) {
            let picker = segue.destinationViewController as! UIImagePickerController
            picker.delegate = self
        }
    }
    
}
