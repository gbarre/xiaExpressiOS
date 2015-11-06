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
    
    var landscape = false
    var btnAddMenu:Int = 0
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnPlay(sender: AnyObject) {
        print("Play")
    }
    
    @IBAction func btnAdd(sender: UIBarButtonItem) {
        
        let menu = UIAlertController(title: "Create detail...", message: nil, preferredStyle: .ActionSheet)
        
        if (btnAddMenu == 0) { // Choose tool mode
            let growAction = UIAlertAction(title: "Rectangle (ToDo)", style: .Default, handler: { action in
                print("Rectangle tool (ToDo)")
                self.btnAddMenu = 0
            })
            let titleAction = UIAlertAction(title: "Ellipse (ToDo)", style: .Default, handler: { action in
                print("Ellipse tool (ToDo)")
                self.btnAddMenu = 0
            })
            let descriptionAction = UIAlertAction(title: "Free form", style: .Default, handler: { action in
                self.btnAddMenu = 1
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
                    if subview.tag == 43 {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        myPoints.removeFirst()
                        subview.removeFromSuperview()
                        
                        let imageName = "corner-draggable.png"
                        let image = UIImage(named: imageName)
                        let imageView = UIImageView(image: image!)
                        imageView.center = location
                        imageView.tag = 43
                        myPoints.append(imageView)
                        //self.view.addSubview(imageView)
                    }
                }
                
                // Build polygon
                if myPoints.count > 1 {
                    self.buildShape(false, color: UIColor.redColor())
                }
                
                // Draw corners
                for ( var i = 0; i < myPoints.count; i++ ) {
                    self.view.addSubview(myPoints[i] as! UIView)
                }
            })
            let moveAction = UIAlertAction(title: "Move shape mode", style: .Default, handler: { action in
                print("Move mode")
                self.endEditShape = false
                if myPoints.count > 2 {
                    self.buildShape(true, color: UIColor.redColor())
                }
                
                // Changing corner image
                for subview in self.view.subviews {
                    if subview.tag == 43 {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        myPoints.removeFirst()
                        subview.removeFromSuperview()
                        
                        let imageName = "corner-moving.png"
                        let image = UIImage(named: imageName)
                        let imageView = UIImageView(image: image!)
                        imageView.center = location
                        imageView.tag = 43
                        myPoints.append(imageView)
                        self.view.addSubview(imageView)
                    }
                }
                
            })
            let endAction = UIAlertAction(title: "End shape creation", style: .Default, handler: { action in
                print("End detail creation")
                // Remove and rebuild the shape to avoid the overlay on alpha channel
                for subview in self.view.subviews {
                    if subview.tag == 42 {
                        subview.removeFromSuperview()
                    }
                    if subview.tag == 43 {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        myPoints.removeFirst()
                        subview.removeFromSuperview()
                        
                        let imageName = "corner-ok.png"
                        let image = UIImage(named: imageName)
                        let imageView = UIImageView(image: image!)
                        imageView.center = location
                        imageView.tag = 43
                        imageView.layer.zPosition = 1
                        myPoints.append(imageView)
                        self.view.addSubview(imageView)
                    }
                }
                if myPoints.count > 2 {
                    self.buildShape(false, color: UIColor.greenColor())
                    self.buildShape(true, color: UIColor.greenColor())
                }
                else { // only 1 or 2 points, remove them
                    for subview in self.view.subviews {
                        if subview.tag == 43 {
                            subview.removeFromSuperview()
                        }
                    }
                }
                self.endEditShape = false
                self.btnAddMenu = 0
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
    
    @IBAction func btnOption(sender: UIBarButtonItem) {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
        let growAction = UIAlertAction(title: "Enable Zoom (ToDo)", style: .Default, handler: { action in
            print("Enable zoom")})
        let titleAction = UIAlertAction(title: "Change title (ToDo)", style: .Default, handler: { action in
            print("ToDo : build interface 1...")})
        let descriptionAction = UIAlertAction(title: "Change Description (ToDo)", style: .Default, handler: { action in
            print("ToDo : build interface 2...")})
        
        menu.addAction(growAction)
        menu.addAction(titleAction)
        menu.addAction(descriptionAction)
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        print("Trash")
    }
    
    @IBAction func btnExport(sender: AnyObject) {
        print("Export")
    }
    
    @IBOutlet weak var myToolbar: UIToolbar!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
              
    }
    
    override func viewWillAppear(animated: Bool) {
        // Remove hairline on toolbar
        myToolbar.clipsToBounds = true
        
        // Load image from svg
        let img = getImageFromBase64(arrayBase64Images[index])
        imgView.image = img
        
        var value: Int
        if ( img.size.width > img.size.height ) { // turn device to landscape
            if( !UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) )
            {
                value = UIInterfaceOrientation.LandscapeRight.rawValue
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
            landscape = true
        }
        else { // turn device to portrait
            if( !UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) )
            {
                value = UIInterfaceOrientation.Portrait.rawValue
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
            landscape = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            if ( !landscape ) {
                let value = UIInterfaceOrientation.Portrait.rawValue
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            if ( landscape ) {
                let value = UIInterfaceOrientation.LandscapeRight.rawValue
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let imageName = "corner-draggable.png"
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
                
                self.buildShape(false, color: UIColor.redColor())
            }
            
        default:
            if ( myPoints.count > 2 && pointInPolygon(myPoints, touchPoint: location) && btnAddMenu == 1 ) {
                movingShape = 1
                movingCoords = location
                moving = true
            }
            
        }
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if moving {
            // Remove polygon (filled)
            for subview in view.subviews {
                if subview.tag == 42 {
                    subview.removeFromSuperview()
                }
            }
            moving = false
        }
        if ( myPoints.count > 2  && btnAddMenu == 1 ) {
            buildShape(false, color: UIColor.redColor())
        }
        if movingShape != -1 {
            buildShape(true, color: UIColor.redColor())
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
    
    
    func getImageFromBase64(b64IMG : String) -> UIImage {
        let imageData = NSData(base64EncodedString: b64IMG, options: .IgnoreUnknownCharacters)
        let image = UIImage(data: imageData!)
        
        return image!
    }

    func pointInPolygon(points: AnyObject, touchPoint: CGPoint) -> Bool {
        // translate from C : http://alienryderflex.com/polygon/
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
    
    func buildShape(fill: Bool, color: UIColor) {
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
        let myView = ShapeView(frame: CGRectMake(xMin, yMin, shapeWidth, shapeHeight), shape: shapeArg, points: myPoints, color: color)
        myView.backgroundColor = UIColor(white: 0, alpha: 0)
        myView.tag = 42
        view.addSubview(myView)
    }
}
