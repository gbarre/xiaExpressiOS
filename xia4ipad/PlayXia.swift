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
                    buildShape(false, color: UIColor.blueColor(), tag: detailTag, points: details["\(detailTag)"]!.points, parentView: view, ellipse: drawEllipse)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playMetas") {
            if let controller:PlayImageMetadatas = segue.destinationViewController as? PlayImageMetadatas {
                controller.xml = self.xml
            }
        }
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

        // Add new background image (with blurred effect)
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
        
        // Show the text...
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
        txtView.frame = CGRect(x: screenWidth / 7, y: -screenWidth / 3.5 - 30, width: 5 * screenWidth / 7, height: screenWidth / 3.5)
        txtView.backgroundColor = UIColor.lightGrayColor()
        txtView.userInteractionEnabled = true
        txtView.scrollEnabled = true
        txtView.editable = false
        txtView.selectable = true
        txtView.dataDetectorTypes = UIDataDetectorTypes.Link
        txtView.tag = 667
        txtView.layer.cornerRadius = 5
        self.view.addSubview(txtView)
        
        // Let's show it baby !
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.txtView.frame.origin = CGPointMake(self.screenWidth / 7, 30)
        })
        self.view.addSubview(txtView)
        showDetail = true
        
        var newCropCenter = CGPointMake(cropDetail.center.x, cropDetail.center.y)
        var detailScale: CGFloat = 1.0
        
        // Show the detail zoomed
        if zoomDetail {
            // Show btnZoom
            btnZoom.layer.zPosition = 2
            btnZoom.enabled = true
            let detailScaleX = (screenWidth - 10) / pathFrameCorners.width
            let detailScaleY = (screenHeight - 50) / pathFrameCorners.height
            detailScale = min(detailScaleX, detailScaleY, maxZoomScale)
            let distanceX = screenWidth/2 - pathFrameCorners.midX
            let distanceY = screenHeight/2 - pathFrameCorners.midY
            //zoomCropCenter = CGPointMake(cropDetail.center.x + distanceX * zoomDetailScale, cropDetail.center.y - txtViewBottom + distanceY * zoomDetailScale)
            newCropCenter = CGPointMake(cropDetail.center.x + distanceX * detailScale, cropDetail.center.y + distanceY * detailScale)
            
        } // no zoom
        else {
            // Calculate available space for detail view
            let txtViewBottom = txtView.frame.origin.y + txtView.frame.height
            let availableWidth = screenWidth
            let availableHeight = screenHeight - txtViewBottom - 15
            let availableRect = CGRect(x: 0, y: txtViewBottom + 15, width: availableWidth, height: availableHeight)
            
            // Center detail in the available space
            var distanceX = availableRect.midX - pathFrameCorners.midX
            var distanceY = availableRect.midY - pathFrameCorners.midY
            
            // Should we scale the detail to fit in available space ?
            if (pathFrameCorners.width > availableWidth || pathFrameCorners.height > availableHeight) {
                let detailScaleX = (availableWidth - 10) / pathFrameCorners.width
                let detailScaleY = (availableHeight - 30) / pathFrameCorners.height
                detailScale = min(detailScaleX, detailScaleY)
                distanceX = availableRect.midX - pathFrameCorners.midX
                distanceY = availableRect.midY - pathFrameCorners.midY - 10
                
                newCropCenter = CGPointMake(cropDetail.center.x + distanceX * detailScale, cropDetail.center.y + distanceY)
            }
            else {
                newCropCenter = CGPointMake(cropDetail.center.x + distanceX, cropDetail.center.y + distanceY)
                
            }
            // Show btnZoom
            if zoomStatus {
                btnZoom.layer.zPosition = 2
                btnZoom.enabled = true
            }
        }
        
        // let's rock & rolls
        UIView.animateWithDuration(0.5, animations: {
            cropDetail.transform = CGAffineTransformScale(cropDetail.transform, detailScale, detailScale)
            cropDetail.center = newCropCenter
        })
        
    }
}
