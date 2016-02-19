//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PlayXia: UIViewController, UIViewControllerTransitioningDelegate {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    let transition = BubbleTransition()
    
    var fileName: String = ""
    var filePath: String = ""
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var touchedTag: Int = 0
    var paths = [Int: UIBezierPath]()
    var showDetail: Bool = false
    var touchBegin = CGPoint(x: 0, y: 0)
    var img: UIImage!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var scale: CGFloat = 1.0
    var landscape = false
    
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    
    @IBOutlet weak var bkgdImage: UIImageView!
    @IBAction func showMetas(sender: AnyObject) {
        performSegueWithIdentifier("playMetas", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gestures on swipe
        let gbSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let filePath = "\(self.filePath).jpg"
        img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img
        
        // Get the scale...
        let scaleX: CGFloat = screenWidth / img!.size.width
        let scaleY: CGFloat = screenHeight / img!.size.height
        scale = min(scaleX, scaleY)
        let xSpace: CGFloat = (screenWidth - img!.size.width * scale) / 2
        let ySpace: CGFloat = (screenHeight - img!.size.height * scale) / 2
        
        // Load xmlDetails from xml
        if let xmlDetails = xml.root["details"]["detail"].all {
            for detail in xmlDetails {
                if let path = detail.attributes["path"] {
                    // Add detail object
                    let detailTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                    let newDetail = xiaDetail(tag: detailTag, scale: scale)
                    details["\(detailTag)"] = newDetail
                    details["\(detailTag)"]!.constraint = detail.attributes["constraint"]!
                    
                    // Add points to detail
                    let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                    for point in pointsArray {
                        let coords = point.characters.split{$0 == ";"}.map(String.init)
                        let x = convertStringToCGFloat(coords[0]) * scale + xSpace
                        let y = convertStringToCGFloat(coords[1]) * scale + ySpace
                        let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner")
                        newPoint?.layer.zPosition = -1
                        view.addSubview(newPoint!)
                    }
                    let drawEllipse: Bool = (detail.attributes["constraint"] == "ellipse") ? true : false
                    buildShape(false, color: blueColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: view, ellipse: drawEllipse)
                    paths[detailTag] = details["\(detailTag)"]!.bezierPath()
                }
            }
        }
        hideDetails(true)
        
        if xml["xia"]["readonly"].value! == "true" {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.bkgdImage)
        touchedTag = 0
        
        switch showDetail {
        case true:
            touchBegin = location
            break
        default:
            // Get tag of the touched detail
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                    //let zoom: Bool = btnZoom.on
                    performSegueWithIdentifier("openDetail", sender: self)
                    break
                }
            }
            // Show details area if none is touched
            if touchedTag == 0 {
                hideDetails(false)
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchedTag == 0 {
            for subview in view.subviews {
                if subview.tag == 666 || subview.tag == 667 {
                    subview.removeFromSuperview()
                }
                if subview.tag > 99 {
                    subview.hidden = false
                }
            }
            showDetail = false
            hideDetails(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playMetas") {
            if let controller:PlayImageMetadatas = segue.destinationViewController as? PlayImageMetadatas {
                controller.xml = self.xml
            }
        }
        if (segue.identifier == "openDetail") {
            if let controller:ViewDetail = segue.destinationViewController as? ViewDetail {
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .FormSheet
                controller.xml = self.xml
                controller.tag = touchedTag
                controller.detail = details["\(touchedTag)"]
                controller.path = paths[touchedTag]
                controller.bkgdImage = bkgdImage
            }
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = location
        transition.bubbleColor = blueColor
        transition.detailFrame = details["\(touchedTag)"]?.bezierFrame()
        transition.path = paths[touchedTag]
        transition.theDetail = details["\(touchedTag)"]
        transition.bkgdImage = bkgdImage
        transition.duration = 0.5
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = CGPointMake(screenWidth / 2, 2 * screenHeight)
        transition.duration = 0.5
        return transition
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func hideDetails(hidden: Bool) {
        for subview in view.subviews {
            if subview.tag > 199 {
                subview.hidden = hidden
            }
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
}
