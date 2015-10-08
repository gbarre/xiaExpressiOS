//
//  ViewPhoto.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewPhoto: UIViewController, NSXMLParserDelegate {

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
        //imgView.image = getImageFromSVG(svgDirectory + arrayNames[index])
        imgView.image = getImageFromBase64(arrayBase64Images[index])
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImageFromBase64(b64IMG : String) -> UIImage {
        let imageData = NSData(base64EncodedString: b64IMG, options: .IgnoreUnknownCharacters)
        let image = UIImage(data: imageData!)
        
        return image!
    }
    
}
