//
//  PlayXia.swift
//  xia
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
    
    var fileName: String = emptyString
    var details = [String: xiaDetail]()
    var location = CGPoint(x: 0, y: 0)
    var touchedTag: Int = 0
    var paths = [Int: UIBezierPath]()
    var showDetails: Bool = false
    var touchBegin = CGPoint(x: 0, y: 0)
    var img: UIImage!
    
    var scale: CGFloat = 1.0
    
    var landscape: Bool = false
    
    var currentDirs = rootDirs
    
    @IBOutlet weak var bkgdImage: UIImageView!
    @IBOutlet var leftButtonBkgd: UIImageView!
    @IBOutlet var leftButton: UIButton!
    @IBAction func showMetas(_ sender: AnyObject) {
        performSegue(withIdentifier: playMetasSegueKey, sender: self)
    }
    @IBAction func showImgInfos(_ sender: AnyObject) {
        touchedTag = 0
        performSegue(withIdentifier: openDetailSegueKey, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide left button (image infos) if there are no title & description
        // hide left button if details are not showed
        if ( ((xml[xmlXiaKey][xmlImageKey].attributes[xmlTitleKey] == nil || xml[xmlXiaKey][xmlImageKey].attributes[xmlTitleKey]! == emptyString) &&
            (xml[xmlXiaKey][xmlImageKey].attributes[xmlDescriptionKey] == nil || xml[xmlXiaKey][xmlImageKey].attributes[xmlDescriptionKey]! == emptyString))
            ) {
            leftButton.isHidden = true
            leftButtonBkgd.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gestures on swipe
        let gbSelector = #selector(PlayXia.goBack)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: gbSelector )
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(rightSwipe)
        
        // Load image
        let imagePath = currentDirs[imagesString]! + separatorString + self.fileName + jpgExtension
        img = UIImage(contentsOfFile: imagePath)
        bkgdImage.image = img
        bkgdImage.backgroundColor = img.getMediumBackgroundColor()
        
        // Load xmlDetails from xml
        if let _ = xml.root[xmlDetailsKey][xmlDetailKey].all {
            loadDetails(xml)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayXia.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // Put the StatusBar in white
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        location = touch.location(in: self.view)
        touchedTag = 0
        
        // Get tag of the touched detail
        for subview in view.subviews {
            guard let accessibitilyIdentifier = subview.accessibilityIdentifier else {continue}
            if accessibitilyIdentifier.contains(xmlDetailKey) && subview.frame.contains(location) {
                touchedTag = subview.tag - 100
                performSegue(withIdentifier: openDetailSegueKey, sender: self)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == playMetasSegueKey) {
            if let controller:PlayImageMetadatas = segue.destination as? PlayImageMetadatas {
                controller.xml = self.xml
                controller.landscape = landscape
            }
        }
        if (segue.identifier == openDetailSegueKey) {
            if let controller:PlayDetail = segue.destination as? PlayDetail {
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .formSheet
                controller.xml = self.xml
                controller.tag = touchedTag
                controller.detail = (touchedTag != 0) ? details[String(touchedTag)] : xiaDetail(tag: 0, scale: 1)
                controller.path = (touchedTag != 0) ? paths[touchedTag] : UIBezierPath()
                controller.bkgdImage = bkgdImage
                controller.landscape = landscape
            }
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = location
        transition.bubbleColor = blueColor
        transition.detailFrame = (touchedTag != 0) ? details[String(touchedTag)]?.bezierFrame() : UIScreen.main.bounds
        transition.path = (touchedTag != 0) ? paths[touchedTag] : UIBezierPath()
        transition.theDetail = (touchedTag != 0) ? details[String(touchedTag)] : xiaDetail(tag: 0, scale: 1)
        transition.bkgdImage = bkgdImage
        transition.noDetailStatus = (touchedTag != 0) ? false : true
        transition.duration = 0.5
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        transition.startingPoint = CGPoint(x: screenWidth / 2, y: 2 * screenHeight)
        transition.duration = 0.5
        return transition
    }
    
    @objc func goBack() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func loadDetails(_ xml: AEXMLDocument) {
        // Get the scale...
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scaleX: CGFloat = screenWidth / img!.size.width
        let scaleY: CGFloat = screenHeight / img!.size.height
        scale = min(scaleX, scaleY)
        let xSpace: CGFloat = (screenWidth - img!.size.width * scale) / 2
        let ySpace: CGFloat = (screenHeight - img!.size.height * scale) / 2
        
        let xmlDetails = xml.root[xmlDetailsKey][xmlDetailKey].all!
        for detail in xmlDetails {
            if let path = detail.attributes[xmlPathKey] {
                // Add detail object
                let detailTag = (NumberFormatter().number(from: detail.attributes[tagString]!)?.intValue)!
                let newDetail = xiaDetail(tag: detailTag, scale: scale)
                details[String(detailTag)] = newDetail
                details[String(detailTag)]!.constraint = detail.attributes[xmlConstraintKey]!
                
                // clean this tag
                for subview in view.subviews {
                    if (subview.tag == detailTag || subview.tag == detailTag + 100) {
                        subview.removeFromSuperview()
                    }
                }
                
                // Add points to detail
                let pointsArray = path.split{$0 == spaceCharacter}.map(String.init)
                var pointIndex = 0
                for point in pointsArray {
                    let coords = point.split{$0 == semicolonCharacter}.map(String.init)
                    let x = convertStringToCGFloat(coords[0]) * scale + xSpace
                    let y = convertStringToCGFloat(coords[1]) * scale + ySpace
                    let newPoint = details[String(detailTag)]?.createPoint(CGPoint(x: x, y: y), imageName: cornerString, index: pointIndex)
                    newPoint?.layer.zPosition = -1
                    pointIndex = pointIndex + 1
                    view.addSubview(newPoint!)
                }
                let drawEllipse: Bool = (detail.attributes[xmlConstraintKey] == constraintEllipse) ? true : false
                buildShape(false, color: blueColor, tag: detailTag, points: details[String(detailTag)]!.points, parentView: view, ellipse: drawEllipse)
                paths[detailTag] = details[String(detailTag)]!.bezierPath()
            }
        }
        
        showDetails = (xml[xmlXiaKey][xmlDetailsKey].attributes[xmlShowKey] == trueString) ? true : false
        for subview in view.subviews {
            if subview.tag > 199 {
                subview.isHidden = !showDetails
            }
        }
    }
    
    @objc func rotated() {
        loadDetails(xml)
        landscape = (UIDevice.current.orientation.isLandscape) ? true : false
    }
}
