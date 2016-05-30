//
//  xiaDetails.swift
//  xia4ipad
//
//  Created by Guillaume on 06/11/2015.
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

class xiaDetail: NSObject {

    var points = [UIImageView]()
    var tag: Int = 0
    var scale: CGFloat = 1.0
    var constraint: String = ""
    var locked: Bool = false
    
    init(tag: Int, scale: CGFloat){
        self.tag = tag
        self.points = []
        self.scale = scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bezierFrame(scale:CGFloat = 1.0) -> CGRect {
        var xMin: CGFloat = UIScreen.mainScreen().bounds.width
        var xMax: CGFloat = 0
        var yMin: CGFloat = UIScreen.mainScreen().bounds.height
        var yMax: CGFloat = 0
        // Get dimensions of the shape
        for point in points {
            let xPoint = point.center.x
            let yPoint = point.center.y
            if ( xPoint < xMin ) {
                xMin = xPoint
            }
            if ( yPoint < yMin ) {
                yMin = yPoint
            }
            if ( xPoint > xMax ) {
                xMax = xPoint
            }
            if ( yPoint > yMax ) {
                yMax = yPoint
            }
        }
        return CGRect(x: xMin * scale, y: yMin * scale, width: (xMax - xMin) * scale, height: (yMax - yMin) * scale)
    }
    
    func bezierPath(scale:CGFloat = 1.0) -> UIBezierPath {
        var path = UIBezierPath()
        if constraint == constraintEllipse {
            path = UIBezierPath(ovalInRect: self.bezierFrame())
        }
        else {
            for point in points {
                if (point == points.first) {
                    path.moveToPoint(CGPointMake(point.center.x * scale, point.center.y * scale))
                }
                else {
                    path.addLineToPoint(CGPointMake(point.center.x * scale, point.center.y * scale))
                }
            }
            path.closePath()
        }
        return path
    }
    
    func createPath() -> String {
        if (points.count < 2) {
            return "0;0"
        }
        else {
            
            var path: String = ""
            for point in points {
                let x = point.center.x / scale
                let y = point.center.y / scale
                path += "\(x);\(y) "
            }
            path = path.substringWithRange(path.startIndex.advancedBy(0)..<path.endIndex.advancedBy(-1))
            
            return path // return X1.xxx;Y1.yyy X2.xxx;Y2.yyy X3.xxx;Y3.yyy ...
        }
    }
    
    func createPoint(location: CGPoint, imageName: String) -> UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.center = location
        imageView.tag = tag
        points.append(imageView)
        
        return imageView
        // remember to add this point to the view afte calling this method :
        // view.addSubview(newPoint)
    }
    
    func makeVirtPoints() -> [Int: UIImageView] {
        let nbPoints = points.count
        var virtPoints = [Int: UIImageView]()
        
        for i in 0...nbPoints-1 {
            let j = (i+1)%nbPoints
            let point1 = CGPointMake(points[i].center.x, points[i].center.y)
            let point2 = CGPointMake(points[j].center.x, points[j].center.y)
            // Get distance between point1 & point2
            let x = point1.x - point2.x
            let y = point1.y - point2.y
            let dist = sqrt(x * x + y * y)
            if dist > 50 {
                // We can show a virt point
                let newPoint = CGPointMake((point1.x+point2.x)/2, (point1.y+point2.y)/2)
                let image = UIImage(named: "corner")
                let imageView = UIImageView(image: image!)
                imageView.alpha = 0.2
                imageView.tag = tag+100
                imageView.center = newPoint
                virtPoints[i] = imageView
            }
        }
        
        return virtPoints
    }
}