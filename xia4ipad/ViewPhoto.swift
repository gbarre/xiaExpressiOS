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
    var currentShapeTag: Int = 0
    var landscape = false
    var btnAddMenu:Int = 0
    
    var details = [String: xiaDetail]()
    var currentDetailTag: Int = 0
    var createDetail: Bool = false
    var beginTouchLocation = CGPoint(x: 0, y: 0)
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnPlay(sender: AnyObject) {
        print("Play")
        print(xml.xmlString)
        self.createDetail = false
    }
    
    @IBAction func btnAddDetail(sender: UIBarButtonItem) {
        // Create new detail object
        self.currentDetailTag = self.xml["xia"]["details"]["detail"].count + 100
        let newDetail = xiaDetail(tag: self.currentDetailTag)
        self.details["\(self.currentDetailTag)"] = newDetail
        let attributes = ["tag" : "\(self.currentDetailTag)",
            "zoom" : "no",
            "title" : "detail\(self.currentDetailTag)",
            "description" : "detail\(self.currentDetailTag) description"]
        self.xml["xia"]["details"].addChild(name: "detail", value: "0;0", attributes: attributes)
        self.createDetail = true
        
        // Change other details color
        for detail in details {
            let thisDetailTag = NSNumberFormatter().numberFromString(detail.0)?.integerValue
            if thisDetailTag != self.currentDetailTag {
                // Remove and rebuild the shape to avoid the overlay on alpha channel
                for subview in self.view.subviews {
                    if subview.tag == (thisDetailTag! + 100) { // polygon
                        subview.removeFromSuperview()
                    }
                    if subview.tag == thisDetailTag! { // points
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        self.details["\(thisDetailTag!)"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        let newPoint = self.details["\(thisDetailTag!)"]?.createPoint(location, imageName: "corner-ok.png")
                        newPoint?.layer.zPosition = 1
                        self.view.addSubview(newPoint!)
                    }
                }
                if self.details["\(thisDetailTag!)"]?.points.count > 2 {
                    //self.buildShape(false, color: UIColor.greenColor(), tag: thisDetailTag!)
                    self.buildShape(true, color: UIColor.greenColor(), tag: thisDetailTag!)
                }
                else { // only 1 or 2 points, remove them
                    for subview in self.view.subviews {
                        if subview.tag == thisDetailTag! {
                            subview.removeFromSuperview()
                        }
                    }
                }
            }
        }
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
                
                self.currentShapeTag = self.xml["xia"]["details"]["detail"].count + 100
                
                // Create new detail object
                let newDetail = xiaDetail(tag: self.currentShapeTag)
                self.details["\(self.currentShapeTag)"] = newDetail
                let attributes = ["tag" : "\(self.currentShapeTag)",
                    "zoom" : "no",
                    "title" : "detail\(self.currentShapeTag)",
                    "description" : "detail\(self.currentShapeTag) description"]
                self.xml["xia"]["details"].addChild(name: "detail", value: "0;0", attributes: attributes)
            })
            
            menu.addAction(growAction)
            menu.addAction(titleAction)
            menu.addAction(descriptionAction)
        }
        else { // Edit shape mode
            // Get form tag
            let tag = self.currentShapeTag
            
            let editAction = UIAlertAction(title: "Edit points mode", style: .Default, handler: { action in
                print("Edit mode")
                self.endEditShape = true
                
                // Remove polygon (filled)
                for subview in self.view.subviews {
                    if subview.tag == (tag + 100) { // polygon
                        subview.removeFromSuperview()
                    }
                    if subview.tag == (tag) { // points
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        
                        
                        self.details["\(tag)"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        _ = self.details["\(tag)"]?.createPoint(location, imageName: "corner-draggable.png")
                    }
                }
                
                let nbPoints = self.details["\(tag)"]?.points.count
                
                // Build polygon
                if nbPoints > 1 {
                    self.buildShape(false, color: UIColor.redColor(), tag: tag)
                }
                
                // Draw corners
                for ( var i = 0; i < nbPoints; i++ ) {
                    self.view.addSubview(self.details["\(tag)"]!.points[i])
                }
            })
            let moveAction = UIAlertAction(title: "Move shape mode", style: .Default, handler: { action in
                print("Move mode")
                self.endEditShape = false
                if self.details["\(tag)"]?.points.count > 2 {
                    self.buildShape(true, color: UIColor.redColor(), tag: tag)
                }
                
                // Changing corner image
                for subview in self.view.subviews {
                    if subview.tag == tag {
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        self.details["\(tag)"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        let newPoint = self.details["\(tag)"]?.createPoint(location, imageName: "corner-moving.png")
                        self.view.addSubview(newPoint!)
                    }
                }
                
            })
            let endAction = UIAlertAction(title: "End shape creation", style: .Default, handler: { action in
                print("End detail creation")
                
                // Remove and rebuild the shape to avoid the overlay on alpha channel
                for subview in self.view.subviews {
                    if subview.tag == (tag + 100) { // polygon
                        subview.removeFromSuperview()
                    }
                    if subview.tag == tag { // points
                        let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                        self.details["\(tag)"]?.points.removeFirst()
                        subview.removeFromSuperview()
                        
                        let newPoint = self.details["\(tag)"]?.createPoint(location, imageName: "corner-ok.png")
                        self.view.addSubview(newPoint!)
                    }
                }
                if self.details["\(tag)"]?.points.count > 2 {
                    self.buildShape(false, color: UIColor.greenColor(), tag: tag)
                    self.buildShape(true, color: UIColor.greenColor(), tag: tag)
                }
                else { // only 1 or 2 points, remove them
                    for subview in self.view.subviews {
                        if subview.tag == tag {
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        switch createDetail {
        case true:
            print("Begin touching in create mode")
            let detailTag = self.currentDetailTag
            let detailPoints = details["\(detailTag)"]?.points.count
            var addPoint = false
            
            if ( detailPoints != 0 ) { // Points exists
                
                for var i=0; i<detailPoints; i++ { // should we move an existing point or add a new one
                    let ploc = details["\(detailTag)"]?.points[i].center
                    
                    let xDist: CGFloat = (location.x - ploc!.x)
                    let yDist: CGFloat = (location.y - ploc!.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 30 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = details["\(detailTag)"]!.points[i]
                        toMove.center = location
                        details["\(detailTag)"]?.points[i] = toMove
                        movingPoint = i
                        addPoint = false
                        break
                    }
                    else { // No point here, we need to create one
                        addPoint = true
                    }
                }
            }
            if ( addPoint || detailPoints == 0 )  {
                // Add new point
                let newPoint = details["\(detailTag)"]?.createPoint(location, imageName: "corner-draggable.png")
                newPoint?.layer.zPosition = 1
                view.addSubview(newPoint!)
                
                // Remove old polygon
                for subview in view.subviews {
                    if subview.tag == (detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                
                self.buildShape(true, color: UIColor.redColor(), tag: detailTag)
            }
            
        default:
            print("Try to edit or move existing detail... (ToDo)")
            // Get tag of the touched detail
            var touchedTag: Int = 0
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                    print("Detail \(detailTag) touched")
                    beginTouchLocation = location
                    movingShape = touchedTag
                    movingCoords = location
                    break
                }
            }
        }
        
        // to remove later...
        if false {
        // Get form tag
        let tag = self.currentShapeTag
        
        var create = false
        let nbPoints = details["\(tag)"]?.points.count
        switch endEditShape {
        case true: // editing points
            if ( nbPoints != 0 ) { // Points exists
                
                for var i=0; i<nbPoints; i++ { // should we move an existing point or add a new one
                    let ploc = details["\(tag)"]?.points[i].center
                    
                    let xDist: CGFloat = (location.x - ploc!.x)
                    let yDist: CGFloat = (location.y - ploc!.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 30 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = details["\(tag)"]!.points[i]
                        toMove.center = location
                        details["\(tag)"]?.points[i] = toMove
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
                let newPoint = details["\(tag)"]?.createPoint(location, imageName: "corner-draggable.png")
                print(newPoint)
                view.addSubview(newPoint!)
                
                // Remove polygon
                for subview in view.subviews {
                    if subview.tag == (tag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                
                self.buildShape(false, color: UIColor.redColor(), tag: tag)
            }
            
        default:
            if ( nbPoints > 2 && pointInPolygon(details["\(tag)"]!.points, touchPoint: location) && btnAddMenu == 1 ) {
                movingShape = 1
                movingCoords = location
                moving = true
            }
        }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        let detailTag = self.currentDetailTag
        
        switch createDetail {
        case true:
            print("Moving in create mode")
            if ( movingPoint != -1 ) {
                let ploc = details["\(detailTag)"]?.points[movingPoint].center
                
                let xDist: CGFloat = (location.x - ploc!.x)
                let yDist: CGFloat = (location.y - ploc!.y)
                let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                
                if ( distance < 30 ) {
                    let toMove: UIImageView = details["\(detailTag)"]!.points[movingPoint]
                    toMove.center = location
                    details["\(detailTag)"]?.points[movingPoint] = toMove
                    //moving = true
                }
            }
            
        default:
            if ( movingShape != -1 ) {
                let xDist: CGFloat = (location.x - beginTouchLocation.x)
                let yDist: CGFloat = (location.y - beginTouchLocation.y)
                let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                if (distance > 10) {
                    let deltaX = location.x - movingCoords.x
                    let deltaY = location.y - movingCoords.y
                    
                    if (self.details["\(movingShape)"]!.distanceToTop() < 55) {
                        for subview in view.subviews {
                            if ( subview.tag == movingShape || subview.tag == (movingShape + 100) ) {
                                let origin = subview.frame.origin
                                let destination = CGPointMake(origin.x, origin.y + 55.5)
                                subview.frame.origin = destination
                            }
                        }
                        movingShape = -1
                    }
                    else {
                        for subview in view.subviews {
                            if ( subview.tag == movingShape || subview.tag == (movingShape + 100) ) {
                                let origin = subview.frame.origin
                                let destination = CGPointMake(origin.x + deltaX/2, origin.y + deltaY/2)
                                subview.frame.origin = destination
                            }
                        }
                    }
                    movingCoords = location
                    //moving = true
                }
            }

        }
        
        // to be removed
        if false {
        // Get form tag
        let tag = self.currentShapeTag
        
        if ( movingPoint != -1 ) {
            let ploc = details["\(tag)"]?.points[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc!.x);
            let yDist: CGFloat = (location.y - ploc!.y);
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
            
            if ( distance < 30 ) {
                let toMove: UIImageView = details["\(tag)"]!.points[movingPoint]
                toMove.center = location
                details["\(tag)"]?.points[movingPoint] = toMove
                moving = true
            }
        }
        
        if ( movingShape != -1 ) {
            let deltaX = location.x - movingCoords.x
            let deltaY = location.y - movingCoords.y
            
            for subview in view.subviews {
                if ( subview.tag == tag || subview.tag == (tag + 100) ) {
                    let origin = subview.frame.origin
                    let destination = CGPointMake(origin.x + deltaX/2, origin.y + deltaY/2)
                    subview.frame.origin = destination
                }
            }
            movingCoords = location
            moving = true
        }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch createDetail {
        case true:
            print("End touching in create mode")
            let detailTag = self.currentDetailTag
            let detailPoints = details["\(detailTag)"]?.points.count
            
            if detailPoints > 2 {
                // rebuild points & shape
                for subview in view.subviews {
                    if subview.tag == (detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                    if subview.tag == detailTag {
                        subview.layer.zPosition = 1
                    }
                }
                buildShape(true, color: UIColor.redColor(), tag: detailTag)
                
            }
            
        default:
            print("End touching with no creation")
            for detail in details {
                detail.1.test()
            }
            movingShape = -1
        }
        
        // to be removed
        if false {
        // Get form tag
        let tag = self.currentShapeTag
        let nbPoints = details["\(tag)"]?.points.count
        
        if moving {
            // Remove polygon (filled)
            for subview in view.subviews {
                print(subview)
                if subview.tag == (tag + 100) {
                    subview.removeFromSuperview()
                }
            }
            moving = false
        }
        if ( nbPoints > 2  && btnAddMenu == 1 ) {
            buildShape(false, color: UIColor.redColor(), tag: tag)
        }
        if movingShape != -1 {
            buildShape(true, color: UIColor.redColor(), tag: tag)
        }
        movingPoint = -1
        movingShape = -1
        // Make point to top
        for subview in view.subviews {
            if subview.tag == tag {
                subview.layer.zPosition = 1
            }
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
    
    func buildShape(fill: Bool, color: UIColor, tag: Int) {
        var shapeArg: Int = 0
        let shapeTag = tag + 100
        switch fill {
        case true:
            shapeArg = 1
            //shapeTag += 100
        default:
            shapeArg = 0
        }
        var xMin: CGFloat = UIScreen.mainScreen().bounds.width
        var xMax: CGFloat = 0
        var yMin: CGFloat = UIScreen.mainScreen().bounds.height
        var yMax: CGFloat = 0
        // Get dimensions of the shape
        for subview in view.subviews {
            if subview.tag == tag {
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
        let myView = ShapeView(frame: CGRectMake(xMin, yMin, shapeWidth, shapeHeight), shape: shapeArg, points: details["\(tag)"]!.points, color: color)
        myView.backgroundColor = UIColor(white: 0, alpha: 0)
        myView.tag = shapeTag
        view.addSubview(myView)
    }
}
