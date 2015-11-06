//
//  ShapeView.swift
//  IOS9DrawShapesTutorial
//
//  Created by Guillaume on 14/10/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    var currentShapeType: Int = 0
    var arrayPoints = [AnyObject]()
    var origin: CGPoint = CGPointMake(0, 0)
    var color: UIColor = UIColor.blackColor()
    
    init(frame: CGRect, shape: Int, points: Array<AnyObject>, color: UIColor) {
        super.init(frame: frame)
        self.currentShapeType = shape
        self.arrayPoints = points
        self.origin = frame.origin
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        switch currentShapeType {
        case 0: drawLines()
        case 1: drawPolygon()
        case 2: drawRectangle()
        case 3: drawCircle()
        default: print("default")
        }
    }
    
    func drawLines() {
        let ctx = UIGraphicsGetCurrentContext()
        
        var beginPoint = arrayPoints[0].center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, beginPoint.x, beginPoint.y)
        for var i=1; i < nbPoints; i++ {
            var point = arrayPoints[i].center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            CGContextAddLineToPoint(ctx, point.x, point.y)
        }
        CGContextSetLineDash(ctx, 0, [5], 1)
//        CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 0.8)
        let alphaColor = CGColorCreateCopyWithAlpha(color.CGColor, 0.8)
        CGContextSetStrokeColorWithColor(ctx, alphaColor)
        CGContextSetLineWidth(ctx, 2.5)
        
        CGContextClosePath(ctx)
        CGContextStrokePath(ctx)
    }
    
    func drawPolygon() {
        let ctx = UIGraphicsGetCurrentContext()
        
        var beginPoint = arrayPoints[0].center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, beginPoint.x, beginPoint.y)
        for var i=1; i < nbPoints; i++ {
            var point = arrayPoints[i].center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            CGContextAddLineToPoint(ctx, point.x, point.y)
        }
        CGContextSetLineWidth(ctx, 2)
        
        //let semiRed = CGColorCreateCopyWithAlpha(UIColor.redColor().CGColor, 0.5)
        let semiRed = CGColorCreateCopyWithAlpha(color.CGColor, 0.5)
        
        CGContextSetFillColorWithColor(ctx, semiRed)
        CGContextFillPath(ctx)
        //CGContextStrokePath(ctx)
    }
    
    func drawRectangle() {
        let center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
        let rectangleWidth:CGFloat = 100.0
        let rectangleHeight:CGFloat = 100.0
        let ctx = UIGraphicsGetCurrentContext()
        
        //4
        CGContextAddRect(ctx, CGRectMake(center.x - (0.5 * rectangleWidth), center.y - (0.5 * rectangleHeight), rectangleWidth, rectangleHeight))
        CGContextSetLineWidth(ctx, 10)
        CGContextSetStrokeColorWithColor(ctx, UIColor.grayColor().CGColor)
        CGContextStrokePath(ctx)
        
        //5
        CGContextSetFillColorWithColor(ctx, UIColor.greenColor().CGColor)
        CGContextAddRect(ctx, CGRectMake(center.x - (0.5 * rectangleWidth), center.y - (0.5 * rectangleHeight), rectangleWidth, rectangleHeight))
        
        CGContextFillPath(ctx)
    }
    
    func drawCircle() {
        let center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(ctx)
        
        //6
        CGContextSetLineWidth(ctx, 1)
        
        let x:CGFloat = center.x
        let y:CGFloat = center.y
        let radius: CGFloat = 9.0
        let endAngle: CGFloat = CGFloat(2 * M_PI)
        
        CGContextAddArc(ctx, x, y, radius, 0, endAngle, 0)

        CGContextSetFillColorWithColor(ctx, UIColor.blueColor().CGColor)
        
        CGContextStrokePath(ctx)
    }
    
}
