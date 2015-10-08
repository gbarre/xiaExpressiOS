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

var arrayNames: Array = [String]()
var arrayBase64Images: Array = [String]()
var nbThumb:Int = 0
var index:Int = 0

let reuseIdentifier = "PhotoCell"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSXMLParserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
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
        
        // Load all svg names & base64 images
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(svgDirectory)
        while let file = files?.nextObject() {
            arrayNames.append(file as! String)
            let (_, b64img) = getImageFromSVG(svgDirectory + (file as! String))
            arrayBase64Images.append(cleanBase64Header(b64img))
        }
        
        // Create default svg if the is no svg in Documents directory
        if ( arrayNames.count == 0 ) {
            // Get the source file (content base64 image
            let Base64XiaLogo: NSString = NSBundle.mainBundle().pathForResource("Base64XiaLogo", ofType: "txt")!
            do {
                let trimmedBase64String = try NSString(contentsOfFile: Base64XiaLogo as String, encoding: NSUTF8StringEncoding)
                let svgText = buildSVG((trimmedBase64String as String), size: CGSize(width: 200, height: 200), name: 123456)
                let path = svgDirectory + "xia.svg"
                do {
                    // Write svg file
                    try svgText.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)

                    arrayNames.append("xia.svg")
                    nbThumb = arrayNames.count
                    arrayBase64Images.append((trimmedBase64String as String))
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            catch {/* error handling here */}
        }
        else {
            nbThumb = arrayNames.count
        }
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

        // Load image from svg
        let (img, _) = getImageFromSVG(svgDirectory + arrayNames[index])
        cell.setThumbnailImage(img)
        index++
        
        return cell
    }
    
    func getImageFromSVG(path : String) -> (image: UIImage, base64: String) {
        // Need to convert path to url before parsing
        let urlToSend: NSURL = NSURL(fileURLWithPath: path)
        
        // Parse the XML
        parser = NSXMLParser(contentsOfURL: urlToSend)!
        parser.delegate = self
        parser.parse()
        
        // Convert base64 to image
        let imageData = NSData(base64EncodedString: cleanBase64Header(b64IMG), options : .IgnoreUnknownCharacters)
        let image = UIImage(data: imageData!)
        
        return (image!, b64IMG)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName;
        if ( elementName == "image" ) { // Get the base 64 image for background
            b64IMG = attributeDict["xlink:href"]!
        }
        // Need a fix to take the first image only...
    }

    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        // Let's store the image into an svg file
        let now:Int = Int(NSDate().timeIntervalSince1970 * 1000)

        let imageData = UIImageJPEGRepresentation(image, 85)
        let size:CGSize = (image?.size)!
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        let trimmedBase64String = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")

        let svgText = buildSVG(trimmedBase64String, size: size, name: now)
        
        let path = svgDirectory + "\(now).svg"
        do {
            try svgText.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        arrayNames.append("\(now).svg")
        nbThumb = arrayNames.count
        arrayBase64Images.append(trimmedBase64String)
    }


}

