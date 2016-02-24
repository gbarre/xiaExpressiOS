//
//  ViewCreateDetails.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
import MessageUI

class ViewCreateDetails: UIViewController, MFMailComposeViewControllerDelegate {
    
    var dbg = debug(enable: true)
    
    var index: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
    var filePath: String = ""
    
    var location = CGPoint(x: 0, y: 0)
    var movingPoint = -1 // Id of point
    var movingCoords = CGPointMake(0, 0)
    var landscape = false
    
    var details = [String: xiaDetail]()
    var currentDetailTag: Int = 0
    var detailToSegue: Int = 0
    var createDetail: Bool = false
    var beginTouchLocation = CGPoint(x: 0, y: 0)
    var editDetail = -1
    var moveDetail = false
    
    var imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var img = UIImage()
    var scale: CGFloat = 1.0
    
    let editColor: UIColor = UIColor.redColor()
    let noEditColor: UIColor = UIColor.greenColor()
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBOutlet weak var btnTitleLabel: UIBarButtonItem!
    @IBAction func btnTitle(sender: AnyObject) {
        performSegueWithIdentifier("viewMetas", sender: self)
    }
    
    
    @IBAction func btnPlay(sender: AnyObject) {
    }
    
    @IBAction func btnAddDetail(sender: UIBarButtonItem) {
        // Prepare new detail
        let lastDetailTag = self.xml["xia"]["details"]["detail"].last
        if lastDetailTag != nil {
            self.currentDetailTag = (NSNumberFormatter().numberFromString((lastDetailTag?.attributes["tag"]!)!)?.integerValue)! + 1
        }
        else {
            self.currentDetailTag = 100
        }
        let newDetail = xiaDetail(tag: self.currentDetailTag, scale: self.scale)
        let attributes = ["tag" : "\(self.currentDetailTag)",
            "zoom" : "false",
            "title" : "\(NSLocalizedString("DETAIL", comment: "")) \(self.currentDetailTag - 99)",
            "path" : "0;0"]
        
        // Build menu
        let menu = UIAlertController(title: "", message: nil, preferredStyle: .ActionSheet)
        let rectangleAction = UIAlertAction(title: NSLocalizedString("RECTANGLE", comment: ""), style: .Default, handler: { action in
            // Create new detail
            self.details["\(self.currentDetailTag)"] = newDetail
            self.details["\(self.currentDetailTag)"]?.constraint = "rectangle"
            
            self.xml["xia"]["details"].addChild(name: "detail", value: NSLocalizedString("DESCRIPTION...", comment: ""), attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag)
            
            // Now build the rectangle
            let newPoint0 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(100, 30), imageName: "corner")
            newPoint0?.layer.zPosition = 1
            self.imgView.addSubview(newPoint0!)
            let newPoint1 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 30), imageName: "corner")
            newPoint1?.layer.zPosition = 1
            self.imgView.addSubview(newPoint1!)
            let newPoint2 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 150), imageName: "corner")
            newPoint2?.layer.zPosition = 1
            self.imgView.addSubview(newPoint2!)
            let newPoint3 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(100, 150), imageName: "corner")
            newPoint3?.layer.zPosition = 1
            self.imgView.addSubview(newPoint3!)
            buildShape(true, color: self.editColor, tag: self.currentDetailTag, points: self.details["\(self.currentDetailTag)"]!.points, parentView: self.imgView, locked: self.details["\(self.currentDetailTag)"]!.locked)
            
            self.stopCreation()
            
            // Save the detail in xml
            if let detail = self.xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(self.currentDetailTag)"]) {
                for d in detail {
                    d.attributes["path"] = (self.details["\(self.currentDetailTag)"]?.createPath())!
                    d.attributes["constraint"] = self.details["\(self.currentDetailTag)"]?.constraint
                }
            }
            let _ = writeXML(self.xml, path: "\(self.filePath).xml")
        })
        let ellipseAction = UIAlertAction(title: NSLocalizedString("ELLIPSE", comment: ""), style: .Default, handler: { action in
            // Create new detail
            self.details["\(self.currentDetailTag)"] = newDetail
            self.details["\(self.currentDetailTag)"]?.constraint = "ellipse"
            
            self.xml["xia"]["details"].addChild(name: "detail", value: NSLocalizedString("DESCRIPTION...", comment: ""), attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag)
            
            // Now build the rectangle
            let newPoint0 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 50), imageName: "corner")
            newPoint0?.layer.zPosition = 1
            self.imgView.addSubview(newPoint0!)
            let newPoint1 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(400, 110), imageName: "corner")
            newPoint1?.layer.zPosition = 1
            self.imgView.addSubview(newPoint1!)
            let newPoint2 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 170), imageName: "corner")
            newPoint2?.layer.zPosition = 1
            self.imgView.addSubview(newPoint2!)
            let newPoint3 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(200, 110), imageName: "corner")
            newPoint3?.layer.zPosition = 1
            self.imgView.addSubview(newPoint3!)
            buildShape(true, color: self.editColor, tag: self.currentDetailTag, points: self.details["\(self.currentDetailTag)"]!.points, parentView: self.imgView, ellipse: true, locked: self.details["\(self.currentDetailTag)"]!.locked)
            
            self.stopCreation()
            
            // Save the detail in xml
            if let detail = self.xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(self.currentDetailTag)"]) {
                for d in detail {
                    d.attributes["path"] = (self.details["\(self.currentDetailTag)"]?.createPath())!
                    d.attributes["constraint"] = self.details["\(self.currentDetailTag)"]?.constraint
                }
            }
            let _ = writeXML(self.xml, path: "\(self.filePath).xml")
        })
        let polygonAction = UIAlertAction(title: NSLocalizedString("POLYGON", comment: ""), style: .Default, handler: { action in
            // Create new detail object
            self.details["\(self.currentDetailTag)"] = newDetail
            self.details["\(self.currentDetailTag)"]?.constraint = "polygon"
            self.xml["xia"]["details"].addChild(name: "detail", value: NSLocalizedString("DESCRIPTION...", comment: ""), attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag)
            self.setBtnsIcons()
            
            // Disable other gesture
            if let recognizers = self.view.gestureRecognizers {
                for recognizer in recognizers {
                    self.view.removeGestureRecognizer(recognizer)
                }
            }
        })
        let attributedTitle = NSAttributedString(string: NSLocalizedString("CREATE_DETAIL", comment: ""), attributes: [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
            NSForegroundColorAttributeName : UIColor.blackColor()
            ])
        menu.setValue(attributedTitle, forKey: "attributedTitle")
        
        rectangleAction.setValue(UIImage(named: "rectangle"), forKey: "image")
        ellipseAction.setValue(UIImage(named: "ellipse"), forKey: "image")
        polygonAction.setValue(UIImage(named: "polygon"), forKey: "image")
        menu.addAction(rectangleAction)
        menu.addAction(ellipseAction)
        menu.addAction(polygonAction)
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender
            ppc.permittedArrowDirections = .Up
        }
        
        presentViewController(menu, animated: true, completion: nil)
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        let detailTag = self.currentDetailTag
        if ( detailTag != 0 ) {
            stopCreation()
            performFullDetailRemove(detailTag, force: true)
            setBtnsIcons()
        }
    }
    
    @IBAction func btnExport(sender: AnyObject) {
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(imgView.image!, 85)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        let trimmedBase64String = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        // prepare xml
        let xiaXML = AEXMLDocument()
        xiaXML.addChild(name: "XiaiPad")
        xiaXML["XiaiPad"].addChild(xml["xia"])
        xiaXML["XiaiPad"].addChild(name: "image", value: trimmedBase64String, attributes: nil)
        
        // write xml to temp directory
        let now:Int = Int(NSDate().timeIntervalSince1970)
        let tempFilePath = NSHomeDirectory() + "/tmp/\(now).xml"
        do {
            try xiaXML.xmlString.writeToFile(tempFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            //Set the subject and message of the email
            let xiaTitle = (xml["xia"]["title"].value == nil) ? "\(now)" : xml["xia"]["title"].value!
            mailComposer.setSubject("[xia iPad] export \"\(xiaTitle)\"")
            mailComposer.setMessageBody("", isHTML: false)
            
            if let fileData = NSData(contentsOfFile: tempFilePath) {
                mailComposer.addAttachmentData(fileData, mimeType: "text/xml", fileName: "\(now).xml")
            }
            else {
                let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("EXPORT_ISSUE", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else {
            dbg.pt("Device cannot send mail")
        }
        
        // remove tmp file
        do {
            try NSFileManager().removeItemAtPath(tempFilePath)
        }
        catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
    }
    
    @IBAction func btnUndo(sender: AnyObject) {
        if details["\(currentDetailTag)"]?.points.count > 3 {
            // remove last point
            details["\(currentDetailTag)"]?.points.last?.removeFromSuperview()
            details["\(currentDetailTag)"]?.points.removeLast()
            
            // Remove old polygon
            for subview in imgView.subviews {
                if subview.tag == (currentDetailTag + 100) {
                    subview.removeFromSuperview()
                }
            }
            buildShape(true, color: editColor, tag: currentDetailTag, points: details["\(currentDetailTag)"]!.points, parentView: imgView, locked: details["\(currentDetailTag)"]!.locked)
        }
    }
    
    @IBAction func btnMetas(sender: AnyObject) {
        performSegueWithIdentifier("viewMetas", sender: self)
    }
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var imgTopBarBkgd: UIImageView!
    @IBOutlet var infoBkgd: UIImageView!
    @IBOutlet var infoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        myToolbar.layer.zPosition = 999
        imgTopBarBkgd.layer.zPosition = 100
        imgTopBarBkgd.hidden = false
        infoBkgd.layer.zPosition = 101
        infoBtn.layer.zPosition = 102
        
        // Load image
        let filePath = "\(self.filePath).jpg"
        img = UIImage(contentsOfFile: filePath)!
        
        var value: Int
        if ( img.size.width > img.size.height ) { // turn device to landscape
            if( !UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) )
            {
                value = (UIDevice.currentDevice().orientation.rawValue == 5) ? 5 : 3
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
            landscape = true
        }
        else { // turn device to portrait
            if( !UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) )
            {
                value = (UIDevice.currentDevice().orientation.rawValue == 2) ? 2 : 1
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
            landscape = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Add gesture on swipe
        /*if let recognizers = view.gestureRecognizers {
        for recognizer in recognizers {
        view.removeGestureRecognizer(recognizer)
        }
        }
        let gbSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        let gfSelector = Selector("goForward")
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: gfSelector )
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        */
        
        let dSelector : Selector = "detailInfos"
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Remove hairline on toolbar
        myToolbar.clipsToBounds = true
        
        // Build the imgView frame
        let availableWidth: CGFloat = UIScreen.mainScreen().bounds.width
        let availableHeight: CGFloat = UIScreen.mainScreen().bounds.height - (myToolbar.frame.origin.y + myToolbar.frame.height)
        let scaleX: CGFloat = availableWidth / img.size.width
        let scaleY: CGFloat = availableHeight / img.size.height
        scale = min(scaleX, scaleY)
        let imageWidth: CGFloat = scale * img.size.width
        let imageHeight: CGFloat = scale * img.size.height
        let x: CGFloat = (availableWidth - imageWidth) / 2
        let y: CGFloat = myToolbar.frame.origin.y + myToolbar.frame.height + (availableHeight - imageHeight) / 2
        imgView.frame = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
        imgView.image = img
        view.addSubview(imgView)
        
        // Load xmlDetails from xml
        if let xmlDetails = xml.root["details"]["detail"].all {
            for detail in xmlDetails {
                if let path = detail.attributes["path"] {
                    // Add detail object
                    let detailTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                    // clean this tag
                    for subview in imgView.subviews {
                        if (subview.tag == detailTag || subview.tag == detailTag + 100) {
                            subview.removeFromSuperview()
                        }
                    }
                    let newDetail = xiaDetail(tag: detailTag, scale: scale)
                    details["\(detailTag)"] = newDetail
                    // Add points to detail
                    let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                    if pointsArray.count > 2 {
                        var attainablePoints: Int = 0
                        for point in pointsArray {
                            let coords = point.characters.split{$0 == ";"}.map(String.init)
                            let x = convertStringToCGFloat(coords[0]) * scale
                            let y = convertStringToCGFloat(coords[1]) * scale
                            let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner")
                            newPoint?.layer.zPosition = 1
                            newPoint?.hidden = true
                            imgView.addSubview(newPoint!)
                            if imgView.frame.contains((newPoint?.center)!) {
                                attainablePoints++
                            }
                        }
                        if let constraint = detail.attributes["constraint"] {
                            details["\(detailTag)"]?.constraint = constraint
                        }
                        else {
                            details["\(detailTag)"]?.constraint = "polygon"
                        }
                        let drawEllipse: Bool = (details["\(detailTag)"]?.constraint == "ellipse") ? true : false
                        details["\(detailTag)"]?.locked = (detail.attributes["locked"] == "true") ? true : false
                        buildShape(true, color: noEditColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView, ellipse: drawEllipse, locked: details["\(detailTag)"]!.locked)
                        
                        if attainablePoints < 2 {
                            //performFullDetailRemove(detailTag, force: true)
                        }
                    }
                }
            }
            btnTitleLabel.title = (xml["xia"]["title"].value == nil) ? fileName : xml["xia"]["title"].value!
        }
        cleaningDetails()
        setBtnsIcons()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.imgView)
        
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
                        movingPoint = -1
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
                    
                    if ( distance < 20 ) { // We are close to an exiting point, move it
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
                let newPoint = details["\(detailTag)"]?.createPoint(location, imageName: "corner")
                newPoint?.layer.zPosition = 1
                imgView.addSubview(newPoint!)
                
                movingPoint = (details["\(detailTag)"]?.points.count)! - 1
                
                // Remove old polygon
                for subview in imgView.subviews {
                    if subview.tag == (detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                buildShape(true, color: editColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView, locked: details["\(detailTag)"]!.locked)
            }
            
        default:
            var touchedTag: Int = 0
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                    beginTouchLocation = location
                    editDetail = touchedTag
                    currentDetailTag = touchedTag
                    movingCoords = location
                    moveDetail = (detailPoints.locked) ? false : true
                    changeDetailColor(editDetail)
                    break
                }
            }
            
            // Should we move an existing point ?
            if (currentDetailTag != 0 && !details["\(currentDetailTag)"]!.locked) {
                movingPoint = -1
                let detailPoints = details["\(currentDetailTag)"]?.points.count
                for var i=0; i<detailPoints; i++ {
                    let ploc = details["\(currentDetailTag)"]?.points[i].center
                    
                    let xDist: CGFloat = (location.x - ploc!.x)
                    let yDist: CGFloat = (location.y - ploc!.y)
                    let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                    
                    if ( distance < 20 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = details["\(currentDetailTag)"]!.points[i]
                        switch details["\(currentDetailTag)"]!.constraint {
                        case "ellipse":
                            toMove.center = ploc!
                            break
                        default:
                            toMove.center = location
                            break
                        }
                        details["\(currentDetailTag)"]?.points[i] = toMove
                        movingPoint = i
                        moveDetail = false
                        break
                    }
                    else { // No point here, just move the detail
                        moveDetail = (details["\(currentDetailTag)"]!.locked) ? false : true
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.imgView)
        let detailTag = self.currentDetailTag
        
        /*if (moveDetail || movingPoint != -1) {
        // Disable swipe gesture
        if let recognizers = view.gestureRecognizers {
        for recognizer in recognizers {
        view.removeGestureRecognizer(recognizer)
        }
        }
        }*/
        
        if ( movingPoint != -1 && detailTag != 0 && !details["\(detailTag)"]!.locked ) {
            let ploc = details["\(detailTag)"]?.points[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc!.x)
            let yDist: CGFloat = (location.y - ploc!.y)
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
            
            if ( distance < 200 ) {
                let toMove: UIImageView = details["\(detailTag)"]!.points[movingPoint]
                let previousPoint: Int = (movingPoint + 3) % 4
                let nextPoint: Int = (movingPoint + 1) % 4
                let oppositePoint: Int = (movingPoint + 2) % 4
                
                // Are there any constraint ?
                switch details["\(detailTag)"]!.constraint {
                case "rectangle":
                    if (movingPoint % 2 == 0) {
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(location.x, details["\(detailTag)"]!.points[previousPoint].center.y)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(details["\(detailTag)"]!.points[nextPoint].center.x, location.y)
                    }
                    else {
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(details["\(detailTag)"]!.points[previousPoint].center.x, location.y)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(location.x, details["\(detailTag)"]!.points[nextPoint].center.y)
                    }
                    toMove.center = location
                    details["\(detailTag)"]?.points[movingPoint] = toMove
                    break
                case "ellipse":
                    if (movingPoint % 2 == 0) {
                        let middleHeight = (details["\(detailTag)"]!.points[oppositePoint].center.y - location.y)/2 + location.y
                        toMove.center = CGPointMake(ploc!.x, location.y)
                        details["\(detailTag)"]?.points[movingPoint].center = CGPointMake(ploc!.x, details["\(detailTag)"]!.points[movingPoint].center.y)
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(details["\(detailTag)"]!.points[previousPoint].center.x, middleHeight)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(details["\(detailTag)"]!.points[nextPoint].center.x, middleHeight)
                    }
                    else {
                        let middleWidth = (details["\(detailTag)"]!.points[oppositePoint].center.x - location.x)/2 + location.x
                        toMove.center = CGPointMake(location.x, ploc!.y)
                        details["\(detailTag)"]?.points[movingPoint].center = CGPointMake(details["\(detailTag)"]!.points[movingPoint].center.x, ploc!.y)
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(middleWidth, details["\(detailTag)"]!.points[previousPoint].center.y)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(middleWidth, details["\(detailTag)"]!.points[nextPoint].center.y)
                    }
                    break
                default:
                    toMove.center = location
                    details["\(detailTag)"]?.points[movingPoint] = toMove
                    break
                }
            }
        }
        
        switch createDetail {
        case true:
            if (moveDetail) {
                movingPoint = -1
                let deltaX = location.x - movingCoords.x
                let deltaY = location.y - movingCoords.y
                for subview in imgView.subviews {
                    if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                        let origin = subview.frame.origin
                        let destination = CGPointMake(origin.x + deltaX, origin.y + deltaY)
                        subview.frame.origin = destination
                    }
                }
                movingCoords = location
            }
            break
            
        default:
            if ( editDetail != -1) {
                if (moveDetail) {
                    movingPoint = -1
                    let deltaX = location.x - movingCoords.x
                    let deltaY = location.y - movingCoords.y
                    for subview in imgView.subviews {
                        if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                            let origin = subview.frame.origin
                            let destination = CGPointMake(origin.x + deltaX, origin.y + deltaY)
                            subview.frame.origin = destination
                        }
                    }
                    movingCoords = location
                }
            }
        }
        
        if details["\(detailTag)"]?.points.count > 2 {
            // rebuild points & shape
            for subview in imgView.subviews {
                if subview.tag == (detailTag + 100) {
                    subview.removeFromSuperview()
                }
                if subview.tag == detailTag {
                    subview.layer.zPosition = 1
                }
            }
            let drawEllipse: Bool = (details["\(detailTag)"]?.constraint == "ellipse") ? true : false
            buildShape(true, color: editColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView, ellipse: drawEllipse, locked: details["\(detailTag)"]!.locked)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.imgView)
        
        // did we move after touches began ?
        if ( currentDetailTag != 0 && (moveDetail || details["\(currentDetailTag)"]!.locked) ) {
            let xDist: CGFloat = (location.x - beginTouchLocation.x)
            let yDist: CGFloat = (location.y - beginTouchLocation.y)
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
            if distance < 1 {
                //performSegueWithIdentifier("viewDetail", sender: self)
            }
        }
        
        let detailTag = self.currentDetailTag
        let detailPoints = details["\(detailTag)"]?.points.count
        if detailPoints > 2 {
            // rebuild points & shape
            for subview in imgView.subviews {
                if subview.tag == (detailTag + 100) {
                    subview.removeFromSuperview()
                }
                if subview.tag == detailTag {
                    subview.layer.zPosition = 1
                }
            }
            let drawEllipse: Bool = (details["\(detailTag)"]?.constraint == "ellipse") ? true : false
            buildShape(true, color: editColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView, ellipse: drawEllipse, locked: details["\(detailTag)"]!.locked)
            
            // Save the detail in xml
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(detailTag)"]) {
                for d in detail {
                    d.attributes["path"] = (details["\(detailTag)"]?.createPath())!
                    d.attributes["constraint"] = details["\(detailTag)"]?.constraint
                }
            }
            let _ = writeXML(xml, path: "\(filePath).xml")
        }
        
        switch createDetail {
        case true:
            moveDetail = false
            break
            
        default:
            if (editDetail == -1 && movingPoint == -1) {
                changeDetailColor(-1)
                currentDetailTag = 0
                moveDetail = false
            }
            else {
                editDetail = -1
            }
            break
        }
        
        setBtnsIcons()
        
        // Add gesture on swipe
        /*if let recognizers = view.gestureRecognizers {
        for recognizer in recognizers {
        view.removeGestureRecognizer(recognizer)
        }
        }
        let gbSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        let gfSelector = Selector("goForward")
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: gfSelector )
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        */
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewDetailInfos") {
            if let controller:ViewDetailInfos = segue.destinationViewController as? ViewDetailInfos {
                if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(self.detailToSegue)"]) {
                    for d in detail {
                        controller.detailTitle = (d.attributes["title"] == nil) ? "" : d.attributes["title"]!
                        controller.detailSubtitle = (d.attributes["subtitle"] == nil) ? "" : d.attributes["subtitle"]!
                        controller.detailDescription = (d.value == nil) ? "" : d.value!
                        controller.zoom = (d.attributes["zoom"] != nil && d.attributes["zoom"] == "true") ? true : false
                        controller.lock = (d.attributes["locked"] != nil && d.attributes["locked"] == "true") ? true : false
                        controller.tag = self.detailToSegue
                        controller.xml = self.xml
                        controller.index = self.index
                        controller.filePath = filePath
                        controller.ViewCreateDetailsController = self
                    }
                }
            }
        }
        if (segue.identifier == "viewMetas") {
            if let controller:ViewMetas = segue.destinationViewController as? ViewMetas {
                controller.xml = self.xml
                controller.filePath = self.filePath
                controller.ViewCreateDetailsController = self
            }
        }
        if (segue.identifier == "playXia") {
            if let controller:PlayXia = segue.destinationViewController as? PlayXia {
                controller.fileName = fileName
                controller.filePath = filePath
                controller.xml = self.xml
            }
        }
    }
    
    func changeDetailColor(tag: Int) {
        let imgName = "corner"
        // Change other details color
        for detail in details {
            let thisDetailTag = NSNumberFormatter().numberFromString(detail.0)?.integerValue
            // Remove and rebuild the shape to avoid the overlay on alpha channel
            for subview in imgView.subviews {
                if subview.tag == (thisDetailTag! + 100) { // polygon
                    subview.tag = thisDetailTag! + 300
                    subview.layer.zPosition = -1
                }
                if subview.tag == thisDetailTag! { // points
                    let location = CGPointMake(subview.frame.origin.x + subview.frame.width/2, subview.frame.origin.y + subview.frame.height/2)
                    details["\(thisDetailTag!)"]?.points.removeFirst()
                    subview.tag = thisDetailTag! + 200
                    subview.layer.zPosition = -1
                    
                    let newPoint: UIView = (details["\(thisDetailTag!)"]?.createPoint(location, imageName: imgName))!
                    newPoint.layer.zPosition = 1
                    if thisDetailTag != tag {
                        newPoint.hidden = true
                    }
                    imgView.addSubview(newPoint)
                }
            }
            if detail.1.points.count > 2 {
                let drawEllipse: Bool = (detail.1.constraint == "ellipse") ? true : false
                if thisDetailTag != tag {
                    buildShape(true, color: noEditColor, tag: thisDetailTag!, points: details["\(thisDetailTag!)"]!.points, parentView: imgView, ellipse: drawEllipse, locked: details["\(thisDetailTag!)"]!.locked)
                }
                else {
                    buildShape(true, color: editColor, tag: thisDetailTag!, points: details["\(thisDetailTag!)"]!.points, parentView: imgView, ellipse: drawEllipse, locked: details["\(thisDetailTag!)"]!.locked)
                }
            }
            else { // only 1 or 2 points, remove them
                for subview in imgView.subviews {
                    if subview.tag == thisDetailTag! {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
        if createDetail && details["\(tag)"]?.constraint == "polygon" {
            imgTopBarBkgd.backgroundColor = editColor
        }
        else {
            imgTopBarBkgd.backgroundColor = blueColor
        }
        cleanOldViews()
    }
    
    func cleaningDetails() {
        for detail in details {
            let detailTag = NSNumberFormatter().numberFromString(detail.0)!.integerValue
            if ( detailTag != 0 && detail.1.points.count < 3 ) {
                performFullDetailRemove(detailTag)
            }
        }
    }
    
    func cleanOldViews() {
        // Remove old (hidden) subviews
        for subview in imgView.subviews {
            if subview.tag > 299 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func detailInfos() {
        moveDetail = false
        movingPoint = -1
        if currentDetailTag == 0 {
            performSegueWithIdentifier("viewMetas", sender: self)
        }
        else {
            detailToSegue = currentDetailTag
            currentDetailTag = 0
            performSegueWithIdentifier("ViewDetailInfos", sender: self)
        }
    }
    
    func goBack() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func goForward() {
        performSegueWithIdentifier("playXia", sender: self)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func performFullDetailRemove(tag: Int, force: Bool = false) {
        if (details["\(tag)"]?.points.count < 3 || force) {
            // remove point & polygon
            for subview in imgView.subviews {
                if subview.tag == tag || subview.tag == (tag + 100) {
                    subview.removeFromSuperview()
                }
            }
            
            // remove detail object
            details["\(tag)"] = nil
            
            // remove detail in xml
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
                for d in detail {
                    d.removeFromParent()
                }
            }
            let _ = writeXML(xml, path: "\(filePath).xml")
            currentDetailTag = 0
        }
    }
    
    func rotated() {
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
    
    func setBtnsIcons() {
        var i = 0
        var btn = UIBarButtonItem()
        var arrayItems = myToolbar.items!
        for item in myToolbar.items! {
            if item.tag == 10 { // play/STOP btn
                if createDetail {
                    btn = UIBarButtonItem(title: NSLocalizedString("OK", comment: ""), style: .Done, target: self, action: "stopCreation")
                }
                else {
                    btn = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "goForward")
                }
            }
            else if item.tag == 11 { // add detail btn
                btn = item
            }
            else if item.tag == 12 { // info detail btn
                btn = item
                btn.enabled = (createDetail || currentDetailTag == 0) ? false : true
            }
            else if item.tag == 13 { // trash btn
                btn = item
                btn.enabled = (currentDetailTag == 0 || details["\(currentDetailTag)"]!.locked ) ? false : true
            }
            else if item.tag == 14 { // undo btn (remove last point of polygon)
                btn = item
                btn.enabled = (currentDetailTag != 0 && createDetail && details["\(currentDetailTag)"]!.constraint == "polygon" && details["\(currentDetailTag)"]?.points.count > 3) ? true : false
            }
            else if item.tag == 20 { // export btn
                btn = item
            }
            else {
                btn = item
            }
            btn.tag = item.tag
            arrayItems[i] = btn
            i++
        }
        myToolbar.setItems(arrayItems, animated: false)
    }
    
    func stopCreation() {
        createDetail = false
        performFullDetailRemove(currentDetailTag)
        if details["\(currentDetailTag)"]?.constraint == "polygon" {
            currentDetailTag = 0
            changeDetailColor(-1)
            imgTopBarBkgd.backgroundColor = blueColor
        }
        setBtnsIcons()
        
        // Add double tap gesture
        let dSelector : Selector = "detailInfos"
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
}
