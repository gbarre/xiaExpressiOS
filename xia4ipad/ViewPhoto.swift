//
//  ViewPhoto.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

var myPoints = [AnyObject]()

class ViewPhoto: UIViewController, NSXMLParserDelegate {

    var index: Int = 0
    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    
    var location = CGPoint(x: 0, y: 0)
    let shapeInt = 0
    var moving = false
    var movingPoint = -1 // Id of point
    var movingShape = -1 // Id of Shape
    var movingCoords = CGPointMake(0, 0)
    var endEditShape = false
    
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
    
    @IBOutlet weak var btnAddMenu: UIBarButtonItem!
    @IBAction func btnAdd(sender: UIBarButtonItem) {

        let menu = UIAlertController(title: "Create detail...", message: nil, preferredStyle: .ActionSheet)

        if (btnAddMenu.tag == 0) { // Choose tool mode
            let growAction = UIAlertAction(title: "Rectangle (ToDo)", style: .Default, handler: { action in
                print("Rectangle tool (ToDo)")
                self.btnAddMenu.tag = 0
            })
            let titleAction = UIAlertAction(title: "Ellipse (ToDo)", style: .Default, handler: { action in
                print("Ellipse tool (ToDo)")
                self.btnAddMenu.tag = 0
            })
            let descriptionAction = UIAlertAction(title: "Free form", style: .Default, handler: { action in
                self.btnAddMenu.tag = 1
                self.endEditShape = true
                // Remove old shape (temp)
                for subview in self.view.subviews {
                    myPoints = []
                    if subview.tag == 42 || subview.tag == 43 {
                        subview.removeFromSuperview()
                    }
                }
            })
            
            menu.addAction(growAction)
            menu.addAction(titleAction)
            menu.addAction(descriptionAction)
        }
        else { // Edit shape mode
            let editAction = UIAlertAction(title: "Edit points mode", style: .Default, handler: { action in
                print("Edit mode")
                self.endEditShape = true
                // Remove polygon (filled)
                for subview in self.view.subviews {
                    if subview.tag == 42 {
                        subview.removeFromSuperview()
                    }
                }
                // Build polygon
                if myPoints.count > 1 {
                    self.buildShape(false)
                }

            })
            let moveAction = UIAlertAction(title: "Move shape mode", style: .Default, handler: { action in
                print("Move mode")
                self.endEditShape = false
                if myPoints.count > 2 {
                    self.buildShape(true)
                }})
            let endAction = UIAlertAction(title: "End shape creation", style: .Default, handler: { action in
                print("End detail creation")
                self.endEditShape = false
                self.btnAddMenu.tag = 0
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
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        if ( movingPoint != -1 ) {
            let ploc = myPoints[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc.x);
            let yDist: CGFloat = (location.y - ploc.y);
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
            
            if ( distance < 30 ) {
                let toMove: UIView = myPoints[movingPoint] as! UIView
                toMove.center = location
                myPoints[movingPoint] = toMove
                moving = true
            }
        }
        
        if ( movingShape != -1 ) {
            let deltaX = location.x - movingCoords.x
            let deltaY = location.y - movingCoords.y
            
            for subview in view.subviews {
                if ( subview.tag == 42 || subview.tag == 43 ) {
                    let origin = subview.frame.origin
                    let destination = CGPointMake(origin.x + deltaX/2, origin.y + deltaY/2)
                    subview.frame.origin = destination
                }
            }
            movingCoords = location
            moving = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        var create = false
        let nbPoints = myPoints.count
        switch endEditShape {
        case true: // editing points
            if ( nbPoints != 0 ) { // Points exists
                
                for var i=0; i<nbPoints; i++ { // should we move an existing point or add a new one
                    let ploc = myPoints[i].center
                    
                    let xDist: CGFloat = (location.x - ploc.x)
                    let yDist: CGFloat = (location.y - ploc.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 30 ) { // We are close to an exiting point, move it
                        let toMove: UIView = myPoints[i] as! UIView
                        toMove.center = location
                        myPoints[i] = toMove
                        movingPoint = i
                        create = false
                        break
                    }
                    else { // No point here, we need to create one
                        create = true
                    }
                }
            }
            if ( create || nbPoints == 0 )  {
                // Add new point
                let imageName = "CropperCornerView.png"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                imageView.center = location
                imageView.tag = 43
                myPoints.append(imageView)
                view.addSubview(imageView)
                
                // Remove all shapeview
                for subview in view.subviews {
                    if subview.tag == 42 {
                        subview.removeFromSuperview()
                    }
                }
                
                self.buildShape(false)
            }
            
        default:
            if ( myPoints.count > 2 && pointInPolygon(myPoints, touchPoint: location) && btnAddMenu.tag == 1 ) {
                movingShape = 1
                movingCoords = location
                moving = true
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if moving {
            // Remove polygon (filled)
            for subview in view.subviews {
                if subview.tag == 42 {
                    subview.removeFromSuperview()
                }
            }
            
            //buildShape(false)
            
            moving = false
        }
        if myPoints.count > 2 {
            buildShape(false)
        }
        if movingShape != -1 {
            buildShape(true)
        }
        movingPoint = -1
        movingShape = -1
        // Make point to top
        for subview in view.subviews {
            if subview.tag == 43 {
                subview.layer.zPosition = 1
            }
        }
    }
    
    func pointInPolygon(points: AnyObject, touchPoint: CGPoint) -> Bool {
        let polyCorners = points.count
        var j = polyCorners - 1
        var oddNodes:Bool = false
        
        for var i=0; i<polyCorners; i++ {
            if ( (points[i].center.y < touchPoint.y && points[j].center.y >= touchPoint.y
                || points[j].center.y < touchPoint.y && points[i].center.y >= touchPoint.y)
                && (points[i].center.x <= touchPoint.x || points[j].center.x <= touchPoint.x) ) {
                    if ( points[i].center.x + (touchPoint.y - points[i].center.y) / (points[j].center.y - points[i].center.y) * (points[j].center.x - points[i].center.x) < touchPoint.x ) {
                        oddNodes = !oddNodes
                    }
            }
            j=i
        }
        
        return oddNodes
    }
    
    func buildShape(fill: Bool) {
        var shapeArg: Int = 0
        switch fill {
        case true:
            shapeArg = 1
        default:
            shapeArg = 0
        }
        var xMin: CGFloat = UIScreen.mainScreen().bounds.width
        var xMax: CGFloat = 0
        var yMin: CGFloat = UIScreen.mainScreen().bounds.height
        var yMax: CGFloat = 0
        // Get dimensions of the shape tagged 43
        for subview in view.subviews {
            if subview.tag == 43 {
                let xMinSubview = subview.frame.origin.x
                let yMinSubview = subview.frame.origin.y
                let xMaxSubview = subview.frame.origin.x + 29
                let yMaxSubview = subview.frame.origin.y + 29
                if ( xMinSubview < xMin ) {
                    xMin = xMinSubview
                }
                if ( yMinSubview < yMin ) {
                    yMin = yMinSubview
                }
                if ( xMaxSubview > xMax ) {
                    xMax = xMaxSubview
                }
                if ( yMaxSubview > yMax ) {
                    yMax = yMaxSubview
                }
            }
        }
        let shapeWidth = xMax - xMin
        let shapeHeight = yMax - yMin
        
        // Build the shape
        let myView = ShapeView(frame: CGRectMake(xMin, yMin, shapeWidth, shapeHeight), shape: shapeArg, points: myPoints)
        myView.backgroundColor = UIColor(white: 0, alpha: 0)
        myView.tag = 42
        view.addSubview(myView)
    }
    
}
