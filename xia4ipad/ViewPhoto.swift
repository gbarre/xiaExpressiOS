//
//  ViewPhoto.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
import Photos

class ViewPhoto: UIViewController, NSXMLParserDelegate {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnExport(sender: AnyObject) {
        print("Export")
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        print("Trash")
    }

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    
    }
    
    override func viewWillAppear(animated: Bool) {
        // Remove hairline on toolbar
        mytoolBar.clipsToBounds = true
        
        // Load image from svg
        imgView.image = getImageFromSVG(sourceDirectory + array[self.index])

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
