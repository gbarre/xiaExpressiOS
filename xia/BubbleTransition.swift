//
//  BubbleTransition.swift
//  BubbleTransition
//
//  Created by Andrea Mazzini on 04/04/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import Foundation
import UIKit

/**
 A custom modal transition that presents and dismiss a controller with an expanding bubble effect.

 - Prepare the transition:
 ```swift
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     let controller = segue.destinationViewController
     controller.transitioningDelegate = self
     controller.modalPresentationStyle = .Custom
 }
 ```
 - Implement UIViewControllerTransitioningDelegate:
 ```swift
 func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
     transition.transitionMode = .Present
     transition.startingPoint = someButton.center
     transition.bubbleColor = someButton.backgroundColor!
     return transition
 }

 func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
     transition.transitionMode = .Dismiss
     transition.startingPoint = someButton.center
     transition.bubbleColor = someButton.backgroundColor!
     return transition
 }
 ```
 */
public class BubbleTransition: NSObject {
    
    /**
    The point that originates the bubble. The bubble starts from this point
    and shrinks to it on dismiss
    */
    public var startingPoint = CGPoint.zero {
        didSet {
            bubble.center = startingPoint
        }
    }
    
    /**
    The transition duration. The same value is used in both the Present or Dismiss actions
    Defaults to `1.0`
    */
    public var duration = 1.0
    
    /**
    The transition direction. Possible values `.Present`, `.Dismiss` or `.Pop`
     Defaults to `.Present`
    */
    public var transitionMode: BubbleTransitionMode = .present
    
    /**
    The color of the bubble. Make sure that it matches the destination controller's background color.
    */
    public var bubbleColor: UIColor = .white()
    
    private var bubble = UIView()

    /**
    The possible directions of the transition.
     
     - Present: For presenting a new modal controller
     - Dismiss: For dismissing the current controller
     - Pop: For a pop animation in a navigation controller
    */
    @objc public enum BubbleTransitionMode: Int {
        case present, dismiss, pop
    }
    
    // Modifs GB
    public var detailFrame: CGRect!
    public var path: UIBezierPath!
    public var bkgdImage: UIImageView!
    public var noDetailStatus: Bool = false
    var theDetail: xiaDetail!
    
    private var detail = UIImageView()
    
}

extension BubbleTransition: UIViewControllerAnimatedTransitioning {

    // MARK: - UIViewControllerAnimatedTransitioning

    /**
    Required by UIViewControllerAnimatedTransitioning
    */
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    /**
     Required by UIViewControllerAnimatedTransitioning
     */
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        if transitionMode == .present {
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextToViewKey)!
            let originalCenter = presentedControllerView.center
            let originalSize = presentedControllerView.frame.size

            bubble = UIView()
            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint
            bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            bubble.backgroundColor = bubbleColor
            containerView.addSubview(bubble)
            

            presentedControllerView.center = CGPoint(x: 0, y: UIScreen.main().bounds.height)
            presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            presentedControllerView.alpha = 0
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: duration, animations: {
                self.bubble.transform = CGAffineTransform.identity
                presentedControllerView.transform = CGAffineTransform.identity
                presentedControllerView.alpha = 1
                presentedControllerView.center = originalCenter
                self.detail = self.showImage(transitionContext, fullImage: self.bkgdImage, myDetail: self.theDetail, noDetail: self.noDetailStatus)
                }) { (_) in
                    transitionContext.completeTransition(true)
            }
            UIView.animate(withDuration: 1 * duration, delay: duration/5, options: .showHideTransitionViews, animations: { () -> Void in
                self.bubble.alpha = 0
                }, completion: nil)
            UIView.animate(withDuration: duration, delay: duration, options: .showHideTransitionViews, animations: { () -> Void in
                self.detail.alpha = 0
                }, completion: nil)
            
        } else {
            let key = (transitionMode == .pop) ? UITransitionContextToViewKey : UITransitionContextFromViewKey
            let returningControllerView = transitionContext.view(forKey: key)!
            let originalCenter = returningControllerView.center
            let originalSize = returningControllerView.frame.size
            
            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint
            
            UIView.animate(withDuration: duration, animations: {
                self.bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                returningControllerView.center = self.startingPoint
                returningControllerView.alpha = 0
                
                if self.transitionMode == .pop {
                    containerView.insertSubview(returningControllerView, belowSubview: returningControllerView)
                    containerView.insertSubview(self.bubble, belowSubview: returningControllerView)
                }
                }) { (_) in
                    returningControllerView.removeFromSuperview()
                    self.bubble.removeFromSuperview()
                    transitionContext.completeTransition(true)
            }
        }
    }
    
    public func showImage(transitionContext: UIViewControllerContextTransitioning, fullImage: UIImageView, myDetail: NSObject, noDetail: Bool = false) -> UIImageView {
        var path: UIBezierPath!
        if !noDetail {
            path = (myDetail as! xiaDetail).bezierPath()
        }
        let pathFrameCorners = (!noDetail) ? (myDetail as! xiaDetail).bezierFrame() : UIScreen.main().bounds
        let imgThumb: UIImageView = UIImageView(frame: fullImage.frame)
        imgThumb.contentMode = UIViewContentMode.scaleAspectFit
        imgThumb.image = fullImage.image
        
        let containerView = transitionContext.containerView()
        
        // Cropping image
        if !noDetail {
            let myMask = CAShapeLayer()
            myMask.path = path.cgPath
            imgThumb.layer.mask = myMask
        }
        containerView.addSubview(imgThumb)
        
        // Scaling cropped image to fit in the 200 x 200 square
        let detailScaleX = 190 / pathFrameCorners.width
        let detailScaleY = 190 / pathFrameCorners.height
        let detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        imgThumb.transform = imgThumb.transform.scaleBy(x: detailScale, y: detailScale)
        
        let centerTarget = getCenter()
        let pathCenter = CGPoint(x: pathFrameCorners.midX * detailScale, y: pathFrameCorners.midY * detailScale)
        let newCenter = CGPoint(x: imgThumb.center.x * detailScale - pathCenter.x + centerTarget.x, y: imgThumb.center.y * detailScale - pathCenter.y + centerTarget.y)
        imgThumb.center = newCenter
        
        return imgThumb
    }
    
}

private extension BubbleTransition {
    private func frameForBubble(originalCenter: CGPoint, size originalSize: CGSize, start: CGPoint) -> CGRect {
        let lengthX = fmax(start.x, originalSize.width - start.x);
        let lengthY = fmax(start.y, originalSize.height - start.y)
        let offset = sqrt(lengthX * lengthX + lengthY * lengthY) * 2;
        let size = CGSize(width: offset, height: offset)

        return CGRect(origin: CGPoint.zero, size: size)
    }
}
