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
    var showDetail: Bool = false
    var touchBegin = CGPoint(x: 0, y: 0)
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let txtView: UITextView = UITextView(frame: CGRect(x: 30, y: 30, width: 500.00, height: 300.00))
    
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
                    
                    // Hide lot of things...
                    for subview in view.subviews {
                        if (subview.tag > 99) {
                            subview.hidden = true
                        }
                    }
                    // Add new background image
                    let blurredBackground: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
                    blurredBackground.contentMode = UIViewContentMode.ScaleAspectFill
                    blurredBackground.image = bkgdImage.image
                    blurredBackground.tag = 666
                    self.view.addSubview(blurredBackground)
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                    let blurView = UIVisualEffectView(effect: blurEffect)
                    blurView.frame = blurredBackground.frame
                    blurView.tag = 666
                    self.view.addSubview(blurView)
                    
                    // Show the textview
                    let pathFrameCorners = (details["\(touchedTag)"]?.bezierFrame())!
                    
                    // Cropping image
                    let cropDetail: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
                    cropDetail.contentMode = UIViewContentMode.ScaleAspectFill
                    cropDetail.image = bkgdImage.image
                    let myMask = CAShapeLayer()
                    myMask.path = paths[touchedTag]!.CGPath
                    cropDetail.layer.mask = myMask
                    
                    // Put it on top
                    cropDetail.layer.zPosition = 2
                    cropDetail.tag = 666
                    /*for corner in pathFrameCorners {
                        if (txtView.frame.contains(corner)) {
                            cropDetail.center = CGPoint(x: screenWidth/2 + 260, y: screenHeight/2 + 150)
                            break
                        }
                    }*/
                    self.view.addSubview(cropDetail)
                    
                    var topLeft = pathFrameCorners.first!
//                    let distanceX =
                    
                    while (txtView.frame.contains(topLeft)) {
                        UIView.animateWithDuration(0.5, animations: {
                            cropDetail.center = CGPoint(x: cropDetail.center.x+1, y: cropDetail.center.y+1)
                        })
                        topLeft = CGPoint(x: topLeft.x+1, y: topLeft.y+1)
                        print("txtview frame : \(txtView.frame)")
                        print(cropDetail.center)
                        
                    }
                    
                    if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(touchedTag)"]) {
                        for d in detail {
                            //let zoomStatus: Bool = (d.attributes["zoom"] == "true") ? true : false
                            let detailTitle = d.attributes["title"]!
                            let detailDescription = d.value!
                            
                            let titleWidth = detailTitle.characters.count
                            let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: detailTitle)
                            attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(14)], range: NSRange(location: 0, length: titleWidth))
                            
                            let attributedDescription: NSMutableAttributedString = NSMutableAttributedString(string: "\n\n\(detailDescription)")
                            attributedText.appendAttributedString(attributedDescription)
                            
                            txtView.attributedText = attributedText
                        }
                    }
                    txtView.backgroundColor = UIColor.redColor()
                    txtView.scrollEnabled = true
                    txtView.editable = false
                    txtView.selectable = true
                    txtView.tag = 666
                    self.view.addSubview(txtView)
                    showDetail = true
                    break
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!txtView.frame.contains(touchBegin) && touchedTag == 0) {
            print("touch end on background")
            for subview in view.subviews {
                if subview.tag == 666 {
                    subview.removeFromSuperview()
                }
                if subview.tag > 99 {
                    subview.hidden = false
                }
            }
            showDetail = false
        }
        print("txtview frame : \(txtView.frame)")
        print("touch begin at : \(touchBegin)")
        print("touched tag : \(touchedTag)")
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
        var xMin: CGFloat = screenWidth
        var xMax: CGFloat = 0
        var yMin: CGFloat = screenHeight
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
