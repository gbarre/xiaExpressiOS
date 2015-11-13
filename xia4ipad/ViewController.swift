//
//  ViewController.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

let home = NSHomeDirectory()
let svgDirectory = home + "/Documents/"

var arrayNames = [String]()
var nbThumb:Int = 0
var index:Int = 0

let reuseIdentifier = "PhotoCell"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    var nbSVG:Int = 0
    
    @IBAction func btnCamera(sender: AnyObject) {
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
    }
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }

    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Load all images names
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(svgDirectory)
        while let fileObject = files?.nextObject() {
            var file = fileObject as! String
            file = file.substringWithRange(Range<String.Index>(start: file.startIndex.advancedBy(0), end: file.endIndex.advancedBy(-4))) // remove .jpg
            arrayNames.append(file)
        }
        
        // Create default image if the is no image in Documents directory
        if ( arrayNames.count == 0 ) {
            let now:Int = Int(NSDate().timeIntervalSince1970 * 1000)
            let filePath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
            let img = UIImage(contentsOfFile: filePath!)
            let imageData = UIImageJPEGRepresentation(img!, 85)
            imageData?.writeToFile(svgDirectory + "\(now).jpg", atomically: true)
            
            arrayNames.append("\(now)")
            nbThumb = arrayNames.count
        }
        else {
            nbThumb = arrayNames.count
        }
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "deleteFiles:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        CollectionView.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(animated: Bool) {
        // fetch the photos from collection
        self.navigationController!.hidesBarsOnTap = false
        mytoolBar.clipsToBounds = true
        
        index = 0
        
        self.CollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewLargePhoto") {
            if let controller:ViewPhoto = segue.destinationViewController as? ViewPhoto {
                if let cell = sender as? UICollectionViewCell {
                    if let indexPath: NSIndexPath = self.CollectionView.indexPathForCell(cell) {
                        controller.index = indexPath.item
                    }
                }
            }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return nbThumb;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail

        // Load image
        let filePath = "\(svgDirectory)\(arrayNames[index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        cell.setThumbnailImage(img!, thumbnailLabel : arrayNames[index])
        index++
        
        return cell
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
        // Let's store the image into an svg file
        let now:Int = Int(NSDate().timeIntervalSince1970 * 1000)

        let imageData = UIImageJPEGRepresentation(image, 85)
        imageData?.writeToFile(svgDirectory + "\(now).jpg", atomically: true)
        
        arrayNames.append("\(now)")
        nbThumb = arrayNames.count
    }
    
    func deleteFiles(gestureReconizer: UILongPressGestureRecognizer) {
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
                        let filePath = "\(svgDirectory)/fileName.jpg"
                        try fileManager.removeItemAtPath(filePath)
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                    // Update arrays
                    arrayNames.removeAtIndex(deleteIndex)
                    
                    // Delete cell in CollectionView
                    nbThumb--
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
            print("Could not find index path")
        }
        
    }
}

