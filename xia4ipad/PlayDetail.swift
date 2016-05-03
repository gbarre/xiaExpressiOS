//
//  PlayDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 17/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class PlayDetail: UIViewController, UIViewControllerTransitioningDelegate {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var detail: xiaDetail!
    var path: UIBezierPath!
    var bkgdImage: UIImageView!
    var zoomDisable: Bool = true
    var showZoom: Bool = false
    
    let transition = BubbleTransition()
    
    //var imgThumb: UIImageView!
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var currentScale: CGFloat = 1.0
    var currentCenter: CGPoint!
    var zoomScale: CGFloat = 1.0
    let transitionDuration: NSTimeInterval = 0.5
    
    @IBAction func close(sender: AnyObject) {
        if !showZoom {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet var popup: UIView!
    @IBOutlet var imgArea: UIView!
    @IBOutlet var imgThumb: UIImageView!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var bkgdzoom: UIImageView!
    
    @IBAction func btnZoomAction(sender: AnyObject) {
        if !zoomDisable && !showZoom {
            showDetail(imgThumb)
        }
    }
    
    @IBAction func closeZoom(sender: AnyObject) {
        if showZoom {
            // Show / hide elements
            self.imgArea.hidden = false
            self.imgArea.alpha = 0
            UIView.animateWithDuration(transitionDuration) { () -> Void in
                self.imgThumb.transform = CGAffineTransformScale(self.imgThumb.transform, self.currentScale / self.zoomScale, self.currentScale / self.zoomScale)
                self.imgThumb.center = self.currentCenter
                self.bkgdzoom.alpha = 0
            }
            UIView.animateWithDuration(2 * transitionDuration) { () -> Void in
                self.imgArea.alpha = 1
            }
            showZoom = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background must be larger the popup
        bkgdzoom.transform = CGAffineTransformScale(bkgdzoom.transform, 3, 3)
        
        imgThumb = UIImageView(frame: CGRect(x: 0, y: 0, width: bkgdImage.frame.width, height: bkgdImage.frame.height))
        imgThumb.contentMode = UIViewContentMode.ScaleAspectFit
        imgThumb.image = bkgdImage.image
        
        // Cropping image
        let myMask = CAShapeLayer()
        if tag != 0 {
            myMask.path = path.CGPath
            imgThumb.layer.mask = myMask
        }
        self.view.addSubview(imgThumb)
        imgThumb.hidden = true
        
        // Scaling cropped image to fit in the 200 x 200 square
        let pathFrameCorners = (tag != 0) ? detail.bezierFrame() : UIScreen.mainScreen().bounds
        let detailScaleX = (imgArea.frame.width - 10) / pathFrameCorners.width
        let detailScaleY = (imgArea.frame.height - 10) / pathFrameCorners.height
        let detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        currentScale = detailScale
        imgThumb.transform = CGAffineTransformScale(imgThumb.transform, detailScale, detailScale)
        
        // Centering the cropped image in imgArea
        let pathCenter = CGPointMake(pathFrameCorners.midX * detailScale, pathFrameCorners.midY * detailScale)
        let newCenter = CGPointMake(imgThumb.center.x * detailScale - pathCenter.x + imgArea.center.x, imgThumb.center.y * detailScale - pathCenter.y + imgArea.center.y)
        imgThumb.center = newCenter
        
        // Show text
        if tag != 0 {
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
                for d in detail {
                    detailTitle.text = d.attributes["title"]
                    detailTitle.sizeToFit()
                    detailTitle.numberOfLines = 0
                    txtDesc.text = d.value
                    zoomDisable = (d.attributes["zoom"] == "true") ? false : true
                }
            }
        }
        else {
            detailTitle.text = (xml["xia"]["image"].attributes["title"] != nil) ? xml["xia"]["image"].attributes["title"] : ""
            detailTitle.sizeToFit()
            detailTitle.numberOfLines = 0
            txtDesc.text =  (xml["xia"]["image"].attributes["description"] != nil) ? xml["xia"]["image"].attributes["description"] : ""
            zoomDisable = false
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 500))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.imgThumb.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        txtDesc.setContentOffset(CGPointMake(0, -txtDesc.contentInset.top), animated: false)
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func showDetail(detailImg: UIImageView) {
        // Show / hide elements
        self.bkgdzoom.hidden = false
        self.bkgdzoom.alpha = 0
        txtDesc.selectable = false
        showZoom = true
        
        currentCenter = detailImg.center
        
        // Scale the detail
        let detailScaleX = (screenWidth - 10) / detail.bezierFrame().width
        let detailScaleY = (screenHeight - 50) / detail.bezierFrame().height
        let detailScale = min(detailScaleX, detailScaleY, 3) // 3 is maximum zoom
        zoomScale = detailScale
        
        UIView.animateWithDuration(transitionDuration) { () -> Void in
            self.bkgdzoom.alpha = 1
            self.imgArea.alpha = 0
            detailImg.transform = CGAffineTransformScale(detailImg.transform, detailScale / self.currentScale, detailScale / self.currentScale)
        }
        
        // Center the detail
        let distanceX = screenWidth/2 - detail.bezierFrame().midX
        let distanceY = screenHeight/2 - detail.bezierFrame().midY
        
        let newCenter = CGPointMake(screenWidth/2 + distanceX * detailScale - getCenter().x + 100, screenHeight/2 + distanceY * detailScale - getCenter().y + 100)
        
        UIView.animateWithDuration(transitionDuration) { () -> Void in
            detailImg.center = newCenter
        }
        
        UIView.animateWithDuration(transitionDuration / 10) { () -> Void in
            self.imgArea.alpha = 0
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 500))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.imgArea.hidden = true
        }
    }
    
}
