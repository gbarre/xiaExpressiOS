//
//  ViewController.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"

let paths = NSSearchPathForDirectoriesInDomains(
                NSSearchPathDirectory.DocumentationDirectory,
                NSSearchPathDomainMask.UserDomainMask, true)
let documentsDirectory = paths[0] as String
let filename = documentsDirectory.stringByAppendingString("/theFile.txt")


let sourceDirectory = "http://guillaume-barre.ac-versailles.fr/xiadev/"
// Get data.plist
let dataURL = NSURL(string: sourceDirectory + "data.plist")
let array = NSArray(contentsOfURL: dataURL!) as! [String]
let nbThumb = array.count
var i:Int = 0

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSXMLParserDelegate {
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    
    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    
    @IBAction func btnCamera(sender: AnyObject) {

    }
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
        print(filename)
    }

    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // fetch the photos from collection
        self.navigationController!.hidesBarsOnTap = false
        mytoolBar.clipsToBounds = true
        
        // handle no photos in the assetCollection
        // ... Have a label ...
        
        i = 0 
        
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

        // Modify the cell
        cell.setThumbnailImage(getImageFromSVG(sourceDirectory + array[i]))
        i++
        
        return cell
    }
        
    func getImageFromSVG(url : String) -> UIImage {
        let urlToSend: NSURL = NSURL(string: url)!
        // Parse the XML
        parser = NSXMLParser(contentsOfURL: urlToSend)!
        parser.delegate = self
        parser.parse()
        
        // Convert base 64 to image
        let imageData = NSData(base64EncodedString: b64IMG.stringByReplacingOccurrencesOfString("data:image/jpeg;base64,", withString: ""), options: .IgnoreUnknownCharacters)
        let image = UIImage(data: imageData!)
        
        return image!
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName;
        if ( elementName == "image" ) { // Get the base 64 image for background
            b64IMG = attributeDict["xlink:href"]!
        }
        
    }

    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }


}

