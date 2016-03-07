//
//  ViewCollectionController.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var dbg = debug(enable: true)
    
    let documentsDirectory = NSHomeDirectory() + "/Documents"
    var arrayNames = [String]()
    var arraySortedNames = [String: String]() // Label : FileName
    let cache = NSCache()
    var segueIndex: Int = -1
    var editingMode: Bool = false
    var showHelp = false

    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    let reuseIdentifier = "PhotoCell"
    var newMedia: Bool?
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    var landscape: Bool = false
    
    @IBOutlet weak var btnCreateState: UIBarButtonItem!
    @IBAction func btnCreate(sender: AnyObject) {
        let menu = UIAlertController(title: "", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("TAKE_PHOTO", comment: ""), style: .Default, handler: { action in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                //load the camera interface
                let picker : UIImagePickerController = UIImagePickerController()
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
        })
        let libraryAction = UIAlertAction(title: NSLocalizedString("SEARCH_IN_PHOTOS", comment: ""), style: .Default, handler: { action in
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = self
            picker.allowsEditing = false
            picker.modalPresentationStyle = .Popover
            self.presentViewController(picker, animated: true, completion: nil)
            self.newMedia = false
            
            picker.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            picker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        })
        let attributedTitle = NSAttributedString(string: NSLocalizedString("CREATE_NEW_DOC", comment: ""), attributes: [
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
    
    @IBAction func btnHelp(sender: AnyObject) {
        for subview in view.subviews {
            if subview.tag > 49 {
                subview.hidden = showHelp
                subview.layer.zPosition = 1
            }
        }
        showHelp = !showHelp
    }
    
    @IBOutlet weak var imgHelp: UIImageView!
    
    @IBOutlet weak var editMode: UIBarButtonItem!
    @IBAction func btnEdit(sender: AnyObject) {
        if editingMode {
            editingMode = false
            self.editMode.title = NSLocalizedString("EDIT", comment: "")
            for cell in CollectionView.visibleCells() {
                let customCell: PhotoThumbnail = cell as! PhotoThumbnail
                customCell.wobble(false)
            }
            self.CollectionView.reloadData()
            btnCreateState.enabled = true
        }
        else {
            editingMode = true
            self.editMode.title = NSLocalizedString("DONE", comment: "")
            for cell in CollectionView.visibleCells() {
                let customCell: PhotoThumbnail = cell as! PhotoThumbnail
                customCell.wobble(true)
            }
            btnCreateState.enabled = false
        }
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // add observer to detect enter foreground and rebuild collection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        // purge tmp
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath("\(NSHomeDirectory())/tmp")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(NSHomeDirectory())/tmp/\(file)"
                try fileManager.removeItemAtPath(filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        self.CollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        // fetch the photos from collection
        self.navigationController!.hidesBarsOnTap = false
        mytoolBar.clipsToBounds = true
        
        editingMode = false
        imgHelp.image = self.textToImage("Hide help", inImage: self.imgHelp.image!, atPoint: CGPointMake(20, 36))
    }
    
    override func viewDidAppear(animated: Bool) {
       self.CollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segueIndex == -1 {
            segueIndex = 0
        }
        let xmlToSegue = getXML("\(documentsDirectory)/\(arrayNames[segueIndex]).xml")
        let nameToSegue = "\(arrayNames[segueIndex])"
        let pathToSegue = "\(documentsDirectory)/\(nameToSegue)"
        if (segue.identifier == "viewLargePhoto") {
            if let controller:ViewCreateDetails = segue.destinationViewController as? ViewCreateDetails {
                controller.fileName = nameToSegue
                controller.filePath = pathToSegue
                controller.xml = xmlToSegue
            }
        }
        if (segue.identifier == "viewMetas") {
            if let controller:ViewMetas = segue.destinationViewController as? ViewMetas {
                controller.xml = xmlToSegue
                controller.filePath = pathToSegue
                controller.landscape = landscape
            }
        }
        if (segue.identifier == "playXia") {
            if let controller:PlayXia = segue.destinationViewController as? PlayXia {
                controller.fileName = nameToSegue
                controller.filePath = pathToSegue
                controller.xml = xmlToSegue
                controller.landscape = landscape
            }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
       self.arrayNames = []
        // Load all images names
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(self.documentsDirectory)
        while let fileObject = files?.nextObject() {
            var file = fileObject as! String
            let ext = file.substringWithRange(Range<String.Index>(start: file.endIndex.advancedBy(-3), end: file.endIndex.advancedBy(0)))
            if (ext != "xml" && file != "Inbox") {
                file = file.substringWithRange(Range<String.Index>(start: file.startIndex.advancedBy(0), end: file.endIndex.advancedBy(-4))) // remove .xyz
                if fileManager.fileExistsAtPath("\(documentsDirectory)/\(file).xml") {
                    self.arrayNames.append(file)
                }
                else {
                    do {
                        try fileManager.removeItemAtPath("\(documentsDirectory)/\(file).jpg")
                    }
                    catch {
                        self.dbg.pt("\(error)")
                    }
                }
            }
        }
        // Create default image if the is no image in Documents directory
        if ( self.arrayNames.count == 0 ) {
            let now:Int = Int(NSDate().timeIntervalSince1970)
            let filePath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
            let img = UIImage(contentsOfFile: filePath!)
            let imageData = UIImageJPEGRepresentation(img!, 85)
            imageData?.writeToFile(self.documentsDirectory + "/\(now).jpg", atomically: true)
            
            // Create associated xml
            let xml = AEXMLDocument()
            let xmlString = xml.createXML("\(now)")
            do {
                try xmlString.writeToFile(self.documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                self.dbg.pt("\(error)")
            }
            
            self.arrayNames.append("\(now)")
        }
        
        // order thumb by title
        self.arraySortedNames = [:]
        for name in self.arrayNames {
            let xml = getXML("\(self.documentsDirectory)/\(name).xml")
            var title = (xml["xia"]["title"].value == nil) ? name : xml["xia"]["title"].value
            title = "\(title)-\(name)"
            self.arraySortedNames[title!] = name
        }
        
        let orderedTitles = self.arraySortedNames.keys.sort()
        self.arrayNames = []
        for title in orderedTitles {
            self.arrayNames.append(self.arraySortedNames[title]!)
        }
        self.CollectionView.reloadData()
        
        return arrayNames.count;
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        
        let index = indexPath.item
        // Load image
        let filePath = "\(documentsDirectory)/\(arrayNames[index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        cell.setThumbnail(img!)
        
        // Load label
        let xml = getXML("\(documentsDirectory)/\(arrayNames[index]).xml")
        let label = (xml["xia"]["title"].value == nil) ? arrayNames[index] : xml["xia"]["title"].value!
        cell.setLabel(label)
        
        let cSelector = Selector("deleteFiles:")
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        cell.addGestureRecognizer(leftSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        tap.delegate = self
        cell.addGestureRecognizer(tap)
        
        return cell
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
            
            let controller = UIAlertController(title: NSLocalizedString("WARNING", comment: ""),
                message: "\(NSLocalizedString("DELETE", comment: ""))\(fileName)\(NSLocalizedString("?", comment: ""))", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: NSLocalizedString("YES", comment: ""),
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
                    self.CollectionView.deleteItemsAtIndexPaths([path])
                    
                    // Information
                    let msg = "\(fileName)\(NSLocalizedString("DELETED", comment: ""))"
                    let controller2 = UIAlertController(
                        title:nil,
                        message: msg, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                        style: .Default , handler: nil)
                    controller2.addAction(cancelAction)
                    self.presentViewController(controller2, animated: true,
                        completion: nil)
            })
            let noAction = UIAlertAction(title: NSLocalizedString("NO", comment: ""),
                style: .Cancel, handler: nil)
            
            controller.addAction(yesAction)
            controller.addAction(noAction)
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else {
            dbg.pt("Could not find index path")
        }
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
                performSegueWithIdentifier("viewMetas", sender: self)
            }
            else {
                let xmlToSegue = getXML("\(documentsDirectory)/\(arrayNames[segueIndex]).xml")
                if xmlToSegue["xia"]["readonly"].value! == "true" {
                    // look for orientation before segue
                    let filePath = "\(documentsDirectory)/\(arrayNames[segueIndex]).jpg"
                    let img = UIImage(contentsOfFile: filePath)!
                    
                    var value: Int
                    if ( img.size.width > img.size.height ) { // turn device to landscape
                        if( !UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) )
                        {
                            value = (UIDevice.currentDevice().orientation.rawValue == 5) ? 5 : 3
                            UIDevice.currentDevice().setValue(value, forKey: "orientation")
                        }
                        landscape = true
                    }
                    else { // turn device to portrait
                        if( !UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) )
                        {
                            value = (UIDevice.currentDevice().orientation.rawValue == 2) ? 2 : 1
                            UIDevice.currentDevice().setValue(value, forKey: "orientation")
                        }
                        landscape = false
                    }
                    
                    performSegueWithIdentifier("playXia", sender: self)
                }
                else {
                    performSegueWithIdentifier("viewLargePhoto", sender: self)
                }
            }
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
        
        // copy the image in the library
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            newMedia = false
        }
        self.CollectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.blackColor()
        let textFont: UIFont = UIFont.systemFontOfSize(14.0)

        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
}

