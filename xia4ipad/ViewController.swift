//
//  ViewController.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var dbg = debug(enable: true)
    
    let documentsDirectory = NSHomeDirectory() + "/Documents"
    var nbThumb:Int = 0
    var arrayNames = [String]()
    let cache = NSCache()
    var segueIndex: Int = -1
    var editingMode: Bool = false

    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    let reuseIdentifier = "PhotoCell"

    
    @IBAction func btnCreate(sender: AnyObject) {
        let menu = UIAlertController(title: "", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .Default, handler: { action in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                //load the camera interface
                let picker : UIImagePickerController = UIImagePickerController()
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                picker.delegate = self
                picker.allowsEditing = false
                self.presentViewController(picker, animated: true, completion: nil)
            }
            else{
                //no camera available
                let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        let libraryAction = UIAlertAction(title: "Search in Photos", style: .Default, handler: { action in
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let attributedTitle = NSAttributedString(string: "Create new document", attributes: [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
            NSForegroundColorAttributeName : UIColor.blackColor()
            ])
        menu.setValue(attributedTitle, forKey: "attributedTitle")
        
        cameraAction.setValue(UIImage(named: "camera"), forKey: "image")
        libraryAction.setValue(UIImage(named: "photos"), forKey: "image")
        menu.addAction(cameraAction)
        menu.addAction(libraryAction)
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender as? UIBarButtonItem
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
    }
    
    @IBOutlet weak var editMode: UIBarButtonItem!
    @IBAction func btnEdit(sender: AnyObject) {
        dbg.pt(self.editMode.title!)
        dbg.pt(editingMode)
        if editingMode {
            dbg.pt("change title to Edit and make cell moving...")
            editingMode = false
            self.editMode.title = "Edit"
        }
        else {
            dbg.pt("change title to Done and stop cell moving...")
            editingMode = true
            self.editMode.title = "Done"
        }
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Load all images names
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(documentsDirectory)
        while let fileObject = files?.nextObject() {
            var file = fileObject as! String
            let ext = file.substringWithRange(Range<String.Index>(start: file.endIndex.advancedBy(-3), end: file.endIndex.advancedBy(0)))
            if (ext != "xml") {
                file = file.substringWithRange(Range<String.Index>(start: file.startIndex.advancedBy(0), end: file.endIndex.advancedBy(-4))) // remove .xyz
                arrayNames.append(file)
            }
        }
        // Create default image if the is no image in Documents directory
        if ( arrayNames.count == 0 ) {
            let now:Int = Int(NSDate().timeIntervalSince1970)
            let filePath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
            let img = UIImage(contentsOfFile: filePath!)
            let imageData = UIImageJPEGRepresentation(img!, 85)
            imageData?.writeToFile(documentsDirectory + "/\(now).jpg", atomically: true)
            
            // Create associated xml
            let xml = AEXMLDocument()
            let xmlString = xml.createXML("\(now)")
            do {
                try xmlString.writeToFile(documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                dbg.pt("\(error)")
            }
            
            arrayNames.append("\(now)")
            nbThumb = arrayNames.count
        }
        else {
            nbThumb = arrayNames.count
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // fetch the photos from collection
        self.navigationController!.hidesBarsOnTap = false
        mytoolBar.clipsToBounds = true
        
        editingMode = false
        
        self.CollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewLargePhoto") {
            if let controller:ViewPhoto = segue.destinationViewController as? ViewPhoto {
                controller.fileName = "\(arrayNames[segueIndex])"
                controller.filePath = "\(documentsDirectory)/\(arrayNames[segueIndex])"
                
                let xmlPath = "\(documentsDirectory)/\(arrayNames[segueIndex]).xml"
                let data = NSData(contentsOfFile: xmlPath)
                do {
                    try controller.xml = AEXMLDocument(xmlData: data!)
                }
                catch {
                    dbg.pt("\(error)")
                }
            }
        }
        if (segue.identifier == "ViewImageInfos") {
            if let controller:ViewImageInfos = segue.destinationViewController as? ViewImageInfos {
                let xmlPath = "\(documentsDirectory)/\(arrayNames[segueIndex]).xml"
                let data = NSData(contentsOfFile: xmlPath)
                var xml: AEXMLDocument!
                do {
                    try xml = AEXMLDocument(xmlData: data!)
                }
                catch {
                    dbg.pt("\(error)")
                }
                
                controller.imageTitle = (xml["xia"]["title"].value == nil) ? "" : xml["xia"]["title"].value!
                controller.imageAuthor = (xml["xia"]["author"].value == nil) ? "" : xml["xia"]["author"].value!
                controller.imageRights = (xml["xia"]["rights"].value == nil) ? "" : xml["xia"]["rights"].value!
                controller.imageDesc = (xml["xia"]["description"].value == nil) ? "" : xml["xia"]["description"].value!
                controller.filePath = "\(documentsDirectory)/\(arrayNames[segueIndex])"
                controller.fileName = "\(arrayNames[segueIndex])"
                controller.xml = xml
            }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return nbThumb;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        
        let index = indexPath.item
      
        // Load image
        if let cachedImage = cache.objectForKey(arrayNames[index]) as? UIImage {
            // Use cached version
            cell.setCachedThumbnailImage(cachedImage)
        }
        else {
            // Create image from scratch then store in the cache
            let filePath = "\(documentsDirectory)/\(arrayNames[index]).jpg"
            let img = UIImage(contentsOfFile: filePath)
            let cachedImage = cell.setThumbnailImage(img!)
            cache.setObject(cachedImage, forKey: arrayNames[index])
        }
        
        // Load label
        cell.setLabel(arrayNames[index])
        
        let cSelector = Selector("deleteFiles:")
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        cell.addGestureRecognizer(leftSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        tap.delegate = self
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
        // Let's store the image
        let now:Int = Int(NSDate().timeIntervalSince1970)
        let imageData = UIImageJPEGRepresentation(image, 85)
        imageData?.writeToFile(documentsDirectory + "/\(now).jpg", atomically: true)
        
        // Create associated xml
        let xml = AEXMLDocument()
        let xmlString = xml.createXML("\(now)")
        do {
            try xmlString.writeToFile(documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        arrayNames.append("\(now)")
        nbThumb = arrayNames.count
    }
    
    func handleTap(gestureReconizer: UISwipeGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(CollectionView)
        let indexPath = CollectionView.indexPathForItemAtPoint(p)
        
        if let path = indexPath {
            segueIndex = path.row
            if editingMode {
                performSegueWithIdentifier("ViewImageInfos", sender: self)
            }
            else {
                performSegueWithIdentifier("viewLargePhoto", sender: self)
            }
        }
    }
    
    func deleteFiles(gestureReconizer: UISwipeGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(CollectionView)
        let indexPath = CollectionView.indexPathForItemAtPoint(p)
        var deleteIndex:Int = 9999
        
        if let path = indexPath {
            deleteIndex = path.row
            
            let fileName = arrayNames[deleteIndex]
            
            let controller = UIAlertController(title: "Warning!",
                message: "Delete \(fileName)?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes, I'm sure!",
                style: .Destructive, handler: { action in
                    
                    // Delete the file
                    let fileManager = NSFileManager()
                    do {
                        var filePath = "\(self.documentsDirectory)/\(fileName).jpg"
                        try fileManager.removeItemAtPath(filePath)
                        filePath = "\(self.documentsDirectory)/\(fileName).xml"
                        try fileManager.removeItemAtPath(filePath)
                    }
                    catch let error as NSError {
                        self.dbg.pt(error.localizedDescription)
                    }
                    
                    // Update arrays
                    self.arrayNames.removeAtIndex(deleteIndex)
                    
                    // Delete cell in CollectionView
                    self.nbThumb--
                    self.CollectionView.deleteItemsAtIndexPaths([path])
                    
                    // Information
                    let msg = "\(fileName) has been deleted..."
                    let controller2 = UIAlertController(
                        title:nil,
                        message: msg, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK",
                        style: .Default , handler: nil)
                    controller2.addAction(cancelAction)
                    self.presentViewController(controller2, animated: true,
                        completion: nil)
            })
            let noAction = UIAlertAction(title: "No way!",
                style: .Cancel, handler: nil)
            
            controller.addAction(yesAction)
            controller.addAction(noAction)
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else {
            dbg.pt("Could not find index path")
        }
        
    }
}

