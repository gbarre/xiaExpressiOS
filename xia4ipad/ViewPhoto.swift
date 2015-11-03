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

    @IBAction func btnPlay(sender: AnyObject) {
        print("Play")
    }
    
    @IBOutlet weak var btnAddImg: UIBarButtonItem!
    @IBAction func btnAdd(sender: UIBarButtonItem) {

        let menu = UIAlertController(title: "Create detail...", message: nil, preferredStyle: .ActionSheet)

        if (btnAddImg.tag == 0) { // Add/move points mode
            let growAction = UIAlertAction(title: "Rectangle (ToDo)", style: .Default, handler: { action in
                print("Enable growing")
                self.btnAddImg.tag = 1
            })
            let titleAction = UIAlertAction(title: "Ellipse (ToDo)", style: .Default, handler: { action in
                print("ToDo : build interface 1...")
                self.btnAddImg.tag = 1
            })
            let descriptionAction = UIAlertAction(title: "Free form", style: .Default, handler: { action in
                print("ToDo : build interface 2...")
                self.btnAddImg.tag = 1
            })
            
            menu.addAction(growAction)
            menu.addAction(titleAction)
            menu.addAction(descriptionAction)
        }
        else { // only move mode
            let editAction = UIAlertAction(title: "Edit mode", style: .Default, handler: { action in
                print("Edit mode")})
            let moveAction = UIAlertAction(title: "Move mode", style: .Default, handler: { action in
                print("Move mode")})
            let endAction = UIAlertAction(title: "End creation", style: .Default, handler: { action in
                print("End detail creation")
                self.btnAddImg.tag = 0
            })
            
            menu.addAction(editAction)
            menu.addAction(moveAction)
            menu.addAction(endAction)
        }
        
        
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var mytoolBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        //create the option button
        let button = UIButton(type : UIButtonType.Custom)
        //set image for button
        button.setImage(UIImage(named: "Info-24"), forState: UIControlState.Normal)
        //add function for button
        button.addTarget(self, action: "btnOption:", forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        button.frame = CGRectMake(0, 0, 31, 31)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        self.mytoolBar.items?.insert(barButton, atIndex: 6)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // Remove hairline on toolbar
        mytoolBar.clipsToBounds = true
        
        // Load image from svg
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
    
    func btnOption(sender: UIButton!) {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
        let growAction = UIAlertAction(title: "Enable Growing (ToDo)", style: .Default, handler: { action in
            print("Enable growing")})
        let titleAction = UIAlertAction(title: "Change title (ToDo)", style: .Default, handler: { action in
            print("ToDo : build interface 1...")})
        let descriptionAction = UIAlertAction(title: "Change Description (ToDo)", style: .Default, handler: { action in
            print("ToDo : build interface 2...")})
        
        menu.addAction(growAction)
        menu.addAction(titleAction)
        menu.addAction(descriptionAction)
        
        if let ppc = menu.popoverPresentationController {
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
        
    }
    
}
