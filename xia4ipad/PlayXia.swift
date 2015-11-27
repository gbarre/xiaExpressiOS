//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PlayXia: UIViewController {
    
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var touchedTag: Int = 0
    var paths = [Int: UIBezierPath]()
    var shapeLayers = [Int: CAShapeLayer]()
    var croppedImages = UIImage()
    
    @IBOutlet weak var bkgdImage: UIImageView!
    
    override func viewDidLoad() {        
        // Add gestures on swipe
        let gbSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let filePath = "\(documentsDirectory)\(self.fileName).jpg"
        let img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img
        
        let xmlPath = "\(documentsDirectory)/\(self.fileName).xml"
        let data = NSData(contentsOfFile: xmlPath)
        do {
            try xml = AEXMLDocument(xmlData: data!)
        }
        catch {
            print("\(error)")
        }
        
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
                        newPoint?.layer.zPosition = -1
                        view.addSubview(newPoint!)
                    }
                    
                    buildShape(false, color: UIColor.blueColor(), tag: detailTag)
                    
                    paths[detailTag] = details["\(detailTag)"]!.bezierPath()
                    
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        // Get tag of the touched detail
        touchedTag = 0
        for detail in details {
            let (detailTag, detailPoints) = detail
            if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                
                // Hide lot of things...
                for subview in view.subviews {
                    if (subview.tag > 99) {
                        subview.hidden = true
                    }
                }
                // Cropping image
                let myMask = CAShapeLayer()
                myMask.path = paths[touchedTag]!.CGPath
                bkgdImage.layer.mask = myMask
                
                //performSegueWithIdentifier("playDetail", sender: self)
                break
            }
            else {
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0, y: 0))
                path.addLineToPoint(CGPoint(x: UIScreen.mainScreen().bounds.width, y: 0))
                path.addLineToPoint(CGPoint(x: UIScreen.mainScreen().bounds.width, y: UIScreen.mainScreen().bounds.height))
                path.addLineToPoint(CGPoint(x: 0, y: UIScreen.mainScreen().bounds.height))
                let myMask = CAShapeLayer()
                myMask.path = path.CGPath
                bkgdImage.layer.mask = myMask
                
                // Unhide lot of things...
                for subview in view.subviews {
                    if (subview.tag > 99) {
                        subview.hidden = false
                    }
                }

            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playDetail") {
            if let controller:playDetail = segue.destinationViewController as? playDetail {
                if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(touchedTag)"]) {
                    for d in detail {
                        /*let zoomStatus: Bool = (d.attributes["zoom"] == "true") ? true : false
                        controller.zoom = zoomStatus*/
                        controller.detailTitle = d.attributes["title"]!
                        controller.detailDescription = d.value!
                        controller.detailPath = paths[touchedTag]
                        
                        // Cropping image
                        let myMask = CAShapeLayer()
                        myMask.path = paths[touchedTag]!.CGPath
                        bkgdImage.layer.mask = myMask
                        controller.croppedImage = bkgdImage
                        
                        /*bkgdImage.layer.mask = shapeLayers[touchedTag]?.mask
                        UIGraphicsBeginImageContextWithOptions(bkgdImage.bounds.size, false, 1)
                        bkgdImage.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                        let newImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        self.croppedImages = newImage
                        print(newImage)
                        print("done")
                        controller.croppedImage = self.croppedImages*/
                    }
                }
            }
        }
    }

    func buildShape(fill: Bool, color: UIColor, tag: Int) {
        var shapeArg: Int = 0
        let shapeTag = tag + 100
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
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
}
