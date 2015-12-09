//
//  ViewPhoto.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
import MessageUI

class ViewPhoto: UIViewController, MFMailComposeViewControllerDelegate {
    
    var dbg = debug(enable: true)
    
    var index: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
    var filePath: String = ""

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
    
    var imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var img = UIImage()
    var scale: CGFloat = 1.0
    
    let editColor: UIColor = UIColor.redColor()
    let noEditColor: UIColor = UIColor.greenColor()
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
            "title" : "detail \(self.currentDetailTag)",
            "path" : "0;0"]
        
        // Build menu
        let menu = UIAlertController(title: "", message: nil, preferredStyle: .ActionSheet)
        let rectangleAction = UIAlertAction(title: "Rectangle (ToDo)", style: .Default, handler: { action in
            // Create new detail
            self.details["\(self.currentDetailTag)"] = newDetail
            
            self.xml["xia"]["details"].addChild(name: "detail", value: "detail \(self.currentDetailTag) description", attributes: attributes)
            self.createDetail = true
            //self.setBtnPlayIcon()
            self.changeDetailColor(self.currentDetailTag, color: "edit")
            
            // Now build the rectangle
            let newPoint1 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(100, 30), imageName: "corner")
            newPoint1?.layer.zPosition = 1
            self.imgView.addSubview(newPoint1!)
            let newPoint2 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 30), imageName: "corner")
            newPoint2?.layer.zPosition = 1
            self.imgView.addSubview(newPoint2!)
            let newPoint3 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(300, 150), imageName: "corner")
            newPoint3?.layer.zPosition = 1
            self.imgView.addSubview(newPoint3!)
            let newPoint4 = self.details["\(self.currentDetailTag)"]?.createPoint(CGPointMake(100, 150), imageName: "corner")
            newPoint4?.layer.zPosition = 1
            self.imgView.addSubview(newPoint4!)
            buildShape(true, color: self.editColor, tag: self.currentDetailTag, points: self.details["\(self.currentDetailTag)"]!.points, parentView: self.imgView)
            self.details["\(self.currentDetailTag)"]?.constraint = "rectangle"
            
            self.stopCreation()
        })
        let ellipseAction = UIAlertAction(title: "Ellipse (ToDo)", style: .Default, handler: { action in
            self.dbg.pt("Ellipse tool (ToDo)")
        })
        let polygonAction = UIAlertAction(title: "Free form", style: .Default, handler: { action in
            // Create new detail object
            self.details["\(self.currentDetailTag)"] = newDetail
            self.xml["xia"]["details"].addChild(name: "detail", value: "detail \(self.currentDetailTag) description", attributes: attributes)
            self.createDetail = true
            self.setBtnPlayIcon()
            self.changeDetailColor(self.currentDetailTag, color: "edit")
            self.details["\(self.currentDetailTag)"]?.constraint = "polygon"
        })
        let attributedTitle = NSAttributedString(string: "Create detail...", attributes: [
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
    
    @IBOutlet weak var btnInfos: UIBarButtonItem!
    
    @IBAction func btnTrash(sender: AnyObject) {
        let detailTag = self.currentDetailTag
        if ( detailTag != 0 ) {
            performFullDetailRemove(detailTag, force: true)
            setBtnPlayIcon()
        }
    }
    
    @IBAction func debugXML(sender: AnyObject) {
        dbg.pt(xml.xmlString)
        for detail in details {
            dbg.pt("\(detail.0) : \(detail.1.constraint)")
        }
    }
    @IBAction func btnExport(sender: AnyObject) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            //Set the subject and message of the email
            mailComposer.setSubject("[xia iPad] debug sources")
            mailComposer.setMessageBody("My bug : ", isHTML: false)
            
            //if let filePath = NSBundle.mainBundle().pathForResource("swifts", ofType: "wav") {
            let filePathJPG = "\(filePath).jpg"
            if let fileData = NSData(contentsOfFile: filePathJPG) {
                mailComposer.addAttachmentData(fileData, mimeType: "image/jpg", fileName: "\(fileName)")
            }
            let filePathXML = "\(filePath).xml"
            if let fileData = NSData(contentsOfFile: filePathXML) {
                mailComposer.addAttachmentData(fileData, mimeType: "text/xml", fileName: "\(fileName)")
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else {
            dbg.pt("Device cannot send mail")
        }
    }
    
    @IBOutlet weak var myToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        myToolbar.layer.zPosition = 999
        
        // Load image
        let filePath = "\(self.filePath).jpg"
        img = UIImage(contentsOfFile: filePath)!
        
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
        
        // Disable detail info
        btnInfos.enabled = false
        
        // Add gesture on swipe
        if let recognizers = view.gestureRecognizers {
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
        
        setBtnPlayIcon()
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
                        for var point in pointsArray {
                            point = point.stringByReplacingOccurrencesOfString(".", withString: ",")
                            let coords = point.characters.split{$0 == ";"}.map(String.init)
                            let x = CGFloat(NSNumberFormatter().numberFromString(coords[0])!) * scale // convert String to CGFloat
                            let y = CGFloat(NSNumberFormatter().numberFromString(coords[1])!) * scale // convert String to CGFloat
                            let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner")
                            newPoint?.layer.zPosition = 1
                            imgView.addSubview(newPoint!)
                        }
                        
                        buildShape(true, color: noEditColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView)
                    }
                    if let constraint = detail.attributes["constraint"] {
                        details["\(detailTag)"]?.constraint = constraint
                    }
                    else {
                        details["\(detailTag)"]?.constraint = "polygon"
                    }
                }
            }
        }
        cleaningDetails()
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
                
                // Remove old polygon
                for subview in imgView.subviews {
                    if subview.tag == (detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                buildShape(true, color: editColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView)
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
                    changeDetailColor(editDetail, color: "edit")
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
                    
                    if ( distance < 20 ) { // We are close to an exiting point, move it
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
        location = touch.locationInView(self.imgView)
        let detailTag = self.currentDetailTag
        
        if (moveDetail || movingPoint != -1) {
            // Disable swipe gesture
            if let recognizers = view.gestureRecognizers {
                for recognizer in recognizers {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
        
        if ( movingPoint != -1 ) {
            let ploc = details["\(detailTag)"]?.points[movingPoint].center
            
            let xDist: CGFloat = (location.x - ploc!.x)
            let yDist: CGFloat = (location.y - ploc!.y)
            let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
            
            if ( distance < 20 ) {
                let toMove: UIImageView = details["\(detailTag)"]!.points[movingPoint]
                toMove.center = location
                details["\(detailTag)"]?.points[movingPoint] = toMove
                
                // Are there any constraint ?
                switch details["\(detailTag)"]!.constraint {
                case "rectangle":
                    let previousPoint: Int = (movingPoint == 0) ? 3 : movingPoint - 1
                    let nextPoint: Int = (movingPoint == 3) ? 0 : movingPoint + 1
                    if (movingPoint % 2 == 0) {
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(location.x, details["\(detailTag)"]!.points[previousPoint].center.y)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(details["\(detailTag)"]!.points[nextPoint].center.x, location.y)
                    }
                    else {
                        details["\(detailTag)"]!.points[previousPoint].center = CGPointMake(details["\(detailTag)"]!.points[previousPoint].center.x, location.y)
                        details["\(detailTag)"]!.points[nextPoint].center = CGPointMake(location.x, details["\(detailTag)"]!.points[nextPoint].center.y)
                    }
                    break
                case "ellipse":
                        
                    break
                default:
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
            if ( editDetail != -1 ) {
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
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
            buildShape(true, color: editColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: imgView)
            
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
                changeDetailColor(-1, color: "edit")
                currentDetailTag = 0
                btnInfos.enabled = false
                moveDetail = false
            }
            else {
                editDetail = -1
                btnInfos.enabled = true
            }
            break
        }
        
        // Add gesture on swipe
        if let recognizers = view.gestureRecognizers {
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewDetailInfos") {
            if let controller:ViewDetailInfos = segue.destinationViewController as? ViewDetailInfos {
                if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(self.currentDetailTag)"]) {
                    for d in detail {
                        let zoomStatus: Bool = (d.attributes["zoom"] == "true") ? true : false
                        controller.zoom = zoomStatus
                        controller.detailTitle = (d.attributes["title"] == nil) ? "" : d.attributes["title"]!
                        controller.detailDescription = (d.value == nil) ? "" : d.value!
                        controller.tag = self.currentDetailTag
                        controller.xml = self.xml
                        controller.index = self.index
                        controller.filePath = filePath
                    }
                }
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
     
    func changeDetailColor(tag: Int, color: String) {
        var shapeColor: UIColor
        var altShapeColor: UIColor
        let imgName = "corner"
        switch color {
        case "edit":
            shapeColor = editColor
            altShapeColor = noEditColor
        default:
            shapeColor = noEditColor
            altShapeColor = editColor
        }
        
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
                    imgView.addSubview(newPoint)
                }
            }
            if details["\(thisDetailTag!)"]?.points.count > 2 {
                if thisDetailTag != tag {
                    buildShape(true, color: altShapeColor, tag: thisDetailTag!, points: details["\(thisDetailTag!)"]!.points, parentView: imgView)
                }
                else {
                    buildShape(true, color: shapeColor, tag: thisDetailTag!, points: details["\(thisDetailTag!)"]!.points, parentView: imgView)
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
    
    func setBtnPlayIcon() {
        var i = 0
        var play = UIBarButtonItem()
        var arrayItems = myToolbar.items!
        for item in myToolbar.items! {
            
            if item.tag == 10 {
                if createDetail {
                    play = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "stopCreation")
                    play.tintColor = UIColor.redColor()
                }
                else {
                    play = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "goForward")
                    play.tintColor = UIColor.whiteColor()
                }
                play.tag = 10
            }
            else if item.tag == 11 {
                if createDetail {
                    play = item
                    play.tag = 11
                    play.enabled = false
                }
                else {
                    play = item
                    play.tag = 11
                    play.enabled = true
                }
            }
            else {
                play = item
                play.tag = 0
            }
            arrayItems[i] = play
            i++
        }
        myToolbar.setItems(arrayItems, animated: false)
        
    }
    
    func stopCreation() {
        createDetail = false
        btnInfos.enabled = true
        performFullDetailRemove(currentDetailTag)
        setBtnPlayIcon()
    }
}
