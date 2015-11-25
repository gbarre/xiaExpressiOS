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
    var movingCoords = CGPointMake(0, 0)
    var landscape = false
    
    var details = [String: xiaDetail]()
    var currentDetailTag: Int = 0
    var createDetail: Bool = false
    var beginTouchLocation = CGPoint(x: 0, y: 0)
    var editDetail = -1
    var moveDetail = false
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnPlay(sender: AnyObject) {
        print("Play")
        print(xml.xmlString)
        for detail in self.details {
            print(detail.0)
            print(detail.1.points)
        }
    }
    
    @IBAction func btnAddDetail(sender: UIBarButtonItem) {
        let menu = UIAlertController(title: "Create detail...", message: nil, preferredStyle: .ActionSheet)
        let growAction = UIAlertAction(title: "Rectangle (ToDo)", style: .Default, handler: { action in
            print("Rectangle tool (ToDo)")
        })
        let titleAction = UIAlertAction(title: "Ellipse (ToDo)", style: .Default, handler: { action in
            print("Ellipse tool (ToDo)")
        })
        let descriptionAction = UIAlertAction(title: "Free form", style: .Default, handler: { action in
            // Create new detail object
            let lastDetailTag = self.xml["xia"]["details"]["detail"].last
            if lastDetailTag != nil {
                self.currentDetailTag = (NSNumberFormatter().numberFromString((lastDetailTag?.attributes["tag"]!)!)?.integerValue)! + 1
            }
            else {
                self.currentDetailTag = 100
            }
            let newDetail = xiaDetail(tag: self.currentDetailTag)
            self.details["\(self.currentDetailTag)"] = newDetail
            let attributes = ["tag" : "\(self.currentDetailTag)",
                "zoom" : "false",
                "title" : "detail \(self.currentDetailTag)",
                "path" : "0;0"]
            self.xml["xia"]["details"].addChild(name: "detail", value: "detail \(self.currentDetailTag) description", attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag, color: "red")
        })
        let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { action in
            self.createDetail = false
        })
        
        menu.addAction(growAction)
        menu.addAction(titleAction)
        menu.addAction(descriptionAction)
        if self.createDetail == true {
            menu.addAction(stopAction)
        }
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var btnInfos: UIBarButtonItem!
    
    @IBAction func btnTrash(sender: AnyObject) {
        print("Trash")
        let detailTag = self.currentDetailTag
        if ( detailTag != 0 ) {
            // remove point & polygon
            for subview in view.subviews {
                if subview.tag == detailTag || subview.tag == (detailTag + 100) {
                    subview.removeFromSuperview()
                }
            }
            
            // remove detail object
            details["\(detailTag)"] = nil
            
            // remove detail in xml
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(detailTag)"]) {
                for d in detail {
                    d.removeFromParent()
                }
            }
            
            // write xml
            do {
                try xml.xmlString.writeToFile(documentsDirectory + "\(arrayNames[index]).xml", atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("\(error)")
            }
        }
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
        
        // Load xmlDetails from xml
        if let xmlDetails = xml.root["details"]["detail"].all {
            for detail in xmlDetails {
                if let path = detail.attributes["path"] {
                    // Add detail object
                    let detailTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                    let newDetail = xiaDetail(tag: detailTag)
                    details["\(detailTag)"] = newDetail
                    
                    // Add points to detail
                    let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                    for var point in pointsArray {
                        point = point.stringByReplacingOccurrencesOfString(".", withString: ",")
                        let coords = point.characters.split{$0 == ";"}.map(String.init)
                        let x = CGFloat(NSNumberFormatter().numberFromString(coords[0])!) // convert String to CGFloat
                        let y = CGFloat(NSNumberFormatter().numberFromString(coords[1])!) // convert String to CGFloat
                        let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner-ok")
                        newPoint?.layer.zPosition = 1
                        view.addSubview(newPoint!)
                    }
                    
                    self.buildShape(true, color: UIColor.greenColor(), tag: detailTag)
                }
            }
        }
        
        // Add gesture to go back on right swipe
        let cSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Disable detail info
        btnInfos.enabled = false
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
            let detailTag = self.currentDetailTag
            let detailPoints = details["\(detailTag)"]?.points.count
            var addPoint = false
            
            if ( detailPoints != 0 ) { // Points exists
                
                // Are we in the polygon ?
                if (detailPoints > 2) {
                    if (pointInPolygon(details["\(detailTag)"]!.points, touchPoint: location)) {
                        beginTouchLocation = location
                        movingCoords = location
                        moveDetail = true
                    }
                    else {
                        addPoint = true
                    }
                }
                
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
                        moveDetail = false
                        addPoint = false
                        break
                    }
                    else {
                        addPoint = true
                    }
                }
            }
            if ( (addPoint || detailPoints == 0) && !moveDetail )  {
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
            // Get tag of the touched detail
            var touchedTag: Int = 0
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                    beginTouchLocation = location
                    editDetail = touchedTag
                    currentDetailTag = touchedTag
                    movingCoords = location
                    moveDetail = true
                    changeDetailColor(editDetail, color: "red")
                    break
                }
            }
            
            // Should we move an existing point ?
            if (currentDetailTag != -1) {
                movingPoint = -1
                let detailPoints = details["\(currentDetailTag)"]?.points.count
                for var i=0; i<detailPoints; i++ {
                    let ploc = details["\(currentDetailTag)"]?.points[i].center
                    
                    let xDist: CGFloat = (location.x - ploc!.x)
                    let yDist: CGFloat = (location.y - ploc!.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 40 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = details["\(currentDetailTag)"]!.points[i]
                        toMove.center = location
                        details["\(currentDetailTag)"]?.points[i] = toMove
                        movingPoint = i
                        moveDetail = false
                        break
                    }
                    else { // No point here, just move the detail
                        moveDetail = true
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        let detailTag = self.currentDetailTag
        
        if ( movingPoint != -1 ) {
            let ploc = details["\(detailTag)"]?.points[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc!.x)
            let yDist: CGFloat = (location.y - ploc!.y)
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
            
            if ( distance < 30 ) {
                let toMove: UIImageView = details["\(detailTag)"]!.points[movingPoint]
                toMove.center = location
                details["\(detailTag)"]?.points[movingPoint] = toMove
            }
        }
        
        switch createDetail {
        case true:
            if (moveDetail) {
                movingPoint = -1
                let xDist: CGFloat = (location.x - beginTouchLocation.x)
                let yDist: CGFloat = (location.y - beginTouchLocation.y)
                let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                if (distance > 10) {
                    let deltaX = location.x - movingCoords.x
                    let deltaY = location.y - movingCoords.y
                    
                    if (details["\(detailTag)"]!.distanceToTop() < 55) { // Avoid to move over navbar
                        for subview in view.subviews {
                            if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                                let origin = subview.frame.origin
                                let destination = CGPointMake(origin.x, origin.y + 55.5)
                                subview.frame.origin = destination
                            }
                        }
                        //editDetail = -1
                    }
                    else {
                        for subview in view.subviews {
                            if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                                let origin = subview.frame.origin
                                let destination = CGPointMake(origin.x + deltaX, origin.y + deltaY)
                                subview.frame.origin = destination
                            }
                        }
                    }
                    movingCoords = location
                }
            }
            break
            
        default:
            if ( editDetail != -1 ) {
                if (moveDetail) {
                    movingPoint = -1
                    let xDist: CGFloat = (location.x - beginTouchLocation.x)
                    let yDist: CGFloat = (location.y - beginTouchLocation.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    if (distance > 10) {
                        let deltaX = location.x - movingCoords.x
                        let deltaY = location.y - movingCoords.y
                        
                        if (details["\(detailTag)"]!.distanceToTop() < 55) { // Avoid to move over navbar
                            for subview in view.subviews {
                                if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                                    let origin = subview.frame.origin
                                    let destination = CGPointMake(origin.x, origin.y + 55.5)
                                    subview.frame.origin = destination
                                }
                            }
                            //editDetail = -1
                        }
                        else {
                            for subview in view.subviews {
                                if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                                    let origin = subview.frame.origin
                                    let destination = CGPointMake(origin.x + deltaX, origin.y + deltaY)
                                    subview.frame.origin = destination
                                }
                            }
                        }
                        movingCoords = location
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
            
            // Save the detail in xml
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(detailTag)"]) {
                for d in detail {
                    d.attributes["path"] = (details["\(detailTag)"]?.createPath())!
                }
            }
            do {
                try xml.xmlString.writeToFile(documentsDirectory + "\(arrayNames[index]).xml", atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("\(error)")
            }
        }
                
        switch createDetail {
        case true:
            moveDetail = false
            break
            
        default:
            if (editDetail == -1 && movingPoint == -1) {
                changeDetailColor(-1, color: "red")
                currentDetailTag = -1
                btnInfos.enabled = false
            }
            else {
                editDetail = -1
                // Remove old (hidden) subviews
                for subview in view.subviews {
                    if subview.tag > 299 {
                        subview.removeFromSuperview()
                    }
                }
                btnInfos.enabled = true
            }
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewDetailInfos") {
            if let controller:ViewDetailInfo = segue.destinationViewController as? ViewDetailInfo {
                if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(self.currentDetailTag)"]) {
                    for d in detail {
                        let zoomStatus: Bool = (d.attributes["zoom"] == "true") ? true : false
                        controller.zoom = zoomStatus
                        controller.detailTitle = d.attributes["title"]!
                        controller.detailDescription = d.value!
                        controller.tag = self.currentDetailTag
                        controller.xml = self.xml
                        controller.index = self.index
                    }
                }
            }
        }
        if (segue.identifier == "play") {

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
    
    func changeDetailColor(tag: Int, color: String) {
        var shapeColor: UIColor
        var altShapeColor: UIColor
        var imgName: String
        var altImgName: String
        switch color {
        case "green":
            shapeColor = UIColor.greenColor()
            imgName = "corner-ok.png"
            altShapeColor = UIColor.redColor()
            altImgName = "corner-draggable.png"
        default:
            shapeColor = UIColor.redColor()
            imgName = "corner-draggable.png"
            altShapeColor = UIColor.greenColor()
            altImgName = "corner-ok.png"
        }
        
        // Change other details color
        for detail in details {
            let thisDetailTag = NSNumberFormatter().numberFromString(detail.0)?.integerValue
            // Remove and rebuild the shape to avoid the overlay on alpha channel
            for subview in self.view.subviews {
                if subview.tag == (thisDetailTag! + 100) { // polygon
                    //subview.removeFromSuperview()
                    subview.tag = thisDetailTag! + 300
                    subview.layer.zPosition = -1
                }
                if subview.tag == thisDetailTag! { // points
                    let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                    details["\(thisDetailTag!)"]?.points.removeFirst()
                    //subview.removeFromSuperview()
                    subview.tag = thisDetailTag! + 200
                    subview.layer.zPosition = -1
                    
                    var newPoint: UIView
                    if thisDetailTag != tag {
                        newPoint = (details["\(thisDetailTag!)"]?.createPoint(location, imageName: altImgName))!
                    }
                    else {
                        newPoint = (details["\(thisDetailTag!)"]?.createPoint(location, imageName: imgName))!
                    }
                    newPoint.layer.zPosition = 1
                    self.view.addSubview(newPoint)
                }
            }
            if details["\(thisDetailTag!)"]?.points.count > 2 {
                if thisDetailTag != tag {
                    self.buildShape(true, color: altShapeColor, tag: thisDetailTag!)
                }
                else {
                    self.buildShape(true, color: shapeColor, tag: thisDetailTag!)
                }
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
    
    func goBack() {
        if currentDetailTag == 0 {
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}
