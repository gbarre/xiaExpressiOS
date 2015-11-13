//
//  ViewPhoto.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewPhoto: UIViewController {

    var index: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    
    var location = CGPoint(x: 0, y: 0)
    var moving = false
    var movingPoint = -1 // Id of point
    var movingShape = -1 // Id of Shape
    var movingCoords = CGPointMake(0, 0)
    var endEditShape = false
    
    var landscape = false
    var btnAddMenu:Int = 0
    
    var details = [Int: xiaDetail]()
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnPlay(sender: AnyObject) {
        print("Play")
        print(xml.xmlString)
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
                    if subview.tag == 42 || subview.tag == 43 {
                        subview.removeFromSuperview()
                    }
                }
                
                var nextTag: Int = 0
                for detail in self.xml["xia"]["detail"].all! {
                    if detail.attributes["flag"] == "0" {
                        nextTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                        break
                    }
                }

                // Create new detail object
                let newDetail = xiaDetail(tag: nextTag)
                self.details[nextTag] = newDetail
                
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
                        self.details["freeform 43"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        _ = self.details["freeform 43"]?.createPoint(location, imageName: "corner-draggable.png")
                    }
                }
                
                let nbPoints = self.details["freeform 43"]?.points.count
                
                // Build polygon
                if nbPoints > 1 {
                    self.buildShape(false, color: UIColor.redColor())
                }
                
                // Draw corners
                for ( var i = 0; i < nbPoints; i++ ) {
                    self.view.addSubview(self.details["freeform 43"]!.points[i])
                }
            })
            let moveAction = UIAlertAction(title: "Move shape mode", style: .Default, handler: { action in
                print("Move mode")
                self.endEditShape = false
                if self.details["freeform 43"]?.points.count > 2 {
                    self.buildShape(true, color: UIColor.redColor())
                }
                
                // Changing corner image
                for subview in self.view.subviews {
                    if subview.tag == 43 {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        self.details["freeform 43"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        let newPoint = self.details["freeform 43"]?.createPoint(location, imageName: "corner-moving.png")
                        self.view.addSubview(newPoint!)
                    }
                }
                
            })
            let endAction = UIAlertAction(title: "End shape creation", style: .Default, handler: { action in
                print("End detail creation")
                
                // Write path to xml
/*                let filePath = "\(documentsDirectory) + \(arrayNames[self.index]).jpg"
                let data = NSData(contentsOfFile: filePath)
                let path: String = (self.details["freeform 43"]?.createPath())!
                do {
                    let svg = try AEXMLDocument(xmlData: data!)
                    
                    if (svg.root["path"].attributes["d"] != nil) {
                        svg.root["path"].attributes["d"] = path
                    }
                    else {
                        svg.addPathInSVG(path)
                        //try svg.xmlString.writeToFile(documentsDirectory + arrayNames[self.index], atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    print(svg.xmlString)
                }
                catch {
                    print("\(error)")
                }
*/                
                // Remove and rebuild the shape to avoid the overlay on alpha channel
                for subview in self.view.subviews {
                    if subview.tag == 42 {
                        subview.removeFromSuperview()
                    }
                    if subview.tag == 43 {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        self.details["freeform 43"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        let newPoint = self.details["freeform 43"]?.createPoint(location, imageName: "corner-ok.png")
                        self.view.addSubview(newPoint!)
                    }
                }
                if self.details["freeform 43"]?.points.count > 2 {
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
        
        // Load image
        let filePath = "\(documentsDirectory)\(arrayNames[self.index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        imgView.image = img
        
/*        print("img : \(img.size.width) x \(img.size.height)")
        print("imgView : \(imgView.bounds.size.width) x \(imgView.bounds.size.height)")
        print("Screen size : \(UIScreen.mainScreen().bounds)")
        print("screen scale : \(UIScreen.mainScreen().scale)")
        print("navbar height : \(myToolbar.bounds.size)")
        let coefWidth = UIScreen.mainScreen().bounds.size.width / img.size.width
        let coefHeight = (UIScreen.mainScreen().bounds.size.height - myToolbar.bounds.origin.y - myToolbar.bounds.height) / img.size.height
        
        // Load path from xml
        let data = NSData(contentsOfFile: documentsDirectory + arrayNames[index])
        
        var path: String = ""
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data!)
            
            // Get data of the first path
            path = xmlDoc.root["path"].attributes["d"]!
        }
        catch {
            print("\(error)")
        }
        
        if (path != "") {
            btnAddMenu = 1
            endEditShape = true
            // Create new detail object
            let newDetail = xiaDetail(tag: 43)
            self.details["freeform 43"] = newDetail
            
            var pointsArray = path.characters.split{$0 == " "}.map(String.init)
            var relativeCoords = false
            if ( pointsArray[0] == "m" ) {
                relativeCoords = true
            }
            pointsArray.removeFirst() // delete "m" or "M"
            pointsArray.removeLast() // delete "z" or "Z"
            var lastPoint = CGPointMake(0, 0)
            for var i = 0; i < pointsArray.count; i++ {
                // Change X.xxx,Y.yyy coords to X,xxx Y,yyy
                pointsArray[i] = pointsArray[i].stringByReplacingOccurrencesOfString(",", withString: " ")
                pointsArray[i] = pointsArray[i].stringByReplacingOccurrencesOfString(".", withString: ",")
                
                print(pointsArray[i])
                
                let coords = pointsArray[i].characters.split{$0 == " "}.map(String.init)
                let x = CGFloat(NSNumberFormatter().numberFromString(coords[0])!) * coefWidth // convert String to CGFloat
                let y = CGFloat(NSNumberFormatter().numberFromString(coords[1])!) * coefHeight + myToolbar.bounds.height / coefHeight // convert String to CGFloat
                print("\(x), \(y)")
                
                
                if relativeCoords { // add coord to lastPoint
                    // Something's wrong here, need to check
                    print(CGPointMake(lastPoint.x + x, lastPoint.y + y))
                    lastPoint = CGPointMake(x, y)
                }
                else {
                    let newPoint = details["freeform 43"]?.createPoint(CGPointMake(x, y), imageName: "corner-draggable.png")
                    view.addSubview(newPoint!)
                }
            }
            if details["freeform 43"]?.points.count > 2 {
                buildShape(false, color: UIColor.redColor())
            }
        }
*/        
        var value: Int
        if ( img!.size.width > img!.size.height ) { // turn device to landscape
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
        let nbPoints = details["freeform 43"]?.points.count
        switch endEditShape {
        case true: // editing points
            if ( nbPoints != 0 ) { // Points exists
                
                for var i=0; i<nbPoints; i++ { // should we move an existing point or add a new one
                    let ploc = details["freeform 43"]?.points[i].center
                    
                    let xDist: CGFloat = (location.x - ploc!.x)
                    let yDist: CGFloat = (location.y - ploc!.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 30 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = details["freeform 43"]!.points[i]
                        toMove.center = location
                        details["freeform 43"]?.points[i] = toMove
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
                let newPoint = details["freeform 43"]?.createPoint(location, imageName: "corner-draggable.png")
                view.addSubview(newPoint!)
                
                // Remove all shapeview
                for subview in view.subviews {
                    if subview.tag == 42 {
                        subview.removeFromSuperview()
                    }
                }
                
                self.buildShape(false, color: UIColor.redColor())
            }
            
        default:
            if ( nbPoints > 2 && pointInPolygon(details["freeform 43"]!.points, touchPoint: location) && btnAddMenu == 1 ) {
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
            let ploc = details["freeform 43"]?.points[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc!.x);
            let yDist: CGFloat = (location.y - ploc!.y);
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
            
            if ( distance < 30 ) {
                let toMove: UIImageView = details["freeform 43"]!.points[movingPoint]
                toMove.center = location
                details["freeform 43"]?.points[movingPoint] = toMove
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
        let nbPoints = details["freeform 43"]?.points.count
        
        if moving {
            // Remove polygon (filled)
            for subview in view.subviews {
                if subview.tag == 42 {
                    subview.removeFromSuperview()
                }
            }
            moving = false
        }
        if ( nbPoints > 2  && btnAddMenu == 1 ) {
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
        let myView = ShapeView(frame: CGRectMake(xMin, yMin, shapeWidth, shapeHeight), shape: shapeArg, points: details["freeform 43"]!.points, color: color)
        myView.backgroundColor = UIColor(white: 0, alpha: 0)
        myView.tag = 42
        view.addSubview(myView)
    }
}
