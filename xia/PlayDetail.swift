//
//  PlayDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 17/01/2016.
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

class PlayDetail: UIViewController, UIViewControllerTransitioningDelegate, UIWebViewDelegate {
        
    var tag: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var detail: xiaDetail!
    var path: UIBezierPath!
    var bkgdImage: UIImageView!
    var zoomDisable: Bool = true
    var showZoom: Bool = false
    var landscape: Bool = true
    
    let transition = BubbleTransition()
    
    let screenWidth = UIScreen.main().bounds.width
    let screenHeight = UIScreen.main().bounds.height
    var currentScale: CGFloat = 1.0
    var currentCenter: CGPoint!
    var zoomScale: CGFloat = 1.0
    let transitionDuration: TimeInterval = 0.5
    
    let converter: TextConverter = TextConverter(videoWidth: 480, videoHeight: 270)
    
    @IBAction func close(_ sender: AnyObject) {
        if !showZoom {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBOutlet var popup: UIView!
    @IBOutlet var imgArea: UIView!
    @IBOutlet var imgThumb: UIImageView!
    @IBOutlet var titleArea: UIView!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var descView: UIWebView!
    @IBOutlet var bkgdzoom: UIImageView!
    
    @IBAction func btnZoomAction(_ sender: AnyObject) {
        if !zoomDisable && !showZoom {
            showDetail(imgThumb)
        }
    }
    
    @IBAction func closeZoom(_ sender: AnyObject) {
        if showZoom {
            // Show / hide elements
            self.imgArea.isHidden = false
            self.imgArea.alpha = 0
            descView.isUserInteractionEnabled = true
            UIView.animate(withDuration: transitionDuration) { () -> Void in
                self.imgThumb.transform = self.imgThumb.transform.scaleBy(x: self.currentScale / self.zoomScale, y: self.currentScale / self.zoomScale)
                self.imgThumb.center = self.currentCenter
                self.bkgdzoom.alpha = 0
            }
            UIView.animate(withDuration: 2 * transitionDuration) { () -> Void in
                self.imgArea.alpha = 1
                self.titleArea.alpha = 1
            }
            showZoom = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background must be larger the popup
        bkgdzoom.transform = bkgdzoom.transform.scaleBy(x: 3, y: 3)
        
        imgThumb = UIImageView(frame: CGRect(x: 0, y: 0, width: bkgdImage.frame.width, height: bkgdImage.frame.height))
        imgThumb.contentMode = UIViewContentMode.scaleAspectFit
        imgThumb.image = bkgdImage.image
        
        // Cropping image
        let myMask = CAShapeLayer()
        if tag != 0 {
            myMask.path = path.cgPath
            imgThumb.layer.mask = myMask
        }
        self.view.addSubview(imgThumb)
        imgThumb.isHidden = true
        
        // Scaling cropped image to fit in the 200 x 200 square
        let pathFrameCorners = (tag != 0) ? detail.bezierFrame() : UIScreen.main().bounds
        let detailScaleX = 190 / pathFrameCorners.width
        let detailScaleY = 190 / pathFrameCorners.height
        let detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        currentScale = detailScale

        imgThumb.transform = imgThumb.transform.scaleBy(x: detailScale, y: detailScale)
        
        // Centering the cropped image in imgArea
        let pathCenter = CGPoint(x: pathFrameCorners.midX * detailScale, y: pathFrameCorners.midY * detailScale)
        let newCenter = CGPoint(x: imgThumb.center.x * detailScale - pathCenter.x + 100, y: imgThumb.center.y * detailScale - pathCenter.y + 100)
        imgThumb.center = newCenter
        
        // Show text
        var htmlString: String = ""
        if tag != 0 {
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
                for d in detail {
                    detailTitle.text = d.attributes["title"]
                    detailTitle.sizeToFit()
                    detailTitle.numberOfLines = 0
                    htmlString = (d.value != nil) ? d.value! : ""
                    zoomDisable = (d.attributes["zoom"] == "true") ? false : true
                }
            }
        }
        else {
            detailTitle.text = (xml["xia"]["image"].attributes["title"] != nil) ? xml["xia"]["image"].attributes["title"] : ""
            detailTitle.sizeToFit()
            detailTitle.numberOfLines = 0
            htmlString = (xml["xia"]["image"].attributes["description"] != nil) ? xml["xia"]["image"].attributes["description"]! : ""
            zoomDisable = false
        }
        
        // Build the webView
        if !landscape {
            converter.videoWidth = 360
            converter.videoHeight = 210
        }
        htmlString = converter._text2html(htmlString)
        
        descView.loadHTMLString(htmlString, baseURL: nil)
        descView.allowsInlineMediaPlayback = true
        descView.delegate = self
        
        // wait 0.5s before showing image (bubbletransition effect)
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC * 500)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.after(when: delayTime){
            self.imgThumb.isHidden = false
        }
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func showDetail(_ detailImg: UIImageView) {
        // Show / hide elements
        self.bkgdzoom.isHidden = false
        self.bkgdzoom.alpha = 0
        descView.isUserInteractionEnabled = false
        showZoom = true
        
        currentCenter = detailImg.center
        
        // Scale the detail
        let detailScaleX = (screenWidth - 10) / detail.bezierFrame().width
        let detailScaleY = (screenHeight - 50) / detail.bezierFrame().height
        let detailScale = min(detailScaleX, detailScaleY, 3) // 3 is maximum zoom
        zoomScale = detailScale
        
        UIView.animate(withDuration: transitionDuration) { () -> Void in
            self.bkgdzoom.alpha = 1
            self.titleArea.alpha = 0
            self.imgArea.alpha = 0
            detailImg.transform = detailImg.transform.scaleBy(x: detailScale / self.currentScale, y: detailScale / self.currentScale)
        }
        
        // Center the detail
        let distanceX = screenWidth/2 - detail.bezierFrame().midX
        let distanceY = screenHeight/2 - detail.bezierFrame().midY
        
        let xCoord = screenWidth/2 + distanceX * detailScale - getCenter().x + 100
        let yCoord = screenHeight/2 + distanceY * detailScale - getCenter().y + 100
        
        let newCenter = CGPoint(x: xCoord, y: yCoord)
        
        UIView.animate(withDuration: transitionDuration) { () -> Void in
            detailImg.center = newCenter
        }
        
        UIView.animate(withDuration: transitionDuration / 10) { () -> Void in
            self.imgArea.alpha = 0
        }
        
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC * 500)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.after(when: delayTime){
            self.imgArea.isHidden = true
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            if #available(iOS 10.0, *) {
                UIApplication.shared().open(request.url!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared().openURL(request.url!)
            }
            return false
        }
        return true
    }
    
}
