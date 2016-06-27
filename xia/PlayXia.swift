//
//  PlayXia.swift
//  xia4ipad
//
//  Created by Guillaume on 25/11/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit

class PlayXia: UIViewController, UIViewControllerTransitioningDelegate {
    
    var xml: AEXMLDocument = AEXMLDocument()
    let transition = BubbleTransition()
    
    var fileName: String = ""
    var filePath: String = ""
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var touchedTag: Int = 0
    var paths = [Int: UIBezierPath]()
    var showDetails: Bool = false
    var touchBegin = CGPoint(x: 0, y: 0)
    var img: UIImage!
    
    var scale: CGFloat = 1.0
    
    var landscape: Bool = false
    
    @IBOutlet weak var bkgdImage: UIImageView!
    @IBOutlet var leftButtonBkgd: UIImageView!
    @IBOutlet var leftButton: UIButton!
    @IBAction func showMetas(sender: AnyObject) {
        performSegueWithIdentifier("playMetas", sender: self)
    }
    @IBAction func showImgInfos(sender: AnyObject) {
        touchedTag = 0
        performSegueWithIdentifier("openDetail", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        // hide left button (image infos) if there are no title & description
        // hide left button if details are not showed
        if ( ((xml["xia"]["image"].attributes["title"] == nil || xml["xia"]["image"].attributes["title"]! == "") &&
            (xml["xia"]["image"].attributes["description"] == nil || xml["xia"]["image"].attributes["description"]! == ""))
            ) {
            leftButton.hidden = true
            leftButtonBkgd.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gestures on swipe
        let gbSelector = #selector(PlayXia.goBack)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let filePath = "\(self.filePath).jpg"
        img = UIImage(contentsOfFile: filePath)
        bkgdImage.image = img
        
        // Load xmlDetails from xml
        if let _ = xml.root["details"]["detail"].all {
            loadDetails(xml)
        }
        showDetails = (xml["xia"]["details"].attributes["show"] == "true") ? true : false
        for subview in view.subviews {
            if subview.tag > 199 {
                subview.hidden = !showDetails
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayXia.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.locationInView(self.bkgdImage)
        touchedTag = 0
        
        // Get tag of the touched detail
        for detail in details {
            let (detailTag, detailPoints) = detail
            if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                touchedTag = (NSNumberFormatter().numberFromString(detailTag)?.integerValue)!
                performSegueWithIdentifier("openDetail", sender: self)
                break
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playMetas") {
            if let controller:PlayImageMetadatas = segue.destinationViewController as? PlayImageMetadatas {
                controller.xml = self.xml
                controller.landscape = landscape
            }
        }
        if (segue.identifier == "openDetail") {
            if let controller:PlayDetail = segue.destinationViewController as? PlayDetail {
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .FormSheet
                controller.xml = self.xml
                controller.tag = touchedTag
                controller.detail = (touchedTag != 0) ? details["\(touchedTag)"] : xiaDetail(tag: 0, scale: 1)
                controller.path = (touchedTag != 0) ? paths[touchedTag] : UIBezierPath()
                controller.bkgdImage = bkgdImage
                controller.landscape = landscape
            }
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = location
        transition.bubbleColor = blueColor
        transition.detailFrame = (touchedTag != 0) ? details["\(touchedTag)"]?.bezierFrame() : UIScreen.mainScreen().bounds
        transition.path = (touchedTag != 0) ? paths[touchedTag] : UIBezierPath()
        transition.theDetail = (touchedTag != 0) ? details["\(touchedTag)"] : xiaDetail(tag: 0, scale: 1)
        transition.bkgdImage = bkgdImage
        transition.noDetailStatus = (touchedTag != 0) ? false : true
        transition.duration = 0.5
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        transition.startingPoint = CGPoint(x: screenWidth / 2, y: 2 * screenHeight)
        transition.duration = 0.5
        return transition
    }
    
    func goBack() {
        let _ = navigationController?.popViewControllerAnimated(true)
    }
    
    func loadDetails(xml: AEXMLDocument) {
        // Get the scale...
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let scaleX: CGFloat = screenWidth / img!.size.width
        let scaleY: CGFloat = screenHeight / img!.size.height
        scale = min(scaleX, scaleY)
        let xSpace: CGFloat = (screenWidth - img!.size.width * scale) / 2
        let ySpace: CGFloat = (screenHeight - img!.size.height * scale) / 2
        
        let xmlDetails = xml.root["details"]["detail"].all!
        for detail in xmlDetails {
            if let path = detail.attributes["path"] {
                // Add detail object
                let detailTag = (NSNumberFormatter().numberFromString(detail.attributes["tag"]!)?.integerValue)!
                let newDetail = xiaDetail(tag: detailTag, scale: scale)
                details["\(detailTag)"] = newDetail
                details["\(detailTag)"]!.constraint = detail.attributes["constraint"]!
                
                // clean this tag
                for subview in view.subviews {
                    if (subview.tag == detailTag || subview.tag == detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                
                // Add points to detail
                let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                var pointIndex = 0
                for point in pointsArray {
                    let coords = point.characters.split{$0 == ";"}.map(String.init)
                    let x = convertStringToCGFloat(coords[0]) * scale + xSpace
                    let y = convertStringToCGFloat(coords[1]) * scale + ySpace
                    let newPoint = details["\(detailTag)"]?.createPoint(CGPoint(x: x, y: y), imageName: "corner", index: pointIndex)
                    newPoint?.layer.zPosition = -1
                    pointIndex = pointIndex + 1
                    view.addSubview(newPoint!)
                }
                let drawEllipse: Bool = (detail.attributes["constraint"] == constraintEllipse) ? true : false
                buildShape(false, color: blueColor, tag: detailTag, points: details["\(detailTag)"]!.points, parentView: view, ellipse: drawEllipse)
                paths[detailTag] = details["\(detailTag)"]!.bezierPath()
            }
        }
    }
    
    func rotated() {
        loadDetails(xml)
        landscape = (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) ? true : false
    }
}
