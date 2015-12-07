//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class PlayXia: UIViewController {
    
    var dbg = debug(enable: true)
    
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = ""
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
        
        // Load image
        let filePath = "\(documentsDirectory)\(self.fileName).jpg"
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
        
        let xmlPath = "\(documentsDirectory)/\(self.fileName).xml"
        let data = NSData(contentsOfFile: xmlPath)
        do {
            try xml = AEXMLDocument(xmlData: data!)
        }
        catch {
            dbg.pt("\(error)")
        }
        
        // Load xmlDetails from xml
        if let xmlDetails = xml.root["details"]["detail"].all {
            for detail in xmlDetails {
                if let path = detail.attributes["path"] {
                    // Add detail object
                    let detailTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                    let newDetail = xiaDetail(tag: detailTag, scale: scale)
                    details["\(detailTag)"] = newDetail
                    
                    // Add points to detail
                    let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                    for var point in pointsArray {
                        point = point.stringByReplacingOccurrencesOfString(".", withString: ",")
                        let coords = point.characters.split{$0 == ";"}.map(String.init)
                        let x = CGFloat(NSNumberFormatter().numberFromString(coords[0])!) * scale + xSpace // convert String to CGFloat
                        let y = CGFloat(NSNumberFormatter().numberFromString(coords[1])!) * scale + ySpace // convert String to CGFloat
                        let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner")
                        newPoint?.layer.zPosition = -1
                        view.addSubview(newPoint!)
                    }
                    
                    buildShape(false, color: UIColor.blueColor(), tag: detailTag)
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
        
        if (btnZoom.frame.contains(location) && btnZoom.enabled){
            if btnZoom.on {
                btnZoom.on = false
                if lastTouchedTag != 0 {
                    showMyDetail(lastTouchedTag, zoomDetail: false)
                }
            }
            else {
                btnZoom.on = true
                if lastTouchedTag != 0 {
                    showMyDetail(lastTouchedTag, zoomDetail: true)
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
                    let zoom: Bool = btnZoom.on
                    showMyDetail(touchedTag, zoomDetail: zoom)
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
    
    func showMyDetail(tag: Int, zoomDetail: Bool) {
        // Hide lot of things...
        for subview in view.subviews {
            if (subview.tag > 99) {
                subview.hidden = true
            }
            if (subview.tag == 667 && !zoomDetail) {
                subview.hidden = false
            }
        }
        // Add new background image
        let blurredBackground: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        blurredBackground.contentMode = UIViewContentMode.ScaleAspectFit
        blurredBackground.image = bkgdImage.image
        blurredBackground.tag = 666
        self.view.addSubview(blurredBackground)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = blurredBackground.frame
        blurView.tag = 666
        self.view.addSubview(blurView)
        
        // Show the textview
        let pathFrameCorners = (details["\(tag)"]?.bezierFrame())!
        
        // Cropping image
        let cropDetail: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        cropDetail.contentMode = UIViewContentMode.ScaleAspectFit
        cropDetail.image = bkgdImage.image
        let myMask = CAShapeLayer()
        myMask.path = paths[tag]!.CGPath
        cropDetail.layer.mask = myMask
        
        // Put it on top
        cropDetail.layer.zPosition = 2
        cropDetail.tag = 666
        self.view.addSubview(cropDetail)
        
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                zoomStatus = (d.attributes["zoom"] == "true") ? true : false
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
        txtView.frame = CGRect(x: screenWidth / 7, y: 30, width: 5 * screenWidth / 7, height: screenWidth / 3.5)
        txtView.backgroundColor = UIColor.lightGrayColor()
        txtView.scrollEnabled = true
        txtView.editable = false
        txtView.selectable = true
        txtView.tag = 667
        self.view.addSubview(txtView)
        showDetail = true
        
        // Calculate available space for detail view
        let txtViewBottom = txtView.frame.origin.y + txtView.frame.height
        let availableWidth = screenWidth
        let availableHeight = screenHeight - txtViewBottom - 15
        let availableRect = CGRect(x: 0, y: txtViewBottom + 15, width: availableWidth, height: availableHeight)
        
        // Center detail in the available space
        let distanceX = availableRect.midX - pathFrameCorners.midX
        let distanceY = availableRect.midY - pathFrameCorners.midY
        var newCropCenter = CGPointMake(cropDetail.center.x + distanceX, cropDetail.center.y + distanceY)
        
        // Should we scale the detail to fit in available space ?
        var detailScale: CGFloat = 1.0
        if (pathFrameCorners.width > availableWidth || pathFrameCorners.height > availableHeight) {
            let detailScaleX = availableWidth / pathFrameCorners.width
            let detailScaleY = availableHeight / pathFrameCorners.height
            detailScale = min(detailScaleX, detailScaleY)
        }
        else if zoomStatus { // looking for max zoom available if enabled on this detail...
            // Show btnZoom
            btnZoom.layer.zPosition = 2
            btnZoom.enabled = true
            let detailScaleX = availableWidth / pathFrameCorners.width
            let detailScaleY = availableHeight / pathFrameCorners.height
            zoomDetailScale = min(detailScaleX, detailScaleY, maxZoomScale)
            zoomCropCenter = CGPointMake(cropDetail.center.x + distanceX * zoomDetailScale, cropDetail.center.y - txtViewBottom + distanceY * zoomDetailScale)
            if zoomDetail {
                detailScale = zoomDetailScale
                newCropCenter = zoomCropCenter
            }
        }
        else {
        btnZoom.layer.zPosition = -1
        btnZoom.enabled = false
        btnZoom.on = false
        }
        
        // let's rock & rolls
        UIView.animateWithDuration(0.5, animations: {
            cropDetail.transform = CGAffineTransformScale(cropDetail.transform, detailScale, detailScale)
            cropDetail.center = newCropCenter
        })
    }
    
    func hideDetails(hidden: Bool) {
        for subview in view.subviews {
            if subview.tag > 199 {
                subview.hidden = hidden
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
