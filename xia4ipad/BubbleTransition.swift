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
    public var startingPoint = CGPointZero {
        didSet {
            bubble.center = startingPoint
        }
    }
    
    /**
    The transition duration. The same value is used in both the Present or Dismiss actions
    Defaults to `0.5`
    */
    public var duration = 1.0
    
    /**
    The transition direction. Possible values `.Present`, `.Dismiss` or `.Pop`
     Defaults to `.Present`
    */
    public var transitionMode: BubbleTransitionMode = .Present
    
    /**
    The color of the bubble. Make sure that it matches the destination controller's background color.
    */
    public var bubbleColor: UIColor = .whiteColor()
    
    private var bubble = UIView()

    /**
    The possible directions of the transition.
     
     - Present: For presenting a new modal controller
     - Dismiss: For dismissing the current controller
     - Pop: For a pop animation in a navigation controller
    */
    @objc public enum BubbleTransitionMode: Int {
        case Present, Dismiss, Pop
    }
    
    // Modifs GB
    public var detailFrame: CGRect!
    public var path: UIBezierPath!
    public var bkgdImage: UIImageView!
    public var zoom = false
    
    private var detail = UIImageView()
    
}

extension BubbleTransition: UIViewControllerAnimatedTransitioning {

    // MARK: - UIViewControllerAnimatedTransitioning

    /**
    Required by UIViewControllerAnimatedTransitioning
    */
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }

    /**
     Required by UIViewControllerAnimatedTransitioning
     */
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else {
            return
        }

        if transitionMode == .Present {
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let originalCenter = presentedControllerView.center
            let originalSize = presentedControllerView.frame.size

            bubble = UIView()
            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint
            bubble.transform = CGAffineTransformMakeScale(0.001, 0.001)
            bubble.backgroundColor = bubbleColor
            containerView.addSubview(bubble)
            

            presentedControllerView.center = startingPoint
            presentedControllerView.transform = CGAffineTransformMakeScale(0.001, 0.001)
            presentedControllerView.alpha = 0
            containerView.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(duration, animations: {
                self.bubble.transform = CGAffineTransformIdentity
                presentedControllerView.transform = CGAffineTransformIdentity
                presentedControllerView.alpha = 1
                presentedControllerView.center = originalCenter
                self.detail = self.showImage(transitionContext, fullImage: self.bkgdImage, path: self.path, pathFrameCorners: self.detailFrame, zoom: self.zoom)
                }) { (_) in
                    transitionContext.completeTransition(true)
            }
            UIView.animateWithDuration(0.5, delay: duration, options: .ShowHideTransitionViews, animations: { () -> Void in
                //self.bubble.transform = CGAffineTransformMakeScale(0.001, 0.001)
                self.bubble.alpha = 0
                }, completion: nil)
            UIView.animateWithDuration(0, delay: duration + 0.2, options: .ShowHideTransitionViews, animations: { () -> Void in
                if !self.zoom {
                    self.detail.alpha = 0
                }
                }, completion: nil)
        } else {
            let key = (transitionMode == .Pop) ? UITransitionContextToViewKey : UITransitionContextFromViewKey
            let returningControllerView = transitionContext.viewForKey(key)!
            let originalCenter = returningControllerView.center
            let originalSize = returningControllerView.frame.size

            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint

            UIView.animateWithDuration(duration, animations: {
                self.bubble.transform = CGAffineTransformMakeScale(0.001, 0.001)
                returningControllerView.transform = CGAffineTransformMakeScale(0.001, 0.001)
                returningControllerView.center = self.startingPoint
                returningControllerView.alpha = 0
                if self.zoom {
                    self.detail.center = getCenter()
                    self.detail.transform = CGAffineTransformMakeScale(0.001, 0.001)
                }

                if self.transitionMode == .Pop {
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
    
    public func showImage(transitionContext: UIViewControllerContextTransitioning, fullImage: UIImageView, path: UIBezierPath, pathFrameCorners: CGRect, zoom: Bool) -> UIImageView {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let imgThumb: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: fullImage.frame.width, height: fullImage.frame.height))
        imgThumb.contentMode = UIViewContentMode.ScaleAspectFit
        imgThumb.image = fullImage.image
        
        guard let containerView = transitionContext.containerView() else {
            return imgThumb
        }
        
        // Cropping image
        let myMask = CAShapeLayer()
        myMask.path = path.CGPath
        imgThumb.layer.mask = myMask
        containerView.addSubview(imgThumb)
        
        var detailScale: CGFloat = 1.0
        if zoom {
            let detailScaleX = (screenWidth - 10) / pathFrameCorners.width
            let detailScaleY = (screenHeight - 50) / pathFrameCorners.height
            detailScale = min(detailScaleX, detailScaleY, 3) // 3 is maximum zoom
        }
        else { // Scaling cropped image to fit in the 200 x 200 square
            let detailScaleX = 190 / pathFrameCorners.width
            let detailScaleY = 190 / pathFrameCorners.height
            detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        }
        imgThumb.transform = CGAffineTransformScale(imgThumb.transform, detailScale, detailScale)
        
        var newCenter = CGPointMake(0, 0)
        if zoom {
            let distanceX = screenWidth/2 - pathFrameCorners.midX
            let distanceY = screenHeight/2 - pathFrameCorners.midY
            
            newCenter = CGPointMake(imgThumb.center.x + distanceX * detailScale, imgThumb.center.y + distanceY * detailScale)
        }
        else {
            let centerTarget = getCenter()
            let pathCenter = CGPointMake(pathFrameCorners.midX * detailScale, pathFrameCorners.midY * detailScale)
            newCenter = CGPointMake(imgThumb.center.x * detailScale - pathCenter.x + centerTarget.x, imgThumb.center.y * detailScale - pathCenter.y + centerTarget.y)
        }
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

        return CGRect(origin: CGPointZero, size: size)
    }
}
