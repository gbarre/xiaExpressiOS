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
    var color: UIColor = UIColor.black
    
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
    
    override func draw(_ rect: CGRect) {
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
        let ctx = UIGraphicsGetCurrentContext()!
        
        var beginPoint = arrayPoints[0]!.center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: beginPoint.x, y: beginPoint.y))
        for i in 1 ..< nbPoints {
            var point = arrayPoints[i]!.center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            ctx.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        ctx.setLineDash(phase: 0, lengths: [5])
        let alphaColor = color.cgColor.copy(alpha: 0.8)
        ctx.setStrokeColor(alphaColor!)
        ctx.setLineWidth(2.5)
        
        ctx.closePath()
        ctx.strokePath()
    }
    
    func drawPolygon() {
        let ctx = UIGraphicsGetCurrentContext()!
        
        var beginPoint = arrayPoints[0]!.center
        beginPoint.x = beginPoint.x - origin.x
        beginPoint.y = beginPoint.y - origin.y
        let nbPoints = arrayPoints.count
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: beginPoint.x, y: beginPoint.y))
        for i in 1 ..< nbPoints {
            var point = arrayPoints[i]!.center
            point.x = point.x - origin.x
            point.y = point.y - origin.y
            ctx.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        ctx.setLineWidth(2)
        
        let semiRed = color.cgColor.copy(alpha: 0.5)
        ctx.setFillColor(semiRed!)
        ctx.fillPath()
    }
    
    func drawEllipse() {
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.setLineDash(phase: 0, lengths: [5])
        let alphaColor = color.cgColor.copy(alpha: 0.8)
        ctx.setStrokeColor(alphaColor!)
        ctx.setLineWidth(2.5)
        
        let size = CGSize(width: arrayPoints[1]!.center.x - arrayPoints[3]!.center.x, height: arrayPoints[2]!.center.y - arrayPoints[0]!.center.y)
        
        let rectangle = CGRect(x: 5, y: 5, width: abs(size.width), height: abs(size.height))
        ctx.addEllipse(in: rectangle)
        ctx.strokePath()
    }
    
    func drawEllipseFilled() {
        let size = CGSize(width: arrayPoints[1]!.center.x - arrayPoints[3]!.center.x, height: arrayPoints[2]!.center.y - arrayPoints[0]!.center.y)
        
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 5, y: 5, width: abs(size.width), height: abs(size.height)))
        color.withAlphaComponent(0.5).setFill()
        ovalPath.fill()
    }
    
    func drawCircle() {
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.beginPath()
        
        ctx.setLineWidth(1)
        
        let x:CGFloat = center.x
        let y:CGFloat = center.y
        let radius: CGFloat = 9.0
        let endAngle: CGFloat = 2 * .pi
        
        ctx.addArc(center: CGPoint(x: x, y: y), radius: radius, startAngle: 0, endAngle: endAngle, clockwise: false)
        
        ctx.setFillColor(UIColor.blue.cgColor)
        
        ctx.strokePath()
    }
    
}
