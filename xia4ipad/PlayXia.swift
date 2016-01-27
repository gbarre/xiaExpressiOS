//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit
//import BubbleTransition

class PlayXia: UIViewController, UIViewControllerTransitioningDelegate {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    let transition = BubbleTransition()
    
    var fileName: String = ""
    var filePath: String = ""
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var touchedTag: Int = 0
    var lastTouchedTag: Int = 0
    var paths = [Int: UIBezierPath]()
    var shapeLayers = [Int: CAShapeLayer]()
    var croppedImages = UIImage()
    var showDetail: Bool = false
    var touchBegin = CGPoint(x: 0, y: 0)
    var zoomStatus: Bool = false
    let maxZoomScale: CGFloat = 3.0
    var zooming: Bool = false
    var zoomCropCenter = CGPointMake(0, 0)
    var zoomDetailScale: CGFloat = 1.0
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var scale: CGFloat = 1.0
    
    let txtView: UITextView = UITextView(frame: CGRect(x: 30, y: 30, width: 0, height: 0))
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    
    @IBOutlet weak var bkgdImage: UIImageView!
    @IBOutlet weak var btnZoom: UISwitch!
    @IBAction func btnZoomAction(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        // Add gestures on swipe
        let gbSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        let metasSelector = Selector("goMetas")
        let downSwipe = UISwipeGestureRecognizer(target: self, action: metasSelector )
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)
        
        // Load image
        let filePath = "\(self.filePath).jpg"
        let img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img
        
        // Hide btnZoom
        btnZoom.layer.zPosition = -1
        
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
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.bkgdImage)
        touchedTag = 0
        
        // detect touch on btnZoom
        if (btnZoom.frame.contains(location) && btnZoom.enabled){
            if btnZoom.on {
                btnZoom.on = false
                if lastTouchedTag != 0 {
                    //showMyDetail(lastTouchedTag, zoomDetail: false)
                }
            }
            else {
                btnZoom.on = true
                if lastTouchedTag != 0 {
                    //showMyDetail(lastTouchedTag, zoomDetail: true)
                }
            }
        }
        
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
                    lastTouchedTag = touchedTag
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
        if (!txtView.frame.contains(touchBegin) && touchedTag == 0 && !btnZoom.frame.contains(touchBegin)) {
            for subview in view.subviews {
                if subview.tag == 666 || subview.tag == 667 {
                    subview.removeFromSuperview()
                }
                if subview.tag > 99 {
                    subview.hidden = false
                }
            }
            showDetail = false
            lastTouchedTag = 0
            
            btnZoom.layer.zPosition = -1
            btnZoom.enabled = false
            btnZoom.on = false
            
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
        return transition
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func goMetas() {
        performSegueWithIdentifier("playMetas", sender: self)
    }
    
    func hideDetails(hidden: Bool) {
        for subview in view.subviews {
            if subview.tag > 199 {
                subview.hidden = hidden
            }
        }
    }
    
}
