//
//  ViewDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 17/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewDetail: UIViewController {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var detail: xiaDetail!
    var path: UIBezierPath!
    var bkgdImage: UIImageView!
    var zoomDisable: Bool = true
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var popup: UIView!
    @IBOutlet var imgArea: UIView!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var detailSubTitle: UILabel!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var btnZoom: UIButton!
    
    @IBAction func btnZoomAction(sender: AnyObject) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        let imgThumb: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bkgdImage.frame.width, height: bkgdImage.frame.height))
        imgThumb.contentMode = UIViewContentMode.ScaleAspectFit
        imgThumb.image = bkgdImage.image
        
        // Cropping image
        let myMask = CAShapeLayer()
        myMask.path = path.CGPath
        imgThumb.layer.mask = myMask
        self.imgArea.addSubview(imgThumb)
        imgThumb.hidden = true
        
        // Scaling cropped image to fit in the 200 x 200 square
        let pathFrameCorners = detail.bezierFrame()
        let detailScaleX = (imgArea.frame.width - 10) / pathFrameCorners.width
        let detailScaleY = (imgArea.frame.height - 10) / pathFrameCorners.height
        let detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        imgThumb.transform = CGAffineTransformScale(imgThumb.transform, detailScale, detailScale)
        
        // Centering the cropped image in imgArea
        let pathCenter = CGPointMake(pathFrameCorners.midX * detailScale, pathFrameCorners.midY * detailScale)
        let newCenter = CGPointMake(imgThumb.center.x * detailScale - pathCenter.x + imgArea.center.x, imgThumb.center.y * detailScale - pathCenter.y + imgArea.center.y)
        imgThumb.center = newCenter
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 900))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            imgThumb.hidden = false
        }
        
        // Show text
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                detailTitle.text = d.attributes["title"]
                detailTitle.sizeToFit()
                detailTitle.numberOfLines = 0
                detailSubTitle.text = "Sub Title..."
                txtDesc.text = d.value
                zoomDisable = (d.attributes["zoom"] == "true") ? false : true
                btnZoom.hidden = zoomDisable
                btnZoom.enabled = !zoomDisable
                btnZoom.layer.zPosition = 3
            }
        }
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
}
