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

var arraySources: Array = [String]()
var nbThumb:Int = 0
var index:Int = 0

let reuseIdentifier = "PhotoCell"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSXMLParserDelegate {
        
    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    var nbSVG:Int = 0
    
    @IBAction func btnCamera(sender: AnyObject) {
    }
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
    }

    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // We need to work with files
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(svgDirectory)
        while let file = files?.nextObject() {
            arraySources.append(file as! String)
        }
        
        // Copy Atlanta.svg if the is no svg in Documents directory
        if ( arraySources.count == 0 ) {
            let defaultFile: NSString = NSBundle.mainBundle().pathForResource("Atlanta", ofType: "svg")!
            do {
                try fileManager.copyItemAtPath(defaultFile as String, toPath: svgDirectory + "Atlanta.svg")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            print("Copy Atlanta to Documents directory...")
            arraySources.append("Atlanta.svg")
            nbThumb = arraySources.count
        }
        else {
            nbThumb = arraySources.count
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
        cell.setThumbnailImage(getImageFromSVG(svgDirectory + arraySources[index]))
        index++
        
        return cell
    }
    
    func getImageFromSVG(path : String) -> UIImage {
        let urlToSend: NSURL = NSURL(fileURLWithPath: path)
        
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

