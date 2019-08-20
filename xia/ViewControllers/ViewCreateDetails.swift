//
//  ViewCreateDetails.swift
//  xia
//
//  Created by Guillaume on 26/09/2015.
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
import MessageUI
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewCreateDetails: UIViewController, MFMailComposeViewControllerDelegate {
        
    var index: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var fileName: String = emptyString
    var fileTitle: String = emptyString
    
    var location = CGPoint(x: 0, y: 0)
    var movingPoint = -1 // Id of point
    var movingCoords = CGPoint(x: 0, y: 0)
    var landscape = false
    
    var details = [String: xiaDetail]()
    var currentDetailTag: Int = 0
    var detailToSegue: Int = 0
    var createDetail: Bool = false
    var beginTouchLocation = CGPoint(x: 0, y: 0)
    var editDetail = -1
    var moveDetail = false
    var virtPoints = [Int: UIImageView]()
    var polygonPointsOrder = [Int]()
    
    var imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var img = UIImage()
    var scale: CGFloat = 1.0
    
    var menu: UIAlertController!
    var btnTag: Int = 0
    
    var currentDirs = rootDirs
    
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var imgTopBarBkgd: UIImageView!
    @IBOutlet var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myToolbar.layer.zPosition = 999
        imgTopBarBkgd.layer.zPosition = 100
        imgTopBarBkgd.isHidden = false
        
        // Load image
        let imagePath = currentDirs[imagesString]! + separatorString + self.fileName + jpgExtension
        img = UIImage(contentsOfFile: imagePath)!
        
        landscape = (img.size.width > img.size.height) ? true : false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewCreateDetails.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        let dSelector : Selector = #selector(ViewCreateDetails.detailInfos)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // Put the StatusBar in white
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove hairline on toolbar
        myToolbar.clipsToBounds = true
        
        // Build the imgView frame
        loadBackground(img)
        
        // Load xmlDetails from xml
        if let _ = xml.root[xmlDetailsKey][xmlDetailKey].all {
            loadDetails(xml)
        }
        fileTitle = (xml[xmlXiaKey][xmlTitleKey].value == nil) ? fileName : xml[xmlXiaKey][xmlTitleKey].value!
        cleaningDetails()
        setBtnsIcons()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.location(in: self.imgView)
        let touchedVirtPoint = touchesVirtPoint(location)
        
        if createDetail {
            let detailTag = self.currentDetailTag
            let detailPoints = details[String(detailTag)]?.points.count
            var addPoint = false
            
            if ( detailPoints != 0 && touchedVirtPoint == -1) { // Points exists
                // Are we in the polygon ?
                if (detailPoints > 2) {
                    if (pointInPolygon(details[String(detailTag)]!.points, touchPoint: location)) {
                        beginTouchLocation = location
                        movingCoords = location
                        moveDetail = true
                        movingPoint = -1
                    }
                    else {
                        addPoint = true
                    }
                }
                
                for (id, point) in (details[String(detailTag)]?.points)! { // should we move an existing point or add a new one
                    let ploc = point.center
                    
                    let dist = distance(location, point2: ploc)
                    if ( dist < 20 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = point
                        toMove.center = location
                        details[String(detailTag)]?.points[id] = toMove
                        movingPoint = id
                        moveDetail = false
                        addPoint = false
                        break
                    }
                    else {
                        addPoint = true
                    }
                }
            }
            if touchedVirtPoint != -1 {
                moveDetail = false
                addPoint = false
            }
            if ( (addPoint || detailPoints == 0 || touchedVirtPoint != -1) && !moveDetail )  {
                if detailPoints == 0 {
                    polygonPointsOrder = []
                }
                let nbPoints = (details[String(detailTag)]?.points.count)!
                movingPoint = (touchedVirtPoint == -1) ? nbPoints : (touchedVirtPoint + 1)
                if touchedVirtPoint != -1 {
                    // Change indexes of next points
                    var i = nbPoints
                    while i > touchedVirtPoint-1 {
                        details[String(detailTag)]?.points[i+1] = details[String(detailTag)]?.points[i]
                        i = i - 1
                        if i > touchedVirtPoint {
                             polygonPointsOrder[i] = polygonPointsOrder[i]+1
                        }
                    }
                }
                
                // Add new point
                let newPoint = details[String(detailTag)]?.createPoint(location, imageName: cornerString, index: movingPoint)
                newPoint?.layer.zPosition = 1
                imgView.addSubview(newPoint!)
                polygonPointsOrder.append(movingPoint)
                
                // Remove old polygon
                for subview in imgView.subviews {
                    if subview.tag == (detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                buildShape(true, color: editColor, tag: detailTag, points: details[String(detailTag)]!.points, parentView: imgView, locked: details[String(detailTag)]!.locked)
            }
        }
        else {
            var touchedTag: Int = 0
            
            // Look if we try to move a detail
            for detail in details {
                let (detailTag, detailPoints) = detail
                if (pointInPolygon(detailPoints.points, touchPoint: location)) {
                    touchedTag = (NumberFormatter().number(from: detailTag)?.intValue)!
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
            if (currentDetailTag != 0 && !details[String(currentDetailTag)]!.locked) {
                movingPoint = -1
                for (id, point) in (details[String(currentDetailTag)]?.points)! {
                    let ploc = point.center
                    
                    let dist = distance(location, point2: ploc)
                    if ( dist < 20 ) { // We are close to an exiting point, move it
                        let toMove: UIImageView = point
                        switch details[String(currentDetailTag)]!.constraint {
                        case constraintEllipse:
                            toMove.center = ploc
                            break
                        default:
                            toMove.center = location
                            break
                        }
                        details[String(currentDetailTag)]?.points[id] = toMove
                        movingPoint = id
                        moveDetail = false
                        break
                    }
                    else { // No point here, just move the detail
                        moveDetail = (details[String(currentDetailTag)]!.locked) ? false : true
                    }
                }
            }
            
            // Should we add a virtual point ?
            if touchedVirtPoint != -1 {
                moveDetail = false
                let nbPoints = (details[String(currentDetailTag)]?.points.count)!
                movingPoint = touchedVirtPoint + 1
                // Change indexes of next points
                var i = nbPoints
                while i > touchedVirtPoint-1 {
                    details[String(currentDetailTag)]?.points[i+1] = details[String(currentDetailTag)]?.points[i]
                    i = i - 1
                }
                
                // Add new point
                let newPoint = details[String(currentDetailTag)]?.createPoint(location, imageName: cornerString, index: movingPoint)
                newPoint?.layer.zPosition = 1
                imgView.addSubview(newPoint!)
                
                // Remove old polygon
                for subview in imgView.subviews {
                    if subview.tag == (currentDetailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                buildShape(true, color: editColor, tag: currentDetailTag, points: details[String(currentDetailTag)]!.points, parentView: imgView, locked: details[String(currentDetailTag)]!.locked)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.location(in: self.imgView)
        let detailTag = self.currentDetailTag
        
        if ( movingPoint != -1 && detailTag != 0 && !details[String(detailTag)]!.locked ) {
            let ploc = details[String(detailTag)]?.points[movingPoint]!.center
            
            let dist = distance(location, point2: ploc!)
            if ( dist < 200 ) {
                let toMove: UIImageView = details[String(detailTag)]!.points[movingPoint]!
                let previousPoint: Int = (movingPoint + 3) % 4
                let nextPoint: Int = (movingPoint + 1) % 4
                let oppositePoint: Int = (movingPoint + 2) % 4
                
                // Are there any constraint ?
                switch details[String(detailTag)]!.constraint {
                case constraintRectangle:
                    if (movingPoint % 2 == 0) {
                        details[String(detailTag)]!.points[previousPoint]!.center = CGPoint(x: location.x, y: details[String(detailTag)]!.points[previousPoint]!.center.y)
                        details[String(detailTag)]!.points[nextPoint]!.center = CGPoint(x: details[String(detailTag)]!.points[nextPoint]!.center.x, y: location.y)
                    }
                    else {
                        details[String(detailTag)]!.points[previousPoint]!.center = CGPoint(x: details[String(detailTag)]!.points[previousPoint]!.center.x, y: location.y)
                        details[String(detailTag)]!.points[nextPoint]!.center = CGPoint(x: location.x, y: details[String(detailTag)]!.points[nextPoint]!.center.y)
                    }
                    toMove.center = location
                    details[String(detailTag)]?.points[movingPoint] = toMove
                    break
                case constraintEllipse:
                    if (movingPoint % 2 == 0) {
                        let middleHeight = (details[String(detailTag)]!.points[oppositePoint]!.center.y - location.y)/2 + location.y
                        toMove.center = CGPoint(x: ploc!.x, y: location.y)
                        details[String(detailTag)]?.points[movingPoint]!.center = CGPoint(x: ploc!.x, y: details[String(detailTag)]!.points[movingPoint]!.center.y)
                        details[String(detailTag)]!.points[previousPoint]!.center = CGPoint(x: details[String(detailTag)]!.points[previousPoint]!.center.x, y: middleHeight)
                        details[String(detailTag)]!.points[nextPoint]!.center = CGPoint(x: details[String(detailTag)]!.points[nextPoint]!.center.x, y: middleHeight)
                    }
                    else {
                        let middleWidth = (details[String(detailTag)]!.points[oppositePoint]!.center.x - location.x)/2 + location.x
                        toMove.center = CGPoint(x: location.x, y: ploc!.y)
                        details[String(detailTag)]?.points[movingPoint]!.center = CGPoint(x: details[String(detailTag)]!.points[movingPoint]!.center.x, y: ploc!.y)
                        details[String(detailTag)]!.points[previousPoint]!.center = CGPoint(x: middleWidth, y: details[String(detailTag)]!.points[previousPoint]!.center.y)
                        details[String(detailTag)]!.points[nextPoint]!.center = CGPoint(x: middleWidth, y: details[String(detailTag)]!.points[nextPoint]!.center.y)
                    }
                    break
                default:
                    toMove.center = location
                    details[String(detailTag)]?.points[movingPoint] = toMove
                    break
                }
            }
        }
        
        if createDetail {
            if (moveDetail) {
                movingPoint = -1
                let deltaX = location.x - movingCoords.x
                let deltaY = location.y - movingCoords.y
                for subview in imgView.subviews {
                    if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                        let origin = subview.frame.origin
                        let destination = CGPoint(x: origin.x + deltaX, y: origin.y + deltaY)
                        subview.frame.origin = destination
                    }
                }
                movingCoords = location
            }
        }
        else {
            if ( editDetail != -1) {
                if (moveDetail) {
                    movingPoint = -1
                    let deltaX = location.x - movingCoords.x
                    let deltaY = location.y - movingCoords.y
                    for subview in imgView.subviews {
                        if ( subview.tag == detailTag || subview.tag == (detailTag + 100) ) {
                            let origin = subview.frame.origin
                            let destination = CGPoint(x: origin.x + deltaX, y: origin.y + deltaY)
                            subview.frame.origin = destination
                        }
                    }
                    movingCoords = location
                }
            }
        }
        
        if details[String(detailTag)]?.points.count > 2 {
            // rebuild points & shape
            for subview in imgView.subviews {
                if subview.tag == (detailTag + 100) {
                    subview.removeFromSuperview()
                }
                if subview.tag == detailTag {
                    subview.layer.zPosition = 1
                }
            }
            let drawEllipse: Bool = (details[String(detailTag)]?.constraint == constraintEllipse) ? true : false
            buildShape(true, color: editColor, tag: detailTag, points: details[String(detailTag)]!.points, parentView: imgView, ellipse: drawEllipse, locked: details[String(detailTag)]!.locked)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.location(in: self.imgView)
        
        let detailTag = self.currentDetailTag
        let detailPoints = details[String(detailTag)]?.points.count
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
            let drawEllipse: Bool = (details[String(detailTag)]?.constraint == constraintEllipse) ? true : false
            buildShape(true, color: editColor, tag: detailTag, points: details[String(detailTag)]!.points, parentView: imgView, ellipse: drawEllipse, locked: details[String(detailTag)]!.locked)
            let locked = details[String(detailTag)]!.locked
            if (details[String(detailTag)]?.constraint == constraintPolygon && !locked) {
                virtPoints = details[String(detailTag)]!.makeVirtPoints()
                for virtPoint in virtPoints {
                    imgView.addSubview(virtPoint.1)
                }
            }
            
            // Save the detail in xml
            if let detail = xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(detailTag)]) {
                for d in detail {
                    d.attributes[xmlPathKey] = (details[String(detailTag)]?.createPath())!
                    d.attributes[xmlConstraintKey] = details[String(detailTag)]?.constraint
                }
            }
            let _ = writeXML(xml, path: currentDirs[xmlString]! + separatorString + fileName + xmlExtension)
        }
        
        if createDetail {
            moveDetail = false
        }
        else {
            if (editDetail == -1 && movingPoint == -1) {
                changeDetailColor(-1)
                currentDetailTag = 0
                moveDetail = false
            }
            else {
                editDetail = -1
            }
        }
        
        setBtnsIcons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == viewDetailInfosSegueKey) {
            if let controller:ViewDetailInfos = segue.destination as? ViewDetailInfos {
                if let detail = xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(self.detailToSegue)]) {
                    for d in detail {
                        controller.detailTitle = (d.attributes[xmlTitleKey] == nil) ? emptyString : d.attributes[xmlTitleKey]!
                        controller.detailDescription = (d.value == nil) ? emptyString : d.value!
                        controller.zoom = (d.attributes[xmlZoomKey] != nil && d.attributes[xmlZoomKey] == trueString) ? true : false
                        controller.lock = (d.attributes[xmlLockedKey] != nil && d.attributes[xmlLockedKey] == trueString) ? true : false
                        controller.tag = self.detailToSegue
                        controller.xml = self.xml
                        controller.index = self.index
                        controller.fileName = fileName
                        controller.ViewCreateDetailsController = self
                        controller.currentDirs = currentDirs
                    }
                }
            }
        }
        if (segue.identifier == viewMetasSegueKey) {
            if let controller:ViewMetas = segue.destination as? ViewMetas {
                controller.xml = self.xml
                controller.fileName = self.fileName
                controller.selectedSegment = btnTag
                controller.ViewCreateDetailsController = self
                controller.currentDirs = currentDirs
            }
        }
        if (segue.identifier == playXiaSegueKey) {
            if let controller:PlayXia = segue.destination as? PlayXia {
                controller.fileName = fileName
                controller.xml = self.xml
                controller.landscape = landscape
                controller.currentDirs = currentDirs
            }
        }
        if (segue.identifier == viewExportSegueKey) {
            if let controller:ViewExport = segue.destination as? ViewExport {
                controller.fileName = fileName
                controller.xml = self.xml
                controller.currentDirs = currentDirs
            }
        }
    }
    
    @objc func addDetail(_ sender: UIBarButtonItem) {
        // Prepare new detail
        let lastDetailTag = self.xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].last
        if lastDetailTag != nil {
            self.currentDetailTag = (NumberFormatter().number(from: (lastDetailTag?.attributes[tagString]!)!)?.intValue)! + 1
        }
        else {
            self.currentDetailTag = 100
        }
        let newDetail = xiaDetail(tag: self.currentDetailTag, scale: self.scale)
        let attributes = [tagString : String(self.currentDetailTag),
            xmlZoomKey : trueString,
            titleKey : emptyString,
            xmlPathKey : newDetailPathString]
        
        // Build menu
        menu = UIAlertController(title: emptyString, message: nil, preferredStyle: .actionSheet)
        let rectangleAction = UIAlertAction(title: NSLocalizedString(constraintRectangle.uppercased(), comment: emptyString), style: .default, handler: { action in
            // Create new detail
            self.details[String(self.currentDetailTag)] = newDetail
            self.details[String(self.currentDetailTag)]?.constraint = constraintRectangle
            
            let _ = self.xml[xmlXiaKey][xmlDetailsKey].addChild(name: xmlDetailKey, attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag)
            
            // Now build the rectangle
            let newPoint0 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 100, y: 30), imageName: cornerString, index: 0)
            newPoint0?.layer.zPosition = 1
            self.imgView.addSubview(newPoint0!)
            let newPoint1 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 300, y: 30), imageName: cornerString, index: 1)
            newPoint1?.layer.zPosition = 1
            self.imgView.addSubview(newPoint1!)
            let newPoint2 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 300, y: 150), imageName: cornerString, index: 2)
            newPoint2?.layer.zPosition = 1
            self.imgView.addSubview(newPoint2!)
            let newPoint3 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 100, y: 150), imageName: cornerString, index: 3)
            newPoint3?.layer.zPosition = 1
            self.imgView.addSubview(newPoint3!)
            buildShape(true, color: editColor, tag: self.currentDetailTag, points: self.details[String(self.currentDetailTag)]!.points, parentView: self.imgView, locked: self.details[String(self.currentDetailTag)]!.locked)
            
            self.stopCreation()
            
            // Save the detail in xml
            if let detail = self.xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(self.currentDetailTag)]) {
                for d in detail {
                    d.attributes[xmlPathKey] = (self.details[String(self.currentDetailTag)]?.createPath())!
                    d.attributes[xmlConstraintKey] = self.details[String(self.currentDetailTag)]?.constraint
                }
            }
            let _ = writeXML(self.xml, path: self.currentDirs[xmlString]! + separatorString + self.fileName + xmlExtension)
        })
        let ellipseAction = UIAlertAction(title: NSLocalizedString(constraintEllipse.uppercased(), comment: emptyString), style: .default, handler: { action in
            // Create new detail
            self.details[String(self.currentDetailTag)] = newDetail
            self.details[String(self.currentDetailTag)]?.constraint = constraintEllipse
            
            let _ = self.xml[xmlXiaKey][xmlDetailsKey].addChild(name: xmlDetailKey, attributes: attributes)
            self.createDetail = true
            self.changeDetailColor(self.currentDetailTag)
            
            // Now build the rectangle
            let newPoint0 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 300, y: 50), imageName: cornerString, index: 0)
            newPoint0?.layer.zPosition = 1
            self.imgView.addSubview(newPoint0!)
            let newPoint1 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 400, y: 110), imageName: cornerString, index: 1)
            newPoint1?.layer.zPosition = 1
            self.imgView.addSubview(newPoint1!)
            let newPoint2 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 300, y: 170), imageName: cornerString, index: 2)
            newPoint2?.layer.zPosition = 1
            self.imgView.addSubview(newPoint2!)
            let newPoint3 = self.details[String(self.currentDetailTag)]?.createPoint(CGPoint(x: 200, y: 110), imageName: cornerString, index: 3)
            newPoint3?.layer.zPosition = 1
            self.imgView.addSubview(newPoint3!)
            buildShape(true, color: editColor, tag: self.currentDetailTag, points: self.details[String(self.currentDetailTag)]!.points, parentView: self.imgView, ellipse: true, locked: self.details[String(self.currentDetailTag)]!.locked)
            
            self.stopCreation()
            
            // Save the detail in xml
            if let detail = self.xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(self.currentDetailTag)]) {
                for d in detail {
                    d.attributes[xmlPathKey] = (self.details[String(self.currentDetailTag)]?.createPath())!
                    d.attributes[xmlConstraintKey] = self.details[String(self.currentDetailTag)]?.constraint
                }
            }
            let _ = writeXML(self.xml, path: self.currentDirs[xmlString]! + separatorString + self.fileName + xmlExtension)
        })
        let polygonAction = UIAlertAction(title: NSLocalizedString(constraintPolygon.uppercased(), comment: emptyString), style: .default, handler: { action in
            // Create new detail object
            self.details[String(self.currentDetailTag)] = newDetail
            self.details[String(self.currentDetailTag)]?.constraint = constraintPolygon
            let _ = self.xml[xmlXiaKey][xmlDetailsKey].addChild(name: xmlDetailKey, attributes: attributes)
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
        let attributedTitle = NSAttributedString(string: NSLocalizedString(createDetailKey, comment: emptyString), attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        menu.setValue(attributedTitle, forKey: attributedTitleKey)
        
        rectangleAction.setValue(UIImage(named: constraintRectangle), forKey: xmlImageKey)
        ellipseAction.setValue(UIImage(named: constraintEllipse), forKey: xmlImageKey)
        polygonAction.setValue(UIImage(named: constraintPolygon), forKey: xmlImageKey)
        menu.addAction(rectangleAction)
        menu.addAction(ellipseAction)
        menu.addAction(polygonAction)
        
        if let ppc = menu.popoverPresentationController {
            ppc.barButtonItem = sender
            ppc.permittedArrowDirections = .up
        }
        
        present(menu, animated: true, completion: nil)
    }
    
    func changeDetailColor(_ tag: Int) {
        // Change other details color
        for detail in details {
            let thisDetailTag = NumberFormatter().number(from: detail.0)?.intValue
            // Remove and rebuild the shape to avoid the overlay on alpha channel
            for subview in imgView.subviews {
                if subview.tag == (thisDetailTag! + 100) { // polygon
                    subview.tag = thisDetailTag! + 300
                    subview.layer.zPosition = -1
                }
                if subview.tag == thisDetailTag! { // points
                    subview.layer.zPosition = 1
                    if thisDetailTag != tag {
                        subview.isHidden = true
                    }
                    else {
                        subview.isHidden = false
                    }
                }
            }
            if detail.1.points.count > 2 {
                let drawEllipse: Bool = (detail.1.constraint == constraintEllipse) ? true : false
                if thisDetailTag != tag {
                    buildShape(true, color: noEditColor, tag: thisDetailTag!, points: details[String(thisDetailTag!)]!.points, parentView: imgView, ellipse: drawEllipse, locked: details[String(thisDetailTag!)]!.locked)
                }
                else {
                    buildShape(true, color: editColor, tag: thisDetailTag!, points: details[String(thisDetailTag!)]!.points, parentView: imgView, ellipse: drawEllipse, locked: details[String(thisDetailTag!)]!.locked)
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
        if createDetail && details[String(tag)]?.constraint == constraintPolygon {
            imgTopBarBkgd.backgroundColor = editColor
        }
        else {
            imgTopBarBkgd.backgroundColor = blueColor
        }
        cleanOldViews()
    }
    
    func cleaningDetails() {
        for detail in details {
            let detailTag = NumberFormatter().number(from: detail.0)!.intValue
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
    
    func touchesVirtPoint(_ location: CGPoint) -> Int {
        var touched = -1
        for virtPoint in virtPoints {
            let dist = distance(location, point2: virtPoint.1.center)
            if dist < 20 {
                touched = virtPoint.0
                break
            }
        }
        
        return touched
    }
    
    @objc func deleteDetail() {
        let detailTag = self.currentDetailTag
        if ( detailTag != 0 ) {
            // Alert
            let controller = UIAlertController(title: NSLocalizedString(warningKey, comment: emptyString),
                message: String(NSLocalizedString(deleteDetailKey, comment: emptyString)), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: NSLocalizedString(yesKey, comment: emptyString),
                style: .destructive, handler: { action in
                    self.stopCreation()
                    self.performFullDetailRemove(detailTag, force: true)
                    self.setBtnsIcons()
            })
            let noAction = UIAlertAction(title: NSLocalizedString(noKey, comment: emptyString),
                style: .cancel, handler: nil)
            
            controller.addAction(yesAction)
            controller.addAction(noAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func detailInfos() {
        moveDetail = false
        movingPoint = -1
        let tmpDetailTag = currentDetailTag
        stopCreation()
        currentDetailTag = tmpDetailTag
        if currentDetailTag == 0 {
            performSegue(withIdentifier: viewMetasSegueKey, sender: self)
        }
        else {
            detailToSegue = currentDetailTag
            currentDetailTag = 0
            performSegue(withIdentifier: viewDetailInfosSegueKey, sender: self)
        }
    }
    
    func distance(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        let x = point1.x - point2.x
        let y = point1.y - point2.y
        return sqrt(x * x + y * y)
    }
    
    @objc func export() {
        performSegue(withIdentifier: viewExportSegueKey, sender: self)
    }
    
    @objc func goBack() {
        let _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func goForward() {
        performSegue(withIdentifier: playXiaSegueKey, sender: self)
    }
    
    func loadDetails(_ xml: AEXMLDocument) {
        let xmlDetails = xml.root[xmlDetailsKey][xmlDetailKey].all!
        for detail in xmlDetails {
            if let path = detail.attributes[xmlPathKey] {
                // Add detail object
                let detailTag = (NumberFormatter().number(from: detail.attributes[tagString]!)?.intValue)!
                // clean this tag
                for subview in imgView.subviews {
                    if (subview.tag == detailTag || subview.tag == detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                let newDetail = xiaDetail(tag: detailTag, scale: scale)
                details[String(detailTag)] = newDetail
                // Add points to detail
                let pointsArray = path.split{$0 == spaceCharacter}.map(String.init)
                if pointsArray.count > 2 {
                    var attainablePoints: Int = 0
                    var pointIndex = 0
                    for point in pointsArray {
                        let coords = point.split{$0 == semicolonCharacter}.map(String.init)
                        if coords.count == 2 {
                            let x = convertStringToCGFloat(coords[0]) * scale
                            let y = convertStringToCGFloat(coords[1]) * scale
                            let newPoint = details[String(detailTag)]?.createPoint(CGPoint(x: x, y: y), imageName: cornerString, index: pointIndex)
                            newPoint?.layer.zPosition = 1
                            newPoint?.isHidden = true
                            imgView.addSubview(newPoint!)
                            pointIndex = pointIndex + 1
                            if imgView.frame.contains((newPoint?.center)!) {
                                attainablePoints += 1
                            }
                        }
                    }
                    if let constraint = detail.attributes[xmlConstraintKey] {
                        details[String(detailTag)]?.constraint = (constraint != constraintPolygon && pointsArray.count != 4) ? constraintPolygon : constraint
                    }
                    else {
                        details[String(detailTag)]?.constraint = constraintPolygon
                    }
                    let drawEllipse: Bool = (details[String(detailTag)]?.constraint == constraintEllipse) ? true : false
                    details[String(detailTag)]?.locked = (detail.attributes[xmlLockedKey] == trueString) ? true : false
                    buildShape(true, color: noEditColor, tag: detailTag, points: details[String(detailTag)]!.points, parentView: imgView, ellipse: drawEllipse, locked: details[String(detailTag)]!.locked)
                    
                    if attainablePoints < 2 {
                        //performFullDetailRemove(detailTag, force: true)
                    }
                }
            }
        }
    }
    
    func loadBackground(_ img: UIImage) {
        let availableWidth: CGFloat = UIScreen.main.bounds.width
        let availableHeight: CGFloat = UIScreen.main.bounds.height - 64
        let scaleX: CGFloat = availableWidth / img.size.width
        let scaleY: CGFloat = availableHeight / img.size.height
        scale = min(scaleX, scaleY)
        let imageWidth: CGFloat = scale * img.size.width
        let imageHeight: CGFloat = scale * img.size.height
        let x: CGFloat = (availableWidth - imageWidth) / 2
        let y: CGFloat = 64 + (availableHeight - imageHeight) / 2
        imgView.frame = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        imgView.image = img
        view.addSubview(imgView)
        backView.backgroundColor = img.getMediumBackgroundColor()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openMetas() {
        performSegue(withIdentifier: viewMetasSegueKey, sender: self)
    }
    
    func performFullDetailRemove(_ tag: Int, force: Bool = false) {
        if (details[String(tag)]?.points.count < 3 || force) {
            // remove point & polygon
            for subview in imgView.subviews {
                if subview.tag == tag || subview.tag == (tag + 100) {
                    subview.removeFromSuperview()
                }
            }
            
            // remove detail object
            details[String(tag)] = nil
            
            // remove detail in xml
            if let detail = xml[xmlXiaKey][xmlDetailsKey][xmlDetailKey].all(withAttributes: [tagString : String(tag)]) {
                for d in detail {
                    d.removeFromParent()
                }
            }
            let _ = writeXML(xml, path: currentDirs[xmlString]! + separatorString + fileName + xmlExtension)
            currentDetailTag = 0
        }
    }
    
    @objc func polygonUndo() {
        let detailTag = self.currentDetailTag
        if details[String(detailTag)]?.points.count > 3 {
            // remove last point
            let lastPoint = polygonPointsOrder.last!
            details[String(detailTag)]?.points[lastPoint]?.removeFromSuperview()
            details[String(detailTag)]?.points[lastPoint] = nil
            
            // Update polygonPointsOrder indexes
            for id in polygonPointsOrder {
                if id > lastPoint - 1  && id != polygonPointsOrder.count {
                    polygonPointsOrder[id] = polygonPointsOrder[id] - 1
                }
            }
            
            // Update points index
            for i in lastPoint...(polygonPointsOrder.count - 1) {
                details[String(detailTag)]?.points[i] = details[String(detailTag)]?.points[i+1]
            }
            
            polygonPointsOrder.removeLast()
            
            // Remove old polygon
            for subview in imgView.subviews {
                if subview.tag == (currentDetailTag + 100) {
                    subview.removeFromSuperview()
                }
            }
            buildShape(true, color: editColor, tag: currentDetailTag, points: details[String(detailTag)]!.points, parentView: imgView, locked: details[String(detailTag)]!.locked)
        }
        setBtnsIcons()
    }
    
    @objc func rotated() {
        loadBackground(img)
        if let _ = xml.root[xmlDetailsKey][xmlDetailKey].all {
            loadDetails(xml)
        }
    }
    
    func setBtnsIcons() {
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil)
        fixedSpace.width = 15.0
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil))
        items.append(UIBarButtonItem(title: NSLocalizedString(collectionKey, comment: emptyString), style: .plain, target: self, action: #selector(ViewCreateDetails.goBack)))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil))
        var itemText = (fileTitle == emptyString) ? fileName : fileTitle
        if itemText.count > 47 {
            itemText = itemText[itemText.index(itemText.startIndex, offsetBy: 0)...itemText.index(itemText.startIndex, offsetBy: 46)] + String(repeating: dotString, count: 3)
        }
        items.append(UIBarButtonItem(title: (itemText), style: .plain, target: self, action: #selector(ViewCreateDetails.openMetas)))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil))
        if !createDetail {
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ViewCreateDetails.addDetail(_:))))
            items.append(fixedSpace)
        }
        if (currentDetailTag != 0 && createDetail && details[String(currentDetailTag)]!.constraint == constraintPolygon && details[String(currentDetailTag)]?.points.count > 3) {
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.reply, target: self, action: #selector(ViewCreateDetails.polygonUndo)))
            items.append(fixedSpace)
        }
        if (currentDetailTag != 0 && !details[String(currentDetailTag)]!.locked) {
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(ViewCreateDetails.deleteDetail)))
            items.append(fixedSpace)
        }
        if createDetail {
            items.append(UIBarButtonItem(title: NSLocalizedString(okKey, comment: emptyString), style: .done, target: self, action: #selector(ViewCreateDetails.stopCreation)))
        }
        else {
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(ViewCreateDetails.goForward)))
        }
        items.append(fixedSpace)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(ViewCreateDetails.export)))
        items.append(fixedSpace)
        let editBtn: UIButton = UIButton()
        editBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        editBtn.backgroundColor = blueColor
        editBtn.setImage(UIImage(named: editString), for: UIControl.State())
        editBtn.addTarget(self, action: #selector(ViewCreateDetails.detailInfos), for: UIControl.Event.touchUpInside)
        let customEditBtn: UIBarButtonItem = UIBarButtonItem()
        customEditBtn.customView = editBtn
        items.append(customEditBtn)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil))
        
        myToolbar.items = items
    }
    
    @objc func stopCreation() {
        createDetail = false
        performFullDetailRemove(currentDetailTag)
        if details[String(currentDetailTag)]?.constraint == constraintPolygon {
            currentDetailTag = 0
            changeDetailColor(-1)
        }
        imgTopBarBkgd.backgroundColor = blueColor
        setBtnsIcons()
        
        // Add double tap gesture
        let dSelector : Selector = #selector(ViewCreateDetails.detailInfos)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
}
