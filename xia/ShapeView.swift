//
//  ShapeView.swift
//  IOS9DrawShapesTutorial
//
//  Created by Guillaume on 14/10/2015.
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

class ShapeView: UIView {
    
    var currentShapeType: Int = 0
    var arrayPoints = [Int: UIImageView]()
    var origin: CGPoint = CGPoint(x: 0, y: 0)
    var color: UIColor = UIColor.blackColor()
    
    init(frame: CGRect, shape: Int, points: [Int: UIImageView], color: UIColor) {
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
        case 2: drawEllipse()
        case 3: drawEllipseFilled()
        case 4: drawCircle()
        default: dbg.pt("default")
        }
    }
    
    func drawLines() {
        let ctx = UIGraphicsGetCurrentContext()
        
        var beginPoint = arrayPoints[0]!.center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, beginPoint.x, beginPoint.y)
        for i in 1 ..< nbPoints {
            var point = arrayPoints[i]!.center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            CGContextAddLineToPoint(ctx, point.x, point.y)
        }
        CGContextSetLineDash(ctx, 0, [5], 1)
        let alphaColor = CGColorCreateCopyWithAlpha(color.CGColor, 0.8)
        CGContextSetStrokeColorWithColor(ctx, alphaColor)
        CGContextSetLineWidth(ctx, 2.5)
        
        CGContextClosePath(ctx)
        CGContextStrokePath(ctx)
    }
    
    func drawPolygon() {
        let ctx = UIGraphicsGetCurrentContext()
        
        var beginPoint = arrayPoints[0]!.center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, beginPoint.x, beginPoint.y)
        for i in 1 ..< nbPoints {
            var point = arrayPoints[i]!.center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            CGContextAddLineToPoint(ctx, point.x, point.y)
        }
        CGContextSetLineWidth(ctx, 2)
        
        let semiRed = CGColorCreateCopyWithAlpha(color.CGColor, 0.5)
        CGContextSetFillColorWithColor(ctx, semiRed)
        CGContextFillPath(ctx)
    }
    
    func drawEllipse() {
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetLineDash(ctx, 0, [5], 1)
        let alphaColor = CGColorCreateCopyWithAlpha(color.CGColor, 0.8)
        CGContextSetStrokeColorWithColor(ctx, alphaColor)
        CGContextSetLineWidth(ctx, 2.5)
        
        let size = CGSize(width: arrayPoints[1]!.center.x - arrayPoints[3]!.center.x, height: arrayPoints[2]!.center.y - arrayPoints[0]!.center.y)
        
        let rectangle = CGRectMake(5, 5, abs(size.width), abs(size.height))
        CGContextAddEllipseInRect(ctx, rectangle)
        CGContextStrokePath(ctx)
    }
    
    func drawEllipseFilled() {
        let size = CGSize(width: arrayPoints[1]!.center.x - arrayPoints[3]!.center.x, height: arrayPoints[2]!.center.y - arrayPoints[0]!.center.y)
        
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(5, 5, abs(size.width), abs(size.height)))
        color.colorWithAlphaComponent(0.5).setFill()
        ovalPath.fill()
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
