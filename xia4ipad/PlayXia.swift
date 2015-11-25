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
    var index: Int = 0
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var showPopup: Bool = false
    var popupCoords: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    @IBOutlet weak var bkgdImage: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTitle: UITextField!
    @IBOutlet weak var detailDescription: UITextView!
    
    override func viewDidLoad() {        
        // Add gesture to go back on right swipe
        let cSelector = Selector("goBack")
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let filePath = "\(documentsDirectory)\(arrayNames[self.index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img
        
        let xmlPath = "\(documentsDirectory)/\(arrayNames[self.index]).xml"
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
                    
                    buildShape(true, color: UIColor.blueColor(), tag: detailTag)
                }
            }
        }
        for s in view.subviews {
            print(s)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.view)
        
        // Check we are not touching the detailView popup
        if (!popupCoords.contains(location)) {
            // Get tag of the touched detail
            var touchedTag: Int = 0
            popupCoords = CGRect(x: 0, y: 0, width: 0, height: 0)
            showPopup = false
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                    for subview in view.subviews {
                        if (subview.tag == touchedTag + 100) {
                            popupCoords = subview.frame
                        }
                    }
                    break
                }
            }
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(touchedTag)"]) {
                for d in detail {
                    detailTitle.text = d.attributes["title"]
                    detailDescription.text = d.value
                    showPopup = true
                }
            }
            if showPopup {
                detailView.layer.zPosition = 10
                detailView.hidden = false
            }
            else {
                detailView.hidden = true
            }
        }
        else {
            detailView.hidden = false
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
